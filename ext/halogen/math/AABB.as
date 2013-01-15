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
package halogen.math {

	/**
	 * Axis Aligned Bounding Box (AABB) represented through min and max values.  
	 * @author henry
	 */
	public class AABB {
		public var minX : Number;
		public var minY : Number;
		public var maxX : Number;
		public var maxY : Number;
		
		public function AABB($minX : Number=Number.MIN_VALUE, $minY : Number=Number.MIN_VALUE, $maxX : Number=Number.MAX_VALUE, $maxY : Number=Number.MAX_VALUE) {
			minX = $minX;
			minY = $minY;
			maxX = $maxX;
			maxY = $maxY;
		}
		
		/**
		 * Perform an inclusive check
		 */
		public function checkInclusive($x:Number, $y:Number):Boolean {
			return $x>=minX && $x<=maxX && $y>=minY && $y<=maxY;
		}
		
		/**
		 * Perform an exclusive check
		 */
		public function checkExclusive($x:Number, $y:Number):Boolean {
			return $x>minX && $x<maxX && $y>minY && $y<maxY;
		}
		
		/**
		 * Checks whether or not another AABB is inclusively contained within current
		 */
		public function containsInclusive($bounds:AABB):Boolean {
			return minX<=$bounds.minX && maxX>=$bounds.maxX && minY<=$bounds.minY && maxY>=$bounds.maxY;
		}
		
		/**
		 * Checks whether or not another AABB is exclusively contained within current
		 */
		public function containsExclusive($bounds:AABB):Boolean {
			return minX<$bounds.minX && maxX>$bounds.maxX && minY<$bounds.minY && maxY>$bounds.maxY;
		}
		
		public function clone() : AABB { return new AABB(minX, minY, maxX, maxY); }
		
		public function toString() : String { return '[AABB minX='+minX+' minY='+minY+' maxX='+maxX+' maxY='+maxY+']'; }
	}
}
