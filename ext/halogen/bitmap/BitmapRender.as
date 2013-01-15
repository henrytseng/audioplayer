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
package halogen.bitmap {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author henry
	 */
	public class BitmapRender {

		/**
		 * Create a Bitmap image using a DisplayObject
		 * 
		 * @param $data
		 * @return Bitmap image generated
		 */
		public static function createBitmap($data:DisplayObject, $doTrim:Boolean=false):Bitmap {
			var data:BitmapData = createBitmapData($data);
			if($doTrim) data = trimBitmapData(data);
			
			var img:Bitmap = new Bitmap(data, PixelSnapping.AUTO, false);
			return img;
		}
		
		/**
		 * Trim BitmapData smaller
		 * @param $data
		 * @param $mask
		 * @param $color
		 * @param $findColor
		 * returnj BitmapData trimmed down according to bitwise operation <code>$mask & value == $color</code> if <code>$findColor</code> true and <code>$mask & value == $color</code> if <code>$findColor</code> false and  
		 */
		public static function trimBitmapData($data:BitmapData, $mask:uint=0xffffffff, $color:uint=0x0, $findColor:Boolean=false):BitmapData {
			var bnd:Rectangle = $data.getColorBoundsRect($mask, $color, $findColor);
			var tmpData:BitmapData = new BitmapData(bnd.width, bnd.height, true, 0x0);
			tmpData.draw($data, new Matrix(1,0,0,1,-bnd.x,-bnd.y), null, null, null);
			return tmpData;
		}
		
		/**
		 * Create a BitmapData image using a DisplayObject
		 * 
		 * @param $data
		 * @return BitmapData information
		 */
		public static function createBitmapData($data:DisplayObject):BitmapData {
			var data:BitmapData;
			
			data = new BitmapData($data.width, $data.height, true, 0x00000000);
			data.draw($data, null, null, null, null, false);
			return data;
		}
		
		/**
		 * Create a Bitmap image using a DisplayObject and replace color values with 
		 * gradient values preserving alpha.
		 * 
		 * @param $data
		 * @return Bitmap image generated
		 */
		public static function createGradientBitmap($data:DisplayObject, $type:String, $colors:Array, $alphas:Array, $ratios:Array, $matrix:Matrix = null, $spreadMethod:String = "pad", $interpolationMethod:String = "rgb", $focalPointRatio:Number = 0):Bitmap {
			var alphaData:BitmapData = createBitmapData($data);
			var imageData:BitmapData = new BitmapData(alphaData.width, alphaData.height, true, 0x00000000);
			
			// create gradient
			var gradient:Shape = new Shape();
			gradient.graphics.beginGradientFill($type, $colors, $alphas, $ratios, $matrix, $spreadMethod, $interpolationMethod, $focalPointRatio);
			gradient.graphics.drawRect(0,0,alphaData.width,alphaData.height);
			gradient.graphics.endFill();
			var gradientData:BitmapData = createBitmapData(gradient);
			
			imageData.copyPixels(gradientData, new Rectangle(0,0,alphaData.width,alphaData.height), new Point(0,0), alphaData, null, true);
			return new Bitmap(imageData, PixelSnapping.AUTO, false);
		}
	}
}
