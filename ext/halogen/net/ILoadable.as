package halogen.net {
	import flash.events.IEventDispatcher;
	
	/**
	 * An item which can be added to a <code>LoadableQueue</code> to be managed and controlled.  An
	 * <code>ILoadable</code> should dispatch an <code>Event.COMPLETE</code> after loading has finished.  
	 * 
	 * @see halogen.net.Loadable;
	 * @see halogen.net.LoadableQueue;
	 * 
	 * @author henry
	 */
	public interface ILoadable extends IEventDispatcher {
		
		/** 
		 * Retrieve loading state
		 */
		function get state():int;
		
		/**
	 	 * All queues must register to this list so that a loadable may remove itself when it is destroyed
	 	 * @param $queue, A queue to register
		 */
		function registerQueue($queue:LoadableQueue):void;
		
		/**
		 * Return <code>IEventDispatcher</code> dispatching events from loader
		 */
		function get dispatcher():IEventDispatcher;
		
		/**
		 * Start loading loadable and set up handlers for simple notification.  If a loadable has already been 
		 * started loading should continue to wait for Event.COMPLETE.  
		 */
		function start():void;
		
		/**
		 * Destroy
		 */
		function destroy():void;
		
	}
}
