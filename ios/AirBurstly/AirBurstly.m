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

#define INTERSTITIAL_FAILURE_RETRY_DELAY  5 //seconds

FREContext AirBurstlyCtx = nil;


@interface AirBurstly ()
{
    BurstlyBannerAdView *_banner;
    BurstlyInterstitial *_interstitial;
}

- (UIViewController *)rootViewController;

@end


@implementation AirBurstly


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

- (void)initWithAppId:(NSString *)appId bannerZoneId:(NSString *)bannerZoneId interstitialZoneId:(NSString *)interstitialZoneId
{
    if (!appId)
    {
        [AirBurstly log:@"Error - init - appId can't be null!"];
        return;
    }
    
    if (bannerZoneId)
    {
        CGRect bannerFrame = CGRectZero;
        bannerFrame.size = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? BBANNER_SIZE_728x90 : BBANNER_SIZE_320x53;
        bannerFrame.origin.x = self.rootViewController.view.frame.size.width/2 - bannerFrame.size.width/2;
        bannerFrame.origin.y = self.rootViewController.view.frame.size.height - bannerFrame.size.height;
        
        _banner = [[BurstlyBannerAdView alloc] initWithAppId:appId zoneId:bannerZoneId frame:bannerFrame anchor:kBurstlyAnchorBottom rootViewController:self.rootViewController delegate:self];
    }
    
    if (interstitialZoneId)
    {
        _interstitial = [[BurstlyInterstitial alloc] initAppId:appId zoneId:interstitialZoneId delegate:self];
    }
    
    NSString *message = [NSString stringWithFormat:@"Info - Did init with appId = %@, bannerZoneId = %@, interstitialZoneId = %@", appId, bannerZoneId, interstitialZoneId];
    [AirBurstly log:message];
}

- (void)setUserInfo:(NSString *)infos
{
    if (_banner)
    {
        [_banner.adRequest setTargettingParameters:infos];
    }
    
    if (_interstitial)
    {
        [_banner.adRequest setTargettingParameters:infos];
    }
    
    NSString *message = [NSString stringWithFormat:@"Info - Did set user info: %@", infos];
    [AirBurstly log:message];
}

- (void)showBanner
{
    if (_banner)
    {
        [self.rootViewController.view addSubview:_banner];
        [_banner setAdPaused:NO];
        [_banner showAd];
    }
}

- (void)hideBanner
{
    if (_banner)
    {
        [_banner setAdPaused:YES];
        [_banner removeFromSuperview];
    }
}

- (BOOL)isInterstitialPreCached
{
    return (_interstitial && _interstitial.state == BurstlyInterstitialStatePreCached);
}

- (void)cacheInterstitial
{
    if (_interstitial)
    {
        [_interstitial cacheAd];
    }
}

- (void)showInterstitial
{
    if (_interstitial)
    {
        [_interstitial showAdWithRootViewController:self.rootViewController];
    }
}


#pragma mark - BurstlyBannerViewDelegate

- (void)burstlyBannerAdView:(BurstlyBannerAdView *)view willTakeOverFullScreen:(NSString *)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"Info - Will present fullscreen %@ banner", adNetwork];
    [AirBurstly log:message];
    
    [_banner setAdPaused:YES];
}

- (void)burstlyBannerAdView:(BurstlyBannerAdView *)view willDismissFullScreen:(NSString *)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"Info - Will dismiss fullscreen %@ banner", adNetwork];
    [AirBurstly log:message];
    
    [_banner setAdPaused:NO];
}

- (void)burstlyBannerAdView:(BurstlyBannerAdView *)view didShow:(NSString*)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"Info - Did show %@ banner", adNetwork];
    [AirBurstly log:message];
}

- (void)burstlyBannerAdView:(BurstlyBannerAdView *)view didCache:(NSString*)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"Info - Did cache %@ banner", adNetwork];
    [AirBurstly log:message];
}

- (void)burstlyBannerAdView:(BurstlyBannerAdView *)view wasClicked:(NSString*)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"Info - Did click %@ banner", adNetwork];
    [AirBurstly log:message];
}

- (void)burstlyBannerAdView:(BurstlyBannerAdView *)view didFailWithError:(BurstlyAdError*)error
{
    NSString *message = [NSString stringWithFormat:@"Warning - Did fail to load banner. Error: %@", [error description]];
    [AirBurstly log:message];
}


#pragma mark - BurstlyInterstitialDelegate

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad willTakeOverFullScreen:(NSString *)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"Info - Will present fullscreen %@ interstitial", adNetwork];
    [AirBurstly log:message];
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad willDismissFullScreen:(NSString *)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"Info - Will dismiss fullscreen %@ interstitial", adNetwork];
    [AirBurstly log:message];
    
    [AirBurstly dispatchEvent:@"INTERSTITIAL_WILL_DISMISS" withInfo:@"OK"];
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didHide:(NSString*)lastViewedNetwork
{
    NSString *message = [NSString stringWithFormat:@"Info - Did hide %@ interstitial", lastViewedNetwork];
    [AirBurstly log:message];
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didShow:(NSString*)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"Info - Did show %@ interstitial", adNetwork];
    [AirBurstly log:message];
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didCache:(NSString *)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"Info - Did cache %@ interstitial", adNetwork];
    [AirBurstly log:message];
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad wasClicked:(NSString*)adNetwork
{
    NSString *message = [NSString stringWithFormat:@"Info - Did click %@ interstitial", adNetwork];
    [AirBurstly log:message];
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didFailWithError:(BurstlyAdError *)error
{
    NSString *message = [NSString stringWithFormat:@"Warning - Did fail to load interstitial. Error: %@", [error description]];
    [AirBurstly log:message];

    [AirBurstly dispatchEvent:@"INTERSTITIAL_DID_FAIL" withInfo:@"OK"];
}

@end


#pragma mark - C interface

DEFINE_ANE_FUNCTION(AirBurstlyInit)
{
    uint32_t stringLength;

    const uint8_t *appIdString;
    NSString *appId = nil;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &appIdString) == FRE_OK)
    {
        appId = [NSString stringWithUTF8String:(char *)appIdString];
    }
    
    const uint8_t *bannerZoneIdString;
    NSString *bannerZoneId = nil;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &bannerZoneIdString) == FRE_OK)
    {
        bannerZoneId = [NSString stringWithUTF8String:(char *)bannerZoneIdString];
    }
    
    const uint8_t *interstitialZoneIdString;
    NSString *interstitialZoneId = nil;
    if (FREGetObjectAsUTF8(argv[2], &stringLength, &interstitialZoneIdString) == FRE_OK)
    {
        interstitialZoneId = [NSString stringWithUTF8String:(char *)interstitialZoneIdString];
    }
    
    [[AirBurstly sharedInstance] initWithAppId:appId bannerZoneId:bannerZoneId interstitialZoneId:interstitialZoneId];
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlySetUserInfo)
{
    // Retrieve infos
    uint32_t arrayLength, stringLength;
    NSMutableString *infos = [[NSMutableString alloc] init];
    FREObject arrayKeys = argv[0]; // array containing the keys
    FREObject arrayValues = argv[1]; // array containing the values
    if (arrayKeys && arrayValues)
    {
        if (FREGetArrayLength(arrayKeys, &arrayLength) != FRE_OK)
        {
            arrayLength = 0;
        }
        
        for (NSInteger i = arrayLength-1; i >= 0; i--)
        {
            // Get the key and value at index i. Skip this index if there's an error.
            FREObject keyRaw, valueRaw;
            if (FREGetArrayElementAt(arrayKeys, i, &keyRaw) != FRE_OK
                || FREGetArrayElementAt(arrayValues, i, &valueRaw) != FRE_OK)
            {
                continue;
            }
            
            // Convert them to strings. Skip this index if there's an error.
            const uint8_t *keyString, *valueString;
            if (FREGetObjectAsUTF8(keyRaw, &stringLength, &keyString) != FRE_OK
                || FREGetObjectAsUTF8(valueRaw, &stringLength, &valueString) != FRE_OK)
            {
                continue;
            }
            NSString *key = [NSString stringWithUTF8String:(char*)keyString];
            NSString *value = [NSString stringWithUTF8String:(char*)valueString];
            
            // Append key and value
            if ([infos length] > 0) [infos appendString:@","];
            [infos appendFormat:@"%@=%@", key, value];
        }
    }
    
    [[AirBurstly sharedInstance] setUserInfo:infos];
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

DEFINE_ANE_FUNCTION(AirBurstlyCacheInterstitial)
{
    [[AirBurstly sharedInstance] cacheInterstitial];
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlyShowInterstitial)
{
    [[AirBurstly sharedInstance] showInterstitial];
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
    NSInteger nbFuntionsToLink = 8;
    *numFunctionsToTest = nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    func[0].name = (const uint8_t*) "AirBurstlyInit";
    func[0].functionData = NULL;
    func[0].function = &AirBurstlyInit;
    
    func[1].name = (const uint8_t*) "AirBurstlySetUserInfo";
    func[1].functionData = NULL;
    func[1].function = &AirBurstlySetUserInfo;
    
    func[2].name = (const uint8_t*) "AirBurstlyShowBanner";
    func[2].functionData = NULL;
    func[2].function = &AirBurstlyShowBanner;
    
    func[3].name = (const uint8_t*) "AirBurstlyHideBanner";
    func[3].functionData = NULL;
    func[3].function = &AirBurstlyHideBanner;
    
    func[4].name = (const uint8_t*) "AirBurstlyIsInterstitialPreCached";
    func[4].functionData = NULL;
    func[4].function = &AirBurstlyIsInterstitialPreCached;
    
    func[5].name = (const uint8_t*) "AirBurstlyCacheInterstitial";
    func[5].functionData = NULL;
    func[5].function = &AirBurstlyCacheInterstitial;
    
    func[6].name = (const uint8_t*) "AirBurstlyShowInterstitial";
    func[6].functionData = NULL;
    func[6].function = &AirBurstlyShowInterstitial;
    
    func[7].name = (const uint8_t*) "AirBurstlyGetSDKVersion";
    func[7].functionData = NULL;
    func[7].function = &AirBurstlyGetSDKVersion;
    
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