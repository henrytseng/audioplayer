package halogen.net {
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * An <code>ILoadable</code> wrapping a <code>URLLoader</code>.
	 * 
	 * Items that have already loaded will simply dispatch an <code>Event.COMPLETE</code>
	 * 
	 * @see halogen.net.ILoadable;
	 * @see halogen.net.AbstractLoadable;
	 * @see halogen.net.LoadableDisplayObject;
	 * @see halogen.net.LoadableQueue;
	 * 
	 * @author henry
	 */
	public class LoadableData extends AbstractLoadable {
		// assoicated
		
		// composed
		private var _urlLoader : URLLoader;
		
		/** Retrieve loader object, a Loader or a URLLoader */
		public function get loader():URLLoader { return _urlLoader; }
		
		/**
		 * Constructor
		 * @param $loader, A <code>URLLoader</code> or <code>Loader</code> to add to the queue.
		 * @param $request, A request assoicated with the load.    
		 * @param $context, A context to associate with a load.
		 */
		public function LoadableData($loader:URLLoader, $request:URLRequest, $context:LoaderContext=null) {
			super($request, $context);
			_urlLoader = $loader;
			if(_urlLoader.data !=null) _loadingState = LoadableState.COMPLETE;
		}
		
		override protected function _init($request:URLRequest, $context:LoaderContext=null):void {
			super._init($request, $context);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function start():void {
			// start load
			if(_loadingState!=LoadableState.COMPLETE) {
				
				// not alrady started
				if(_loadingState!=LoadableState.RUNNING) {
					if(_urlLoader != null) {
						_addListeners(_urlLoader);
						if(_loadingState!=LoadableState.RUNNING) {
							_urlLoader.load(_request);
							_loadingState = LoadableState.RUNNING;
						}
					}
				}
				
			// already completed so notify finish imediately
			} else {
				if(_urlLoader != null) _removeListeners(_urlLoader);
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get dispatcher():IEventDispatcher {
			return _urlLoader;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			super.destroy();
			
			if(_urlLoader != null) {
				_removeListeners(_urlLoader);
				_urlLoader = null;
			}
		}
	}
}
