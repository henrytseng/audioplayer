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
package halogen.debug.window {
	import fluorescent.text.TextFieldFactory;

	import halogen.debug.DebugLevel;
	import halogen.debug.Debugger;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;

	/**
	 * @author henry
	 */
	public class DebugWindow extends Sprite {
		// interface
		private var _uiContainer : Sprite;
		private var _isPause : Boolean;
		private var _pauseButton : TextField;
		private var _clearButton : TextField;
		
		private var _categoryContainer : Sprite;
		private var _categoryMask : Shape;
		private var _categoryIdDictionary : Dictionary;
		private var _categoryIdList : Vector.<int>;
		private var _categoryDataList : Vector.<String>;
		private var _idLabelHash : Object;
		
		private var _selectedCategory : int;
		private var _selectedIndex : int;
		private var _logField : TextField;
		private var _mouseOriginY : int;
		private var _scrollOriginY : int;
		
		// server
		private var _server : DebugServer;
		
		/**
		 * Consstructor
		 */
		public function DebugWindow() {
			_selectedCategory = DebugLevel.ALL;
			_selectedIndex = 0;
			_initStage();
			_initInterface();
			_initServer();
			_updateLog();
		}
		
		/**
		 * Initialize stage parameters
		 */
		private function _initStage():void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
		/**
		 * Initialize server for receiving messages from multiple clients
		 */
		private function _initServer():void {
			_server = new DebugServer();
			_server.setMessageHandler(_onMessage);
			if(_server.init()) {
				_log(DebugLevel.ALL, 'Connection established.\n');
				_isPause = false;
			} else {
				_log(DebugLevel.ALL, 'Failed to establish connection.\n');
				_isPause = true;
			}
			_renderPause();
		}
		
		/**
		 * Destroy server
		 */
		private function _destroyServer():void {
			if(_server) {
				_server.destroy();
				_server = null;
				_isPause = true;
			}
		}
		
		/**
		 * Initialize interface elements
		 */
		private function _initInterface():void {
			addChild(_uiContainer = new Sprite());
			
			_pauseButton = TextFieldFactory.createTextField({font:'Arial', embedFonts:false, backgroundColor:0x000000, size:9});
			_pauseButton.addEventListener(MouseEvent.CLICK, _clickPause);
			_renderPause();
			_uiContainer.addChild(_pauseButton);
			
			_clearButton = TextFieldFactory.createTextField({font:'Arial', embedFonts:false, backgroundColor:0x000000, size:9});
			_clearButton.addEventListener(MouseEvent.CLICK, _clickClear);
			_clearButton.text = "Clear";
			_uiContainer.addChild(_clearButton);
			
			_logField = TextFieldFactory.createTextField({font:'Arial', embedFonts:false, backgroundColor:0x000000, size:9, wordWrap:true, multiline:true, autoSize:TextFieldAutoSize.NONE});
			_uiContainer.addChild(_logField);
			
			_uiContainer.addChild(_categoryContainer = new Sprite());
			_uiContainer.addChild(_categoryMask = new Shape());
			_categoryMask.graphics.beginFill(0x0ff, 1);
			_categoryMask.graphics.drawRect(0,0,100,100);
			_categoryMask.graphics.endFill();
			_categoryContainer.mask = _categoryMask;
			_categoryIdDictionary = new Dictionary();
			_categoryIdList = new Vector.<int>();
			_categoryDataList = new Vector.<String>();
			_idLabelHash = {};
			_idLabelHash[Debugger.DEBUG_CATEGORIES] = 'all';
			_idLabelHash[DebugLevel.DEFAULT] = 'default';
			_idLabelHash[DebugLevel.ERROR] = 'error';
			_idLabelHash[DebugLevel.WARNING] = 'warning';
			_addCategory(Debugger.DEBUG_CATEGORIES);
			
			stage.addEventListener(MouseEvent.MOUSE_UP, _mouseUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDown);
			stage.addEventListener(Event.RESIZE, _onResize);
			_onResize(null);
		}
		
		private function _clickClear($e:MouseEvent):void {
			while(_categoryContainer.numChildren) {
				_removeCategory(_categoryContainer.removeChildAt(0));
			}
			_categoryIdDictionary = new Dictionary();
			_categoryIdList = new Vector.<int>();
			_categoryDataList = new Vector.<String>();
			_idLabelHash = {};
			_idLabelHash[Debugger.DEBUG_CATEGORIES] = 'all';
			_idLabelHash[DebugLevel.DEFAULT] = 'default';
			_idLabelHash[DebugLevel.ERROR] = 'error';
			_idLabelHash[DebugLevel.WARNING] = 'warning';
			_addCategory(Debugger.DEBUG_CATEGORIES);
			
			_updateLog();
			_onResize(null);
		}
		
		private function _mouseUp($e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _mouseMove);
		}
		
		private function _mouseMove($e:MouseEvent):void {
			var delta:Number = (_mouseOriginY-_uiContainer.mouseY)/10;
			_logField.scrollV = _scrollOriginY-delta;
		}
		
		private function _mouseDown($e:MouseEvent):void {
			_mouseOriginY = _uiContainer.mouseY;
			_scrollOriginY = _logField.scrollV;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _mouseMove);
		}
		
		/**
		 * Destroy interface elements
		 */
		private function _destroyInterface():void {
			// last
			if(_uiContainer) {
				if(_pauseButton) {
					_pauseButton.removeEventListener(MouseEvent.CLICK, _clickPause);
					_pauseButton = null;
				}
				
				if(_clearButton) {
					_clearButton.removeEventListener(MouseEvent.CLICK, _clickClear);
					_clearButton = null;
				}
				
				if(_categoryContainer) {
					while(_categoryContainer.numChildren) {
						_removeCategory(_categoryContainer.removeChildAt(0));
					}
					_categoryContainer = null;
				}
				
				if(_categoryMask) {
					_categoryMask = null;
				}
				
				if(_categoryIdDictionary) {
					_categoryIdDictionary = null;
				}
				
				if(_categoryIdList) {
					_categoryIdList = null;
				}
				
				if(_categoryDataList) {
					_categoryDataList = null;
				}
				
				if(_idLabelHash) {
					_idLabelHash = null;
				}
				
				removeChild(_uiContainer);
				_uiContainer = null;
			}
			
			if(stage) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, _mouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, _mouseDown);
				stage.removeEventListener(Event.RESIZE, _onResize);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, _mouseMove);
			}
		}
		
		/** 
		 * Renders pause button according to pause state
		 */
		private function _renderPause():void {
			_pauseButton.text = (!_isPause) ? 'Disable' : 'Enable';
			_onResize(null);
		}
		
		/** 
		 * Toggles pause
		 */
		private function _clickPause($e:MouseEvent):void {
			_isPause = !_isPause;
			if(_isPause) {
				_destroyServer();
			} else {
				_initServer();
			}
			_renderPause();
			_updateLog();
		}
		
		/**
		 * Handler for receiving messages
		 */
		private function _onMessage($channelId:String, $params:Array):void {
			var type:String = $params[0];
			
			switch(type) {
				// receive message
				case 'debug_message':
					var callLine:Object = $params[1];
					var out:String = $params[2];
					var categorySet:int = $params[3];
					var outputCount:int = $params[4];
					var isUpdated:Boolean = false;
					
					// parse set
					var category:Number;
					for (var i:int=0; i< 16; i++) {
						// append to log
						if ((categorySet >> i)&1) {
							category = Math.pow(2,i);
							_log(category, '['+outputCount+']: '+callLine+out+'\n');
						}
						
						// check for current category
						if(_selectedCategory & category) isUpdated = true;
					}
					
					// append everything to all
					category = DebugLevel.ALL;
					_log(category, '['+outputCount+']: '+callLine+out+'\n');
					
					// update
					if(isUpdated) _updateLog();
					break;
			
				// add new category label
				case 'debug_category':
					_addCategoryLabel($params[1], $params[2]);
					break;
			}
		}
		
		private function _log($category:int, $output:String):void {
			var index:int = _categoryIdList.indexOf($category);
			if(index==-1) index = _addCategory($category);
			_categoryDataList[index]+=$output;
		}
		
		private function _addCategoryLabel($category:int, $label:String):void {
			if(!_idLabelHash.hasOwnProperty($category)) {
				_idLabelHash[$category] = $label;
			}
		}
		
		private function _translateLabel($category:int):String {
			if(_idLabelHash.hasOwnProperty($category)) return _idLabelHash[$category];
			else return String($category);
		}
		
		private function _addCategory($category:int):int {
			var categoryButton:TextField = TextFieldFactory.createTextField({font:'Arial', embedFonts:false, backgroundColor:0x000000, size:9});
			var index:int = _categoryIdList.length;
			
			categoryButton.text = _translateLabel($category);
			categoryButton.y = index*15;
			categoryButton.addEventListener(MouseEvent.CLICK, _clickCategory);
			_categoryContainer.addChild(categoryButton);
			
			_categoryIdDictionary[categoryButton] = index;
			_categoryIdList.push($category);
			_categoryDataList.push(new String());
			
			return index;
		}
		
		private function _removeCategory($button:DisplayObject):void {
			if($button) {
				$button.removeEventListener(MouseEvent.CLICK, _clickCategory);
				if($button.parent) $button.parent.removeChild($button);
			}
		}
		
		private function _clickCategory($e:MouseEvent):void {
			var index:int = _categoryIdDictionary[$e.target];
			_selectedCategory = _categoryIdList[index];
			_selectedIndex = index;
			_updateLog();
		}
		
		private function _updateLog():void {
			_logField.text = _categoryDataList[_selectedIndex];
			_logField.scrollV = _logField.maxScrollV;
		}
		
		/**
		 * Adjust layout
		 */
		private function _onResize($e:Event):void {
			var margin:Number = 6;
			var secondColumn:Number = 150;
			
			if(_pauseButton) {
				_pauseButton.x = margin;
				_pauseButton.y = margin;
			}
			
			if(_clearButton && _pauseButton) {
				_clearButton.x = _pauseButton.x+_pauseButton.width+margin;
				_clearButton.y = _pauseButton.y;
			}
			
			if(_categoryContainer && _categoryMask && _pauseButton) {
				_categoryContainer.x = _categoryMask.x=margin;
				_categoryContainer.y = _categoryMask.y=_pauseButton.y+_pauseButton.height+margin;
				_categoryMask.height = stage.stageHeight - (_categoryMask.y+margin);
			}
			
			if(_logField) {
				_logField.x = secondColumn;
				_logField.y = margin;
				_logField.width = stage.stageWidth-(secondColumn+margin);
				_logField.height = stage.stageHeight-(margin*2);
			}
		}
		
		/**
		 * Destroy everything
		 */
		public function destroy():void {
			_destroyServer();
			_destroyInterface();
		}
	}
}
