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
	import halogen.math.AABB;

	import flash.events.EventDispatcher;

	/**
	 * @author henry
	 */
	public class DiscBody extends EventDispatcher {
		// coordinates
		public var x : Number;
		public var y : Number;
		
		// buckets
		public var i : int;
		public var j : int;
		
		// use as pin
		public var radius : Number;
		
		public function DiscBody($x:Number, $y:Number, $radius:Number) {
			x = $x;
			y = $y;
			radius=$radius;
			i=-1;
			j=-1;
		}
		
		public function get aabb():AABB { return new AABB(x-radius, y-radius, x+radius, y+radius); }
		
		override public function toString():String { return '[DiscBody]'; }
	}
}
