package com.heycanvas.audio.engine {
	import fluorescent.component.DataComponent;

	import halogen.debug.Debugger;

	import com.heycanvas.audio.engine.mode.AbstractPlayerMode;
	import com.heycanvas.audio.engine.mode.ProgressivePlayerMode;
	import com.heycanvas.audio.engine.mode.StreamingPlayerMode;
	import com.heycanvas.audio.engine.state.AbstractPlayerState;
	import com.heycanvas.audio.engine.state.FwdState;
	import com.heycanvas.audio.engine.state.PauseState;
	import com.heycanvas.audio.engine.state.PlayState;
	import com.heycanvas.audio.engine.state.RwdState;
	import com.heycanvas.audio.engine.state.StopState;

	import flash.media.SoundTransform;

	/**
	 * @author htse
	 */
	public class AudioEngineProxy extends DataComponent {
		public static const FWD_SCALAR : Number = 5;
		public static const RWD_SCALAR : Number = 5;
		
		// associated
		
		// composed
		private var _mode : AbstractPlayerMode;
		private var _state : AbstractPlayerState;
		private var _stateQueue : Vector.<AbstractPlayerState>;
		
		private var _isPlaying : Boolean;
		private var _isHold : Boolean;
		private var _bufferSize : Number;
		private var _sndTransform : SoundTransform;
		
		/**
		 * Constructor
		 */
		public function AudioEngineProxy() {
			_isHold = false;
			_isPlaying = false;
			_bufferSize = 4;
		}
		
		/**
		 * Initialize
		 */
		public function init():void {
			Debugger.send();
			_sndTransform = new SoundTransform();
			_stateQueue = new Vector.<AbstractPlayerState>();
		}
		
		/**
		 * Sets a hold flag and queues all subsequent operations.  Remove hold must be called in order for 
		 * normal operation to continue.  
		 */
		private function _onSetHold():void {
			_isHold = true;
		}
		
		/**
		 * Removes the hold flag and continues operation
		 */
		private function _onRemoveHold():void {
			_isHold = false;
			_nextState();
		}
		
		/**
		 * Run next state if available
		 */
		private function _nextState():void {
			// run all states
			while(_stateQueue.length > 0 && !_isHold) {
				_setState(_stateQueue.shift());
			}
		}
		
		internal function _setState($state:AbstractPlayerState):void {
			if(_isHold) {
				_stateQueue.push($state);
				
			} else {
				var lastState:AbstractPlayerState = _state;
				if(lastState) {
					lastState.onExit();
				}
				
				_state = $state;
				_state.setContext(this, _mode);
				_state.onEnter();
			}
		}
		
		internal function _setMode($mode:AbstractPlayerMode):void {
			var lastMode:AbstractPlayerMode = _mode;
			if(lastMode) {
				lastMode.destroy();
			}
			
			Debugger.send('$mode:'+$mode);
			
			_mode = $mode;
			_mode.setEngine(this, _onSetHold, _onRemoveHold);
			_mode.init();
		}
		
		/**
		 * Loads a sound based on a hash map of parameters.  
		 * 
		 * <p>The following is a list of available parameters for a streaming connection:<br />
		 * <ul><li>type - Specifies what type of sound to create (e.g. - <code>streaming</code>)</li>
		 * <li>connection - A base URL used as a prefix for progressively loaded sounds</li>
		 * <li>src - A streaming command to play a specific file</li></ul>
		 * 
		 * <p>The following is a list of available parameters for a progressive sound:<br />
		 * <ul><li>type - Specifies what type of sound to create (e.g. - <code>progressive</code>)</li>
		 * <li>server - A base URL used as a prefix</li>
		 * <li>src - A URL of the sound to play</li></ul>
		 * @param $params, A hash object of parameters for sound construction
		 */
		public function load($params:Object):void {
			switch($params['type']) {
				case 'streaming':
					_setMode(new StreamingPlayerMode($params['connection'], $params['src'], $params['onBufferWait'], $params['onBufferReady']));
					break;
					
				case 'progressive':
					_setMode(new ProgressivePlayerMode($params['server'], $params['src']));
					break;
			}
		}
		
		/**
		 * Sets sound play mode
		 */
		public function play():void {
			_setState(new PlayState());
		}
		
		/**
		 * Sets sound pause mode
		 */
		public function pause():void {
			_setState(new PauseState());
		}
		
		/**
		 * Sets sound stop mode
		 */
		public function stop():void {
			_setState(new StopState());
		}
		
		/**
		 * Set fast-forward mode
		 */
		public function fwd():void {
			_setState(new FwdState());
		}
		
		/**
		 * Set rewind mode
		 */
		public function rwd():void {
			_setState(new RwdState());
		}
		
		/**
		 * Set a specific volume level
		 * @param $level, A specified volume level 0..1
		 */
		public function setVolume($level:Number):void {
			_sndTransform.volume = $level;
			if(_mode) {
				_mode.onSetVolume(_sndTransform);
			}
		}
		
		/**
		 * Gets <code>SoundTransform</code> object
		 */
		public function get soundTransform():SoundTransform { return _sndTransform; }
		
		/**
		 * Gets a parameter 0..1 specifying volume level
		 */
		public function get volume():Number { return _sndTransform.volume; }
		
		/**
		 * Gets a number representing bytes loaded
		 */
		public function get bytesLoaded():uint { return _mode.getBytesLoaded(); }
		
		/**
		 * Gets a number representing total bytes
		 */
		public function get bytesTotal():uint { return _mode.getBytesTotal(); }
		
		/**
		 * Jump to a specific point in the sound
		 * @param $position, A position specified in milliseconds
		 */
		public function seek($initPosition:int):void {
			_setState(new PlayState($initPosition));
		}

		/**
		 * Gets an integer value specifying position by milliseconds
		 */
		public function get position():int {
			if(_mode) {
				return _mode.getPosition();
				
			} else return 0;
		}
		
		/**
		 * Gets an integer value specifying length by milliseconds
		 */
		public function get length():int {
			if(_mode) {
				return _mode.getLength();
				
			} else return 0;
		}

		public function setIsPlaying($b:Boolean):void {
			_isPlaying = $b;
		}
		public function get isPlaying():Boolean { return _isPlaying; }
		
		/**
		 * Gets the value of buffer size in seconds
		 */
		public function get bufferSize():Number { return _bufferSize; }
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			super.destroy();
			if(_mode) {
				_mode.destroy();
				_mode = null;
			}
			if(_stateQueue) {
				for(var i:int=0; i<_stateQueue.length; i++) _stateQueue[i].destroy();
				_stateQueue = null;
			}
			if(_state) {
				_state.destroy();
				_state = null;
			}
		}
	}
}
