package com.heycanvas.audio.initial {
	import halogen.debug.widgets.FramerateStat;
	import fluorescent.action.AbstractAction;
	import fluorescent.component.ComponentManager;
	import fluorescent.initial.IStartupAction;
	import fluorescent.initial.Initial;

	import halogen.debug.Debugger;
	import halogen.debug.widgets.MemoryStat;

	import com.heycanvas.audio.controls.ExternalControlProxy;
	import com.heycanvas.common.ConfigurationProxy;
	import com.heycanvas.common.StageProxy;

	import flash.display.Sprite;
	import flash.utils.getTimer;

	/**
	 * @author htse
	 */
	public class InitialAction extends AbstractAction implements IStartupAction {
		// assoicated
		private var _initial : Initial;
		private var _site : Sprite;
		private var _stageProxy : StageProxy;
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
			/*FDT_IGNORE*/
			if(CONFIG::RELEASE == true && CONFIG::DEBUG == false) {
			/*FDT_IGNORE*/
				Debugger.disable();
				
			/*FDT_IGNORE*/
			} else {
			/*FDT_IGNORE*/
				_initial.addChild(new MemoryStat());
				_initial.addChild(new FramerateStat(true));
				Debugger.enable();
			/*FDT_IGNORE*/
			}
			/*FDT_IGNORE*/
			
			Debugger.send('time:'+getTimer());
			
			// create components
			_stageProxy = ComponentManager.createComponent('stage_proxy', StageProxy) as StageProxy;
			_configProxy = ComponentManager.createComponent('configuration_proxy', ConfigurationProxy) as ConfigurationProxy;
			_externalProxy = ComponentManager.createComponent('externalcontrol_proxy', ExternalControlProxy) as ExternalControlProxy;
			
			// initialize components
			_stageProxy.init(_initial);
			_configProxy.init(_initial.loaderInfo.parameters);
			
			_onComplete();
		}
		
		override public function destroy():void {
			super.destroy();
			_stageProxy = null;
			_configProxy = null;
			_externalProxy = null;
		}
	}
}
