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
package fluorescent.text {
	import halogen.debug.DebugLevel;
	import halogen.debug.Debugger;

	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	/**
	 * @author henry
	 */
	public class TextFieldFactory {
		public static var DEFAULT_FONT : String;
		
		protected static var _isInit : Boolean;
		protected static var _formatHash : Object;
		protected static var _styleHash : Object;
		protected static var _textFormatCache : Dictionary;
		
		/**
		 * Initialization
		 */
		protected static function _init():void {
			if(!_isInit) {
				_formatHash = {};
				_styleHash = {};
				_textFormatCache = new Dictionary(true);
				_isInit = true;
			}
		}
		
		/**
		 * @param $params, An id corresponding to a format or a set of parameters
		 */
		public static function createTextField($params:Object=null) : TextField {
			_init();
			var params:Object;
			var format:TextFormat;
			
			// use format
			if($params is String) {
				if(_formatHash[$params]!=null) {
					params = _getFormat($params as String);
					format = _textFormatCache[params];
				} else {
					Debugger.send('format:'+$params+' not available', DebugLevel.WARNING);
					return null;
				}
				
			// use params
			} else {
				params = $params;
				format = _createTextFormat($params);
			}
			
			// only create Textfields with embedded fonts
			if(params['embedFonts']!=false) {
				var fontNameList:Array = FontRegistry.getFontNameList();
				if(fontNameList.indexOf(params['font'])==-1 && !params.hasOwnProperty('css')) {
					Debugger.send('unable to find font:'+params['font'], DebugLevel.ERROR);
					return null;
				}
			} else {
				Debugger.send('using nonembedded font:'+params['font'], DebugLevel.WARNING);
			}
			
			// create textfield
			var field:TextField = new TextField();
			field.selectable = (params.hasOwnProperty('selectable')) ? params['selectable'] : false;
			field.embedFonts = (params.hasOwnProperty('embedFonts')) ? params['embedFonts'] : true;
			field.autoSize = (params.hasOwnProperty('autoSize')) ? params['autoSize'] : TextFieldAutoSize.LEFT;
			field.antiAliasType = (params.hasOwnProperty('antiAliasType')) ? params['antiAliasType'] : AntiAliasType.NORMAL;
			field.background = (params.hasOwnProperty('backgroundColor')) ? true : false;
			field.backgroundColor = (params.hasOwnProperty('backgroundColor')) ? params['backgroundColor'] : 0xffffff;
			field.multiline = (params.hasOwnProperty('multiline')) ? params['multiline'] : true;
			field.wordWrap = (params.hasOwnProperty('wordWrap')) ? params['wordWrap'] : null;
			field.defaultTextFormat = format;
			
			// setup style sheet
			if(params['css'] is String) { 
				field.styleSheet = _getStyleSheet(params['css']);
			} else if(params['css'] is StyleSheet) {
				field.styleSheet = params['css'] as StyleSheet;
			}
			
			return field;
		}
		
		/**
		 * Create TextFormat from parameters
		 * @param $params, Parameters for TextFormat
		 */
		protected static function _createTextFormat($params:Object) : TextFormat {
			var format:TextFormat = new TextFormat();
			format.font = $params['font'];
			format.size = $params.hasOwnProperty('size') ? $params['size'] : 20;
			format.color = $params.hasOwnProperty('color') ? $params['color'] : 0xffffff;;
			format.align = $params.hasOwnProperty('align') ? $params['align'] : null;
			format.bold = $params.hasOwnProperty('bold') ? $params['bold'] : false;
			format.italic = $params.hasOwnProperty('italic') ? $params['italic'] : false;
			format.letterSpacing = $params.hasOwnProperty('letterSpacing') ? $params['letterSpacing'] : null;
			format.leading = $params.hasOwnProperty('leading') ? $params['leading'] : null;
			return format;
		}
		
		/**
		 * Store format parameters and associate with <code>$formatId</code>.  Format parameters include parameters for
		 * TextFormat and parameters for TextField.  
		 * @param $formatId, A unique identifier for the format
		 * @param $params, A set of format parameters
		 */
		public static function storeFormat($formatId:String, $params:Object=null) : void {
			_init();
			_formatHash[$formatId] = $params;
			
			var format:TextFormat = _createTextFormat($params);			
			_textFormatCache[$params] = format;
		}
		
		/**
		 * Store a StyleSheet
		 * @param $styleId, A unique identifier for the style sheet
		 * @param $css, A CSS text string
		 */
		public static function storeStyleSheet($styleId:String, $css:String) : void {
			_init();
			var styleSheet:StyleSheet = new StyleSheet();
			styleSheet.parseCSS($css);
			_styleHash[$styleId] = styleSheet;
		}
		
		/**
		 * Retrieve a style sheet
		 * @param $styleId, A unique identifier for the style sheet
		 * 
		 */
		protected static function _getStyleSheet($styleId:String) : StyleSheet {
			if(!_styleHash) return null;
			return _styleHash[$styleId];
		}
		
		/**
		 * Retrieve format parameters
		 * @param $formatId Unique identifier corresponding with format parameters
		 */
		protected static function _getFormat($formatId:String) : Object {
			if(!_formatHash) return null;
			return _formatHash[$formatId];
		}
	}
}
