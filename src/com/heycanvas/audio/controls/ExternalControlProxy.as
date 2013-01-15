package com.heycanvas.audio.controls {
	import fluorescent.component.ComponentManager;
	import fluorescent.component.DataComponent;

	import halogen.debug.DebugLevel;
	import halogen.debug.Debugger;

	import com.heycanvas.audio.engine.AudioEngineProxy;
	import com.heycanvas.audio.playlist.PlaylistProxy;

	import flash.events.Event;
	import flash.external.ExternalInterface;

	/**
	 * @author htse
	 */
	public class ExternalControlProxy extends DataComponent {
		// associated
		private var _engineProxy : AudioEngineProxy;
		private var _playlistProxy : PlaylistProxy;
		
		// composed
		private var _firstPosition : int;
		
		public function ExternalControlProxy() {
			_firstPosition = -1;
		}
		
		public function init($paramHash:Object):void {
			_engineProxy = ComponentManager.getComponent('audioengine_proxy') as AudioEngineProxy;
			_playlistProxy = ComponentManager.getComponent('playlist_proxy') as PlaylistProxy;

			_engineProxy.addEventListener(Event.SOUND_COMPLETE, _onAudioComplete);
			_playlistProxy.addEventListener(Event.OPEN, _onPlaylistLoad);
			_playlistProxy.addEventListener(Event.CHANGE, _onPlaylistChange);
			
			if($paramHash.hasOwnProperty('firstPosition')) {
				_firstPosition = $paramHash['firstPosition'];
			}
			
			if(ExternalInterface.available) ExternalInterface.call('onInit');
		}
		
		private function _onAudioComplete($e:Event):void {
			Debugger.send();
			if(ExternalInterface.available) {
				ExternalInterface.call('onStop'); 
			}
			
			_playlistProxy.trackComplete();
			
		}
		
		private function _onPlaylistLoad($e:Event):void {
			if(_playlistProxy.playheadTrack==null) return;
			Debugger.send(_playlistProxy.playheadTrack.artist+' - '+_playlistProxy.playheadTrack.title);
			
			// load next
			_engineProxy.load({
				type: _playlistProxy.playheadTrack.type, 
				connection: _playlistProxy.playheadTrack.connection,
				server: _playlistProxy.playheadTrack.server,
				src: _playlistProxy.playheadTrack.src,
				onBufferWait: _onBufferWait,
				onBufferReady: _onBufferReady
			});
		}
		
		private function _onPlaylistChange($e:Event):void {
			if(ExternalInterface.available) {
				ExternalInterface.call('onChangeTrack');
			}
			
			// jump to starting point
			if(_firstPosition>-1) {
				_engineProxy.seek(_firstPosition);
				_firstPosition = -1;
				
			// play normally
			} else {
				_engineProxy.play();
			}
			if(ExternalInterface.available) {
				ExternalInterface.call('onPlay');
			}
		}
		
		private function _onBufferWait():void {
			if(ExternalInterface.available) {
				ExternalInterface.call('onBufferWait');
			}
		}
		
		private function _onBufferReady():void {
			if(ExternalInterface.available) {
				ExternalInterface.call('onBufferReady');
			}
		}
		
		/**
		 * Set up connection thru ExternalInterface.  The following calls may be made to Flash:<br/>
		 * <ul><li>getTitle</li>
		 * <li>getArtist</li>
		 * 
		 * <li>getIsPlaying</li>
		 * <li>setPlay</li>
		 * <li>setPause</li>
		 * <li>setStop</li>
		 * <li>setFwd</li>
		 * <li>setRwd</li>
		 * <li>getPosition</li>
		 * <li>getLength</li>
		 * <li>setSeek</li>
		 * <li>getVolume</li>
		 * <li>setVolume</li>
		 * 
		 * <li>setGotoTrack</li>
		 * <li>setNextTrack</li>
		 * <li>setPrevTrack</li>
		 * <li>getPlaylistSize</li>
		 * <li>setPlayTrack</li>
		 * <li>getPlayTrack</li>
		 * 
		 * <li>setExtensionParam</li></ul>
		 * <br/>
		 * The following methods are handlers called by Flash:<br/> 
		 * <ul><li>onInit</li>
		 * <li>onPlay</li>
		 * <li>onPause</li>
		 * <li>onStop</li>
		 * <li>onFwd</li>
		 * <li>onRwd</li>
		 * <li>onVolume</li>
		 * <li>onSeek</li>
		 * <li>onBufferWait</li>
		 * <li>onBufferReady</li>
		 * <li>onChangeTrack</li></ul>
		 */
		public function connectExternal():void {
			if(ExternalInterface.available) {
				// song information
				ExternalInterface.addCallback('getTitle', _onExternalGetTitle);
				ExternalInterface.addCallback('getArtist', _onExternalGetArtist);
				
				// song control
				ExternalInterface.addCallback('getIsPlaying', _onExternalGetIsPlaying);
				ExternalInterface.addCallback('setPlay', _onExternalPlay);
				ExternalInterface.addCallback('setPause', _onExternalPause);
				ExternalInterface.addCallback('setStop', _onExternalStop);
				ExternalInterface.addCallback('setFwd', _onExternalFwd);
				ExternalInterface.addCallback('setRwd', _onExternalRwd);
				ExternalInterface.addCallback('getPosition', _onExternalGetPosition);
				ExternalInterface.addCallback('getLength', _onExternalGetLength);
				ExternalInterface.addCallback('setSeek', _onExternalSeek);
				ExternalInterface.addCallback('getVolume', _onExternalGetVolume);
				ExternalInterface.addCallback('setVolume', _onExternalSetVolume);
				ExternalInterface.addCallback('getBytesLoaded', _onExternalGetBytesLoaded);
				ExternalInterface.addCallback('getBytesTotal', _onExternalGetBytesTotal);
				
				// play list navigation
				ExternalInterface.addCallback('setGotoTrack', _onExternalGotoTrack);
				ExternalInterface.addCallback('setNextTrack', _onExternalNextTrack);
				ExternalInterface.addCallback('setPrevTrack', _onExternalPrevTrack);
				ExternalInterface.addCallback('getPlaylistSize', _onExternalGetPlaylistSize);
				ExternalInterface.addCallback('setPlayTrack', _onExternalPlayTrack);
				ExternalInterface.addCallback('getPlayTrack', _onExternalGetPlayTrack);
				
				// extension
				ExternalInterface.addCallback('setExtensionParam', _onExternalExtensionParam);
			} else {
				Debugger.send('ExternalInterface is required for communication', DebugLevel.WARNING);
			}
		}
		
		/** Handler for external get title */
		private function _onExternalGetTitle():String {
			if(_playlistProxy.playheadTrack==null) return '';
			return _playlistProxy.playheadTrack.title;
		}
		
		/** Handler for external get artist */
		private function _onExternalGetArtist():String {
			if(_playlistProxy.playheadTrack==null) return '';
			return _playlistProxy.playheadTrack.artist;
		}
		
		/** Handler for external pause */
		private function _onExternalPause():void {
			Debugger.send();
			_engineProxy.pause();
			if(ExternalInterface.available) {
				ExternalInterface.call('onPause'); 
			}
		}
		
		/** Handler for external get is playing */
		private function _onExternalGetIsPlaying():Boolean { return _engineProxy.isPlaying; }
		
		/** Handler for external play */
		private function _onExternalPlay():void {
			Debugger.send();
			_engineProxy.play();
			if(ExternalInterface.available) {
				ExternalInterface.call('onPlay');
			}
		}
		
		/** Handler for external stop */
		private function _onExternalStop():void {
			Debugger.send();
			_engineProxy.stop();
			if(ExternalInterface.available) {
				ExternalInterface.call('onStop'); 
			}
		}
		
		/** Handler for external fwd */
		private function _onExternalFwd():void {
			Debugger.send();
			_engineProxy.fwd();
			if(ExternalInterface.available) {
				ExternalInterface.call('onFwd'); 
			}
		}
		
		/** Handler for external rwd */
		private function _onExternalRwd():void {
			Debugger.send();
			_engineProxy.rwd();
			if(ExternalInterface.available) {
				ExternalInterface.call('onRwd'); 
			}
		}
		
		/** Handler for external get time */
		private function _onExternalGetPosition():int { return _engineProxy.position; }
		
		/** Handler for external get length */
		private function _onExternalGetLength():int { 
			var playlistLength:int = (_playlistProxy.playheadTrack) ? _playlistProxy.playheadTrack.length : 0;
			var engineLength:int = _engineProxy.length;
			return Math.max(playlistLength, engineLength);
		}
		
		/**
		 * Handler for external seek
		 * @param $position, A position in milliseconds
		 */
		private function _onExternalSeek($position:int):void {
			Debugger.send('$position:'+$position);
			_engineProxy.seek($position);
			if(ExternalInterface.available) {
				ExternalInterface.call('onSeek');
			}
		}
		
		/** Handler for external get volume */
		private function _onExternalGetVolume():int { return _engineProxy.volume; }
		
		/**
		 *  Set volume using a number 0..1
		 *  @param $level, A number specifying volume 0..1
		 */
		private function _onExternalSetVolume($level:Number):void {
			Debugger.send('$level:'+$level);
			_engineProxy.setVolume($level);
		}
		
		/** Gets bytes loaded. */
		private function _onExternalGetBytesLoaded():uint {
			return _engineProxy.bytesLoaded;
		}
		
		/** Gets bytes total. */
		private function _onExternalGetBytesTotal():uint {
			return _engineProxy.bytesTotal;
		}
		
		/** Handler for external jump to playlist */
		private function _onExternalGotoTrack($track:int):void {
			Debugger.send();
			_engineProxy.stop();
			_playlistProxy.setTrack($track, _playlistProxy.isPlayOnAdvance);
		}
		
		/** Handler for external next in playlist */
		private function _onExternalNextTrack():void {
			Debugger.send();
			_engineProxy.stop();
			_playlistProxy.nextTrack();
		}
		
		/** Handler for external prev in playlist */
		private function _onExternalPrevTrack():void {
			Debugger.send();
			_engineProxy.stop();
			_playlistProxy.prevTrack();
		}
		
		/** Handler for external get playlist */
		private function _onExternalGetPlaylistSize():int { 
			Debugger.send();
			return _playlistProxy.playlistSize;
		}
		
		/** Handler for external play track */
		private function _onExternalPlayTrack($track:int):void {
			Debugger.send('$track:'+$track);
			_engineProxy.stop();
			_playlistProxy.setTrack($track);
		}
		
		/** Handler for external get current track */
		private function _onExternalGetPlayTrack():int {
			return _playlistProxy.playheadIndex;
		}
		
		/**
		 * Handler to pass a message to an extension
		 * @param $name, A name associated with the message
		 * @param $param, A parameter associated with the message
		 */
		private function _onExternalExtensionParam($name:String, $param:String):void {
			Debugger.send('$name:'+$name+' $param:'+$param);
		}
		
		override public function destroy():void {
			super.destroy();
			_engineProxy.removeEventListener(Event.SOUND_COMPLETE, _onAudioComplete);
			_engineProxy = null;
			_playlistProxy.removeEventListener(Event.CHANGE, _onPlaylistChange);
			_playlistProxy = null;
		}
	}
}
