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
package halogen.debug.widgets {
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author henry
	 */
	public class DebugWidget extends Sprite {
		private static var _widgetList : Vector.<DebugWidget>;
		private static var _isInit : Boolean = false;
		
		public function DebugWidget() {
			_init(this);
			addEventListener(Event.ADDED_TO_STAGE, _addedStage);
			addEventListener(Event.REMOVED_FROM_STAGE, _removedStage);
		}
		
		private function _addedStage($e:Event):void {
			addEventListener(Event.RESIZE, _onResize);
			_onResize(null);
		}

		private function _removedStage($e:Event):void {
			removeEventListener(Event.RESIZE, _onResize);
		}
		
		private function _onResize($e:Event):void {
			var offsetY:Number = 0;
			for each(var widget:DebugWidget in _widgetList) {
				widget.x = 0;
				widget.y = offsetY;
				offsetY+=widget.height;
			}
		}
		
		private static function _init($widget:DebugWidget):void {
			if(!_isInit) {
				_widgetList = new Vector.<DebugWidget>();
				_isInit = true;
			}
			_widgetList.push($widget);
		}
		
		private static function _getIndex($widget:DebugWidget):int { return _widgetList.indexOf($widget); }
		
		public function destroy():void {
			if(this.parent) this.parent.removeChild(this);
			removeEventListener(Event.ADDED_TO_STAGE, _addedStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removedStage);
			removeEventListener(Event.RESIZE, _onResize);
			_widgetList = null;
		}
		
		override public function toString():String { return '[DebugWidget]'; }
	}
}
