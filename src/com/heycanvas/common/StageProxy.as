package com.heycanvas.common {
	import flash.display.StageAlign;
	import fluorescent.component.DataComponent;
	import fluorescent.initial.Initial;

	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.ui.ContextMenu;

	/**
	 * @author htse
	 */
	public class StageProxy extends DataComponent {
		// assoicated
		protected var _stage : Stage;
		protected var _contextMenu : ContextMenu;
		// composed
		protected var _minWidth : Number;
		protected var _minHeight : Number;
		protected var _width : Number;
		protected var _height : Number;
		
		public function StageProxy() {
			_minWidth = _minHeight = 0;
			_width = _height = 0;
		}
		
		public function init($initial:Initial):void {
			_stage = $initial.stage;
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.align = StageAlign.TOP_LEFT;
			_stage.addEventListener(Event.RESIZE, _onResize);
			
			// remove context menu
			_contextMenu = new ContextMenu();
			_contextMenu.hideBuiltInItems();
			$initial.contextMenu = _contextMenu;
		}
		
		public function get width():Number { return _width; }
		
		public function get height():Number { return _height; }
		
		public function refresh():void {
			_width = Math.max(_stage.stageWidth, _minWidth);
			_height = Math.max(_stage.stageHeight, _minHeight);
		}
		
		public function _onResize($e:Event):void {
			refresh();
		}
		
		override public function destroy():void {
			super.destroy();
			_stage.removeEventListener(Event.RESIZE, _onResize);
			_stage = null;
			_contextMenu = null;
		}
	}
}
