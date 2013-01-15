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
package halogen.datastructures.spatial {
	import halogen.math.AABB;

	/**
	 * A data type * will require typecasting and may be slow.
	 * <br><br>
	 * Quadrants are labeled clockwise starting from top-left and ending bottom-left, where y-positive is 
	 * directed upwards and x-positive is directed right.  
	 * <br><br>
	 * If y-positive is considered as downwards, quadrants can be considered as labeled counter-clockwise.      
	 *  
	 * @author henry
	 */
	public class Quadtree {
		internal var _root : QuadNode;
		internal var _size : int;
		protected var _allowDuplicate : Boolean;
		
		/** Boundaries for current node, oriented so that positive is top-right. */
		public var bounds : AABB;
		
		/**
		 * Constructor
		 */
		public function Quadtree($bounds:AABB, $allowDuplicate:Boolean=false) {
			bounds = $bounds;
			_allowDuplicate = $allowDuplicate;
			_root = null;
			_size = 0;
		}
		
		/**
		 * Insert a node according to key value
		 * @param $key, A key determining the placement of the node
		 * @param $data, A data entity to place within the node
		 * @return True if data correctly inserted, false if unable to insert node
		 */
		public function insert($key:QuadKey, $data:*):QuadNode {
			// outside bounds
			if(!bounds.checkInclusive($key.x, $key.y)) return null;  
			
			// perform insert
			var parentNode:QuadNode;
			var createdNode:QuadNode = null;
			if(_root == null) {
				createdNode = _root = new QuadNode($key, $data, bounds.clone());
				
			} else {
				parentNode = _root;
				var i:int;
				var j:int;
				while(parentNode) {
					i = parentNode.key.compareX($key);
					j = parentNode.key.compareY($key);
					
					// q1
					if(i<=0 && j>=0 && !(i==0 && j==0)) {
						if(parentNode.q1==null) {
							createdNode = parentNode.insertTopLeft($key, $data);
							break;
						} else {
							parentNode = parentNode.q1;
							continue;
						}
						
					// q2
					} else if(i>0 && j>=0) {
						if(parentNode.q2==null) {
							createdNode = parentNode.insertTopRight($key, $data);
							break;
						} else {
							parentNode = parentNode.q2;
							continue;
						}
						
					// q3
					} else if(i>0 && j<0) {
						if(parentNode.q3==null) {
							createdNode = parentNode.insertBottomRight($key, $data);
							break;
						} else {
							parentNode = parentNode.q3;
							continue;
						}
						
					// q4
					} else if(i<=0 && j<0) {
						if(parentNode.q4==null) {
							createdNode = parentNode.insertBottomLeft($key, $data);
							break;
						} else {
							parentNode = parentNode.q4;
							continue;
						}
						
					// same point
					} else if(i==0 && j==0) {
						// replace existing
						if(!_allowDuplicate) {
							createdNode = parentNode;
							createdNode.key = $key;
							createdNode.data = $data;
							createdNode.resetBoundaries();
							break;
							
						// insert duplicate on top-left
						} else {
							if(parentNode.q1==null) {
								createdNode = parentNode.insertTopLeft($key, $data);
								break;
							} else {
								parentNode = parentNode.q1;
								continue;
							}
						}
					}
				}
			}
			_size++;
			
			return createdNode;
		}

		/**
		 * Remove a node based on a key
		 * @param $key
		 */
		public function remove($key:QuadKey):* {
			var data:* = null;
			var node:QuadNode = _getNode($key);
			if(node) {
				_disconnectNode(node);
				_size--;
				
				// reinsert children
				if(node.q1) _reinsertNode(node.q1);
				if(node.q2) _reinsertNode(node.q2);
				if(node.q3) _reinsertNode(node.q3);
				if(node.q4) _reinsertNode(node.q4);
				
				node.destroy();
			}
			return data;
		}
		
		/**
		 * Disconnect node from parent only
		 * @param $node, Node to disconnect from its parent
		 */
		private function _disconnectNode($node:QuadNode):QuadNode {
			if($node.parent) {
				if($node.isTopLeft()) {
					$node.parent.q1 = null;
					$node.parent = null;
					
				} else if($node.isTopRight()) {
					$node.parent.q2 = null;
					$node.parent = null;
					
				} else if($node.isBottomRight()) {
					$node.parent.q3 = null;
					$node.parent = null;
					
				} else if($node.isBottomLeft()) {
					$node.parent.q4 = null;
					$node.parent = null;
				}
			}
			return $node;
		}
		
		/**
		 * Reinsert recursively
		 * @param $node, Node to reinsert
		 */
		private function _reinsertNode($node:QuadNode):void {
			if($node.q1) _reinsertNode($node.q1);
			if($node.q2) _reinsertNode($node.q2); 
			if($node.q3) _reinsertNode($node.q3);
			if($node.q4) _reinsertNode($node.q4);
			
			_disconnectNode($node);
			insert($node.key, $node.data);
			
			$node.destroy();
		}
		
		/**
		 * Quads that intersect are traversed, with each sub-Quad tested for intersection.
		 */
		public function query($bounds:AABB):void {
			
		}
		
		/**
		 * Find set of nearest neighbors
		 */
		public function nearestNeighbor():void {
			// return result set sorted by increasing distance
		}
		
		/**
		 * Clear tree
		 */
		public function clear():void {
			if(_root) {
				_root.destroy();
				_root = null;
			}
			_size = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function contains($data:*):Boolean {
			return _getData(_root, $data)!=null;
		}
		
		/**
		 * Search all sub nodes for data containing
		 * @param $node
		 * @return
		 */
		internal function _getData($node:QuadNode, $data:*):QuadNode {
			if(!$node) return null;
			else if($node.data === $data) return $node;
			else return _getData($node.q1, $data) || _getData($node.q2, $data) ||  _getData($node.q3, $data) || _getData($node.q4, $data);
		}
		
		/**
		 * Search for node with corresponding key
		 * @param $key
		 * @return
		 */
		public function find($key:QuadKey):* {
			var node:QuadNode = _getNode($key);
			return (node) ? node.data : null;
		}
		
		/**
		 * Traverse through tree and locate a specific key starting from a specific node
		 * @param $key
		 * @param $start
		 * @return
		 */
		internal function _getNode($key:QuadKey, $start:QuadNode=null):QuadNode {
			var node:QuadNode = ($start) ? $start : _root;
	        while(node) {
	            var i:int = node.key.compareX($key);
	            var j:int = node.key.compareY($key);
	            
	            // q1
            	if(i<=0 && j>=0 && !(i==0 && j==0)) {
					node = node.q1;
					
				// q2
				} else if(i>0 && j>=0) {
					node = node.q2;
					
				// q3
				} else if(i>0 && j<0) {
					node = node.q3;
					
				// q4
				} else if(i<=0 && j<0) {
					node = node.q4;
					
				// same point
				} else if(i==0 && j==0) {
					return node;
            	}
			}
	        return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get size():int { return _size; }
		
		/**
		 * @inheritDoc
		 */
		public function toString():String { return '[Quadtree]'; }
		
		/**
		 * @inheritDoc
		 */
		public function destroy():void {
			if(_root) {
				_root.destroy();
				_root = null;
			}
		}
	}
}
