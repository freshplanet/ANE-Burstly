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

package com.freshplanet.burstly;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import android.view.Gravity;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.FrameLayout;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.burstly.conveniencelayer.Burstly;
import com.burstly.conveniencelayer.BurstlyAnimatedBanner;
import com.burstly.conveniencelayer.BurstlyBaseAd;
import com.burstly.conveniencelayer.BurstlyInterstitial;
import com.burstly.conveniencelayer.IBurstlyListener;
import com.burstly.conveniencelayer.events.AdCacheEvent;
import com.burstly.conveniencelayer.events.AdClickEvent;
import com.burstly.conveniencelayer.events.AdDismissFullscreenEvent;
import com.burstly.conveniencelayer.events.AdFailEvent;
import com.burstly.conveniencelayer.events.AdHideEvent;
import com.burstly.conveniencelayer.events.AdPresentFullscreenEvent;
import com.burstly.conveniencelayer.events.AdShowEvent;
import com.freshplanet.burstly.functions.AirBurstlyGetSDKVersion;
import com.freshplanet.burstly.functions.AirBurstlyHideBanner;
import com.freshplanet.burstly.functions.AirBurstlyIsInterstitialPreCached;
import com.freshplanet.burstly.functions.AirBurstlyOnPause;
import com.freshplanet.burstly.functions.AirBurstlyOnResume;
import com.freshplanet.burstly.functions.AirBurstlySetAppId;
import com.freshplanet.burstly.functions.AirBurstlySetBannerZoneId;
import com.freshplanet.burstly.functions.AirBurstlySetInterstitialZoneId;
import com.freshplanet.burstly.functions.AirBurstlyShowBanner;
import com.freshplanet.burstly.functions.AirBurstlyShowInterstitial;

public class ExtensionContext extends FREContext implements IBurstlyListener
{
	// Public API
	
	@Override
	public void dispose() { }

	@Override
	public Map<String, FREFunction> getFunctions()
	{
		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
		
		functionMap.put("AirBurstlySetAppId", new AirBurstlySetAppId());
		functionMap.put("AirBurstlySetBannerZoneId", new AirBurstlySetBannerZoneId());
		functionMap.put("AirBurstlySetInterstitialZoneId", new AirBurstlySetInterstitialZoneId());
		functionMap.put("AirBurstlyShowBanner", new AirBurstlyShowBanner());
		functionMap.put("AirBurstlyHideBanner", new AirBurstlyHideBanner());
		functionMap.put("AirBurstlyIsInterstitialPreCached", new AirBurstlyIsInterstitialPreCached());
		functionMap.put("AirBurstlyShowInterstitial", new AirBurstlyShowInterstitial());
		functionMap.put("AirBurstlyOnResume", new AirBurstlyOnResume());
		functionMap.put("AirBurstlyOnPause", new AirBurstlyOnPause());
		functionMap.put("AirBurstlyGetSDKVersion", new AirBurstlyGetSDKVersion());
		
		return functionMap;	
	}
	
	public void setAppId(String appId)
	{
		if (appId != _appId)
		{
			if (_banner != null)
			{
				hideBanner();
				_banner = null;
			}
			
			_interstitial = null;
			
			_appId = appId;
			
			if (_initialized)
			{
				Burstly.deinit();
				_initialized = false;
			}
		}
	}
	
	public void setBannerZoneId(String zoneId)
	{
		if (zoneId != _bannerZoneId)
		{
			if (_banner != null)
			{
				hideBanner();
				_banner = null;
			}
			
			_bannerZoneId = zoneId;
		}
	}
	
	public void setInterstitialZoneId(String zoneId)
	{
		if (zoneId != _interstitialZoneId)
		{
			_interstitial = null;
			
			_interstitialZoneId = zoneId;
			
			getInterstitial().cacheAd();
		}
	}
	
	public void showBanner()
	{
		getRootContainer().addView(getBannerContainer());
		getBanner().showAd();
	}
	
	public void hideBanner()
	{
		getBanner().hideAd();
		getRootContainer().removeView(getBannerContainer());
	}
	
	public Boolean isInterstitialPreCached()
	{
		return true;
		//return getInterstitial().hasCachedAd();
	}
	
	public void showInterstitial()
	{
		getInterstitial().showAd();
	}
	
	
	// Private API
	
	private static final ScheduledExecutorService worker = Executors.newSingleThreadScheduledExecutor();
	
	private Boolean _initialized = false;
	
	private ViewGroup _bannerContainer;
	private BurstlyAnimatedBanner _banner;
	private BurstlyInterstitial _interstitial;
	
	private String _appId;
	private String _bannerZoneId;
	private String _interstitialZoneId;
	
	private void initialize()
	{
		Burstly.init(getActivity(), _appId);
		Burstly.setLoggingEnabled(false);
		_initialized = true;
	}
	
	private ViewGroup getRootContainer()
	{
		return (ViewGroup)((ViewGroup)getActivity().findViewById(android.R.id.content)).getChildAt(0);
	}
	
	private ViewGroup getBannerContainer()
	{
		if (_bannerContainer == null)
		{
			_bannerContainer = new FrameLayout(getActivity());
			
			FrameLayout.LayoutParams layoutParams;
			float scale = getActivity().getResources().getDisplayMetrics().density;
			int tabletBannerWidth = Math.round(728*scale);
			int tabletBannerHeight = Math.round(90*scale);
			int phoneBannerWidth = Math.round(320*scale);
			int phoneBannerHeight = Math.round(53*scale);
			if (getRootContainer().getWidth() >= tabletBannerWidth)
			{
				layoutParams = new FrameLayout.LayoutParams(tabletBannerWidth, tabletBannerHeight, Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL);
			}
			else
			{
				layoutParams = new FrameLayout.LayoutParams(phoneBannerWidth, phoneBannerHeight, Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL);
			}
			_bannerContainer.setLayoutParams(layoutParams);
		}
		
		return _bannerContainer;
	}
	
	private BurstlyAnimatedBanner getBanner()
	{
		if (_banner == null)
		{
			if (!_initialized) initialize();
			
			_banner = new BurstlyAnimatedBanner(getActivity(), getBannerContainer(), new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL), _bannerZoneId, "Banner", 30, true);
			_banner.addBurstlyListener(this);
		}
		
		return _banner;
	}
	
	private BurstlyInterstitial getInterstitial()
	{
		if (_interstitial == null)
		{
			if (!_initialized) initialize();
			
			_interstitial = new BurstlyInterstitial(getActivity(), _interstitialZoneId, "Interstitial", false);
			_interstitial.addBurstlyListener(this);
			
			HashMap<String, String> map = new HashMap<String, String>();
			map.put("sid", "267063");
			_interstitial.setBurstlyUserInfo(map);
		}
		
		return _interstitial;
	}
	
	
	// IBurstlyListener
	
	public void onHide(BurstlyBaseAd ad, AdHideEvent event)
	{
		Extension.log("On hide: " + ad.getName() + " ("+ad.getZoneId()+")");
	}
	
	public void onShow(BurstlyBaseAd ad, AdShowEvent event)
	{
		Extension.log("On show: " + ad.getName() + " ("+ad.getZoneId()+")");
	}
	
	public void onFail(final BurstlyBaseAd ad, final AdFailEvent event)
	{
		Extension.log("On fail: " + ad.getName() + " ("+ad.getZoneId()+") [ network: " + event.getFailedCreativesNetworks() + " - was caching: " + event.wasFailureResultOfCachingAttempt() + " - next request in: " + event.getMinTimeUntilNextRequest() + "]");
		
		if (ad == getInterstitial())
		{
			Runnable retry = new Runnable() {
				public void run() {
					getInterstitial().cacheAd();
				}
			};
			worker.schedule(retry, event.getMinTimeUntilNextRequest()+500, TimeUnit.MILLISECONDS);
			
			if (!event.wasFailureResultOfCachingAttempt())
			{
				dispatchStatusEventAsync("INTERSTITIAL_DID_FAIL", "OK");
			}
		}
	}
	
	public void onCache(final BurstlyBaseAd ad, final AdCacheEvent event)
	{
		Extension.log("On cache: " + ad.getName() + " ("+ad.getZoneId()+")");
	}
	
	public void onClick(final BurstlyBaseAd ad, final AdClickEvent event)
	{
		Extension.log("On click: " + ad.getName() + " ("+ad.getZoneId()+")");
	}
	
	public void onPresentFullscreen(final BurstlyBaseAd ad, final AdPresentFullscreenEvent event)
	{
		Extension.log("On present fullscreen: " + ad.getName() + " ("+ad.getZoneId()+")");
	}
	
	public void onDismissFullscreen(final BurstlyBaseAd ad, final AdDismissFullscreenEvent event)
	{
		Extension.log("On dismiss fullscreen: " + ad.getName() + " ("+ad.getZoneId()+")");
		
		if (ad == getInterstitial())
		{
			dispatchStatusEventAsync("INTERSTITIAL_WILL_DISMISS", "OK");
			getInterstitial().cacheAd();
		}
		
	}
}
