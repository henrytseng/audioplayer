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
package fluorescent.action {
	import halogen.debug.DebugLevel;
	import halogen.debug.Debugger;

	import flash.events.IEventDispatcher;

	/**
	 * <code>ActionPackage</code> is a bundle for a <code>Class</code> reference to an action and
	 * a set of parameters to pass to an action.  
	 * 
	 * @see fluorescent.action.IAction
	 * @author henry
	 */
	public class ActionPackage {
		/** A reference to the <code>Class</code> */
		public var ref : Class;
		
		/** A set of paramters */  
		public var paramList : Object;
		
		/**
		 * Constructor
		 */
		public function ActionPackage($ref:Class, $paramList:Object) {
			ref = $ref;
			paramList = $paramList;
		}
		
		/**
		 * Create action and add new parameters as necessary
		 * @param $paramsAppended Parameters to append to original list
		 * @param $isReuseable
		 * @param $target
		 */
		public function createAction($paramsAppended:Object=null, $isReuseable:Boolean=false, $target:IEventDispatcher=null):IAction {
			try {
				var tempParams:Object;
				if($paramsAppended) {
					for(var name:String in paramList) {
						if(!$paramsAppended.hasOwnProperty(name)) $paramsAppended[name]=paramList[name];
					}
					tempParams = $paramsAppended;
				} else {
					tempParams = paramList;
				}
				return new ref(tempParams, $isReuseable, $target);
				
			} catch($err:Error) {
				Debugger.send('Error creating action\n'+$err.getStackTrace(), DebugLevel.ERROR);
			}
			return null;
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void {
			ref = null;
			paramList = null;
		}
	}
}
