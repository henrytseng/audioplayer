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
package halogen.debug.utils {
	import flash.utils.getQualifiedClassName;

	/**
	 * @author henry
	 */
	public class DebugObject {
		/**
		 * Enumerate an Object
		 * @param $object, An object to enumerate
		 * @param $params, A hash table of parameters to utilize.  
		 */
		public static function enumerate($object:*, $params:Object=null):String {
			var prefix:String = '{';
			var suffix:String = '}';
			var comma:String = ',';
			var endLine:String = '\n';
			var colon:String = ':';
			var tab:String = '\t';
			var quote:String = '"';
			var level:int = 0;
			if($params!=null) {
				prefix=$params.hasOwnProperty('prefix') ? $params['prefix'] : prefix;
				suffix=$params.hasOwnProperty('suffix') ? $params['suffix'] : suffix;
				comma=$params.hasOwnProperty('comma') ? $params['comma'] : comma;
				endLine=$params.hasOwnProperty('endLine') ? $params['endLine'] : endLine;
				colon=$params.hasOwnProperty('colon') ? $params['colon'] : colon;
				tab=$params.hasOwnProperty('tab') ? $params['tab'] : tab;
				quote=$params.hasOwnProperty('quote') ? $params['quote'] : quote;
				level=$params.hasOwnProperty('level') ? $params['level'] : level;
			}
			
			// tab depth
			var tabDepth:String='';
			for(var t:int=0; t<level+1; t++) {
				tabDepth+=tab;
			}
			
			// create results
			var result:String='';
			if($object!=null) {
				var resultList:Array = [];
				for(var p:String in $object) {
					if(getQualifiedClassName($object[p]) == 'Object') {
						var param:Object = {prefix:prefix, suffix:suffix, comma:comma, endLine:endLine, colon:colon, tab:tab, quote:quote, level:level+1};
						resultList.push(tabDepth+p+colon+enumerate($object[p], param));
						
					} else if($object[p] is String) {
						resultList.push(tabDepth+p+colon+quote+$object[p]+quote);
						
					} else {
						resultList.push(tabDepth+p+colon+String($object[p]));
					}
				}
				
				// tabulate
				for(var i:int=0; i<resultList.length; i++) {
					result+=resultList[i] + ((i==resultList.length-1) ? endLine : comma+endLine);
				}
				return prefix+endLine+result+tabDepth+suffix;
				
			} else {
				return $object;
			}
		}
	}
}
