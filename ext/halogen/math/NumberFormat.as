package halogen.math {

	/**
	 * @author henry
	 */
	public class NumberFormat {
		public static function delimit($numericalValue:*, $delimiter:String=',', $digits:int=3):String {
			var edit:String = String($numericalValue);
			var split:int = edit.length-$digits;
			while(split > 0) {
				edit = edit.substring(0,split)+$delimiter+edit.substring(split);
				split = split-$digits;
			}
			return edit;
		}
		
		public static function placementSuffix($num:int):String {
			var edit:String = $num.toString();
			//if(isNaN($num)) return edit;
			
			var suffix:String = '';
			if(edit.charAt(edit.length-1) == '1' && edit.charAt(edit.length-2) != '1') {
				suffix='st';
				
			} else if(edit.charAt(edit.length-1) == '2' && edit.charAt(edit.length-2) != '1') {
				suffix='nd';
				
			} else if(edit.charAt(edit.length-1) == '3' && edit.charAt(edit.length-2) != '1') {
				suffix='rd';
				
			} else {
				suffix='th';
			}
			return edit+suffix;
		}
	}
}
