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
	import halogen.datastructures.linked.DoublyLinkedList;
	import halogen.math.AABB;

	import flash.events.EventDispatcher;
	import flash.geom.Point;

	/**
	 * Divides world into grid and computes distance based collision.  
	 * @author henry
	 */
	public class DiscWorld extends EventDispatcher {
		internal var _bounds : AABB;
		internal var _span : Number;
		internal var _grid : DiscGrid;
		internal var _collision : DiscCollision;
		
		public function DiscWorld($bounds:AABB, $span:Number=20) {
			_bounds = $bounds.clone();
			_span = $span;
			_grid=new DiscGrid(this);
			_collision = new DiscCollision(this);
		}
		
		public function get span():Number { return _span; }
		
		public function get minX():Number { return _bounds.minX; }
		
		public function get minY():Number { return _bounds.minY; }
		
		public function get maxX():Number { return _bounds.maxX; }
		
		public function get maxY():Number { return _bounds.maxY; }
		
		public function createBody($x:Number, $y:Number, $radius:Number):DiscBody {
			var bd:DiscBody = new DiscBody($x, $y, $radius);
			_grid.initiate(bd);
			return bd;
		}
		
		public function update():void {
			_grid.update();
			_collision.clear();
		}
		
		public function check($body:DiscBody):DoublyLinkedList {
			return _collision.check($body);
		}
		
		public function convertPoint($p:Point):Point {
			return new Point(_grid.getI($p.x), _grid.getJ($p.y));
		}
		
		public function destroy():void {
			_grid.destroy();
			_collision.destroy();
		}
		
	}
}
