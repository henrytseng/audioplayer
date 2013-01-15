package halogen.math {

	/**
	 * @author henry
	 */
	public class Numerical {
		/**
		 * Calculate least common multiple using gcd
		 * @param $a
		 * @param $b
		 */
		public static function lcm($a:int, $b:int):int {
			return $a*$b/gcd($a,$b);
		}
		
		/**
		 * Find greatest common denominator using Bishop's method
		 * @param $a
		 * @param $b
		 */
		public static function gcd($a:int, $b:int):int {
			var small:int;
			var large:int;
			if($a>$b) {
				large = $a;
				small = $b;
			} else {
				large = $b;
				small = $a;
			}
			
			while(small!=large) {
				if(large>small) large-=small;
				else {
					var temp:int = small;
					small = large;
					large = temp;
				}
			}
			return small;
		}
		
		public static function toRadians($angleDegrees:Number):Number { return $angleDegrees * Math.PI/180; }
		
		public static function toDegrees($angleRadians:Number):Number { return $angleRadians * 180/Math.PI; }
		
		/**
		 * Pick a random number from the exclusive set of numbers specified
		 */
		public static function randomNumber($low:Number=-1, $high:Number=1):Number {
			return $low + Math.random()*($high-$low);
		}
		
		/**
		 * Pick a random integer from the inclusive set of integers specified
		 */
		public static function randomInteger($low:int=-1, $high:int=1):int {
			return $low + Math.floor(Math.random()*($high-$low+1));
		}
		
		/**
		 * Return a numerical hex value based on a string
		 * @param $hex, A string based hex value, may include a '#' instead of a '0x' 
		 */
		public static function validateHexString($hex:String):int {
			var result:String = $hex.replace('#', '0x');
			if(result.indexOf('0x')==-1) {
				var negIndex:int = result.indexOf('-');
				result = result.substring(0,negIndex+1)+'0x'+result.substring(negIndex+1,result.length);
			}
			return Number(result);
		}
		
	}
}
