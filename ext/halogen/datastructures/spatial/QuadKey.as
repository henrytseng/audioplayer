package halogen.datastructures.spatial {

	/**
	 * A key allows items in a Quadtree to be ordered.  QuadKey is a default key type sorting data by x,y coordinates.  
	 * 
	 * @author henry
	 */
	public class QuadKey {
		public var x : Number;
		public var y : Number;
		
		/**
		 * Constructor
		 */
		public function QuadKey($x:Number, $y:Number) {
			x = $x;
			y = $y;
		}
		
		/**
		 * Compare along x-axis keys and returns integer value.    
		 * @param $insert
		 * @return -1 if current key lies left of $other, 1 if current key lies right of $other, and 0 if 
		 * current $key has the same x value as $other.
		 */
		public function compareX($other:QuadKey):int {
			if(x > $other.x) return -1;
			else if(x < $other.x) return 1;
			else return 0;
		}
		
		/**
		 * Compare along y-axis keys and returns integer value.    
		 * @param $insert
		 * @return -1 if current key lies above $other, 1 if current key lies below $other, and 0 if 
		 * current $key has the same y value as $other.
		 */
		public function compareY($other:QuadKey):int {
			if(y > $other.y) return -1;
			else if(y < $other.y) return 1;
			else return 0;
		}
		
		public function toString():String { return '[QuadKey '+x+', '+y+']'; }
		
		/**
		 * Retrieve an exact copy
		 */
		public function clone():QuadKey {
			return new QuadKey(x, y);
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void { }
	}
}
