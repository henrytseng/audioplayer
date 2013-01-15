package com.heycanvas.audio.playlist {
	import fluorescent.component.DataComponent;

	import halogen.math.Numerical;

	import flash.events.Event;

	/**
	 * @author htse
	 */
	public class PlaylistProxy extends DataComponent {
		// assoicated 
		private var _historyList : Vector.<int>;
		
		// composed
		private var _isLoop : Boolean;
		private var _isPlayOnInit : Boolean;
		private var _isPlayOnAdvance : Boolean;
		private var _isAutoAdvance : Boolean;
		private var _isShuffle : Boolean;
		private var _playheadIndex : int;
		private var _trackList : Vector.<TrackDataObject>;
		
		public function PlaylistProxy() {
			_playheadIndex = 0;
		}
		
		public function addTrack($track:TrackDataObject):void {
			if(!_trackList) _trackList = new Vector.<TrackDataObject>();
			_trackList.push($track);
		}
		
		public function init($paramHash:Object):void {
			if($paramHash) {
				_isLoop = _checkParam($paramHash, 'isLoop', true);
				_isPlayOnInit = _checkParam($paramHash, 'isPlayOnInit', true);
				_isPlayOnAdvance = _checkParam($paramHash, 'isPlayOnAdvance', true);
				_isAutoAdvance = _checkParam($paramHash, 'isAutoAdvance', true);
				_isShuffle = _checkParam($paramHash, 'isShuffle', false);
				
				if($paramHash.hasOwnProperty('firstTrack')) 
					_playheadIndex = $paramHash['firstTrack'];
			}
			
			_historyList = new Vector.<int>();
			
			// play on init
		 	setTrack(_playheadIndex, _isPlayOnInit);
		}
		
		private function _checkParam($paramHash:Object, $paramName:String, $defaultValue:Boolean):Boolean {
			if($paramHash.hasOwnProperty($paramName)) {
				return ($paramHash[$paramName]=='true') ? true : false;
			}
			return $defaultValue;
		}
		
		/** Set playlist to circlar */
		public function set isLoop($b:Boolean):void { _isLoop = $b; }
		
		/** Get playlist is circlar */
		public function get isLoop():Boolean { return _isLoop; }
		
		/** Set playlist to play when first initialized */
		public function set isPlayOnInit($b:Boolean):void { _isPlayOnInit = $b; }
		
		/** Get playlist is played when first initialized */
		public function get isPlayOnInit():Boolean { return _isPlayOnInit; }
		
		/** Set track to play when playhead advances */
		public function set isPlayOnAdvance($b:Boolean):void { _isPlayOnAdvance = $b; }
		
		/** Get track is played when playhead advances */
		public function get isPlayOnAdvance():Boolean { return _isPlayOnAdvance; }
		
		/** Set playlist to advances at the end of a song */
		public function set isAutoAdvance($b:Boolean):void { _isAutoAdvance = $b; }
		
		/** Get playlist is advances at the end of a song  */
		public function get isAutoAdvance():Boolean { return _isAutoAdvance; }
		
		/** Set playlist advances in a random order */
		public function set isShuffle($b:Boolean):void { _isShuffle = $b; }
		
		/** Get playlist advances in a random order */
		public function get isShuffle():Boolean { return _isShuffle; }
		
		public function nextTrack():void {
			if(!_trackList) return;
			
			if(_isShuffle) {
				setTrack(Numerical.randomInteger(0, _trackList.length), _isPlayOnAdvance);
			} else {
				setTrack(_playheadIndex+1, _isPlayOnAdvance);
			}
		}
		
		public function prevTrack():void {
			if(!_trackList) return;
			
			if(_isShuffle) {
				if(_historyList.length>0) {
					var index : int = _historyList.pop();
					setTrack(index, _isPlayOnAdvance);
				} else {
					setTrack(Numerical.randomInteger(0, _trackList.length), _isPlayOnAdvance);
				}
				
			} else {
				setTrack(_playheadIndex-1, _isPlayOnAdvance);
			}
		}
		
		/**
		 * Set track index directly, does not move playhead unless the track exists
		 * @param $i, An index according to the track list
		 */
		public function setTrack($i:int, $isNotifyChange:Boolean=true):void {
			if(!_trackList) return;
			
			_playheadIndex=$i;
			// loop
			if(_isLoop) {
				if(_playheadIndex > _trackList.length-1) _playheadIndex = 0;
				else if(_playheadIndex < 0) _playheadIndex = _trackList.length-1;
				
			// stop point
			} else {
				if(_playheadIndex > _trackList.length-1) _playheadIndex = _trackList.length-1;
				else if(_playheadIndex < 0) _playheadIndex = 0;
			}
			
			dispatchEvent(new Event(Event.OPEN));
			
			if($isNotifyChange) {
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		/**
		 * Handler for music completion
		 */
		public function trackComplete():void {
			if(!_trackList) return;
			
			if(_isAutoAdvance) {
				if(_playheadIndex < _trackList.length) nextTrack();
			}
		}
		
		public function get playlistSize():int {
			if(!_trackList) return 0; 
			return _trackList.length;
		}
		
		public function get playheadIndex():int { return _playheadIndex; }
		
		public function get playheadTrack():TrackDataObject {
			if(!_trackList) return null;
			else if(_trackList.length==0) return null;  
			return _trackList[_playheadIndex];
		}
		
		override public function destroy():void {
			super.destroy();
			
			if(_trackList) {
				for(var i:int=0; i<_trackList.length; i++) _trackList[i].destroy();
				_trackList = null;
			}
			
			_historyList = null;
		}
		
	}
}
