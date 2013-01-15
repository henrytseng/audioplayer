package com.heycanvas.audio.engine {
	import halogen.debug.DebugLevel;
	import halogen.debug.Debugger;

	import flash.net.NetConnection;
	import flash.utils.Dictionary;

	/**
	 * @author henry
	 */
	public class ConnectionPool {
		// associated 
		private static var _connectionMap : Dictionary; 
		
		// composed
		private static var _connectionList : Vector.<NetConnection>; 
		private static var _isInit : Boolean = false;
		
		private static function _init():void {
			if(!_isInit) {
				_connectionMap = new Dictionary();
				_connectionList = new Vector.<NetConnection>();
				_isInit = true;
			}
		}
		
		public static function createConnection($url:String):NetConnection {
			_init();
			
			var connection:NetConnection;
			if(hasConnection($url)) {
				connection = getConnection($url);
				
			} else {
				connection = new NetConnection();
				_connectionMap[$url] = connection;
				_connectionList.push(connection);
			}
			
			return connection;
		}
		
		public static function getConnection($url:String):NetConnection {
			_init();
			return _connectionMap[$url];
		}
		
		public static function hasConnection($url:String):Boolean {
			if(!_isInit) return false;
			else return _connectionMap[$url] !=null;
		} 
		
		public static function get numConnections():int {
			if(!_isInit) return 0;
			else return _connectionList.length;
		}
		
		public static function destroy():void {
			for(var i:int=0; i<_connectionList.length; i++) {
				try {
					_connectionList[i].close();
					
				} catch($error:Error) {
					Debugger.send($error.getStackTrace(), DebugLevel.WARNING);
				}
			}
			_connectionList = null;
			_connectionMap = null;
			_isInit = false;
		}
	}
}
