//
//  BurstlyInterstitialDelegate.h
//  BurstlyConvenienceLayer
//
//  Created by Abishek Ashok on 7/3/12.
//  Copyright (c) 2012 Burstly. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BurstlyInterstitial;

@protocol BurstlyInterstitialDelegate <NSObject>

@required
- (UIViewController*) viewControllerForModalPresentation:(BurstlyInterstitial *)interstitial;	/* Required, this must be your top most view controller */

@optional

// Sent when a modal view controller takes over the screen when showAd: is invoked. Use this callback
//  as an oppurtunity to implement state specific details such as pausing animation, timers, etc. The
// exact timing of this callback is not guaranteed as a few ad networks roll out the canvas
// prior to sending a callback whereas some others do the opposite. The following ad networks
// notify us prior to rolling out the canvas.
// Admob, Greystripe, Inmobi
// @param: adNetwork - Specifies the adNetwork that was displayed.
-(void) burstlyInterstitial:(BurstlyInterstitial *)ad willTakeOverFullScreen:(NSString*)adNetwork;

// Sent when the modal view controller is dismissed. This is a good time to cache an
// ad for the next attempt to display an interstitial. eg: between game levels.
-(void) burstlyInterstitial:(BurstlyInterstitial *)ad willDismissFullScreen:(NSString*)adNetwork;


-(void) burstlyInterstitial:(BurstlyInterstitial *)ad didHide:(NSString*)lastViewedNetwork;

// Sent when an interstitial ad request succeeded. This callback will be followed by
// burstlyInterstitial:willTakeOverFullScreen:. @param: adNetwork specifies the
// mediated network that just loaded.
-(void) burstlyInterstitial:(BurstlyInterstitial *)ad didShow:(NSString*)adNetwork;

// Sent when an ad is successfully precached. The ad is now ready to be displayed.
// Follow up with a call to showAd. @param: adNetwork specifies the mediated network
// that was cached.
// Discussion: Following a request to cache an ad, the adServer responds with a
// list of networks to mediate from. The list is auto-enumerated and the SDK traverses
// the list until an ad network succeeds. Note that while it is highly recommended
// that you cache an ad prior to displaying it, you could invoke showAd: directly
// and the auto-enumeration process would repeat. The ad will be displayed albeit
// delayed. If you do not choose to cache the ad, you must notify your users of a
// pending ad after calling showAd. You could remove the spinner after you recieve
// burstlyInterstitial:willTakeOverFullScreen: or burstlyInterstitial:didFailWithError:
//callbacks.
-(void) burstlyInterstitial:(BurstlyInterstitial *)ad didCache:(NSString*)adNetwork;

-(void) burstlyInterstitial:(BurstlyInterstitial *)ad wasClicked:(NSString*)adNetwork;

// Sent when the ad request has failed. Typically this would occur when either Burstly or
// one our 3rd party networks have no fill. Refer to NSError for more details.
// You could send a request to cache an ad for your next attempt.
-(void) burstlyInterstitial:(BurstlyInterstitial *)ad didFailWithError:(NSError*)error;

@end
