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
	import flash.display.Sprite;

	/**
	 * <code>VisualComponents</code> accept user input and display user feedback.  
	 * <br><br>
	 * <code>VisualComponents</code> communicate with other components through the use of actions.  These 
	 * actions decouple <code>VisualComponents</code> from the rest of the application.  
	 * 
	 * @see fluorescent.component.ComponentManager
	 * @see fluorescent.component.DataComponent
	 * @see fluorescent.component.Controller
	 * @see fluorescent.action.IAction
	 * @author henry
	 */
	public class VisualComponent extends Sprite implements IComponent {
		protected var _id : String;
		
		/**
		 * @inheritDoc
		 */
		public function set id($id : String) : void {
			_id = $id;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get id() : String { return _id; }
		
		/**
		 * @inheritDoc
		 */
		public function destroy() : void {
			if(this.parent) this.parent.removeChild(this);
		}
	}
}
