//
//  BurstlyInterstitial.h
//  BurstlyConvenienceLayer
//
//  Created by Abishek Ashok on 7/3/12.
//  Copyright (c) 2012 Burstly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BurstlyInterstitialDelegate.h"
#import "BurstlyAdRequest.h"

@class OAIAdManager;

// Use BurstlyInterstitialState to poll the current state of burstly interstitals.
typedef enum {
    
    /** The default state for interstitials. Returns to
     * this state if an ad fails to load or when the modal
     * takeover ends.
     **/
    BurstlyInterstitialStateStandBy,
    /**
     *  Indicates that a pre-cache request is pending.
     **/
    BurstlyInterstitialStatePreCaching,
    /**
     *  Pre-cache request succeeded. The interstitial is now
     *  ready to be displayed
     **/
    BurstlyInterstitialStatePreCached,
    /**
     *  The interstitial is loading state.
     *  This would be a good time to handle UI elements such
     *  as a spinner view to notify users that an ad is about
     *  to load
     **/
    BurstlyInterstitialStateLoading,
    /**
     *  The ad is visible on screen. You should
     *  remove any UI elements introduced while
     *  loading the ad. Any game activity should be paused
     *  during this state.
     **/
    BurstlyInterstitialStateVisible
} BurstlyInterstitialState;

@interface BurstlyInterstitial : NSObject {    
    OAIAdManager *_adManager;
}

/** Required value created via the Burstly web interface. Create
 *   a new appId for every application produced by your organization.
 *   Unless your application is universal, you should create a new
 *   app id for iPhone/iPad SKUs.
 *   Sample app id: 5fWofmS3902gWbwSZhXa1w
 **/
@property (nonatomic, retain) NSString *appId;

/** Required value created via the Burstly web interface for every
 *   unique placement of an ad in your application.
 **/
@property (nonatomic, retain) NSString *zoneId;

/** Delegate object that receives state change notifications when
 *  conforming to the BurstlyInterstitialDelegate protocol.
 *  Remember to explicitly set the delegate to nil when you
 *  release the delegate object.
 **/
@property (nonatomic, assign) id<BurstlyInterstitialDelegate> delegate;

/** This property can be used to poll the current state
 *  of the interstitial ad. Refer to the BurstlyInterstitialState
 *  enum constants for more info.
 **/
@property (nonatomic, readonly) BurstlyInterstitialState state;

/** Specifies the maximum timeout interval that the
 *  application is willing to wait before it has to continue
 *  with in-game activity. When the timeout fires, the Burstly
 *  SDK cancels pending requests in the queue. However, the current
 *  request in the queue may not be cancelled - Ideally you would
 *  specify a value lower that your application's internal timer
 *  to remove UI elements such as a spinner view prior to displaying
 *  an interstitial.
 **/
@property (nonatomic, assign) NSTimeInterval requestTimeout;


@property (nonatomic, retain) BurstlyAdRequest *adRequest;

/** Set to YES to enable automatic caching.
 * If enabled, this interstitial will automatically begin
 * caching before showAdWithRootViewController is called.
 * This is meant to reduce the delay in displaying an interstitial.
 **/
@property (nonatomic, readwrite) BOOL useAutomaticCaching;


#pragma Intialize the interstitial ad

- (id)initAppId:(NSString *)anAppId zoneId:(NSString *)aZoneId delegate:(id<BurstlyInterstitialDelegate>)aDelegate;
- (id)initAppId:(NSString *)anAppId zoneId:(NSString *)aZoneId delegate:(id<BurstlyInterstitialDelegate>)aDelegate useAutomaticCaching:(BOOL)automaticCaching;

// NOT FOR PRODUCTION USE. Init with integration mode and a specific test network.
- (id)initWithIntegrationModeTestNetwork:(BurstlyTestAdNetwork)aTestNetwork filterDeviceMacAddresses:(NSArray *)deviceMacAddresses delegate:(id<BurstlyInterstitialDelegate>)aDelegate;

/** Call to display an interstitial. Should be used in conjunction
 *  with cacheAd. 
 **/
- (void)showAd;

/** Call to precache an interstitial. Must be mapped to a corresponding
 *  request to display an ad. Ideally, this call should be made several
 *  seconds before invoking showAdWithRootViewController. You could also
 *  cache a subsequent ad from the burstlyInterstitial:willDismissFullScreen:
 *  callback.
 **/
- (void)cacheAd;

@end
