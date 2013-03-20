//
//  BurstlyBannerAdView.h
//  BurstlyConvenienceLayer
//
//  Created by Abishek Ashok on 7/3/12.
//  Copyright (c) 2012 Burstly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BurstlyBannerViewDelegate.h"
#import "BurstlyAdRequest.h"

#pragma mark -
#pragma mark Ad Sizes

// iPhone and iPod Touch ad size.
#define BBANNER_SIZE_320x53     CGSizeMake(320, 53)

// Medium Rectangle size for the iPhone/iPad
#define BBANNER_SIZE_300x250    CGSizeMake(300, 250)

// Leaderboard size for the iPad.
#define BBANNER_SIZE_728x90     CGSizeMake(728, 90)

// Skyscraper size for the iPad.
#define BBANNER_SIZE_120x600    CGSizeMake(120, 600)

@class OAIAdManager;
/** The anchor tag specifies the region on the frame from where the banner ad fills out.
 Specifying the anchor ensures that the ads of varying sizes (in pixels) are held in place
 with respect to their superview.
 */
typedef enum {
	kBurstlyAnchorBottom			= 0x1,
	kBurstlyAnchorTop				= 0x2,
	kBurstlyAnchorLeft				= 0x4,
	kBurstlyAnchorRight             = 0x8,
	kBurstlyAnchorCenter			= 0xF  // Equal to Anchor_Bottom | Anchor_Top | Anchor_Left | Anchor_Right
} BurstlyAnchor;

@interface BurstlyBannerAdView : UIView {
    OAIAdManager *_adManager;
}

// The width and height of the banner ad that was last loaded.
@property CGSize adSize;

// Should set to YES if the banner ad should no longer appear on screen.
// Should set to NO if the banner ad should resume displaying on screen.
@property (nonatomic, assign, getter =isAdPaused) BOOL adPaused;

// Required value created via the Burstly web interface. Create
// a new appId for every application produced by your organization.
// Unless your application is universal, you should create a new
// app id for iPhone/iPad SKUs.
// Sample app id: 5fWofmS3902gWbwSZhXa1w
@property (nonatomic, retain) NSString *appId;

// Required value created via the Burstly web interface for every
// unique placement of an ad in your application.
@property (nonatomic, retain) NSString *zoneId;

// The anchor tag specifies the region on the frame from where the banner ad fills out.
// Specifying the anchor ensures that the ads of varying sizes (in pixels) are held in place
// with respect to their superview.
@property (nonatomic, assign) BurstlyAnchor anchor;

// Specifies the view controller to modally present the ad when a user clicks on the banners.
// Set the rootViewController to the most valid topmost view controller. You will recieve a
// callback (burstlyBannerAdView:willTakeOverFullScreen:) via the BurstlyBannerViewDelegate when the
// banner is clicked and prior to rolling out the modal view controller.
@property (nonatomic, assign) UIViewController *rootViewController;

// Delegate object that receives state change notifications when conforming to the
// BurstyBannerViewDelegate protocol. Remember to explicitly set the delegate to nil
// when you release the delegate object.
@property (nonatomic, assign) id<BurstlyBannerViewDelegate> delegate;

// Specifies the interval between banner ad refreshes. Burstly handles
// the ad refreshes after the first call to showAd. This value can be
// overridden via the web interface.
@property (nonatomic, assign) CGFloat defaultRefreshInterval;

@property (nonatomic,retain) BurstlyAdRequest *adRequest;

#pragma Intialize the banner ad

// Initialize a new BurstlyBannerAdView object for any zone id provided to you.
- (id)initWithAppId:(NSString *)anAppId zoneId:(NSString *)aZoneId frame:(CGRect)aFrame anchor:(BurstlyAnchor)anAnchor rootViewController:(UIViewController *)aRootViewController delegate:(id<BurstlyBannerViewDelegate>)aDelegate;

// NOT FOR PRODUCTION USE. Init with integration mode and a specific test network.
- (id)initWithIntegrationModeTestNetwork:(BurstlyTestAdNetwork)aTestNetwork filterDeviceMacAddresses:(NSArray *)deviceMacAddresses frame:(CGRect)aFrame anchor:(BurstlyAnchor)anAnchor rootViewController:(UIViewController *)aRootViewController delegate:(id<BurstlyBannerViewDelegate>)aDelegate;

// Loads an Ad and accepts an optional request parameter that can be set to nil.
- (void)showAd;

// Precache a banner ad. Should be mapped to every request that loads the banner.
// This method is typically invoked several seconds ahead of showAd.
- (void)cacheAd;

@end
