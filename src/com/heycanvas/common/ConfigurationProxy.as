package com.heycanvas.common {
	import fluorescent.component.DataComponent;

	/**
	 * @author htse
	 */
	public class ConfigurationProxy extends DataComponent {
		// associated
		
		// composed
		private var _parametersHash : Object;

		public function ConfigurationProxy() {
			_parametersHash = {};
		}
		
		public function init($initialParameters:Object):void {
			var id:String;
			// copy initial parameters
			for(id in $initialParameters) {
				_parametersHash[id] = $initialParameters[id];
			}
		}
		
		public function get parameters():Object {
			var copy:Object = {};
			var id:String;
			for(id in _parametersHash) {
				copy[id] = _parametersHash[id];
			}
			return copy;
		}
		
		override public function destroy():void {
			super.destroy();
			_parametersHash = null;
		}
	}
}
