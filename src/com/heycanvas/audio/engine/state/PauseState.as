package com.heycanvas.audio.engine.state {

	/**
	 * @author htse
	 */
	public class PauseState extends AbstractPlayerState {
		// assoicated
		
		// composed
		
		override public function onEnter():void {
			_engineMode.onPause();
		}
		
		override public function onExit():void {
			destroy();
		}

		override public function get id():String { return 'pause'; }
	}
}
