package halogen.event {
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * Aggregates Events and calls a handler when all events have dispatched.  
	 * @author henry
	 */
	public class EventCoordinator {
		// assoicated
		
		// composed
		private var _list : Vector.<IEventDispatcher>;
		private var _handler : Function;
		private var _delay : int;
		private var _delayTimeout : uint;
		
		public function get handler():Function { return _handler; }
		
		public function get numWaiting():int { return _list.length; }
		
		/**
		 * Constructor
		 * @param $handler, A handler to execute at completion
		 */
		public function EventCoordinator($handler:Function, $delay:int=0) {
			_init($handler, $delay);
		}
		
		private function _init($handler:Function, $delay:int):void {
			_delay = $delay;
			_handler = $handler;
		}
		
		/**
		 * Set a handler function
		 */
		public function setHandler($h:Function):void {
			_handler=$h;
		}
		
		/**
		 * Register a dispatcher
		 * @param eventType, A particular event type to register
		 * @param $dispatchers, Each parameter following should be a dispatcher to register
		 */
		public function register($eventType:String, ...$dispatchers):void {
			// new list
			if(_list == null) _list = new Vector.<IEventDispatcher>();
			
			// add dispatcher
			for(var i:int=0; i<$dispatchers.length; i++) {
				var dispatcher:IEventDispatcher = $dispatchers[i] as IEventDispatcher;
				
				if(dispatcher) {
					dispatcher.addEventListener($eventType, _onComplete);
					_list.push(dispatcher);
				}
			}
		}
		
		/**
		 * Remove a dispatcher.  Becareful when removing queue may now be empty and handler will 
		 * not be called.  A check to call the handler is made at the time of an event.  
		 * @param eventType, A particular event type to register
		 * @param $dispatchers, Each parameter following should be a dispatcher to unregister
		 */
		public function unregister($eventType:String, ...$dispatchers):int {
			// remove dispatchers
			for(var i:int=0; i<$dispatchers.length; i++) {
				var dispatcher:IEventDispatcher = $dispatchers[i] as IEventDispatcher;
				if(dispatcher) {
					dispatcher.removeEventListener($eventType, _onComplete);
					_removeDispatcher(dispatcher);
				}
			}
			
			// return list length
			return getListLength();
		}
		
		private function _removeDispatcher($dispatcher:IEventDispatcher):void {
			var i:int = _list.indexOf($dispatcher);
			if(i!=-1) _list.splice(i,1);
			
			// nothing left
			if(getListLength()==0) _list = null;
		}
		
		private function _onComplete($e:Event):void {
			
			($e.target as IEventDispatcher).removeEventListener($e.type, _onComplete);
			_removeDispatcher($e.target as IEventDispatcher);
			
			if(getListLength()==0) {
				if(_delay!=0) {
					clearTimeout(_delayTimeout);
					_delayTimeout = setTimeout(_callHandler, _delay*1000);
				} else {
					_callHandler();
				}
			}
		}
		
		private function _callHandler():void {
			if(_handler!=null && getListLength()==0) _handler.apply();
		}
		
		private function getListLength():int { return _list!=null ? _list.length : 0; } 
		
		/**
		 * Destroy
		 */
		public function destroy():void {
			if(_list) {
				var dispatcher:IEventDispatcher = _list.pop();
				while(dispatcher) {
					_removeDispatcher(dispatcher);
					dispatcher = (_list) ? _list.pop() : null;
				}
				_list = null;
			}
			_handler = null;
			clearTimeout(_delayTimeout);
		}
	}
}
