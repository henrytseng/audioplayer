package com.heycanvas.audio.engine.mode {
	import com.heycanvas.audio.engine.AudioEngineProxy;

	import flash.events.EventDispatcher;
	import flash.media.SoundTransform;

	/**
	 * An abstract layer to conform progressive and streaming players to a single platform.  
	 * 
	 * Event.SOUND_COMPLETE is dispatched after a sound has completed
	 * 
	 * @eventType flash.events.Event.SOUND_COMPLETE;
	 * 
	 * @author henry
	 */
	public class AbstractPlayerMode extends EventDispatcher {
		// assoicated
		protected var _engine : AudioEngineProxy;
		protected var _setHold : Function;
		protected var _removeHold : Function;
		
		// composed
		protected var _isPaused : Boolean;
		
		public function get isPaused():Boolean { return _isPaused; }
		
		/**
		 * Initialize
		 */
		public function init():void { }
		
		/**
		 * Handler to play from start
		 */
		public function onPlay():void { }
		
		/**
		 * Handler to play at a specific position or resumes when previously paused
		 * @param $initPosition, An initial position to start playing (default=-1 ignore) 
		 */
		public function onSeek($initPosition:Number=-1):void { }
		
		/**
		 * Get current position in milliseconds
		 */
		public function getPosition():int { return 0; }
		
		/**
		 * Get sound length in milliseconds
		 */
		public function getLength():int { return 0; }
		
		/**
		 * Handler to set the volume according to a <code>SoundTransform</code>
		 */
		public function onSetVolume($sndTransform:SoundTransform):void { }
		
		/**
		 * Get bytes loaded
		 */
		public function getBytesLoaded():uint { return 0; }
		
		/**
		 * Get bytes total
		 */
		public function getBytesTotal():uint { return 0; }
		
		/**
		 * Handler to pause
		 */
		public function onPause():void { }
		
		/**
		 * Handler to resume from pause
		 */
		public function onResume():void { }
		
		/**
		 * Handler to stop completely
		 */
		public function onStop():void { }
		
		/**
		 * Set the engine reference and also pass handlers to control holding.
		 * @param $engine, A reference to the engine proxy
		 * @param $setHoldHandler, A handler to set hold flag
		 * @param $removeHoldHandler, A handler to remove hold flag
		 */
		public function setEngine($engine:AudioEngineProxy, $setHoldHandler:Function, $removeHoldHandler:Function):void {
			_engine = $engine;
			_setHold = $setHoldHandler;
			_removeHold = $removeHoldHandler;
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void {
			_engine = null;
			_setHold = null;
			_removeHold = null;
		}
	}
}
