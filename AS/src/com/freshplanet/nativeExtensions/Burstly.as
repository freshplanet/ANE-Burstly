//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

package com.freshplanet.nativeExtensions
{
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	public class Burstly extends EventDispatcher
	{
		private static var _instance:Burstly;
		
		private var _extCtx:ExtensionContext;
		
		private var _initialized:Boolean = false;
		
		public static function getInstance() : Burstly
		{
			return _instance ? _instance : new Burstly();
		}
		
		public function Burstly()
		{
			if (!_instance)
			{
				_extCtx = ExtensionContext.createExtensionContext("com.freshplanet.AirBurstly", null);
				if (_extCtx) _extCtx.addEventListener(StatusEvent.STATUS, onStatus);
				else trace('[Burstly] Error - Extension Context is null.');
				_instance = this;
			}
			else
			{
				throw Error('This is a singleton, use getInstance, do not call the constructor directly!');
			}
		}
		
		public function initBurstly( publisherId : String, zoneId : String ) : void
		{
			_extCtx.call('initBurstly', publisherId, zoneId);
			_initialized = true;
		}
		
		public function get isInitialized() : Boolean
		{
			return _initialized;
		}
		
		public function displayAd() : void
		{
			_extCtx.call('displayAd');
		}
		
		public function hideAd() : void
		{
			_extCtx.call('hideAd');
		}
		
		private function onStatus( event : StatusEvent ) : void
		{
			if (event.code == "LOGGING")
				trace('[Burstly] ' + event.level);
		}
		
		
	}
}