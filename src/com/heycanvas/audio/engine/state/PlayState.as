package com.heycanvas.audio.engine.state {
	import flash.events.Event;

	/**
	 * @author htse
	 */
	public class PlayState extends AbstractPlayerState {
		// assoicated
		
		// composed
		private var _initPosition : Number;
		
		public function PlayState($initPosition:Number=-1) {
			_initPosition = $initPosition;
		}
		
		override public function onEnter():void {
			_engineMode.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			
			if(_engineMode.isPaused && _initPosition==-1) {
				_engineMode.onResume();
				
			} else if(_initPosition==-1) {
				_engineMode.onPlay();
				
			} else {
				_engineMode.onSeek(_initPosition);
			}
		}
		
		private function _onSoundComplete($e:Event):void {
			_engine.dispatchEvent($e);
		}
		
		override public function onExit():void {
			_engineMode.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			
			destroy();
		}
		
		override public function get id():String { return 'play'; }
	}
}
