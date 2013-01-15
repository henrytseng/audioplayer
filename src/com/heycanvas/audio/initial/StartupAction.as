package com.heycanvas.audio.initial {
	import fluorescent.action.AbstractAction;
	import fluorescent.component.ComponentManager;
	import fluorescent.initial.IStartupAction;
	import fluorescent.initial.Initial;

	import halogen.debug.DebugLevel;
	import halogen.debug.Debugger;

	import com.heycanvas.audio.assets.ContentData;
	import com.heycanvas.audio.controls.ExternalControlProxy;
	import com.heycanvas.audio.engine.AudioEngineProxy;
	import com.heycanvas.audio.playlist.PlaylistProxy;
	import com.heycanvas.audio.playlist.TrackDataObject;
	import com.heycanvas.common.ConfigurationProxy;

	import flash.display.Sprite;

	/**
	 * @author htse
	 */
	public class StartupAction extends AbstractAction implements IStartupAction {
		// assoicated
		private var _initial : Initial;
		private var _site : Sprite;
		private var _contentData : XML;
		private var _engineProxy : AudioEngineProxy;
		private var _playlistProxy : PlaylistProxy;
		private var _configProxy : ConfigurationProxy;
		private var _externalProxy : ExternalControlProxy;

		// composed
		
		public function setInitial($initial : Initial) : void {
			_initial = $initial;
		}
		
		public function setSite($site : Sprite) : void {
			_site = $site;
		}
		
		override public function execute():void {
			_contentData = new XML(new ContentData());
			
			// create components
			_engineProxy = ComponentManager.createComponent('audioengine_proxy', AudioEngineProxy) as AudioEngineProxy;
			_playlistProxy = ComponentManager.createComponent('playlist_proxy', PlaylistProxy) as PlaylistProxy;
			_configProxy = ComponentManager.getComponent('configuration_proxy') as ConfigurationProxy;
			_externalProxy = ComponentManager.getComponent('externalcontrol_proxy') as ExternalControlProxy;
			
			// parse content
			_parseContent();
			
			// initialize components
			_engineProxy.init();
			
			// start up
			_externalProxy.connectExternal();
			_externalProxy.init(_configProxy.parameters);
			_playlistProxy.init(_configProxy.parameters);
			
			_onComplete();
		}
		
		private function _parseContent() : void {
			// if this fails error; error should be fatal, do not deploy to production
			for(var i:int=0; i<_contentData.playlist.item.length(); i++) {
				var track:TrackDataObject = new TrackDataObject();
				
				// default to default config
				if(_contentData.config..parameter.(@id=='streaming_connection').length() > 0) 
					track.connection = _contentData.config..parameter.(@id=='streaming_connection').@value;
				if(_contentData.config..parameter.(@id=='progressive_server').length() > 0)
					track.server = _contentData.config..parameter.(@id=='progressive_server').@value;
				
				// override with local config
				if(_contentData.playlist.item[i].config..parameter.(@id=='streaming_connection').length() > 0) 
					track.connection = _contentData.playlist.item[i].config..parameter.(@id=='streaming_connection').@value;
				if(_contentData.playlist.item[i].config..parameter.(@id=='progressive_server').length() > 0)
					track.server = _contentData.playlist.item[i].config..parameter.(@id=='progressive_server').@value;
				
				track.title = _contentData.playlist.item[i].title[0];
				track.artist = _contentData.playlist.item[i].artist[0];
				
				track.type = _contentData.playlist.item[i].audio[0].@type;
				track.src = _contentData.playlist.item[i].audio[0].@src;
				track.length = _contentData.playlist.item[i].audio[0].@length;
				
				track.extensionData = _contentData.playlist.item[i].extensionData[0];
				
				_playlistProxy.addTrack(track);
				
				Debugger.send('track['+i+']:'+track.length+':'+track.artist+' - '+track.title);
			}
		}
		
		override public function destroy():void {
			super.destroy();
			_contentData = null;
			_engineProxy = null;
			_playlistProxy = null;
			_configProxy = null;
			_externalProxy = null;
		}
	}
}
