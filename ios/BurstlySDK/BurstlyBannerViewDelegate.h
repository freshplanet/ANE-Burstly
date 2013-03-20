//
//  BurstlyBannerViewDelegate.h
//  BurstlyConvenienceLayer
//
//  Created by Abishek Ashok on 7/3/12.
//  Copyright (c) 2012 Burstly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BurstlyBannerAdView;

@protocol BurstlyBannerViewDelegate <NSObject>

@optional

// Sent when the ad view takes over the screen when the banner is clicked. Use this callback as an
// oppurtunity to implement state specific details such as pausing animation, timers, etc. The
// exact timing of this callback is not guaranteed as a few ad networks roll out the canvas
// prior to sending a callback whereas some others do the opposite. The following ad networks
// notify us prior to rolling out the canvas.
// Admob, Greystripe, Inmobi
// @param: adNetwork - Specifies the adNetwork that was displayed.
-(void) burstlyBannerAdView:(BurstlyBannerAdView *)view willTakeOverFullScreen:(NSString*)adNetwork;

// Sent when the ad view is dismissed from screen.
-(void) burstlyBannerAdView:(BurstlyBannerAdView *)view willDismissFullScreen:(NSString*)adNetwork;

-(void) burstlyBannerAdView:(BurstlyBannerAdView *)view didHide:(NSString*)lastViewedNetwork;

// Sent when an ad request succeeded and a valid view is available to be displayed.
// @param: adNetwork - Specifies the network that was loaded.
-(void) burstlyBannerAdView:(BurstlyBannerAdView *)view didShow:(NSString*)adNetwork;

// Typically caching a banner is not required as it does not introduce delays that affect user
// experience. But in select cases, the game may run in to resource intensive modes and would require
// the ad to be loaded during off-peak intervals such as in-between levels. This is when you may want
// to cache a banner and animate the view whenever applicable.
-(void) burstlyBannerAdView:(BurstlyBannerAdView *)view didCache:(NSString*)adNetwork;

// Sent when the banner ad view is clicked.
-(void) burstlyBannerAdView:(BurstlyBannerAdView *)view wasClicked:(NSString*)adNetwork;

// Sent when the ad request has failed. Typically this would occur when either Burstly or
// one our 3rd party networks have no fill. Refer to NSError for more details.
-(void) burstlyBannerAdView:(BurstlyBannerAdView *)view didFailWithError:(NSError*)error;

@end

