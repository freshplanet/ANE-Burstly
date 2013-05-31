package com.freshplanet.ane.AirBurstly
{
	import flash.events.Event;

	public class BurstlyEvent extends Event
	{
		public static const INTERSTITIAL_WILL_DISMISS:String = "INTERSTITIAL_WILL_DISMISS";
		public static const INTERSTITIAL_DID_FAIL:String = "INTERSTITIAL_DID_FAIL";
		public static const INTERSTITIAL_WILL_APPEAR:String = "INTERSTITIAL_WILL_APPEAR";
		
		public function BurstlyEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}