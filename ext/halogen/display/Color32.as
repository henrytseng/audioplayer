package halogen.display {

	/**
	 * <code>Color32</code> is a 32-bit color representing 4 channels, alpha, red, green, and blue.  
	 * <br><br>
	 * 
	 * @author henry
	 */
	public class Color32 {
		/** Value of color */
		internal var _value : uint;
		
		/** Number representing alpha component, 0..1 */
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
		public function Color32($value:uint=0x0):void {
			_value = $value;
			updateComponents();
		}
		
		/**
		 * Set value
		 * @param $value, Unsigned integer value representing alpha, red, green, and blue color components.  
		 */
		public function setValue($value:uint):void {
			_value = $value;
			updateComponents();
		}
		
		/**
		 * Update color <code>_value</code> according to components
		 */
		public function updateValue():void {
			_value = (((((this.alphaValue<<8)+this.redValue)<<8)+this.greenValue)<<8)+this.blueValue;
		}
		
		/**
		 * Update color components according to <code>_value</code>
		 */
		public function updateComponents():void {
			alpha = (_value >>> 24)/0xff;
			red = ((_value >>> 16)%0x100)/0xff;
			green = ((_value >>> 8)%0x100)/0xff;
			blue = (_value%0x100)/0xff;
		}
		
		/**
		 * Retrive alpha value, 0xff000000
		 */
		public function get alphaValue():int { return alpha*0xff; }
		
		/**
		 * Retrive red value, 0x00ff0000
		 */
		public function get redValue():int { return red*0xff; }
		
		/**
		 * Retrive green value, 0x0000ff00
		 */
		public function get greenValue():int { return green*0xff; }
		
		/**
		 * Retrive blue value, 0x000000ff
		 */
		public function get blueValue():int { return blue*0xff; }
		
		/**
		 * Clone color object
		 */
		public function clone():Color32 { return new Color32(_value); }
		
		/**
		 * Retrieve numerical value of color
		 */
		public function valueOf():uint { return _value; }
		
		/**
		 * Retrieve 24-bit color <code>Color24</code> object
		 */
		public function toColor24():Color24 { return new Color24(_value%0x1000000); }
		
		/**
		 * Retrieve color value as a String in representation in hex format
		 */
		public function toString():String { return '0x'+_value.toString(16); }
	}
}
