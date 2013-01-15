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
	 * Aggregates messages from multiple DebugClient objects and calls a handler.  
	 * 
	 * @author henry
	 * @see halogen.debug.window.DebugClient;
	 */
	public class DebugServer {
		public static const SUBSCRIPTION_CHANNEL : String = 'debugsubscribe';
		
		/** True to enable debugging */
		public var isDebugging : Boolean;
		
		private var _subscriptionChannel : LocalConnection;
		private var _messageChannelHash: Object;
		private var _messageChannelList : Vector.<LocalConnection>;
		private var _messageHandler : Function;
		private var _responseChannelHash : Object;
		private var _responseChannelList : Vector.<LocalConnection>;
		private var _channelIdList : Array;
		
		/**
		 * Constructor
		 */
		public function DebugServer() {
			isDebugging = false;
		}
		
		/**
		 * Initialization
		 */
		public function init():Boolean {
			var isConnectionEstablished:Boolean = true;
			_channelIdList = [];
			_messageChannelHash = {};
			_messageChannelList = new Vector.<LocalConnection>();
			_responseChannelHash = {};
			_responseChannelList = new Vector.<LocalConnection>();
			
			_subscriptionChannel = null;
			_subscriptionChannel = new LocalConnection();
			_subscriptionChannel.client = this;
			try {
				_subscriptionChannel.connect(SUBSCRIPTION_CHANNEL);
			} catch($err:Error) {
				isConnectionEstablished = false;
				trace('DebugServer.init() failed to connect.\n' + $err.message);
			}
			
			return isConnectionEstablished;
		}

		/**
		 * Set a _messageHandler to receive messages from a DebugClient
		 */
		public function setMessageHandler($handler:Function):void {
			_messageHandler = $handler;
		}
		
		/**
		 * Send a response to a client
		 */
		public function response($channelId:String, ...$params):void {
			if(hasClient($channelId)) {
				var channel:LocalConnection = _responseChannelHash[$channelId] as LocalConnection;
				if(channel) {
					var responseParams:Array = [DebugClient.RESPONSE_CHANNEL_PREFIX+$channelId, 'onResponse'];
					channel.send.apply(channel, responseParams.concat($params));
				}
			}
		}
		
		public function hasClient($channelId:String):Boolean { return Boolean(_responseChannelHash[$channelId]); }
		
		public function getChannelList():Array {
			 return _channelIdList.slice(0);
		}

		/**
		 * 
		 */
		public function onSubscribe($channelId:String):void {
			if(_messageChannelHash[$channelId] == null) {
				var message:LocalConnection = new LocalConnection();
				message.client = this;
				try {
					message.connect(DebugClient.MESSAGE_CHANNEL_PREFIX+$channelId);
					_messageChannelHash[$channelId] = message;
					_messageChannelList.push(message);
				} catch($err:Error) {
					trace('DebugServer.onSubscribe() failed to connect.\n' + $err.message);
				}
				var response:LocalConnection = new LocalConnection();
				response.addEventListener(StatusEvent.STATUS, _onResponseStatus);
				_responseChannelHash[$channelId] = response;
				_responseChannelList.push(response);
				_channelIdList.push($channelId);
			}
		}
		
		public function onReady($channelId:String):void { }
		
		/**
		 * A handler to receive responses sent from a DebugClient object 
		 */
		public function onSend($channelId:String, $params:Array):void {
			if(_messageHandler!=null) {
				_messageHandler($channelId, $params);
			}
		}
		
		/**
		 * A handler for status events associated with response sending
		 */
		private function _onResponseStatus($e:StatusEvent):void {
			switch($e.level) {
				case 'status':
					if(isDebugging) trace('DebugServer._onResponseStatus() Send succeeded.');
					break;
				case 'error':
					if(isDebugging) trace('DebugServer._onResponseStatus() Error send failed.');
					break;
			}
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void {
			_subscriptionChannel = null;
			_messageChannelHash = null;
			_messageChannelList = null;
			for(var i:int=0; i<_responseChannelList.length; i++) 
				_responseChannelList[i].removeEventListener(StatusEvent.STATUS, _onResponseStatus);
			_responseChannelList = null;
			_responseChannelHash = null;
			_messageHandler = null;
			_channelIdList = null;
		}
	}
}
