package com.heycanvas.audio {
	import fluorescent.initial.Initial;

	import com.heycanvas.audio.initial.InitialAction;

	import flash.events.IOErrorEvent;

	/**
	 * @author htse
	 */
	public class AudioPlayer extends Initial {
		public function AudioPlayer() {
			super();
			_preloadClassName = 'com.heycanvas.audio.initial.StartupAction';
			
			_preInit();
			_init();
		}
		
		private function _preInit():void {
			// avoid unhandled IOError
			addEventListener(IOErrorEvent.IO_ERROR, _onLoadNeverCompleted);
			
			// initial action
			var initialAction:InitialAction = new InitialAction();
			initialAction.setInitial(this);
			initialAction.setSite(_site);
			initialAction.execute();
		}

		private function _onLoadNeverCompleted($e:IOErrorEvent):void {
			
		}
		
		override protected function _initMain():void {
			super._initMain();
			removeEventListener(IOErrorEvent.IO_ERROR, _onLoadNeverCompleted);
		}
		
		override protected function _init():void {
			super._init();
		}
		
		override public function destroy():void {
			super.destroy();
		}
	}
}
