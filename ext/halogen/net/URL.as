/**
 * Copyright (c) 2010 Henry Tseng (http://www.henrytseng.com)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 package halogen.net {

	/**
	 * @author henry
	 */
	public class URL {
		private static const NULL_RESULT : String = null;
		
		private static const RESERVED_CHARACTERS : String = '$&+,/:;=?@';
		private static const UNSAFE_CHARACTERS : String = ' "<>#%{}|\\^~[]`';
		private static const ESCAPE_CHARACTER : String = '%';
		
		public static var PROTOCOL_REGEXP : RegExp = /^[a-zA-Z0-9]+(?=:\/\/)/i;
		public static var AUTHORITY_REGEXP : RegExp = /(?<=:\/\/)[a-zA-Z\-\.]+:?[0-9]*/i;
		public static var HOST_REGEXP : RegExp = /(?<=:\/\/)[a-zA-Z\-\.]+/i;
		public static var PORT_REGEXP : RegExp = /(?<=:)[0-9]+/i;
		public static var PATH_REGEXP : RegExp = /(?<!\/)\/[a-zA-Z\-\.0-9%_\+\*\(\)]+[a-zA-Z\-\.0-9\/%_\+\*\(\)]*/i;
		public static var QUERY_REGEXP : RegExp = /(?<=\?)[a-zA-Z\-\.0-9\/%=_\+\*\(\)]*/i;
		public static var FILE_REGEXP : RegExp = /(?<!\/)\/[a-zA-Z\-\.0-9_\+\*\(\)]+[a-zA-Z\-\.0-9\/\?%=_\+\*\(\)]*/i;
		public static var REF_REGEXP : RegExp = /(?<=#)[a-zA-Z\-\.0-9\/%=_\+\*\(\)]*/i;
		
		/**
		 * Returns the protocol identifier component of the URL.
		 */
		public static function getProtocol($url:String):String {
			var p:Array = $url.match(PROTOCOL_REGEXP);
			return (p==null) ? NULL_RESULT : p[0];
		}
		
		/**
		 * Returns the authority component of the URL; the host name and the port together.  
		 */
		public static function getAuthority($url:String):String {
			var p:Array = $url.match(AUTHORITY_REGEXP);
			return (p==null) ? NULL_RESULT : p[0];
		}
		
		/**
		 * Returns the host name component of the URL. 
		 */
		public static function getHost($url:String):String {
			var p:Array = $url.match(HOST_REGEXP);
			return (p==null) ? NULL_RESULT : p[0];
		}
		
		/**
		 * Returns the port number component of the URL. 
		 */
		public static function getPort($url:String):String {
			var p:Array = $url.match(PORT_REGEXP);
			return (p==null) ? NULL_RESULT : p[0];
		}
		
		/**
		 * Returns the path component of this URL. 
		 */
		public static function getPath($url:String):String {
			var p:Array = $url.match(PATH_REGEXP);
			return (p==null) ? NULL_RESULT : p[0];
		}
	
		/**
		 * Returns the query component of this URL. 
		 */
		public static function getQuery($url:String):String {
			var p:Array = $url.match(QUERY_REGEXP);
			return (p==null) ? NULL_RESULT : p[0];
		}
	
		/**
		 * Returns the filename component of the URL. The getFile method returns the same as getPath, plus the concatenation of the value of getQuery, if any. 
		 */
		public static function getFile($url:String):String {
			var p:Array = $url.match(FILE_REGEXP);
			return (p==null) ? NULL_RESULT : p[0];
		}
		
		/**
		 * Returns the reference component of the URL. 
		 */
		public static function getRef($url:String):String {
			var p:Array = $url.match(REF_REGEXP);
			return (p==null) ? NULL_RESULT : p[0];
		}
		
		/**
		 * Append variables to query string
		 */
		public static function appendQuery($url:String, $parameters:Object=null):String {
			// no parameters
			if($parameters==null) return $url;
			
			var url:String;
			var query:String = getQuery($url);
			var param:String;
			
			// no query string
			if(query==null) { 
				query = '?';
				for(param in $parameters) {
					query+=param+'='+$parameters[param]+'&';
				}
				url = $url.replace(FILE_REGEXP, getFile($url)+query.substr(0,query.length-1));
				
			// append to current query string
			} else {
				query = query+'&';
				for(param in $parameters) {
					query+=param+'='+$parameters[param]+'&';
				}
				url = $url.replace(QUERY_REGEXP, query.substr(0,query.length-1));
			}
			return url;
		}
		
		/**
		 * Accepts a string and encodes using URL encoding
		 * @param $unencoded
		 */
		public static function encode($unencoded:String):String {
			var encoded:String = '';
			for(var i:int=0; i<$unencoded.length; i++) {
				var r : int = RESERVED_CHARACTERS.indexOf($unencoded.charAt(i));
				var u : int = UNSAFE_CHARACTERS.indexOf($unencoded.charAt(i));
				if(r!=-1) {
					encoded += ESCAPE_CHARACTER + RESERVED_CHARACTERS.charCodeAt(r).toString(16);
				} else if(u!=-1) {
					encoded += ESCAPE_CHARACTER + UNSAFE_CHARACTERS.charCodeAt(u).toString(16);
				} else {
					encoded += $unencoded.charAt(i);
				}
			}
			return encoded;
		}
		
	}
}
