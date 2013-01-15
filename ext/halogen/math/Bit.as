package halogen.math {

	/**
	 * @author henry
	 */
	public class Bit {
		public static function on($num:int, $bitValue:int):int {
			return $num | $bitValue;
		}
		
		public static function off($num:int, $bitValue:int):int {
			return $num & (0xffffffff)-uint($bitValue);
		}
		
		public static function check($num:int, $bitValue:int):Boolean {
			return ($num & $bitValue) == $bitValue;
		}
	}
}
