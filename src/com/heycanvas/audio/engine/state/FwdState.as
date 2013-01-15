package com.heycanvas.audio.engine.state {
	import halogen.debug.Debugger;

	import com.heycanvas.audio.engine.AudioEngineProxy;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author htse
	 */
	public class FwdState extends AbstractPlayerState {
		// assoicated
		
		// composed
		private var _fwdTimer : Timer;
		
		override public function onEnter():void {
			_engineMode.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			
			_fwdTimer = new Timer(100);
			_fwdTimer.addEventListener(TimerEvent.TIMER, _onUpdateFwd);
			_fwdTimer.start();
		}
		
		private function _onUpdateFwd($e:Event):void {
			Debugger.send(_engineMode.getPosition());
			_engineMode.onSeek(_engineMode.getPosition()+(AudioEngineProxy.FWD_SCALAR*_fwdTimer.delay));
		}
		
		private function _onSoundComplete($e:Event):void { }
		
		override public function onExit():void {
			_engineMode.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			
			_fwdTimer.stop();
			_fwdTimer.removeEventListener(TimerEvent.TIMER, _onUpdateFwd);
			
			_engineMode.onPause();
			destroy();
		}
		
		override public function get id():String { return 'fwd'; }
	}
}
