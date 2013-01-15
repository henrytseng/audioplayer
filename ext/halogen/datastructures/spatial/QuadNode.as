package halogen.datastructures.spatial {
	import halogen.math.AABB;

	/**
	 * An array of nodes containing branches of each of the 4 quadrants.  Boundaries are oriented for a Cartiesian coordinate system.  
	 * 
	 * @author henry
	 */
	public class QuadNode {
		/** Key for data. */
		public var key : QuadKey;
		
		/** Data object contained in node. */
		public var data : *;
		
		/** Top-left quadrant */
		public var q1 : QuadNode;
		
		/** Top-right quadrant */
		public var q2 : QuadNode;
		
		/** Bottom-right quadrant */
		public var q3 : QuadNode;
		
		/** Bottom-left quadrant */
		public var q4 : QuadNode;
		
		/** Parent node */
		public var parent : QuadNode;
		
		/** Boundaries for current node, oriented so that positive is top-right. */
		public var bounds : AABB;
		
		public function QuadNode($key:QuadKey, $data:*, $bounds:AABB) {
			key = $key;
			data = $data;
			bounds = $bounds;
		}
		
		public function get x():Number { return key.x; }
		
		public function get y():Number { return key.y; }
		
		/**
		 * Calculates levels of depth from this node.
		 */
		public function getDepth():int {
			var q1Depth:int = 0;
			var q2Depth:int = 0;
			var q3Depth:int = 0;
			var q4Depth:int = 0;
			if(q1) q1Depth = q1.getDepth();
			if(q2) q2Depth = q2.getDepth();
			if(q3) q3Depth = q3.getDepth();
			if(q4) q4Depth = q4.getDepth();
			
			var depth:int = Math.max(q1Depth, q2Depth, q3Depth, q4Depth);
			return depth+1;
		}
		
		/**
		 * Calculates size of tree from this node
		 */
		public function getSize():int {
			var q1Depth:int = 0;
			var q2Depth:int = 0;
			var q3Depth:int = 0;
			var q4Depth:int = 0;
			if(q1) q1Depth = q1.getDepth();
			if(q2) q2Depth = q2.getDepth();
			if(q3) q3Depth = q3.getDepth();
			if(q4) q4Depth = q4.getDepth();
			
			var depth:int = q1Depth+q2Depth+q3Depth+q4Depth;
			return depth+1;
		}
		
		/**
		 * Reset boundaries according to parent node parameters
		 */
		public function resetBoundaries():void {
			if(parent==null) return; 
			
			if(isTopLeft()) {
				bounds.minX = parent.bounds.minX;
				bounds.minY = parent.key.y;
				bounds.maxX = parent.key.x;
				bounds.maxY = parent.bounds.maxY;
				
			} else if(isTopRight()) {
				bounds.minX = parent.key.x;
				bounds.minY = parent.key.y;
				bounds.maxX = parent.bounds.maxX;
				bounds.maxY = parent.bounds.maxY;
				
			} else if(isBottomRight()) {
				bounds.minX = parent.key.x;
				bounds.minY = parent.bounds.minY;
				bounds.maxX = parent.bounds.maxX;
				bounds.maxY = parent.key.y;
				
			} else if(isBottomLeft()) {
				bounds.minX = parent.bounds.minX;
				bounds.minY = parent.bounds.minY;
				bounds.maxX = parent.key.x;
				bounds.maxY = parent.key.y;
			}
		}
		
		/**
		 * Sets data in node on top-left or creates new node
		 * @param $key
		 * @param $data
		 * @return
		 */
		public function insertTopLeft($key:QuadKey, $data:*):QuadNode {
			if(q1) {
				q1.data = $data;
				q1.resetBoundaries();
				
			} else {
				q1 = new QuadNode($key, $data, new AABB());
				q1.parent = this;
				q1.resetBoundaries();
			}
			return q1;
		}
		
		/**
		 * Sets data in node on top-right or creates new node
		 * @param $key
		 * @param $data
		 * @return
		 */
		public function insertTopRight($key:QuadKey, $data:*):QuadNode {
			if(q2) {
				q2.data = $data;
				q2.resetBoundaries();
				
			} else {
				q2 = new QuadNode($key, $data, new AABB());
				q2.parent = this;
				q2.resetBoundaries();
			}
			return q2;
		}
		
		/**
		 * Sets data in node on bottom-right or creates new node
		 * @param $key
		 * @param $data
		 * @return
		 */
		public function insertBottomRight($key:QuadKey, $data:*):QuadNode {
			if(q3) {
				q3.data = $data;
				q3.resetBoundaries();
				
			} else {
				q3 = new QuadNode($key, $data, new AABB());
				q3.parent = this;
				q3.resetBoundaries();
			}
			return q3;
		}
		
		/**
		 * Sets data in node on bottom-left or creates new node
		 * @param $key
		 * @param $data
		 * @return
		 */
		public function insertBottomLeft($key:QuadKey, $data:*):QuadNode {
			if(q4) {
				q4.data = $data;
				q4.resetBoundaries();
				
			} else {
				q4 = new QuadNode($key, $data, new AABB());
				q4.parent = this;
				q4.resetBoundaries();
			}
			return q4;
		}
		
		/**
		 * Checks if current node is top-left quadrant of parent
		 */
		public function isTopLeft():Boolean {
			if(!parent) return false;
			return parent.q1==this;
		}
		
		/**
		 * Checks if current node is top-right quadrant of parent
		 */
		public function isTopRight():Boolean {
			if(!parent) return false;
			return parent.q2==this;
		}
		
		/**
		 * Checks if current node is bottom-right quadrant of parent
		 */
		public function isBottomRight():Boolean {
			if(!parent) return false;
			return parent.q3==this;
		}
		
		/**
		 * Checks if current node is bottom-left quadrant of parent
		 */
		public function isBottomLeft():Boolean {
			if(!parent) return false;
			return parent.q4==this;
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void {
			key.destroy();
			key = null;
			data = null;
			if(q1) {
				q1.destroy();
				q1=null; 
			}
			if(q2) {
				q2.destroy();
				q2=null; 
			}
			if(q3) {
				q3.destroy();
				q3=null; 
			}
			if(q4) {
				q4.destroy();
				q4=null; 
			}
			bounds = null;
			parent = null;
		}
	}
}
