/**
 * Copyright (c) 2010 Henry Tseng (http://www.henrytseng.com)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package halogen.debug.window {
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;

	/**
	 * A client that sends messages to a DebugServer.
	 * 
	 * @author henry
	 * @see halogen.debug.window.DebugServer;
	 */
	public class DebugClient {
		public static const MESSAGE_CHANNEL_PREFIX : String = 'debugclient_message';
		public static const RESPONSE_CHANNEL_PREFIX : String = 'debugclient_response';
		
		/** True to enable debugging */
		public var isDebugging : Boolean;
		
		private var _isInit : Boolean;
		private var _isReady : Boolean;
		private var _subscriptionChannel : LocalConnection;
		private var _messageChannel : LocalConnection;
		private var _responseChannel : LocalConnection;
		private var _responseHandler : Function;
		private var _channelId : String;
		
		/**
		 * Constructor
		 */
		public function DebugClient() {
			isDebugging = false;
			_isInit = false;
			_isReady = false;
		}
		
		/**
		 * Set a _responseHandler to receive responses from a DebugServer
		 */
		public function setResponseHandler($handler:Function):void {
			_responseHandler = $handler;
		}
		
		/**
		 * Initialization
		 */
		public function init():void {
			if(!_isInit) {
				_subscriptionChannel = new LocalConnection();
				_subscriptionChannel.addEventListener(StatusEvent.STATUS, _onSubscribeStatus);
				_isInit = true;
			}
		}
		
		/**
		 * Send a response to a DebugServer
		 */
		public function send(...$params):void {
			if(_isInit) {
				if(!_isReady) {
					_subscribe();
				}
				_messageChannel.send(MESSAGE_CHANNEL_PREFIX+_channelId, 'onSend', _channelId, $params);
			}
		}
		
		/**
		 * Internal method to handle subscription to a DebugServer, also creates a _channelId
		 */
		private function _subscribe():void {
			_channelId = String((new Date()).valueOf());
			_subscriptionChannel.send(DebugServer.SUBSCRIPTION_CHANNEL, 'onSubscribe', _channelId);
			_messageChannel = new LocalConnection();
			_messageChannel.addEventListener(StatusEvent.STATUS, _onMessageStatus);
			_responseChannel = new LocalConnection();
			_responseChannel.client = this;
			try {
				_responseChannel.connect(RESPONSE_CHANNEL_PREFIX+_channelId);
				_isReady = true;
			} catch($err:Error) {
				trace('DebugServer._subscribe() failed to connect.\n' + $err.message);
				_isReady = false;
			}
		}
		
		/**
		 * A handler for status events associated with subscription
		 */
		private function _onSubscribeStatus($e:StatusEvent):void {
			switch($e.level) {
				case 'status':
					if(isDebugging) trace('DebugClient._onSubscribeStatus() Send succeeded.');
					break;
				case 'error':
					if(isDebugging) trace('DebugClient._onSubscribeStatus() Error send failed.');
					break;
			}
		}
		
		/**
		 * A handler for status events associated with messages sending
		 */
		private function _onMessageStatus($e:StatusEvent):void {
			switch($e.level) {
				case 'status':
					if(isDebugging) trace('DebugClient._onMessageStatus() Send succeeded id='+_channelId);
					break;
				case 'error':
					if(isDebugging) trace('DebugClient._onMessageStatus() Error send failed id='+_channelId);
					break;
			}
		}
		
		/**
		 * A handler for DebugServer responses
		 * @param $params, An array of parameters received from DebugServer 
		 */
		public function onResponse(...$params):void {
			if(Boolean(_responseHandler)) {
				_responseHandler.apply(this, $params);
			}
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void {
			_subscriptionChannel.removeEventListener(StatusEvent.STATUS, _onSubscribeStatus);
			_subscriptionChannel = null;
			_messageChannel.removeEventListener(StatusEvent.STATUS, _onMessageStatus);
			_messageChannel=null;
			_responseChannel=null;
			_responseHandler = null;
			_isInit = false;
			_isReady = false;
		}
	}
}
