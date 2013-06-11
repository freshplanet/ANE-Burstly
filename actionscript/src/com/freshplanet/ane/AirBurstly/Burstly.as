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

package com.freshplanet.ane.AirBurstly
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
	
	public class Burstly extends EventDispatcher
	{
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		public var logEnabled : Boolean = false;
		
		/** Burstly is supported on iOS and Android devices. */
		public static function get isSupported() : Boolean
		{
			return Capabilities.manufacturer.indexOf("iOS") != -1 || Capabilities.manufacturer.indexOf("Android") != -1;
		}
		
		public function Burstly()
		{
			if (!_instance)
			{
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				if (!_context)
				{
					log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
					return;
				}
				_context.addEventListener(StatusEvent.STATUS, onStatus);
				
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onNativeApplicationActivate, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onNativeApplicationDeactivate, false, 0, true);
				
				_instance = this;
			}
			else
			{
				throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
			}
		}
		
		public static function getInstance() : Burstly
		{
			return _instance ? _instance : new Burstly();
		}
		
		/** Burstly SDK version depends on the platform. */
		public function get sdkVersion() : String 
		{
			if (!isSupported) return null;
			
			return _context.call("AirBurstlyGetSDKVersion") as String;
		}
		
		public function init( appId : String, bannerZoneId : String, interstitialZoneId : String, additionalZoneIds : Array = null ) : void
		{
			if (!isSupported) return;
			
			if (additionalZoneIds != null)
			{
				_context.call("AirBurstlyInit", appId, bannerZoneId, interstitialZoneId, additionalZoneIds);
			} else
			{
				_context.call("AirBurstlyInit", appId, bannerZoneId, interstitialZoneId);
			}
		}
		
		public function showBanner() : void
		{
			if (!isSupported) return;
			
			_context.call("AirBurstlyShowBanner");
		}
		
		public function hideBanner() : void
		{
			if (!isSupported) return;
			
			_context.call("AirBurstlyHideBanner");
		}
		
		public function isInterstitialPreCached() : Boolean
		{
			if (!isSupported) return false;
			
			return _context.call("AirBurstlyIsInterstitialPreCached");
		}
		
		public function cacheInterstitial(additionalZoneId : String = null) : void
		{
			if (!isSupported) return;
			
			if (additionalZoneId != null)
			{
				_context.call("AirBurstlyCacheInterstitial", additionalZoneId);
			} else
			{
				_context.call("AirBurstlyCacheInterstitial");
			}
		}
		
		public function showInterstitial(additionalZoneId : String = null) : void
		{
			if (!isSupported) return;
			
			if (additionalZoneId != null)
			{
				_context.call("AirBurstlyShowInterstitial", additionalZoneId);
			} else
			{
				_context.call("AirBurstlyShowInterstitial");
			}
		}
		
		public function setUserInfo( infos : Object ) : void
		{
			if (!isSupported) return;
			
			// Separate parameters keys and values
			var keys:Array = []; var values:Array = [];
			for (var key:String in infos)
			{
				keys.push(key);
				values.push(infos[key]);
			}
			
			_context.call("AirBurstlySetUserInfo", keys, values);
		}
		
		
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private static const EXTENSION_ID : String = "com.freshplanet.AirBurstly";
		
		private static var _instance : Burstly;
		
		private var _context : ExtensionContext;
		
		private function onStatus( event : StatusEvent ) : void
		{
			if (event.code == "LOGGING")
			{
				log(event.level);
			}
			else if ([BurstlyEvent.INTERSTITIAL_WAS_CLICKED, BurstlyEvent.INTERSTITIAL_WILL_DISMISS, BurstlyEvent.INTERSTITIAL_DID_FAIL, BurstlyEvent.INTERSTITIAL_WILL_APPEAR].indexOf(event.code) > -1)
			{
				dispatchEvent(new BurstlyEvent(event.code));
			}
		}
		
		private function onNativeApplicationActivate( event : Event ) : void
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				_context.call("AirBurstlyOnResume");
			}
		}
		
		private function onNativeApplicationDeactivate( event : Event ) : void
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				_context.call("AirBurstlyOnPause");
			}
		}
		
		private function log( message : String ) : void
		{
			if (logEnabled) trace("[Burstly] " + message);
		}
	}
}