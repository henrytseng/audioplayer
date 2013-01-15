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
package halogen.mutex {

	/**
	 * @author henry
	 */
	public class SemaphoreCount {
		private var _count : int;
		private var _handlerQueue : Vector.<Function>;
		
		public function SemaphoreCount($initialCount:int=1) {
			_count = $initialCount;
			_handlerQueue = new Vector.<Function>();
		}
		
		public function acquire($handler:Function):void {
			if(!Boolean($handler)) return;
			
			if(_count > 0) {
				_count--;
				$handler();
				
			} else {
				_handlerQueue.push($handler);
			}
		}
		
		public function release():void {
			_count++;
			_releaseQueued();
		}
		
		private function _releaseQueued():void {
			// check queue
			if(_handlerQueue.length > 0) {
				_count--;
				var handler:Function = _handlerQueue.shift();
				handler();
			}
		}
		
		public function get count():int { return _count; }
		
		public function destroy():void {
			_handlerQueue = null;
		}
		
		public function toString():String { return '[SemaphoreCount]'; }
	}
}
