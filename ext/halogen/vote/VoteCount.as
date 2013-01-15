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
package halogen.vote {
	import flash.events.EventDispatcher;

	/**
	 * @author henry
	 */
	public class VoteCount extends EventDispatcher {
		private var _totalCount : int;
		private var _passCount : int;
		private var _voteHash : Object;
		private var _isPassed : Boolean;
		
		public function VoteCount($initValue:Boolean=false) {
			_voteHash = {};
			_passCount = 0;
			_totalCount = 0;
			_isPassed = $initValue;
		}
		
		public function accept($id:String):void {
			if(!_voteHash.hasOwnProperty($id)) _totalCount++;
			if(!Boolean(_voteHash[$id])) {
				_passCount++;
			}
			_voteHash[$id]=true;
			
			if(!_isPassed) {
				_isPassed = _checkPassed();
				if(_isPassed) dispatchEvent(new VoteEvent(VoteEvent.ACCEPTED));
			}
		}
		
		public function reject($id:String):void {
			if(!_voteHash.hasOwnProperty($id)) _totalCount++;
			if(Boolean(_voteHash[$id])) {
				_passCount--;
			}
			_voteHash[$id]=false;
			
			if(_isPassed) {
				_isPassed = _checkPassed();
				if(!_isPassed) dispatchEvent(new VoteEvent(VoteEvent.REJECTED));
			}
		}
		
		protected function _checkPassed():Boolean {
			return _passCount >= _totalCount;
		}

		public function get isPassed():Boolean { return _isPassed; }
		
		public function get passCount():int { return _passCount; }
		
		public function get totalCount():int { return _totalCount; }
		
		public function destroy():void {
			_voteHash = null;
		}
	}
}
