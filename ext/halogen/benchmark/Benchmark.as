package halogen.benchmark {

	/**
	 * @author henry
	 */
	public class Benchmark {
		
		/**
		 * Check performance benchmark of an operation
		 * @param $operation, Function to execute
		 * @param $params, Parameters to pass to function
		 * @param $iterations, Iterations to execute in 10's, where 1 iteration = 10x
		 * @return Outputs number of miliseconds benchmark took
		 */
		public static function check($operation:Function, $params:Array, $iterations:int=100000):Number {
			if($iterations<1) $iterations = 1;
			var start:int = new Date().valueOf();
			
			// execute operation 10 times
			for(var i:int=0; i<$iterations; i++) {
				$operation.apply(null, $params);
				$operation.apply(null, $params);
				$operation.apply(null, $params);
				$operation.apply(null, $params);
				$operation.apply(null, $params);
				$operation.apply(null, $params);
				$operation.apply(null, $params);
				$operation.apply(null, $params);
				$operation.apply(null, $params);
				$operation.apply(null, $params);
			}
			var now:int = new Date().valueOf();
			return (now-start);
		}
		
	}
}
