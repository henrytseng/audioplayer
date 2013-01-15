package halogen.net {
	import halogen.debug.DebugLevel;
	import halogen.debug.Debugger;

	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * A pseudo abstract <code>ILoadable</code> containing basic <code>ILoadable</code> functionality.
	 * 
	 * Items that have already loaded will simply dispatch an <code>Event.COMPLETE</code>
	 * 
	 * @see halogen.net.ILoadable;
	 * @see halogen.net.LoadableQueue;
	 * 
	 * @author henry
	 */
	public class AbstractLoadable extends EventDispatcher implements ILoadable {
		// assoicated
		protected var _queueList : Vector.<LoadableQueue>;
		
		// composed
		protected var _request : URLRequest;
		protected var _context : LoaderContext;
		protected var _loadingState : int;
		/** True if item has finished loading */
		public function get isLoaded():Boolean { return (_loadingState == LoadableState.COMPLETE); }
		
		/** @inheritDoc */
		public function get state():int { return _loadingState; }

		/** Retrieve URLLoader object */
		public function get request():URLRequest { return _request; }
		
		/**
		 * Constructor
		 * @param $loader, A <code>URLLoader</code> or <code>Loader</code> to add to the queue.
		 * @param $request, A request assoicated with the load.    
		 * @param $context, A context to associate with a load.
		 */
		public function AbstractLoadable($request:URLRequest, $context:LoaderContext=null) {
			_init($request, $context);
		}
		
		protected function _init($request:URLRequest, $context:LoaderContext=null):void {
			_loadingState = LoadableState.WAITING;
			_request = $request;
			_context = $context;
			
			_queueList = new Vector.<LoadableQueue>();
		}
		
		/**
		 * @inheritDoc
		 */
		public function registerQueue($queue:LoadableQueue):void {
			_queueList.push($queue);
		}

		/**
		 * @inheritDoc
		 */
		public function start():void {
			throw(new IllegalOperationError('Abstract method has not been implemented.'));	
		}
		
		protected function _addListeners($dispatcher:IEventDispatcher):void {
			$dispatcher.addEventListener(Event.COMPLETE, _onLoadComplete, false, 10);
			$dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onSecurityError, false, 10);
			$dispatcher.addEventListener(IOErrorEvent.IO_ERROR, _onIOError, false, 10);
		}

		protected function _removeListeners($dispatcher:IEventDispatcher):void {
			if($dispatcher != null) {
				$dispatcher.removeEventListener(Event.COMPLETE, _onLoadComplete, false);
				$dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onSecurityError, false);
				$dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, _onIOError, false);
			}
		}
		
		protected function _onSecurityError($e:Event):void {
			Debugger.send('url:'+_request.url, DebugLevel.WARNING);
			
			_loadingState = LoadableState.ATTEMPTED;
			_removeListeners($e.target as IEventDispatcher);
			dispatchEvent($e);
		}
		
		protected function _onIOError($e:Event):void {
			Debugger.send('url:'+_request.url, DebugLevel.WARNING);
			
			_loadingState = LoadableState.ATTEMPTED;
			_removeListeners($e.target as IEventDispatcher);
			dispatchEvent($e);
		}
		
		protected function _onLoadComplete($e:Event):void {
			_loadingState = LoadableState.COMPLETE;
			_removeListeners($e.target as IEventDispatcher);
			dispatchEvent($e);
		}
		
		/**
		 * @inheritDoc
		 */
		public function get dispatcher():IEventDispatcher {
			throw(new IllegalOperationError('Abstract method has not been implemented.'));
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function destroy():void {
			_request = null;
			_context = null;
			if(_queueList) {
				var listRemoveLoadable:Function = function($queue:LoadableQueue, $index:int, $list:Vector.<LoadableQueue>):Boolean {
					$queue.removeLoadable(this as ILoadable);
					return true;
				};
				_queueList.every(listRemoveLoadable);
				_queueList = null;
			}
		}
	}
}
