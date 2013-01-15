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

	

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.Timer;

	/**
	 * @author henry
	 */
	public class MemoryStat extends DebugWidget {
		private var _updateTimer : Timer;
		private var _memStat : TextField;
		
		public function MemoryStat() {
			super();
			
			_memStat = TextFieldFactory.createTextField({font:'Arial', embedFonts:false, backgroundColor:0x000000, size:9});
			addChild(_memStat);
			
			_updateTimer = new Timer(1000);
			_updateTimer.addEventListener(TimerEvent.TIMER, _onTimer);
			_onTimer(null);
			
			addEventListener(Event.ADDED_TO_STAGE, _addedStage);
			addEventListener(Event.REMOVED_FROM_STAGE, _removedStage);
		}
		
		private function _addedStage($e:Event):void {
			_updateTimer.start();
		}
		
		private function _removedStage($e:Event):void {
			_updateTimer.stop();
		}
		
		private function _onTimer($e:TimerEvent):void {
			var mem:Number = (System.totalMemory)/1048576;
			_memStat.text = 'mem: '+mem.toFixed(2)+' Mb';
		}
		
		override public function destroy():void {
			super.destroy();
			removeEventListener(Event.ADDED_TO_STAGE, _addedStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removedStage);
			_updateTimer.removeEventListener(TimerEvent.TIMER, _onTimer);
			_updateTimer.stop();
			_updateTimer = null;
			_memStat = null;
		}
		
		override public function toString():String { return '[MemoryStat]'; }
	}
}
