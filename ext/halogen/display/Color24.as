package halogen.display {

	/**
	 * <code>Color24</code> is a 24-bit color representing 3 channels, red, green, and blue.  
	 * <br><br>
	 * 
	 * @author henry
	 */
	public class Color24 {
		/** Value of color */
		internal var _value : int;
		
		/** Number representing alpha component, 0..1.  Alpha value is not represented in color value. */
		public var alpha : Number;
		
		/** Number representing red component, 0..1 */
		public var red : Number;
		
		/** Number representing green component, 0..1 */
		public var green : Number;
		
		/** Number representing blue component, 0..1 */
		public var blue : Number;
		
		/**
		 * Constructor
		 */
		public function Color24($value :int=0x0):void {
			_value = $value;
			updateComponents();
		}
		
		/**
		 * Set value
		 * @param $value, Unsigned integer value representing alpha, red, green, and blue color components.  
		 */
		public function setValue($value:int):void {
			_value = $value;
			updateComponents();
		}
		
		/**
		 * Update color <code>_value</code> according to components
		 */
		public function updateValue():void {
			_value = ((((this.redValue)<<8)+this.greenValue)<<8)+this.blueValue;
		}
		
		/**
		 * Update color components according to <code>_value</code>
		 */
		public function updateComponents():void {
			red = ((_value >>> 16)%0x100)/0xff;
			green = ((_value >>> 8)%0x100)/0xff;
			blue = (_value%0x100)/0xff;
		}
		
		/**
		 * Retrive red value, 0xff0000
		 */
		public function get redValue():int { return red*0xff; }
		
		/**
		 * Retrive green value, 0x00ff00
		 */
		public function get greenValue():int { return green*0xff; }
		
		/**
		 * Retrive blue value, 0x0000ff
		 */
		public function get blueValue():int { return blue*0xff; }
		
		/**
		 * Clone color object
		 */
		public function clone():Color24 { return new Color24(_value); }
		
		/**
		 * Retrieve numerical value of color
		 */
		public function valueOf():int { return _value; }
		
		/**
		 * Retrieve 32-bit color <code>Color32</code> object
		 * @param $alpha, Alpha value to use, default is 0xff (opaque)
		 */
		public function toColor32($alpha:int=0xff):Color32 { return new Color32(($alpha<<24)+_value); }
		
		/**
		 * Retrieve color value as a String in representation in hex format
		 */
		public function toString():String { return '0x'+_value.toString(16); }
	}
}
