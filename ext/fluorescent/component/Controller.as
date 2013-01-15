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
package fluorescent.component {
	import fluorescent.action.ActionPackage;
	import fluorescent.action.IAction;

	import halogen.debug.DebugLevel;
	import halogen.debug.Debugger;

	import flash.events.Event;

	/**
	 * <code>Controller</code> executes and manages actions.  
	 * <br><br>
	 * Actions decouple components from the rest of the application through the usage of a command pattern
	 * scheme.  
	 *  
	 * @see fluorescent.action.IAction
	 * @author henry
	 */
	public class Controller {
		private var _actionHash : Object;
		
		/**
		 * Controller
		 */
		public function Controller() {
			_actionHash = {};
		}
		
		/**
		 * Register action
		 * @param $id, A unique id corresponding to the action
		 * @param $ref, A reference to a <code>Class</code> which will be used to create the action
		 * @param $paramList, A hash object of intialization parameters used when the action is executed
		 */
		public function registerAction($id:String, $ref:Class, $paramList:Object=null):void {
			if(_actionHash[$id]) {
				Debugger.send('An action with id:'+$id+' already exists, overwriting previous action', DebugLevel.WARNING);
				if(_actionHash[$id].destroy is Function) _actionHash[$id].destroy();
			}
			
			_actionHash[$id] = new ActionPackage($ref, $paramList);
		}
		
		/**
		 * Execute action
		 * @param $id, A unique id corresponding to the action
		 * @param $paramList, A hash object of intialization parameters used when the action is executed
		 * @param $onComplete, A function handler called when the action has completed execution
		 */
		public function executeAction($id:String, $paramList:Object=null, $onComplete:Function=null):void {
			var pack:ActionPackage = _actionHash[$id] as ActionPackage;
			if(!pack) {
				Debugger.send('An action with id:'+$id+' does not exist', DebugLevel.ERROR);
				return;
			}
			var action:IAction = pack.createAction($paramList);
			if($onComplete!=null) action.addEventListener(Event.COMPLETE, function($e:Event):void {
				$onComplete();
			}, false, 0, true);
			action.execute();
		}
		
		/**
		 * Unregister action
		 * @param $id, A unique id corresponding to the action
		 */
		public function unregisterAction($id:String):void {
			var pack:ActionPackage = _actionHash[$id] as ActionPackage;
			if(!pack) {
				Debugger.send('An action with id:'+$id+' does not exist', DebugLevel.ERROR);
				return;
			}
			pack.destroy();
			delete(_actionHash[$id]);
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void {
			for(var id:String in _actionHash) unregisterAction(id);
			_actionHash = null;
		}
	}
}
