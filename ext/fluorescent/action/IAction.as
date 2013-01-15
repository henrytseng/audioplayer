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
	 * Command pattern based constructs used for execution of complex tasks.  Meant to
	 * be used in a fire-and-forget scheme.  By default actions should only be used once.  
	 * <br><br>
	 * Uses inversion of control to set up parameters for execution.  
	 * @author henry
	 */
	public interface IAction extends IEventDispatcher {
		/**
		 * Set a parameter.  Make sure not to orphan parameter values after the action executes.  
		 * @param $name
		 * @param $value
		 */
		function registerParam($name:String, $value:*):void;
		
		/**
		 * Execute instructions.  Should call _onComplete after finished.  
		 */
		function execute():void;
		
		/**
		 * Destroy
		 */
		function destroy():void;
	}
}
