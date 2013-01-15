package halogen.net {
	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;

	/**
	 * A cache for loader objects, using the loadable framework.  <code>LoadableCache</code> is implemented through
	 * associating unique url Strings with Loadable objects.  
	 * 
	 * @see halogen.net.Loadable
	 * @see halogen.net.LoadableQueue
	 * 
	 * @author henry
	 */
	public class LoadableCache {
		private static var _isInit : Boolean; 
		private static var _loadableMap : Dictionary;
		
		/**
		 * Initialize
		 */
		private static function _init():void {
			if(!_isInit) {
				_loadableMap = new Dictionary();
				_isInit = true;
			}
		}
		
		/**
		 * Create a loadable 
		 * @param $loader, A <code>URLLoader</code> or <code>Loader</code> to add to the queue.
		 * @param $request, A request assoicated with the load.    
		 * @param $context, A context to associate with a load.
		 */
		public static function createLoadable($loader:*, $request:URLRequest, $context:LoaderContext=null):ILoadable {
			_init();
			var loadable:ILoadable;
			
			// exists
			if(getLoadable($request.url)!=null) {
				loadable = getLoadable($request.url);
				
			// doesn't exist
			} else {
				if($loader is URLLoader) {
					loadable = new LoadableData($loader, $request, $context);
					
				} else if($loader is Loader) {
					loadable = new LoadableDisplayObject($loader, $request, $context);
				}
				_storeLoadable($request.url, loadable);
			}
			
			return loadable;
		}
		
		/**
		 * Stores a loader within the cache
		 * @param $url, A unique url to associate with the ILoadable
		 * @param $loadable, An <code>ILoadable</code> object to store
		 */
		private static function _storeLoadable($url:String, $loadable:ILoadable):void {
			_loadableMap[$url] = $loadable;
		}
		
		/**
		 * Retrieve a loader from the cache
		 * @param $request, A <code>URLRequest</code> corresponding to a specific loader
		 */
		public static function getLoadable($url:String):ILoadable { return _loadableMap[$url] as ILoadable; }
		
		/**
		 * Release a loadable from the cache
		 */
		public static function releaseLoadable($url:String):ILoadable {
			var loadable:ILoadable = getLoadable($url);
			delete(_loadableMap[$url]);
			return loadable;
		}
		
		/**
		 * Reset entire cache; all loadables are also destroyed.  
		 */
		public static function reset():void {
			if(_loadableMap) {
				for(var loadable:* in _loadableMap) {
					(loadable as ILoadable).destroy();
				}
				_loadableMap = null;
			}
			_isInit = false;
		}
	}
}
