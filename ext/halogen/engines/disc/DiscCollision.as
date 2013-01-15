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
package halogen.engines.disc {
	import halogen.datastructures.IIterator;
	import halogen.datastructures.linked.DoublyLinkedList;
	import halogen.math.AABB;

	import flash.utils.Dictionary;

	/**
	 * @author henry
	 */
	public class DiscCollision {
		protected var _world : DiscWorld;
		protected var _cache : Dictionary;
		
		public function DiscCollision($world:DiscWorld) {
			_world=$world;
			clear();
		}
		
		/**
		 * Clears cached collisions
		 */
		public function clear():void {
			_cache = new Dictionary(true);
		}
		
		/**
		 * Calculates overlapping discs based on current world coordinates.  Results
		 * are cached until <code>clear()</code> is called.  
		 * @param $body
		 * @return
		 */
		public function check($body:DiscBody):DoublyLinkedList {
			// use cache
			if(_cache[$body]) {
				return _cache[$body];
			
			// calculate
			} else {
				var first:DiscBody = _world._grid._radiusList.iterator.data;
				var largestRadii:Number = first.radius;
				
				// create bounding box
				var aabb:AABB = new AABB(_world._grid.getI($body.x-largestRadii), _world._grid.getJ($body.y-largestRadii),
				                         _world._grid.getI($body.x+largestRadii), _world._grid.getJ($body.y+largestRadii));
				
				// collect all local
				var list:DoublyLinkedList = new DoublyLinkedList();
				for(var i:int=aabb.minX; i<=aabb.maxX; i++) {
					for(var j:int=aabb.minY; j<=aabb.maxY; j++) {
						var sector:DoublyLinkedList = _world._grid._getBox(i, j);
						for(var n:IIterator=sector.iterator; n.hasNext();) {
							var other:DiscBody=n.next();
							if(other==$body) continue;
							var r0:Number = other.radius + $body.radius;
							var x0:Number = other.x-$body.x;
							var y0:Number = other.y-$body.y;
							if((r0*r0) >= (x0*x0)+(y0*y0)) list.add(other);
						}
					}
				}
				_cache[$body] = list;
				return list;
			}
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void {
			_world = null;
			_cache=null;
		}
	}
}
