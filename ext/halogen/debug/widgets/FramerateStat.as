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
	import fluorescent.text.TextFieldFactory;

	

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.getTimer;

	/**
	 * @author henry
	 */
	public class FramerateStat extends DebugWidget {
		public static var UPDATE_FRAME : int = 10;
		
		private var _framerate : TextField;
		private var _elapsedTime : int;
		private var _count : int;
		
		private var _graph : Bitmap;
		private var _graphData : BitmapData;
		private var _graphWidth : int;
		private var _graphHeight : int;
		
		public function FramerateStat($renderGraph:Boolean=false) {
			super();
			
			_framerate = TextFieldFactory.createTextField({font:'Arial', embedFonts:false, backgroundColor:0x000000, size:9});
			_framerate.text = ' ';
			addChild(_framerate);
			
			if($renderGraph) {
				_graphWidth = 100;
				_graphHeight = 30;
				_graphData = new BitmapData(_graphWidth, _graphHeight, false, 0x0);
				_graph = new Bitmap(_graphData);
				_graph.y = _framerate.height;
				addChild(_graph);
			}
			
			addEventListener(Event.ADDED_TO_STAGE, _addedStage);
			addEventListener(Event.REMOVED_FROM_STAGE, _removedStage);
		}
		
		private function _addedStage($e:Event):void {
			stage.addEventListener(Event.ENTER_FRAME, _onFrame);
			_update();
		}

		private function _removedStage($e:Event):void {
			stage.removeEventListener(Event.ENTER_FRAME, _onFrame);
		}
		
		private function _onFrame($e:Event):void {
			_count++;
			if(_count >= UPDATE_FRAME) _update();
		}
		
		private function _update():void {
			var lastTime:int = _elapsedTime;
			_elapsedTime = getTimer();
			if(_count >= UPDATE_FRAME) {
				var rate:Number = _count/(_elapsedTime - lastTime)*1000;
				_framerate.text = 'framerate: '+rate.toFixed(1)+' fps';
				
				if(_graph) {
					var h:int = Math.round( _graphHeight * .5 * rate/stage.frameRate );
					_graphData.lock();
					_graphData.fillRect(new Rectangle(1, _graphHeight-h, 1, h), 0x003333);
					_graphData.setPixel(1, _graphHeight-h, 0xff00ffff);
					_graphData.scroll(1, 0);
					_graphData.unlock();
				}
			}
			_count = 0;
		}
		
		override public function destroy():void {
			super.destroy();
			if(stage) stage.removeEventListener(Event.ENTER_FRAME, _onFrame);
			removeEventListener(Event.ADDED_TO_STAGE, _addedStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removedStage);
			_framerate = null;
		}
		
		override public function toString():String { return '[FramerateStat]'; }
	}
}
