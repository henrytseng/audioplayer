package fluorescent.text {
	import flash.text.Font;

	/**
	 * A proxy class to manage the registration of fonts.  
	 * @author henry
	 */
	public class FontRegistry {
		private static var _fontList : Array; 
		
		/**
		 * Register a font with Flash
		 * @param $font, A reference to the class definition of the font
		 */
		public static function registerFont($font:Class):void {
			if(!_isFontRegistered($font)) {
				Font.registerFont($font);
			}
		}
		
		/**
		 * Internal method to check whether or not a font name, style and type exists
		 * @param $font, A reference to the class definition of the font
		 * @return True if font is already registered with Flash
		 */
		private static function _isFontRegistered($font:Class):Boolean {
			_fontList = Font.enumerateFonts(false);
			var font:Font = new $font() as Font;
			if(font!=null) {
				for(var i:int=0; i<_fontList.length; i++) {
					if((_fontList[i] as Font).fontName == font.fontName && (_fontList[i] as Font).fontStyle == font.fontStyle && (_fontList[i] as Font).fontType == font.fontType) return true;
				}
			}
			return false;
		}
		
		/**
		 * Return an array of font names.  
		 * @return An array of font names registered with Flash not including device fonts.  
		 */
		public static function getFontNameList($enumerateDeviceFonts:Boolean=false):Array {
			_fontList = Font.enumerateFonts($enumerateDeviceFonts);
			var nameList:Array = [];
			for(var i:int=0; i<_fontList.length; i++) {
				nameList.push((_fontList[i] as Font).fontName);
			}
			return nameList;
		}
	}
}
