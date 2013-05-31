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

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import android.util.Log;
import android.view.Gravity;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.FrameLayout;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.burstly.lib.conveniencelayer.Burstly;
import com.burstly.lib.conveniencelayer.BurstlyAnimatedBanner;
import com.burstly.lib.conveniencelayer.BurstlyBaseAd;
import com.burstly.lib.conveniencelayer.BurstlyInterstitial;
import com.burstly.lib.conveniencelayer.IBurstlyListener;
import com.burstly.lib.conveniencelayer.events.AdCacheEvent;
import com.burstly.lib.conveniencelayer.events.AdClickEvent;
import com.burstly.lib.conveniencelayer.events.AdDismissFullscreenEvent;
import com.burstly.lib.conveniencelayer.events.AdFailEvent;
import com.burstly.lib.conveniencelayer.events.AdHideEvent;
import com.burstly.lib.conveniencelayer.events.AdPresentFullscreenEvent;
import com.burstly.lib.conveniencelayer.events.AdShowEvent;
import com.freshplanet.burstly.functions.AirBurstlyCacheInterstitial;
import com.freshplanet.burstly.functions.AirBurstlyGetSDKVersion;
import com.freshplanet.burstly.functions.AirBurstlyHideBanner;
import com.freshplanet.burstly.functions.AirBurstlyInit;
import com.freshplanet.burstly.functions.AirBurstlyIsInterstitialPreCached;
import com.freshplanet.burstly.functions.AirBurstlyOnPause;
import com.freshplanet.burstly.functions.AirBurstlyOnResume;
import com.freshplanet.burstly.functions.AirBurstlySetUserInfo;
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
		
		functionMap.put("AirBurstlyInit", new AirBurstlyInit());
		functionMap.put("AirBurstlySetUserInfo", new AirBurstlySetUserInfo());
		functionMap.put("AirBurstlyShowBanner", new AirBurstlyShowBanner());
		functionMap.put("AirBurstlyHideBanner", new AirBurstlyHideBanner());
		functionMap.put("AirBurstlyIsInterstitialPreCached", new AirBurstlyIsInterstitialPreCached());
		functionMap.put("AirBurstlyCacheInterstitial", new AirBurstlyCacheInterstitial());
		functionMap.put("AirBurstlyShowInterstitial", new AirBurstlyShowInterstitial());
		functionMap.put("AirBurstlyOnResume", new AirBurstlyOnResume());
		functionMap.put("AirBurstlyOnPause", new AirBurstlyOnPause());
		functionMap.put("AirBurstlyGetSDKVersion", new AirBurstlyGetSDKVersion());
		
		return functionMap;	
	}
	
	public void init(String appId, String bannerZoneId, String interstitialZoneId, String[] additionalInterstitialZoneIds)
	{
		if (appId == null)
		{
			Extension.log("Error - init - appId can't be null!");
			return;
		}
		
		Burstly.init(getActivity(), appId);
		
		if (bannerZoneId != null)
		{
			_banner = new BurstlyAnimatedBanner(getActivity(), getBannerContainer(), new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL), bannerZoneId, BANNER, 30, true);
			_banner.addBurstlyListener(this);
		}
		
		if (interstitialZoneId != null)
		{
			_interstitial = new BurstlyInterstitial(getActivity(), interstitialZoneId, INTERSTITIAL, false);
			_interstitial.addBurstlyListener(this);
		}
		
		if (additionalInterstitialZoneIds != null)
		{
			_additionalInterstitials = new HashMap<String, BurstlyInterstitial>();
			Extension.log("Info - putting new additional zones (" + Integer.toString(additionalInterstitialZoneIds.length)+")!");
			for (int i=0; i<additionalInterstitialZoneIds.length; i++ )
			{
				String key = additionalInterstitialZoneIds[i];
				if (key != null)
				{
					BurstlyInterstitial interstitial = new BurstlyInterstitial(getActivity(), additionalInterstitialZoneIds[i], INTERSTITIAL, false);
					interstitial.addBurstlyListener(this);
					_additionalInterstitials.put(key, interstitial);
				}
			}
		} else
		{
			Extension.log("Warning - no additional Zone ids!");
		}
		
		
		Extension.log("Info - Did init with appId = " + appId + ", bannerZoneId = " + bannerZoneId + ", interstitialZoneId = " + interstitialZoneId);
	}
	
	public void setUserInfo(Map<String, String> infos)
	{
		String strInfos = "";
		for (Entry<String, String> entry : infos.entrySet())
		{
			if (strInfos.length() > 0)
				strInfos = strInfos+",";
			strInfos = strInfos+entry.getKey()+"="+entry.getValue();
		}
		
		if (_banner != null)
		{
			_banner.setBurstlyUserInfo(infos);
			_banner.setTargetingParameters(strInfos);
		}
		
		if (_interstitial != null)
		{
			_interstitial.setBurstlyUserInfo(infos);
			_interstitial.setTargetingParameters(strInfos);
		}
		
		if (_additionalInterstitials != null)
		{
			for (BurstlyInterstitial interstitial: _additionalInterstitials.values())
			{
				interstitial.setBurstlyUserInfo(infos);
				interstitial.setTargetingParameters(strInfos);
			}
		}
		
		
		Extension.log("Info - Did set user infos: " + strInfos);
	}
	
	public void showBanner()
	{
		if (_banner != null)
		{
			getRootContainer().addView(getBannerContainer());
			_banner.showAd();
		}
	}
	
	public void hideBanner()
	{
		if (_banner != null)
		{
			_banner.hideAd();
			getRootContainer().removeView(getBannerContainer());
		}
		
	}
	
	public Boolean isInterstitialPreCached()
	{
		return _interstitial.hasCachedAd();
	}
	
	public void cacheInterstitial()
	{
		if (_interstitial != null)
		{
			_interstitial.cacheAd();
		}
	}
	
	public void showInterstitial()
	{
		if (_interstitial != null)
		{
			_interstitial.showAd();
		}
	}
	
	public void showInterstitialWithZoneId(String zoneId)
	{
		BurstlyInterstitial interstitial = null;
		if (_additionalInterstitials != null)
		{
			interstitial = _additionalInterstitials.get(zoneId);
		}
		if (interstitial != null)
		{
			interstitial.showAd();
		} else
		{
			Log.d("extension context", "couldnt find the interstitial");
		}
	}

	
	
	// Private API
	
	private static final String BANNER = "banner";
	private static final String INTERSTITIAL = "interstitial";
	
	private ViewGroup _bannerContainer;
	private BurstlyAnimatedBanner _banner;
	private BurstlyInterstitial _interstitial;
	private HashMap<String, BurstlyInterstitial> _additionalInterstitials;
	
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
	
	
	// IBurstlyListener
	
	public void onHide(BurstlyBaseAd ad, AdHideEvent event)
	{
		String network = event.getMatchingShowEvent().getLoadedCreativeNetwork() != null ? event.getMatchingShowEvent().getLoadedCreativeNetwork() : "unknown network";
		Extension.log("Info - Did hide " + network + " " + ad.getName());
	}
	
	public void onShow(BurstlyBaseAd ad, AdShowEvent event)
	{
		String network = event.getLoadedCreativeNetwork() != null ? event.getLoadedCreativeNetwork() : "unknown network";
		Extension.log("Info - Did show " + network + " " + ad.getName());
	}
	
	public void onFail(final BurstlyBaseAd ad, final AdFailEvent event)
	{
		String verb = event.wasFailureResultOfCachingAttempt() ? "cache" : "show";
		String network = event.getFailedCreativesNetworks() != null && event.getFailedCreativesNetworks().size() > 0 ? event.getFailedCreativesNetworks().toString() : "unknown network";
		Extension.log("Warning - Did fail to " + verb + " " + ad.getName() + " for " + network);
		
		if (ad == _interstitial)
		{
			dispatchStatusEventAsync("INTERSTITIAL_DID_FAIL", "OK");
		}
	}
	
	public void onCache(final BurstlyBaseAd ad, final AdCacheEvent event)
	{
		String network = event.getLoadedCreativeNetwork() != null ? event.getLoadedCreativeNetwork() : "unknown network";
		Extension.log("Info - Did cache " + network + " " + ad.getName());
	}
	
	public void onClick(final BurstlyBaseAd ad, final AdClickEvent event)
	{
		String network = event.getClickedNetwork() != null ? event.getClickedNetwork() : "unknown network";
		Extension.log("Info - Did click " + network + " " + ad.getName());
	}
	
	public void onPresentFullscreen(final BurstlyBaseAd ad, final AdPresentFullscreenEvent event)
	{
		Extension.log("Info - Will present fullscreen " + ad.getName());
		
		Boolean isRegisteredInterstitial = ad == _interstitial || (_additionalInterstitials != null && _additionalInterstitials.get(ad.getZoneId()) != null) ;
		if (isRegisteredInterstitial)
		{
			dispatchStatusEventAsync("INTERSTITIAL_WILL_APPEAR", "OK");
		}
	}
	
	public void onDismissFullscreen(final BurstlyBaseAd ad, final AdDismissFullscreenEvent event)
	{
		Extension.log("Info - Will dismiss fullscreen " + ad.getName());
		Boolean isRegisteredInterstitial = ad == _interstitial || (_additionalInterstitials != null && _additionalInterstitials.get(ad.getZoneId()) != null) ;
		if (isRegisteredInterstitial)
		{
			dispatchStatusEventAsync("INTERSTITIAL_WILL_DISMISS", "OK");
		}
		
	}
}
