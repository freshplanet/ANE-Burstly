Air Native Extension for Burstly (iOS only)
======================================

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for [Burstly](http://burstly.com) SDK on iOS. It has been developed by [FreshPlanet](http://freshplanet.com) and is used in the game [SongPop](http://songpop.fm).


Burstly
-------

This ANE only works for displaying a banner ad at the bottom of the screen.

It has been tested with the following third-party networks:

* AdMob
* Greystripe
* iAd
* InMobi
* Jumptap
* Millenial Media


Installation
---------

The ANE binary (AirBurstly.ane) is located in the *bin* folder. You should add it to your application project's Build Path and make sure to package it with your app (more information [here](http://help.adobe.com/en_US/air/build/WS597e5dadb9cc1e0253f7d2fc1311b491071-8000.html)).


Usage
-----

Here are the three lines of Actionscript code you need to use this ANE:
    
    // Initialize the extension
    Burstly.getInstance().initBurstly("yourPublisherID", "yourZoneID");

    // Display the banner
    Burstly.getInstance().displayAd();

    // Hide the banner
    Burstly.getInstance().hideAd();


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