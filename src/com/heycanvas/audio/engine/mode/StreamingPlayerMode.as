package com.heycanvas.audio.engine.mode {
	import halogen.debug.Debugger;

	import com.heycanvas.audio.engine.ConnectionPool;

	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;

	/**
	 * @author henry
	 */
	public class StreamingPlayerMode extends AbstractPlayerMode {
		// assoicated
		private var _connection : NetConnection;
		
		// composed
		private var _location : String;
		private var _connectionURL : String;
		
		private var _musicStream : NetStream;
		private var _initPosition : int;
		private var _length : Number;
		private var _onBufferWaitHandler : Function;
		private var _onBufferReadyHandler : Function;
		
		public function StreamingPlayerMode($connectionURL:String, $location:String, $onBufferWait:Function=null, $onBufferReady:Function=null) {
			_isPaused = false;
			_connectionURL = $connectionURL;
			_location = $location;
			_onBufferWaitHandler = $onBufferWait;
			_onBufferReadyHandler = $onBufferReady;
		}

		override public function init():void {
			_initPosition = 0;
			_length = 0;
			
			// keep only 1 connection open
			if(ConnectionPool.numConnections>=1 && !ConnectionPool.hasConnection(_connectionURL)) {
				ConnectionPool.destroy();
			}
			
			// make connection
			if(!ConnectionPool.hasConnection(_connectionURL)) {
				_connection = ConnectionPool.createConnection(_connectionURL);
				_connection.client = this;
				_connection.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);
				
				_setHold();
				_connection.connect(_connectionURL);
				
			// get connection
			} else {
				_connection = ConnectionPool.createConnection(_connectionURL);
				_connection.client = this;
				_connection.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);
				
				if(_connection.connected) {
					_connectStream();
					_removeHold();
					
				} else {
					_setHold();
				}
			}
		}
		
		private function _onNetStatus($e:NetStatusEvent):void {
			//Debugger.send('info:'+DebugObject.enumerate($e.info));
			
			switch($e.info.code) {
				case "NetConnection.Connect.Success":
					_connectStream();
					_removeHold();
					break;
			}
		}
		
		public function onBWDone():void {
			Debugger.send();
		}
		
		public function setNetClientLength($length:Number):void {
			_length = $length * 1000;
		}
		
		private function _connectStream():void {
			_musicStream = new NetStream(_connection);
			_musicStream.client = {onPlayStatus:function():void {}};
			_musicStream.addEventListener(NetStatusEvent.NET_STATUS, _onStreamStatus);
			_musicStream.soundTransform = _engine.soundTransform;
		}
		
		private function _onStreamStatus($e:NetStatusEvent):void {
			//Debugger.send('info:'+DebugObject.enumerate($e.info));
			
			switch($e.info.code) {
				case "NetStream.Buffer.Full":
					if(_onBufferReadyHandler!=null) _onBufferReadyHandler.apply();
					break;
					
				case "NetStream.Buffer.Empty":
					if(_onBufferWaitHandler!=null) _onBufferWaitHandler.apply(); 
					break;
					
				case "NetStream.Play.Failed":
				case "NetStream.Play.Stop":
					_engine.setIsPlaying(false);
					dispatchEvent(new Event(Event.SOUND_COMPLETE));
					break;
			}
		}
		
		public function close():void {
			Debugger.send();
			_removeHold();
		}
		
		override public function onPlay():void {
			_musicStream.play("mp3:"+_location);
			_musicStream.seek(_initPosition/1000);
			_engine.setIsPlaying(true);
			_isPaused = false;
			
			_connection.call('getStreamLength', new Responder(setNetClientLength), "mp3:"+_location);
		}
		
		override public function onSeek($initPosition:Number=-1):void {
			_initPosition = $initPosition;
			if(_initPosition<0) _initPosition = 0;
			else if(_initPosition > getLength()) _initPosition = getLength();
			
			if(_musicStream) {
				_musicStream.resume();
				_musicStream.seek(_initPosition/1000);
			}
			_engine.setIsPlaying(true);
			_isPaused = false;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getPosition():int {
			if(_musicStream) return _musicStream.time*1000;
			else return 0;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getLength():int { return Math.max(_length, _initPosition); }

		override public function onSetVolume($sndTransform:SoundTransform):void {
			_musicStream.soundTransform = $sndTransform;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getBytesLoaded():uint {
			if(_musicStream) {
				return _musicStream.bytesLoaded;
			} else return 0;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getBytesTotal():uint { 
			if(_musicStream) {
				return _musicStream.bytesTotal;
			} else return 0;
		}
		
		override public function onPause():void {
			Debugger.send();
			
			_isPaused = true;
			_engine.setIsPlaying(false);
			if(_musicStream) _musicStream.pause();
		}
		
		override public function onResume():void {
			Debugger.send();
			
			_isPaused = true;
			_engine.setIsPlaying(true);
			if(_musicStream) _musicStream.resume();
		}
		
		override public function onStop():void {
			_isPaused = false;
			_initPosition = 0;
			_engine.setIsPlaying(false);
			if(_musicStream) _musicStream.close();
		}
		
		override public function destroy():void {
			super.destroy();
			
			if(_musicStream) {
				_musicStream.close();
				_musicStream.removeEventListener(NetStatusEvent.NET_STATUS, _onStreamStatus);
				_musicStream = null;
			}
			
			if(_connection) {
				_connection = null;
			}
			
			_onBufferWaitHandler = null;
			_onBufferReadyHandler = null;
		}
	}
}
