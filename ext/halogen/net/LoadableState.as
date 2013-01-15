package halogen.net {

	/**
	 * @author henry
	 */
	public class LoadableState {
		
		/** A loading failure occurred earlier. */
		public static const ATTEMPTED : int = -1;
		
		/** Loading has not been attempted and is available to start. */
		public static const WAITING : int = 0;
		
		/** Loading has already started */
		public static const RUNNING : int = 1;
		
		/** Loading has completed */
		public static const COMPLETE : int = 2;
		
	}
}
