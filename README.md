Air Native Extension for Burstly (iOS + Android)
======================================

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for [Burstly](http://burstly.com) SDK on iOS and Android. It has been developed by [FreshPlanet](http://freshplanet.com) and is used in the game [SongPop](http://songpop.fm).


Burstly SDK
--------

This ANE includes the following versions of the Burstly SDK:
* iOS: 1.40
* Android: 1.24

It only supports displaying a bottom banner and/or a fullscreen interstitial.


Installation
---------

The ANE binary (AirBurstly.ane) is located in the *bin* folder. You should add it to your application project's Build Path and make sure to package it with your app (more information [here](http://help.adobe.com/en_US/air/build/WS597e5dadb9cc1e0253f7d2fc1311b491071-8000.html)).


Usage
-----
    
    ```actionscript
    // Initialize Burstly
    Burstly.getInstance().init("MY_BURSTLY_APP_ID", "MY_BURSTLY_BANNER_ZONE_ID", "MY_BURSTLY_INTERSTITIAL_ZONE_ID");

    // Show the banner
    Burstly.getInstance().showBanner();

    // Hide the banner
    Burstly.getInstance().hideBanner();

    // Check if an interstitial is pre-cached
    Burstly.getInstance().isInterstitialPreCached();

    // Cache the interstitial
    Burstly.getInstance().cacheInterstitial();

    // Show the interstitial
    Burstly.getInstance().showInterstitial();
    ```


Build script
---------

Should you need to edit the extension source code and/or recompile it, you will find an ant build script (build.xml) in the *build* folder:

    cd /path/to/the/ane/build
    mv example.build.config build.config
    #edit the build.config file to provide your machine-specific paths
    ant


Authors
------

This ANE has been written by [Alexis Taugeron](http://alexistaugeron.com). It belongs to [FreshPlanet Inc.](http://freshplanet.com) and is distributed under the [Apache Licence, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).