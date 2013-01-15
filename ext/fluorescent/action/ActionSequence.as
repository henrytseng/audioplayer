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
	import flash.events.IEventDispatcher;

	/**
	 * <code>ActionSequence</code> is a queue for a list of actions.  
	 * <br><br>
	 * An <code>Event.COMPLETE</code> is dispatched after all actions complete.  
	 * 
	 * @see fluorescent.action.ActionPackage
	 * @see fluorescent.action.SequenceExecution
	 * @see fluorescent.action.IAction
	 * @author henry
	 */
	public class ActionSequence extends AbstractAction implements IAction {
		private var _actionList : Vector.<ActionPackage>;
		private var _sequenceList : Vector.<SequenceExecution>;
		
		/**
		 * Constructor
		 * @param $paramList If this is a Vector.<ActionPackage> ActionSequence will use this to set up the sequence
		 */
		public function ActionSequence($paramList:Object=null, $isReuseable:Boolean=false, $target:IEventDispatcher=null) {
			super($paramList, $isReuseable, $target);
			_actionList = ($paramList is Vector.<ActionPackage>) ? $paramList as Vector.<ActionPackage> : new Vector.<ActionPackage>();
			_sequenceList = new Vector.<SequenceExecution>;
		}
		
		/**
		 * Add action
		 * @param $ref, A reference to the <code>Class</code> of the action to add
		 */
		public function addAction($ref:Class, $paramList:Object=null):void {
			var pack:ActionPackage = new ActionPackage($ref, $paramList);
			_actionList.push(pack);
		}
		
		/**
		 * Execute all actions in sequence
		 */
		override public function execute():void {
			var seq:SequenceExecution = new SequenceExecution(this);
			_sequenceList.push(seq);
			seq._actionList = _actionList.slice(0);
			seq._start();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			super.destroy();
			for(var i:int=0; i<_actionList.length; i++) _actionList[i].destroy();
			_actionList = null;
			for(var j:int=0; j<_sequenceList.length; j++) _sequenceList[j].destroy();
			_sequenceList = null;
		}
	}
}
