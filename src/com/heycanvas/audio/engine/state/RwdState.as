package com.heycanvas.audio.engine.state {
	import halogen.debug.Debugger;

	import com.heycanvas.audio.engine.AudioEngineProxy;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author htse
	 */
	public class RwdState extends AbstractPlayerState {
		// assoicated
		
		// composed
		private var _rwdTimer : Timer;
		
		override public function onEnter():void {
			_engineMode.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			
			_rwdTimer = new Timer(100);
			_rwdTimer.addEventListener(TimerEvent.TIMER, _onUpdateRwd);
			_rwdTimer.start();
		}
		
		private function _onUpdateRwd($e:Event):void {
			Debugger.send(_engineMode.getPosition());
			_engineMode.onSeek(_engineMode.getPosition()-(AudioEngineProxy.RWD_SCALAR*_rwdTimer.delay));
		}
		
		private function _onSoundComplete($e:Event):void { }
		
		override public function onExit():void {
			_engineMode.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			
			_rwdTimer.stop();
			_rwdTimer.removeEventListener(TimerEvent.TIMER, _onUpdateRwd);
			
			_engineMode.onPause();
			destroy();
		}
		
		override public function get id():String { return 'rwd'; }
	}
}
