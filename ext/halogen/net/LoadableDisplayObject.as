package halogen.net {
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * An <code>ILoadable</code> wrapping a <code>Loader</code>.
	 * 
	 * Items that have already loaded will simply dispatch an <code>Event.COMPLETE</code>
	 * 
	 * @see halogen.net.ILoadable;
	 * @see halogen.net.AbstractLoadable;
	 * @see halogen.net.LoadableData;
	 * @see halogen.net.LoadableQueue;
	 * 
	 * @author henry
	 */
	public class LoadableDisplayObject extends AbstractLoadable {
		// assoicated
		
		// composed
		private var _loader : Loader;
		
		/** Retrieve loader object, a Loader or a URLLoader */
		public function get loader():Loader { return _loader; }
		
		/**
		 * Constructor
		 * @param $loader, A <code>URLLoader</code> or <code>Loader</code> to add to the queue.
		 * @param $request, A request assoicated with the load.    
		 * @param $context, A context to associate with a load.
		 */
		public function LoadableDisplayObject($loader:Loader, $request:URLRequest, $context:LoaderContext=null) {
			super($request, $context);
			_loader = $loader;
			if(_loader.content !=null) _loadingState = LoadableState.COMPLETE;
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
					if(_loader != null) {
						_addListeners(_loader.contentLoaderInfo);
						if(_loadingState!=LoadableState.RUNNING) {
							_loader.load(_request, _context);
							_loadingState = LoadableState.RUNNING;
						}
					}
				}
				
			// already completed so notify finish imediately
			} else {
				if(_loader != null) _removeListeners(_loader.contentLoaderInfo);
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get dispatcher():IEventDispatcher {
			if(_loader) return _loader.contentLoaderInfo;
			else return null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			super.destroy();
			
			if(_loader != null) {
				_removeListeners(_loader.contentLoaderInfo);
				_loader = null;
			}
		}
	}
}
