package com.heycanvas.audio.engine.state {
	import halogen.debug.Debugger;

	import com.heycanvas.audio.engine.AudioEngineProxy;
	import com.heycanvas.audio.engine.mode.AbstractPlayerMode;

	/**
	 * @author htse
	 */
	public class AbstractPlayerState {
		// associated
		protected var _engine : AudioEngineProxy;
		protected var _engineMode : AbstractPlayerMode;
		
		// composed
		
		public function setContext($engine : AudioEngineProxy, $mode:AbstractPlayerMode) : void {
			Debugger.send('$engine:'+$engine+' $mode:'+$mode);
			_engine = $engine;
			_engineMode = $mode;
		}
		
		/**
		 * Handler called when state enters.  
		 */
		public function onEnter():void { }
		
		/**
		 * Handler called when state exits.  State should also call destroy on itself.  
		 */
		public function onExit():void { }
		
		public function get id():String { return ''; }
		
		public function destroy():void {
			_engine = null;
			_engineMode = null;
		}
	}
}
