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

#import "AirBurstly.h"
#import "BurstlyAdError.h"
#import "BurstlyAdRequest.h"
#import "BurstlyAdUtils.h"
#import "BurstlyBannerAdView.h"
#import "BurstlyInterstitial.h"

#define INTERSTITIAL_MAX_FAILURE_COUNT  5

FREContext AirBurstlyCtx = nil;


@interface AirBurstly ()
{
    NSUInteger _interstitialFailureCount;
}

@property (nonatomic, readonly) UIViewController *rootViewController;
@property (nonatomic, readonly) BurstlyBannerAdView *banner;
@property (nonatomic, readonly) BurstlyInterstitial *interstitial;

@end


@implementation AirBurstly

@synthesize rootViewController = _rootViewController;

@synthesize banner = _banner;
@synthesize interstitial = _interstitial;

@synthesize appId = _appId;
@synthesize bannerZoneId = _bannerZoneId;
@synthesize interstitialZoneId = _interstitialZoneId;

@synthesize integrationMode = _integrationMode;
@synthesize testAdNetwork = _testAdNetwork;


#pragma mark - Singleton

static AirBurstly *sharedInstance = nil;

+ (AirBurstly *)sharedInstance
{
    if (!sharedInstance)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return self;
}

#pragma mark - NSObject

- (void)dealloc
{
    _banner.delegate = nil;
    [_banner release];
    
    _interstitial.delegate = nil;
    [_interstitial release];
    
    [_appId release];
    [_bannerZoneId release];
    [_interstitialZoneId release];
    
    [super dealloc];
}


#pragma mark - AirBurstly

+ (void)dispatchEvent:(NSString *)eventName withInfo:(NSString *)info
{
    FREDispatchStatusEventAsync(AirBurstlyCtx, (const uint8_t *)[eventName UTF8String], (const uint8_t *)[info UTF8String]);
}

+ (void)log:(NSString *)message
{
    [AirBurstly dispatchEvent:@"LOGGING" withInfo:message];
}

- (UIViewController *)rootViewController
{
    return [[[UIApplication sharedApplication] keyWindow] rootViewController];
}

- (BurstlyBannerAdView *)banner
{
    if (!_banner && _appId && _bannerZoneId)
    {
        CGRect bannerFrame = CGRectZero;
        bannerFrame.origin.x = self.rootViewController.view.frame.size.width/2 - BBANNER_SIZE_320x53.width/2;
        bannerFrame.origin.y = self.rootViewController.view.frame.size.height - BBANNER_SIZE_320x53.height;
        bannerFrame.size = BBANNER_SIZE_320x53;
        
        _banner = [[BurstlyBannerAdView alloc] initWithAppId:_appId zoneId:_bannerZoneId frame:bannerFrame anchor:kBurstlyAnchorBottom rootViewController:self.rootViewController delegate:self];
    }
    
    return _banner;
}

- (BurstlyInterstitial *)interstitial
{
    if (!_interstitial && _appId && _interstitialZoneId)
    {
        _interstitial = [[BurstlyInterstitial alloc] initAppId:_appId zoneId:_interstitialZoneId delegate:self];
    }
    
    return _interstitial;
}

- (void)setAppId:(NSString *)appId
{
    if (appId != _appId)
    {
        [self hideBanner];
        _banner.delegate = nil;
        [_banner release];
        _banner = nil;
        
        _interstitial.delegate = nil;
        [_interstitial release];
        _interstitial = nil;
        
        _appId = [appId retain];
        
        [self.interstitial cacheAd];
    }
}

- (void)setBannerZoneId:(NSString *)bannerZoneId
{
    if (bannerZoneId != _bannerZoneId)
    {
        [self hideBanner];
        _banner.delegate = nil;
        [_banner release];
        _banner = nil;
        
        _bannerZoneId = [bannerZoneId retain];
    }
}

- (void)setInterstitialZoneId:(NSString *)interstitialZoneId
{
    if (interstitialZoneId != _interstitialZoneId)
    {
        _interstitial.delegate = nil;
        [_interstitial release];
        _interstitial = nil;
        
        _interstitialZoneId = [interstitialZoneId retain];
        
        [self.interstitial cacheAd];
    }
}

- (void)showBanner
{
    [self.rootViewController.view addSubview:self.banner];
    [self.banner setAdPaused:NO];
    [self.banner showAd];
}

- (void)hideBanner
{
    [self.banner setAdPaused:YES];
    [self.banner removeFromSuperview];
}

- (BOOL)isInterstitialPreCached
{
    return (self.interstitial.state == BurstlyInterstitialStatePreCached);
}

- (void)showInterstitial
{
    [self.interstitial showAdWithRootViewController:self.rootViewController];
}


#pragma mark - BurstlyBannerViewDelegate

- (void)burstlyBannerAdView:(BurstlyBannerAdView *)view willTakeOverFullScreen:(NSString *)adNetwork
{
    [self.banner setAdPaused:YES];
}

- (void)burstlyBannerAdView:(BurstlyBannerAdView *)view willDismissFullScreen:(NSString *)adNetwork
{
    [self.banner setAdPaused:NO];
}


#pragma mark - BurstlyInterstitialDelegate

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad willTakeOverFullScreen:(NSString *)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"%@ interstitial will take over full screen", adNetwork];
    FREDispatchStatusEventAsync(AirBurstlyCtx, (const uint8_t *)"LOGGING", (const uint8_t *)[message UTF8String]);
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad willDismissFullScreen:(NSString *)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"%@ interstitial will dismiss full screen", adNetwork];
    FREDispatchStatusEventAsync(AirBurstlyCtx, (const uint8_t *)"LOGGING", (const uint8_t *)[message UTF8String]);
    
    FREDispatchStatusEventAsync(AirBurstlyCtx, (const uint8_t *)"INTERSTITIAL_WILL_DISMISS", (const uint8_t *)"OK");
    
    [self.interstitial cacheAd];
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didFailWithError:(BurstlyAdError *)error
{
    NSString *message = [NSString stringWithFormat:@"Interstitial did fail with error: %@", error];
    FREDispatchStatusEventAsync(AirBurstlyCtx, (const uint8_t *)"LOGGING", (const uint8_t *)[message UTF8String]);
    
    FREDispatchStatusEventAsync(AirBurstlyCtx, (const uint8_t *)"INTERSTITIAL_DID_FAIL", (const uint8_t *)"OK");
    
    _interstitialFailureCount++;
    if (_interstitialFailureCount < INTERSTITIAL_MAX_FAILURE_COUNT)
    {
        [self.interstitial cacheAd];
    }
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didCache:(NSString *)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"%@ interstitial did cache", adNetwork];
    FREDispatchStatusEventAsync(AirBurstlyCtx, (const uint8_t *)"LOGGING", (const uint8_t *)[message UTF8String]);
    
    _interstitialFailureCount = 0;
}

@end


#pragma mark - C interface

DEFINE_ANE_FUNCTION(AirBurstlySetAppId)
{
    uint32_t stringLength;
    
    // Retrieve appId
    const uint8_t *appIdString;
    NSString *appId = nil;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &appIdString) == FRE_OK)
    {
        appId = [NSString stringWithUTF8String:(char *)appIdString];
    }
    
    if (appId)
    {
        [[AirBurstly sharedInstance] setAppId:appId];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlySetBannerZoneId)
{
    uint32_t stringLength;
    
    // Retrieve zoneId
    const uint8_t *zoneIdString;
    NSString *zoneId = nil;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &zoneIdString) == FRE_OK)
    {
        zoneId = [NSString stringWithUTF8String:(char *)zoneIdString];
    }
    
    if (zoneId)
    {
        [[AirBurstly sharedInstance] setBannerZoneId:zoneId];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlySetInterstitialZoneId)
{
    uint32_t stringLength;
    
    // Retrieve zoneId
    const uint8_t *zoneIdString;
    NSString *zoneId = nil;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &zoneIdString) == FRE_OK)
    {
        zoneId = [NSString stringWithUTF8String:(char *)zoneIdString];
    }
    
    if (zoneId)
    {
        [[AirBurstly sharedInstance] setInterstitialZoneId:zoneId];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlyShowBanner)
{
    [[AirBurstly sharedInstance] showBanner];
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlyHideBanner)
{
    [[AirBurstly sharedInstance] hideBanner];
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlyIsInterstitialPreCached)
{
    BOOL isInterstitialPreCached = [[AirBurstly sharedInstance] isInterstitialPreCached];
    
    FREObject result;
    if (FRENewObjectFromBool(isInterstitialPreCached, &result) == FRE_OK)
    {
        return result;
    }
    else return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlyShowInterstitial)
{
    [[AirBurstly sharedInstance] showInterstitial];
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlySetIntegrationMode)
{
    uint32_t stringLength;
    
    // Retrieve network
    const uint8_t *networkString;
    NSString *network = nil;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &networkString) == FRE_OK)
    {
        network = [NSString stringWithUTF8String:(char *)networkString];
    }
    
    if (network)
    {
        AirBurstly *burstly = [AirBurstly sharedInstance];
        if ([network isEqualToString:@"ADMOB"])
        {
            burstly.testAdNetwork = kBurstlyTestAdmob;
        }
        else if ([network isEqualToString:@"GREYSTRIPE"])
        {
            burstly.testAdNetwork = kBurstlyTestGreystripe;
        }
        else if ([network isEqualToString:@"INMOBI"])
        {
            burstly.testAdNetwork = kBurstlyTestInmobi;
        }
        else if ([network isEqualToString:@"IAD"])
        {
            burstly.testAdNetwork = kBurstlyTestIad;
        }
        else if ([network isEqualToString:@"JUMPTAP"])
        {
            burstly.testAdNetwork = kBurstlyTestJumptap;
        }
        else if ([network isEqualToString:@"MILLENIAL"])
        {
            burstly.testAdNetwork = kBurstlyTestMillennial;
        }
        burstly.integrationMode = YES;
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlyGetSDKVersion)
{
    NSString *sdkVersion = [BurstlyAdUtils version];
    
    FREObject result;
    if (FRENewObjectFromUTF8(sdkVersion.length, (const uint8_t *)[sdkVersion UTF8String], &result) == FRE_OK)
    {
        return result;
    }
    else return nil;
}


#pragma mark - ANE setup

void AirBurstlyContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 9;
    *numFunctionsToTest = nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    func[0].name = (const uint8_t*) "AirBurstlySetAppId";
    func[0].functionData = NULL;
    func[0].function = &AirBurstlySetAppId;
    
    func[1].name = (const uint8_t*) "AirBurstlySetBannerZoneId";
    func[1].functionData = NULL;
    func[1].function = &AirBurstlySetBannerZoneId;
    
    func[2].name = (const uint8_t*) "AirBurstlySetInterstitialZoneId";
    func[2].functionData = NULL;
    func[2].function = &AirBurstlySetInterstitialZoneId;
    
    func[3].name = (const uint8_t*) "AirBurstlyShowBanner";
    func[3].functionData = NULL;
    func[3].function = &AirBurstlyShowBanner;
    
    func[4].name = (const uint8_t*) "AirBurstlyHideBanner";
    func[4].functionData = NULL;
    func[4].function = &AirBurstlyHideBanner;
    
    func[5].name = (const uint8_t*) "AirBurstlyIsInterstitialPreCached";
    func[5].functionData = NULL;
    func[5].function = &AirBurstlyIsInterstitialPreCached;
    
    func[6].name = (const uint8_t*) "AirBurstlyShowInterstitial";
    func[6].functionData = NULL;
    func[6].function = &AirBurstlyShowInterstitial;
    
    func[7].name = (const uint8_t*) "AirBurstlySetIntegrationMode";
    func[7].functionData = NULL;
    func[7].function = &AirBurstlySetIntegrationMode;
    
    func[8].name = (const uint8_t*) "AirBurstlyGetSDKVersion";
    func[8].functionData = NULL;
    func[8].function = &AirBurstlyGetSDKVersion;
    
    *functionsToSet = func;
    
    AirBurstlyCtx = ctx;
}

void AirBurstlyContextFinalizer(FREContext ctx) { }

void AirBurstlyInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirBurstlyContextInitializer;
	*ctxFinalizerToSet = &AirBurstlyContextFinalizer;
}

void AirBurstlyFinalizer(void* extData) { }