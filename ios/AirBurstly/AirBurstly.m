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
#import "AirBurstlyBannerDelegate.h"
#import "AirBurstlyInterstitialDelegate.h"
#import "BurstlyAdUtils.h"
#import "BurstlyBanner.h"
#import "BurstlyInterstitial.h"


static FREContext context;
static BurstlyBanner *banner;
static BOOL bannerShown;
static AirBurstlyBannerDelegate *bannerDelegate;
static BurstlyInterstitial *interstitial;
static AirBurstlyInterstitialDelegate *interstitialDelegate;
static NSMutableArray *additionalInterstitials;

DEFINE_ANE_FUNCTION(AirBurstlyInit)
{
    NSString *appId = FPANE_FREObjectToNSString(argv[0]);
    NSString *bannerZoneId = FPANE_FREObjectToNSString(argv[1]);
    NSString *interstitialZoneId = FPANE_FREObjectToNSString(argv[2]);
    NSArray *additionalInterstitialZoneIds = nil;
    
    if (argc > 3) // means we have more interstitials
    {
        additionalInterstitialZoneIds = FPANE_FREObjectToNSArrayOfNSString(argv[3]);
    }
    
    if (bannerZoneId)
    {
        CGRect bannerFrame = CGRectZero;
        bannerFrame.size = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? BBANNER_SIZE_728x90 : BBANNER_SIZE_320x50;
        bannerFrame.origin.x = ROOT_VIEW_CONTROLLER.view.frame.size.width/2 - bannerFrame.size.width/2;
        bannerFrame.origin.y = ROOT_VIEW_CONTROLLER.view.frame.size.height - bannerFrame.size.height;
        
        bannerDelegate = [[AirBurstlyBannerDelegate alloc] initWithContext:context];
        banner = [[BurstlyBanner alloc] initWithAppId:appId zoneId:bannerZoneId frame:bannerFrame anchor:BurstlyAnchorBottom rootViewController:ROOT_VIEW_CONTROLLER delegate:bannerDelegate];
        [banner cacheAd];
    }
    
    if (interstitialZoneId)
    {
        interstitialDelegate = [[AirBurstlyInterstitialDelegate alloc] initWithContext:context];
        interstitial = [[BurstlyInterstitial alloc] initAppId:appId zoneId:interstitialZoneId delegate:interstitialDelegate];
    }
    
    if (additionalInterstitialZoneIds != nil)
    {
        if (!interstitialDelegate)
        {
            interstitialDelegate = [[AirBurstlyInterstitialDelegate alloc] initWithContext:context];
        }
        
        additionalInterstitials = [NSMutableArray arrayWithCapacity:[additionalInterstitialZoneIds count]];
        for (NSString* zoneId in additionalInterstitialZoneIds)
        {
            [additionalInterstitials addObject:[[BurstlyInterstitial alloc] initAppId:appId zoneId:zoneId delegate:interstitialDelegate]];
        }
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlySetUserInfo)
{
    NSDictionary *infoDict = FPANE_FREObjectsToNSDictionaryOfNSString(argv[0], argv[1]);
    
    NSMutableArray *infoItems = [NSMutableArray arrayWithCapacity:infoDict.count];
    [infoDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [infoItems addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    
    NSString *infoString = [infoItems componentsJoinedByString:@","];
    
    [banner.adRequest setTargetingParameters:infoString];
    [interstitial.adRequest setTargetingParameters:infoString];
    
    if (additionalInterstitials != nil)
    {
        for (BurstlyInterstitial *bInterstitial in additionalInterstitials)
        {
            [bInterstitial.adRequest setTargetingParameters:infoString];
        }
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlyShowBanner)
{
    if (!bannerShown)
    {
        [banner showAd];
        bannerShown = YES;
    }
    
    [ROOT_VIEW_CONTROLLER.view addSubview:banner];
    banner.adPaused = NO;
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlyHideBanner)
{
    [banner removeFromSuperview];
    banner.adPaused = YES;
    [banner cacheAd];
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlyIsInterstitialPreCached)
{
    BurstlyInterstitial *selectedInterstitial = nil;
    if (argc > 0)
    {
        NSString *zoneId = FPANE_FREObjectToNSString(argv[0]);
        if (zoneId != nil)
        {
            for (BurstlyInterstitial *possibleInterstitial in additionalInterstitials)
            {
                if ([possibleInterstitial.zoneId isEqualToString:zoneId])
                {
                    selectedInterstitial = possibleInterstitial;
                    break;
                }
            }
        }
    } else
    {
        selectedInterstitial = interstitial;
    }
    if (selectedInterstitial)
    {
        return FPANE_BOOLToFREObject(selectedInterstitial.state == BurstlyInterstitialStateCached);
    } else
    {
        return FPANE_BOOLToFREObject(NO);
    }
}

DEFINE_ANE_FUNCTION(AirBurstlyCacheInterstitial)
{
    BurstlyInterstitial *selectedInterstitial = nil;
    if (argc > 0)
    {
        NSString *zoneId = FPANE_FREObjectToNSString(argv[0]);
        if (zoneId != nil)
        {
            for (BurstlyInterstitial *possibleInterstitial in additionalInterstitials)
            {
                if ([possibleInterstitial.zoneId isEqualToString:zoneId])
                {
                    selectedInterstitial = possibleInterstitial;
                    break;
                }
            }
        }
    } else
    {
        selectedInterstitial = interstitial;
    }

    if (selectedInterstitial)
    {
        [selectedInterstitial cacheAd];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlyShowInterstitial)
{
    BurstlyInterstitial *selectedInterstitial = nil;
    if (argc > 0)
    {
        NSString *zoneId = FPANE_FREObjectToNSString(argv[0]);
        if (zoneId != nil)
        {
            for (BurstlyInterstitial *possibleInterstitial in additionalInterstitials)
            {
                if ([possibleInterstitial.zoneId isEqualToString:zoneId])
                {
                    selectedInterstitial = possibleInterstitial;
                    break;
                }
            }
        }
    } else
    {
        selectedInterstitial = interstitial;
    }
    
    if (selectedInterstitial)
    {
        [selectedInterstitial showAd];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBurstlyGetSDKVersion)
{
    return FPANE_NSStringToFREOBject([BurstlyAdUtils version]);
}


#pragma mark - ANE setup

void AirBurstlyContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    NSDictionary *functions = @{
        @"AirBurstlyGetSDKVersion": [NSValue valueWithPointer:&AirBurstlyGetSDKVersion],
        @"AirBurstlyInit": [NSValue valueWithPointer:&AirBurstlyInit],
        @"AirBurstlySetUserInfo": [NSValue valueWithPointer:&AirBurstlySetUserInfo],
        @"AirBurstlyShowBanner": [NSValue valueWithPointer:&AirBurstlyShowBanner],
        @"AirBurstlyHideBanner": [NSValue valueWithPointer:&AirBurstlyHideBanner],
        @"AirBurstlyIsInterstitialPreCached": [NSValue valueWithPointer:&AirBurstlyIsInterstitialPreCached],
        @"AirBurstlyCacheInterstitial": [NSValue valueWithPointer:&AirBurstlyCacheInterstitial],
        @"AirBurstlyShowInterstitial": [NSValue valueWithPointer:&AirBurstlyShowInterstitial]
    };
    
    *numFunctionsToTest = [functions count];
    
    FRENamedFunction *func = (FRENamedFunction *)malloc(sizeof(FRENamedFunction) * [functions count]);
    
    for (NSInteger i = 0; i < [functions count]; i++)
    {
        func[i].name = (const uint8_t *)[[[functions allKeys] objectAtIndex:i] UTF8String];
        func[i].functionData = NULL;
        func[i].function = [[[functions allValues] objectAtIndex:i] pointerValue];
    }
    
    *functionsToSet = func;
    
    context = ctx;
}

void AirBurstlyContextFinalizer(FREContext ctx) { }

void AirBurstlyInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirBurstlyContextInitializer;
	*ctxFinalizerToSet = &AirBurstlyContextFinalizer;
}

void AirBurstlyFinalizer(void* extData) { }