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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * <code>SequenceExecution</code> is an instantiation of an execution of a sequence of actions.  
	 * <br><br>
	 * A <code>Event.COMPLETE</code> will be dispatched after all actions have finished.
	 *   
	 * @see fluorescent.action.ActionPackage
	 * @see fluorescent.action.IAction
	 * @author henry
	 */
	public class SequenceExecution extends EventDispatcher {
		internal var _actionList : Vector.<ActionPackage>;
		private var _nextAction : IAction;
		
		/**
		 * Constructor
		 */
		public function SequenceExecution($target:IEventDispatcher) {
			super($target);
		}
		
		/**
		 * An internal method to start execution
		 */
		internal function _start():void {
			_executeNext();
		}
		
		/**
		 * A method to instantiate and execute next action
		 */
		private function _executeNext():void {
			var pack:ActionPackage = _actionList.shift();
			_nextAction = pack.createAction();
			_nextAction.addEventListener(Event.COMPLETE, _onActionComplete);
			_nextAction.execute();
		}
		
		/**
		 * A method which serves as a handler for an action completion.  
		 */
		private function _onActionComplete($e:Event):void {
			_nextAction.removeEventListener(Event.COMPLETE, _onActionComplete);
			_executeNext();
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void {
			if(_nextAction) _nextAction.removeEventListener(Event.COMPLETE, _onActionComplete);
			_actionList = null;
		}
	}
}
