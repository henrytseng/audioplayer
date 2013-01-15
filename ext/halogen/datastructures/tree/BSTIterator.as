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
	import halogen.datastructures.IIterator;

	/**
	 * Traverse tree using an in-order searching algorithm
	 * @author henry
	 */
	public class BSTIterator implements IIterator {
		protected var _tree : BinarySearchTree;
		protected var _stack : Vector.<BSTNode>;
		
		public function BSTIterator($tree:BinarySearchTree) {
			_tree = $tree;
			_stack = new Vector.<BSTNode>();
			_pushLeft(_tree._root);
		}
		
		/**
		 * Returns <code>true</code> if the iteration has more elements.
		 * @return <code>true</code> if next node is available
		 */
		public function hasNext():Boolean {
			return _stack.length!=0;
		}
		
		/**
		 * Move iterator to next item and retrieve data item.  Next item begins at list head at start.  
		 * @return Returns the next data in the collection.  
		 */
		public function next():* {
			if(!hasNext()) return null; 
			var n:BSTNode = _stack.pop();
			_pushLeft(n.right);
			return n._data;
		}
		
		protected function _pushLeft($node:BSTNode):void {
			while($node) {
				_stack.push($node);
				$node=$node.left;
			}
		}
		
		/**
		 * Removes the current node and moves the cursor to the next node
		 */
		public function remove():void {
			if(hasNext()) {
				var n:BSTNode = _stack.pop();
				_pushLeft(n.right);
				_tree.remove(n._key);
			}
		}
		
		public function get key():BSTKey { return _stack[_stack.length-1]._key; }
		
		/**
		 * Set data at current node.  
		 * @param $data data to set
		 */
		public function set data($data:*):void {
			_stack[_stack.length-1]._data=$data;
		}
		
		/**
		 * Get data at current node.  
		 * @return data on current node
		 */
		public function get data():* {
			return _stack[_stack.length-1]._data;
		}
		
		public function toString():String { return '[BSTIterator]'; }
		
		public function destroy():void {
			_tree = null;
			_stack = null;
		}
	}
}
