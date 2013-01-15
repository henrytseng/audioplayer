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
package halogen.datastructures.tree {

	/**
	 * A key allows items in a BST to be ordered.  BSTKey is a default key type sorting data by Numbers.  
	 * 
	 * @author henry
	 */
	public class BSTKey {
		public var value : Number;
		
		public function BSTKey($value:*) {
			value = Number($value);
		}
		
		/**
		 * Compare keys and returns integer value.  -1 for other key value smaller, 1 for 
		 * @param $insert
		 * @return 
		 */
		public function compare($other:BSTKey):int {
			if($other.value < value) return -1;
			else if($other.value > value) return 1;
			else return 0;
		}
		
		public function toString():String { return '[BSTKey '+value+']'; }
		
		/**
		 * Retrieve an exact copy
		 */
		public function clone():BSTKey {
			return new BSTKey(value);
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void { }
	}
}
