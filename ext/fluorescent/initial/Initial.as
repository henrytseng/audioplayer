/**
 * Copyright (c) 2010 Henry Tseng (http://www.henrytseng.com)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package fluorescent.initial {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;

	/**
	 * Entry point for application; preloader using Flex SDK.  
	 * 
	 * @author henry
	 */
	public class Initial extends MovieClip {
		protected var _initialLoaded : Boolean;
		protected var _site : Sprite;
		protected var _startupAction : IStartupAction;
		protected var _preloadClassName : String;
		
		/**
		 * Constructor
		 */
		public function Initial() : void {
			super();
			_initialLoaded = false;
			addChild(_site = new Sprite());
		}
		
		/**
		 * Application initialization registers actions, proxies and mediators
		 * required for startup.   
		 */
		protected function _init() : void {
			addEventListener(Event.ENTER_FRAME, _onPreloadCheck);
		}
		
		/**
		 * Internal method to check if frames are loaded
		 */
		protected function _onPreloadCheck($e : Event) : void {
			if(currentFrame==totalFrames) {
				stop();
				removeEventListener(Event.ENTER_FRAME, _onPreloadCheck);
				_initMain();
			}
		}
		
		/**
		 * Application is ready.  
		 */
		protected function _initMain() : void {
			var ref : Class;
			
			// get reference
			ref = getDefinitionByName(_preloadClassName) as Class;
			
			// instantiate and take over
			_startupAction = new ref() as IStartupAction;
			if(_startupAction) {
				_startupAction.setInitial(this);
				_startupAction.setSite(_site);
				_startupAction.addEventListener(Event.COMPLETE, _onStartupComplete);
				_startupAction.execute();
				
			} else {
				throw(new IllegalOperationError('Unable able to instantiate '+_preloadClassName+' as AbstractAction'));
			}
		}
		
		/**
		 * Hand over operation to rest of application
		 */
		private function _onStartupComplete($e:Event):void {
			_startupAction.removeEventListener(Event.COMPLETE, _onStartupComplete);
			_startupAction.destroy();
			_startupAction = null;
			
			_site = null;
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void {
			if(_startupAction) {
				_startupAction.removeEventListener(Event.COMPLETE, _onStartupComplete);
				_startupAction = null;
			}
			
			_site = null;
		}
		
		override public function toString() : String { return '[Initial]'; }
	}
}
