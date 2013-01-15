package com.heycanvas.audio.playlist {
	import flash.xml.XMLNode;

	/**
	 * @author htse
	 */
	public class TrackDataObject {
		public var type : String;
		public var connection : String;
		public var server : String;
		public var src : String;
		public var length : int;
		
		public var title : String;
		public var artist : String;
		public var extensionData : XMLNode;
		
		public function TrackDataObject() { }
		
		public function destroy():void {
			extensionData = null;
		}
	}
}
