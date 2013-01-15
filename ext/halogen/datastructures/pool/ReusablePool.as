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
package halogen.datastructures.pool {

	/**
	 * <code>ReusablePool</code> creates a reusable object pool.  Objects can be acquired and released into the pool 
	 * and are picked up from the pool instead of instantiated.  
	 * <br><br>
	 * Object creation requires memory allocation and can therefore often be slower to process.  An object pool
	 * allows several objects to be waiting in standby.  
	 * 
	 * * @see halogen.datastructures.pool.IReusable
	 * @author henry
	 */
	public class ReusablePool {
		protected var _maxPoolSize : int;
		protected var _freeList : Vector.<IReusable>;
		protected var _useList : Vector.<IReusable>;
		protected var _requestList : Vector.<Function>;
		protected var _ref : Class;
		
		public function ReusablePool($ref:Class=null, $maxPoolSize:int=5) {
			_ref = $ref;
			_maxPoolSize = $maxPoolSize;
			_freeList = new Vector.<IReusable>();
			_useList = new Vector.<IReusable>();
			_requestList = new Vector.<Function>();
		}
		
		/**
		 * Handlers receive two parameters <code>$onCreatedHandler($reusable:IReusable, $params:Object=null)</code>
		 * @param $onCreatedHandler
		 * @param $params
		 */
		public function acquire($onCreatedHandler:Function=null, $params:Object=null):IReusable {
			var reusable:IReusable = null;
			if(_useList.length<_maxPoolSize && _ref!=null) {
				reusable = _getFreeAgent();
				_useList.push(reusable);
				reusable.onAcquire($params);
				if(Boolean($onCreatedHandler)) $onCreatedHandler(reusable, $params);
				
			} else {
				_requestList.push($onCreatedHandler);
			}
			return reusable;
		}
		
		/**
		 * @param $reusable
		 * @param $params
		 */
		public function release($reusable:IReusable, $params:Object=null):void {
			 var i:int = _useList.indexOf($reusable);
			 if(i!=-1) {
			 	_useList.splice(i,1);
				_freeList.push($reusable);
				$reusable.onRelease($params);
				
				// handled previous requests
				if(_requestList.length>0) {
					acquire(_requestList.shift());
				}
			}
		}
		
		protected function _getFreeAgent():IReusable {
			var freeAgent:IReusable = _freeList.shift() as IReusable;
			return (!freeAgent) ? new _ref() : freeAgent;
		}
		
		public function set ref($ref:Class):void {
			_ref = $ref;
		}
		public function get ref():Class { return _ref; }
		
		public function set maxPoolSize($maxPoolSize:int):void {
			_maxPoolSize = $maxPoolSize;
		}
		public function get maxPoolSize():int { return _maxPoolSize; }
		
		public function get numFree():int { return _maxPoolSize-_useList.length; }
		
		public function get numUsed():int { return _useList.length; }

		public function destroy():void {
			_ref = null;
			_freeList = null;
			_useList = null;
			_requestList = null;
		}
	}
}
