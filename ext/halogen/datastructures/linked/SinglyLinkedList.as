/** * Copyright (c) 2010 Henry Tseng (http://www.henrytseng.com) *  * Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions: *  * The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE. */package halogen.datastructures.linked {	import halogen.datastructures.ICollection;	import halogen.datastructures.IIterator;	/**	 * A singly linked list.  	 *  	 * @author henry	 */	public class SinglyLinkedList implements ICollection {		internal var _head : SinglyNode;		internal var _tail : SinglyNode;		protected var _size : int;				/**		 * Constructor		 */		public function SinglyLinkedList() {			_size=0;		}				/**		 * Add data to collection		 * @param $data item to add to collection		 */		public function add($data:*):void {			var node:SinglyNode = new SinglyNode($data);			_size++;						// first one			if(_head==null && _tail==null) {				_head=_tail=node;							// additional			} else {				_tail._insertAfter(node);				_tail=node;			}		}				/**		 * Appends all the data to this collection to tail		 * @param $collection collection to recieve items		 */		public function addAll($collection:ICollection):void {			var iterator:IIterator = $collection.iterator;			while(iterator.hasNext()) {				add(iterator.next());			}		}				/**		 * Removes instance of data from beginning of collection		 * @param $data item to remove from collection		 */		public function remove($data:*):void {			// nothing there			if(_head==null) return; 						var last:SinglyNode=null;			for(var n:SinglyNode=_head; n!=null; n=n._next) {				if(n._data==$data) {					if(last!=null) last._next = n._next;					if(_head==n) _head=n._next;					if(_tail==n) _tail=last;					_size--;					return;				}				last=n;			}		}				/**		 * Removes all the data present in collection from this		 */		public function removeAll($collection:ICollection):void {			// nothing there			if(_head==null) return;						var iterator:IIterator = $collection.iterator;			while(iterator.hasNext()) {				remove(iterator.next());			}		}				/**		 * Removes all data from collection		 */		public function clear():void {			// nothing there			if(_head==null) return; 						var n:SinglyNode=_head;			while(n!=null) {				var t:SinglyNode=n;				n=n._next;				t.destroy();			}			_head=_tail=null;			_size=0;		}				/**		 * Returns <code>true</code> if collection contains data  		 * @return <code>true</code> if collection contains data  		 */		public function contains($data:*):Boolean {			// nothing there			if(_head==null) return false; 						for(var n:SinglyNode=_head; n!=null; n=n._next) {				if(n._data==$data) return true;			}						// nothing found			return false;		}				/**		 * Gets an iterator to this collection		 * @return Create a new instance of an <code>IIterator</code>		 */		public function get iterator():IIterator {			return new SinglyIterator(this);		}				/**		 * Gets the number of items in collection		 * @return Number of items in collection, otherwise -1 if no items in collection		 */		public function get size():int { return _size; }				/**		 * Gets a shallow duplicate of current list		 * @return A shallow duplicate of current list		 */		public function clone():SinglyLinkedList {			var list:SinglyLinkedList = new SinglyLinkedList();			var iterator:IIterator = this.iterator;			while(iterator.hasNext()) {				list.add(iterator.next());			}			return list;		}				/**		 * Returns an array containing all data		 * @return Array containing all data		 */		public function toArray():Array {			var list:Array = [];			var iterator:IIterator = this.iterator;			while(iterator.hasNext()) {				list.push(iterator.next());			}			return list;		}				/**		 * Returns a string representation of data		 */		public function toString():String {			var list:Array = toArray();			var str:String='';			if(list.length) str += ' '+list.toString();			return '[SinglyList'+str+']';		}				/**		 * Destroy		 */		public function destroy():void {			clear();		}	}}