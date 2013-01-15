package com.heycanvas.audio.engine.mode {
	import halogen.debug.DebugLevel;
	import halogen.debug.Debugger;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	/**
	 * @author henry
	 */
	public class ProgressivePlayerMode extends AbstractPlayerMode {
		// assoicated
		
		// composed
		private var _initPosition : int;
		
		private var _request : URLRequest;
		private var _sound : Sound;
		private var _sndChannel : SoundChannel;
		
		private var _src : String;
		
		public function ProgressivePlayerMode($serverURL:String, $src:String) {
			_isPaused = false;
			_src = $serverURL+$src;
		}
		
		override public function init():void {
			_initPosition = 0;
			_request = new URLRequest(_src);
			try {
				_sound = new Sound();
				_sound.addEventListener(IOErrorEvent.IO_ERROR, _onSteamIOError);
				_sound.addEventListener(IOErrorEvent.NETWORK_ERROR, _onSteamIOError);
				_sound.load(_request, new SoundLoaderContext(_engine.bufferSize*1000));
			} catch($error:Error) {
				Debugger.send($error.getStackTrace(), DebugLevel.WARNING);
			}
		}
		
		override public function onPlay():void {
			if(_sndChannel) {
				_sndChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
				_sndChannel.stop();
			}
			_sndChannel = _sound.play(_initPosition, 0, _engine.soundTransform);
			_sndChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			
			_engine.setIsPlaying(true);
			_isPaused = false;
		}
		
		override public function onSeek($initPosition:Number=-1):void {
			_initPosition = $initPosition;
			if(_initPosition<0) _initPosition = 0;
			else if(_initPosition > getLength()) _initPosition = getLength();
			
			if(_sndChannel) {
				_sndChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
				_sndChannel.stop();
			}
			_sndChannel = _sound.play(_initPosition, 0, _engine.soundTransform);
			_sndChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			
			_engine.setIsPlaying(true);
			_isPaused = false;
		}

		/**
		 * @inheritDoc
		 */
		override public function getPosition():int { 
			if(_sndChannel) return _sndChannel.position;
			else return 0;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getLength():int { 
			return _sound.length;
		}
		
		override public function onSetVolume($soundTransform:SoundTransform):void {
			if(_sndChannel) _sndChannel.soundTransform = $soundTransform;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getBytesLoaded():uint { return _sound.bytesLoaded; }
		
		/**
		 * @inheritDoc
		 */
		override public function getBytesTotal():uint { return _sound.bytesTotal; }
		
		override public function onPause():void {
			if(_sndChannel) {
				_initPosition = _sndChannel.position;
				_sndChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
				_sndChannel.stop();
				_engine.setIsPlaying(false);
				_isPaused = true;
			}
		}
		
		override public function onResume():void {
			if(_sndChannel) {
				_sndChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
				_sndChannel.stop();
			}
			_sndChannel = _sound.play(_initPosition, 0, _engine.soundTransform);
			_sndChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			_engine.setIsPlaying(true);
			_isPaused = false;
		}
		
		override public function onStop():void {
			if(_sndChannel) {
				_initPosition = 0;
				_sndChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
				_sndChannel.stop();
				_engine.setIsPlaying(false);
				_isPaused = false;
			}
		}
		
		private function _onSoundComplete($e: Event) : void {
			Debugger.send();
			_engine.setIsPlaying(false);
			dispatchEvent($e);
		}
		
		private function _onSteamIOError($e:IOErrorEvent):void {
			Debugger.send($e.text, DebugLevel.WARNING);
		}
		
		override public function destroy():void {
			super.destroy();
			_request = null;
			if(_sound) {
				try {
					_sound.close();
				} catch($error:Error) { }
				_sound.removeEventListener(IOErrorEvent.NETWORK_ERROR, _onSteamIOError);
				_sound.removeEventListener(IOErrorEvent.IO_ERROR, _onSteamIOError);
				_sound = null;
			}
			if(_sndChannel) {
				_sndChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
				_sndChannel.stop();
				_sndChannel = null;
			}
		}
	}
}
