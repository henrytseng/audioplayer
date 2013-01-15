package com.heycanvas.audio.engine.state {

	/**
	 * @author htse
	 */
	public class StopState extends AbstractPlayerState {
		// assoicated
		
		// composed
		
		override public function onEnter():void {
			_engineMode.onStop();
		}
		
		override public function onExit():void {
			destroy();
		}
		
		override public function get id():String { return 'stop'; }
	}
}
