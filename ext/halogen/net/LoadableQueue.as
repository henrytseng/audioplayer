package halogen.net {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * A loading queue of <code>ILoadable</code> items used to load one-by-one.  <code>LoadableQueue</code>
	 * also implements <code>ILoadable</code> and can be added to parent queues.  
	 * 
	 * A queue's state will not reflect items that have failed to load.  A call to <code>numFailed</code> must be made
	 * to check whether or not any items have failed.  
	 * 
	 * Items that are added that have successfully loaded before the are processed by the queue will be skipped.   
	 * 
	 * @see halogen.net.ILoadable;
	 * @see halogen.net.AbstractLoadable;
	 * @see halogen.net.LoadableData;
	 * @see halogen.net.LoadableDisplayObject;
	 * 
	 * @author henry
	 */
	public class LoadableQueue extends EventDispatcher implements ILoadable {
		// assoicated
		private var _queueList : Vector.<LoadableQueue>;
		private var _waitList : Vector.<ILoadable>;
		private var _completetList : Vector.<ILoadable>;
		private var _failedList : Vector.<ILoadable>;
		private var _currentItem : ILoadable;
		
		// composed
		private var _loadingState : int;
		
		/** @inheritDoc */
		public function get state():int { return _loadingState; }
		
		/** Number of items completed loading */
		public function get numLoaded():int { return _completetList.length; }
		
		/** Number of items waiting to load */
		public function get numWaiting():int { return _waitList.length; }
		
		/** Total number of items in queue */
		public function get numTotal():int { return _completetList.length + _waitList.length; }
		
		/** Number of items failed to load */
		public function get numFailed():int { return _failedList.length; }
		
		/**
		 * Constructor
		 */
		public function LoadableQueue($target:IEventDispatcher = null) {
			super($target);
			_init();
		}
		
		private function _init():void {
			_loadingState = LoadableState.WAITING;
			_currentItem = null;
			_queueList = new Vector.<LoadableQueue>();
			_waitList = new Vector.<ILoadable>();
			_completetList = new Vector.<ILoadable>();
			_failedList = new Vector.<ILoadable>();
		}
		
		public function registerQueue($queue:LoadableQueue):void {
			_queueList.push($queue);
		}
		
		/**
		 * Add a <code>ILoadable</code> directly to the queue.  
		 * @param $loadable, A loadable to add to the queue
		 */
		public function addLoadable($loadable:ILoadable):void {
			_waitList.push($loadable);
			$loadable.registerQueue(this);
			_continueLoad();
		}
		
		/**
		 * Removes a <code>Loadable</code> from the queue.  
		 * @param $loader, A <code>URLLoader</code> or <code>Loader</code> to remove from the queue.  
		 */
		public function removeLoadable($loadable:ILoadable):void {
			if($loadable != null) {
				// remove from lists
				var i:int = -1;
				if(_waitList) {
					i=_waitList.indexOf($loadable);
					if(i!=-1) _waitList.splice(i, 1);
				}
				
				if(_waitList) {
					i=_completetList.indexOf($loadable);
					if(i!=-1) _completetList.splice(i, 1);
				}
				
				if(_waitList) {
					i=_failedList.indexOf($loadable);
					if(i!=-1) _failedList.splice(i, 1);
				}
				
				// continue loading
				if(_currentItem==$loadable) {
					_currentItem = null;
					_continueLoad();
				}
			}
		}
		
		/**
		 * Start running queue if not already running
		 */
		public function start():void {
			_loadingState = LoadableState.RUNNING;
			_continueLoad();
		}
		
		/**
		 * Load next <code>Loadable</code>
		 */
		private function _continueLoad():void {
			if(_currentItem==null && _loadingState == LoadableState.RUNNING && Boolean(_waitList.length)) {
				_currentItem = _waitList.shift();
				_addListeners(_currentItem);
				_currentItem.start();
			}
		}
		
		private function _addListeners($dispatcher:IEventDispatcher):void {
			$dispatcher.addEventListener(Event.COMPLETE, _onLoadComplete, false, 10);
			$dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onSecurityError, false, 10);
			$dispatcher.addEventListener(IOErrorEvent.IO_ERROR, _onIOError, false, 10);
		}

		private function _removeListeners($dispatcher:IEventDispatcher):void {
			if($dispatcher != null) {
				$dispatcher.removeEventListener(Event.COMPLETE, _onLoadComplete, false);
				$dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onSecurityError, false);
				$dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, _onIOError, false);
			}
		}
		
		private function _onSecurityError($e:Event):void {
			_removeListeners(_currentItem);
			_failedList.push(_currentItem);
			_loadNext();
		}
		
		private function _onIOError($e:Event):void {
			_removeListeners(_currentItem);
			_failedList.push(_currentItem);
			_loadNext();
		}
		
		private function _onLoadComplete($e:Event):void {
			_removeListeners(_currentItem);
			_completetList.push(_currentItem);
			_loadNext();
		}
		
		private function _loadNext():void {
			_currentItem = null;
			if(_waitList.length) {
				_continueLoad();
			} else {
				_loadingState = LoadableState.COMPLETE;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		 * Stops after current finishes
		 */
		public function stop():void {
			if(_waitList.length) {
				_loadingState = LoadableState.WAITING;
				
			} else {
				_loadingState = LoadableState.COMPLETE;
			}
		}

		public function reset():void {
			var i:int;
			for(i=0; i<_queueList.length; i++) {
				_queueList[i].removeLoadable(this);
			}
			_queueList = new Vector.<LoadableQueue>();
				
			_waitList = new Vector.<ILoadable>();
			_completetList = new Vector.<ILoadable>();
			_failedList = new Vector.<ILoadable>();
			
			_loadingState = LoadableState.WAITING;
			_currentItem = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get dispatcher():IEventDispatcher {
			return this;
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void {
			var i:int;
			if(_waitList) {
				_waitList = null;
			}
			if(_completetList) {
				_completetList = null;
			}
			if(_failedList) {
				_failedList = null;
			}
			if(_currentItem!=null) {
				_removeListeners(_currentItem);
				_currentItem = null;
			}
			if(_queueList) {
				for(i=0; i<_queueList.length; i++) {
					_queueList[i].removeLoadable(this);
				}
				_queueList = null;
			}
		}
	}
}
