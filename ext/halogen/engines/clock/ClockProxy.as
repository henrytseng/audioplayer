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
package halogen.engines.clock {
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	/**
	 * @author henry
	 */
	public class ClockProxy extends EventDispatcher {
		private var _timer : Timer;
		private var _list : Vector.<Function>;
		public var lastTime : int;
		
		/**
		 * Constructor
		 */
		public function ClockProxy($delay:int=25) {
			_list = new Vector.<Function>;
			_timer = new Timer($delay);
			_timer.addEventListener(TimerEvent.TIMER, _onTic);
		}
		
		private function _onTic($e:TimerEvent):void {
			var execution:Function = function($handler:Function, $i:int, $vector:Vector.<Function>):void {
				$handler();
			};
			_list.forEach(execution);
			lastTime = getTimer();
		}
		
		/**
		 * Registers a handler which will be called each time the clock tics
		 * @param $handler Handler to add 
		 * @param $index Default -1 value appends handler to the end of the list
		 */
		public function registerHandler($handler:Function, $index:int=-1):void {
			if($index<=-1 || $index>=_list.length) {
				_list.push($handler); 
			} else {
				_list.splice($index,0,$handler);
			}
		}
		
		/**
		 * Unregisters a handler
		 * @param $handler Handler to remove
		 */
		public function unregisterHandler($handler:Function):void {
			var i:int = _list.indexOf($handler);
			if(i!=-1) _list.splice(i, 1);
		}
		
		/**
		 * Unregisters a handler at a specific index
		 * @param $index Index of handler to remove
		 */
		public function unregisterHandlerAt($index:int):void {
			if($index>=0 && $index<_list.length) _list.splice($index, 1);
		}
		
		/**
		 * Starts the clock
		 */
		public function start():void {
			//if(_timer.running) _timer.stop();
			_timer.start();
			lastTime = getTimer();
		}
		
		/**
		 * Stops the clock
		 */
		public function stop():void {
			_timer.stop();
		}
		
		/**
		 * Gets the time since the last clock tic
		 */
		public function get elapsedTime():int { return getTimer()-lastTime; }
		
		/**
		 * Accessor for the amount of delay between each lock tic
		 */
		public function set delay($delay:Number):void {
			_timer.delay = $delay;
			start();
		}
		public function get delay():Number { return _timer.delay; }
		
		/**
		 * Destroy
		 */
		public function destroy():void {
			_timer.removeEventListener(TimerEvent.TIMER, _onTic);
			_timer = null;
			_list = null;
		}
	}
}
