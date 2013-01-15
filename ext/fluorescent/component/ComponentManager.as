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
 * LIABILITY, WHETHER IN the action OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package fluorescent.component {
	import halogen.debug.DebugLevel;
	import halogen.debug.Debugger;

	/**
	 * <code>ComponentManager</code> works as a lookup table for application components.  
	 * <br><br>
	 * <code>ComponentManager</code> decouples components with the rest of the application by allowing the use of 
	 * events and actions between <code>DataComponents</code> and <code>VisualComponents</code>.  
	 * <br><br>
	 * <code>ComponentManager</code> acts as a proxy for a <code>Controller</code>, a manager for action which utilizes
	 * a command pattern based scheme.  
	 * 
	 * @see fluorescent.component.DataComponent
	 * @see fluorescent.component.VisualComponent
	 * @see fluorescent.component.Controller
	 * @see fluorescent.action.IAction
	 * @author henry
	 */
	public class ComponentManager {
		private static var _componentHash : Object;
		private static var _controller : Controller;
		private static var _isInit : Boolean = false;
		
		/**
		 * Initialization
		 */
		private static function _init():void {
			if(!_isInit) {
				_componentHash = {};
				_controller = new Controller();
				_isInit = true;
			}
		}
		
		/**
		 * Register the action according to an <code>$id</code>
		 * @param $id, A unique id corresponding to the action
		 * @param $ref, A reference to a <code>Class</code> which will be used to create the action
		 * @param $paramList, A hash object of intialization parameters used when the action is executed
		 */
		public static function registerAction($id:String, $ref:Class, $paramList:Object=null):void {
			_init();
			_controller.registerAction($id, $ref, $paramList);
		}
		
		/**
		 * Execute the action by <code>$id</code>
		 * @param $id, A unique id corresponding to the action
		 * @param $paramList, A hash object of intialization parameters used when the action is executed
		 * @param $onComplete, A function handler called when the action has completed execution
		 */
		public static function executeAction($id:String, $paramList:Object=null, $onComplete:Function=null):void {
			_init();
			_controller.executeAction($id, $paramList, $onComplete);
		}

		/**
		 * Unregister the action
		 * @param $id, A unique id corresponding to the action
		 */
		public static function unregisterAction($id:String):void {
			_init();
			_controller.unregisterAction($id);
		}
		
		/**
		 * Create a component using a reference to its <code>Class</code>
		 * @param $id, A unique id corresponding to the component
		 * @param $ref, A reference to the Class used to create the compoennt
		 * @return A reference to the component once it is created
		 */
		public static function createComponent($id:String, $ref:Class):IComponent {
			_init();
			if(_componentHash.hasOwnProperty($id)) {
				Debugger.send('Component id:'+$id+' is already registered', DebugLevel.WARNING);
				return null;
			}
			var component:IComponent = new $ref() as IComponent;
			_componentHash[$id]=component;
			component.id = $id;
			return component;
		}
		
		/**
		 * Retrieve a component by its id
		 * @param $id, A unique id corresponding to the component
		 * @return A reference to the component
		 */
		public static function getComponent($id:String):IComponent { return _componentHash[$id] as IComponent; }
		
		public static function listComponents():Array {
			var list:Array = [];
			for each(var id:String in _componentHash) {
				list.push(id);
			}
			return list;
		}
		
		/**
		 * Destroy a component
		 * @param $id, A unique id corresponding to the component
		 */
		public static function destroyComponent($id:String):void {
			_init();
			if(_componentHash.hasOwnProperty($id)) {
				var component:IComponent = _componentHash[$id] as IComponent;
				component.destroy();
				delete(_componentHash[$id]);
			}
		}
	}
}
