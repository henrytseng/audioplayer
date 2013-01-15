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
package halogen.debug {
	import halogen.debug.window.DebugClient;

	import flash.system.Capabilities;

	/**
	 * <code>Debugger</code> centralizes debugging input and output.  
	 * @author henry
	 */
	public class Debugger {
		public static var DEBUG_STACK : Boolean = true;
		public static var DEBUG_CATEGORIES : int = 0xffffff;
		
		private static var _isEnabled : Boolean = false;
		private static var _outputCount : int = 1;
		private static var _client : DebugClient;
		
		public function Debugger() {
			throw(new Error('Debugger(): cannot be instantiated'));
		}
		
		public static function connectExternal():void {
			_client = new DebugClient();
			_client.setResponseHandler(_onWindowResponse);
			_client.init();
		}
		
		public static function destroyExternal():void {
			if(_client) {
				_client.destroy();
				_client = null;
			}
		}
		
		/**
		 * Response handler for DebugWindow
		 */
		private static function _onWindowResponse(...$params):void {
			
		}
		
		public static function enable($isConnectExternal:Boolean=false):void {
			_isEnabled = true;
			if($isConnectExternal) connectExternal();
			_send('Debugger.enable()');
		}
		
		public static function disable():void {
			_send('Debugger.disable()');
			_isEnabled = false;
			destroyExternal();
		}
		
		/**
		 * Send debugging information
		 * @param $str, Information to send
		 * @param $categorySet, Bitwise filter of information
		 */
		public static function send($str:*='', $categorySet:int=1):void {
			if(_isEnabled) _send($str, $categorySet, DEBUG_STACK);
		}
		
		/**
		 * Internal method used to send debugging information
		 * @param $str, Information to send
		 * @param $categorySet, Bitwise filter of information
		 * @param $useStack, True to prefix class and method debugging information
		 */
		private static function _send($str:*='', $categorySet:int=1, $useStack:Boolean=false):void {
			var out:String=String($str);
			var callStack:Object = null;
			var callLine:String = '';
			
			if($useStack && Capabilities.isDebugger) {
				callStack = DebugStack.parse(2);
				callLine = callStack['line']+' ';
			}
			
			// trace out
			if($categorySet & DEBUG_CATEGORIES) {
				var prefix:String='';
				if($categorySet) prefix=':'+$categorySet.toString();
				trace( '['+_outputCount+prefix+']: '+callLine+out );
			}
			
			// external
			if(_client) {
				_client.send('debug_message', callLine, out, $categorySet, _outputCount);
			}
			
			_outputCount++;
		}
		
		/**
		 * Identify a category label
		 * @param $category, Bitwise category filter, should be a power of 2; not a set
		 * @param $label, A string to associate with the filter
		 */
		public static function identifyCategory($category:int, $label:String):void {
			if(_client) {
				_client.send('debug_category', $category, $label);
			}
		}
	}
}
