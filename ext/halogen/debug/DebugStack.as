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

	/**
	 * Retrieves the package, class, and method name of a stack trace by throwing an Error.  
	 * 
	 * @author henry
	 */
	public class DebugStack {
		public static var LINE_REGEXP:RegExp = /(?<=at\s)[\d\w\.\/:]+\(\)/i;
		public static var PACKAGE_REGEXP:RegExp = /(?<=at\s)[\d\w\.]+(?=::)/i;
		public static var CLASS_REGEXP:RegExp = /((?<=::)[\d\w]+)(?=::|\(\))|((?<=::)[\d\w]+)(?=\/|\(\))|((?<=at\s)[\d\w]+)(?=\/|\(\))/i;
		public static var METHOD_REGEXP:RegExp = /[\d\w]+(?=\(\))/i;
		
		/**
		 * Retrieves the calling package, class, and method by parsing an error stack.    
		 * @param $level zero-based index for error stack (calling method is level 0)
		 */
		public static function parse($level:int=0):Object {
			var obj:Object = {};
			obj['package']='';
			obj['class']='';
			obj['method']='';
			obj['line']='';
			
			try {
				throw(new Error());
				
			} catch($err:Error) {
				var stackTrace:Array = $err.getStackTrace().split('\n');
				if(stackTrace.length >= 4) {
					var line:String = String(stackTrace[$level+2]);
					var stack:Array = line.match(LINE_REGEXP);
					var p:Array = line.match(PACKAGE_REGEXP);
					var c:Array = line.match(CLASS_REGEXP);
					var m:Array = line.match(METHOD_REGEXP);
					obj['package'] = (p==null) ? '' : p[0];
					obj['class'] = (c==null) ? '' : c[0];
					obj['method'] = (m==null) ? '' : m[0];
					obj['line']=(stack==null) ? '' : stack[0];
				}
			}
			return obj;
		}
		
	}
}
