package com.burstly.lib.constants;

import java.util.Properties;

import android.content.Context;

import com.burstly.lib.BurstlySdk;
import com.burstly.lib.exception.BurstlySdkNotInitializedException;

public final class BurstlyProperties
{
  public static final String TAG = BurstlyProperties.class.getName();

  private static Properties sProperties = new Properties();
  private static volatile boolean sIsLoaded;

  public static void initProperties(Context context)
  {
    if (!sIsLoaded) {
//      loadPropertiesFromFile(context, "burstly.properties");
//      loadPropertiesFromFile(context, "version.properties");
    	
		sProperties.setProperty(PropertyKey.IS_DEBUG_MODE, "false");
		sProperties.setProperty(PropertyKey.GLOBAL_ADAPTOR_TIMEOUT, "35000");
    	sProperties.setProperty(PropertyKey.PRIMARY_HOST, "req.appads.com");
    	sProperties.setProperty(PropertyKey.CURRENCY_SECURED_POINT, "/Services/Secured/Service1.svc/Process/v1");
    	sProperties.setProperty(PropertyKey.CURRENCY_SERVER_LIST, "/Services/SysInfo.svc/GetServersList");
    	sProperties.setProperty(PropertyKey.CURRENCY_PRIMARY_HOST, "lv.appads.com");
    	sProperties.setProperty(PropertyKey.SINGLE_AD_URI, "/Services/PubAd.svc/GetSingleAdPlacement");
    	sProperties.setProperty(PropertyKey.SINGLE_TRACK_URI, "/Services/PubAd.svc/Track");
    	sProperties.setProperty(PropertyKey.SINGLE_TRACK_CLICK_URI, "/Services/PubAd.svc/Click");
    	sProperties.setProperty(PropertyKey.SINGLE_DOWNLOAD_TRACK_URI, "/scripts/ConfirmDownload.aspx");
    	sProperties.setProperty(PropertyKey.CONFIGURATION_URI, "/Services/Client.svc/GetConfiguration");
    	sProperties.setProperty(PropertyKey.CONTENT_ROOT, "http://cdn.appads.com/sdk");
    	sProperties.setProperty(PropertyKey.SDK_VERSION, "1.20.0.35186");
    	sProperties.setProperty(PropertyKey.AD_SERVER_URI, "/Services/SysInfo.svc/GetAdServerList");
    	
      sIsLoaded = true;
    }
  }

//  private static void loadPropertiesFromFile(Context context, String fileName)
//  {
//    AssetManager assetsManager = context.getAssets();
//    InputStream in = null;
//    try {
//      in = assetsManager.open(fileName);
//      sProperties.load(in);
//    }
//    catch (Exception e) {
//      Log.e(TAG, "FATAL ERROR! Application could not find properties file: " + fileName);
//    }
//    finally {
//      close(in);
//    }
//  }

//  private static void close(InputStream in)
//  {
//    if (in != null)
//      try {
//        in.close();
//      }
//      catch (IOException e)
//      {
//      }
//  }

  public static String getString(String propKey)
  {
    if (BurstlySdk.wasInit()) {
      if (sIsLoaded) {
        return sProperties.getProperty(propKey, "Can not find property with key :" + propKey);
      }
      return "Property file is not initialized!";
    }
    throw new BurstlySdkNotInitializedException();
  }

  static final class PropertyKey
  {
    static final String IS_DEBUG_MODE = "isDebug";
    static final String GLOBAL_ADAPTOR_TIMEOUT = "globalAdaptorTimeout";
    static final String PRIMARY_HOST = "connect.singleAdHost";
    static final String CURRENCY_SECURED_POINT = "currency.encrypted.point";
    static final String CURRENCY_SERVER_LIST = "connect.serverList";
    static final String CURRENCY_PRIMARY_HOST = "currency.host";
    static final String SINGLE_AD_URI = "connect.singleAdUri";
    static final String SINGLE_TRACK_URI = "connect.singleTrackUri";
    static final String SINGLE_TRACK_CLICK_URI = "connect.singleTrackClickUri";
    static final String SINGLE_DOWNLOAD_TRACK_URI = "connect.singleDownloadTrackUri";
    static final String CONFIGURATION_URI = "connect.confService";
    static final String CONTENT_ROOT = "connect.contentRoot";
    static final String SDK_VERSION = "sdk.version";
    static final String AD_SERVER_URI = "connect.adServerList";
  }
}