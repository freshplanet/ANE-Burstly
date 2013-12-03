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

#import "AirBurstlyInterstitialDelegate.h"
#import "FPANEUtils.h"


#define INTERSTITIAL_WILL_DISMISS_EVENT   @"INTERSTITIAL_WILL_DISMISS"
#define INTERSTITIAL_DID_FAIL_EVENT       @"INTERSTITIAL_DID_FAIL"
#define INTERSTITIAL_WAS_CLICKED_EVENT    @"INTERSTITIAL_WAS_CLICKED"
#define INTERSTITIAL_WILL_APPEAR_EVENT   @"INTERSTITIAL_WILL_APPEAR"

@interface AirBurstlyInterstitialDelegate ()

@property (nonatomic) FREContext context;
           
@end

           
@implementation AirBurstlyInterstitialDelegate

- (id)initWithContext:(FREContext)context
{
    if (self = [super init])
    {
        _context = context;
    }
    return self;
}


#pragma mark - BurstlyInterstitialDelegate

- (UIViewController *)viewControllerForModalPresentation:(BurstlyInterstitial *)interstitial
{
    return ROOT_VIEW_CONTROLLER;
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad willDismissFullScreen:(NSDictionary *)info
{
    FPANE_DispatchEvent(self.context, INTERSTITIAL_WILL_DISMISS_EVENT);
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didCache:(NSDictionary *)info
{
    FPANE_Log(self.context, [NSString stringWithFormat:@"Did cache %@ interstitial", [info objectForKey:BurstlyInfoNetwork]]);
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didShow:(NSDictionary *)info
{
    FPANE_Log(self.context, [NSString stringWithFormat:@"Did show %@ interstitial", [info objectForKey:BurstlyInfoNetwork]]);
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didHide:(NSDictionary *)info
{
    FPANE_Log(self.context, [NSString stringWithFormat:@"Did hide %@ interstitial", [info objectForKey:BurstlyInfoNetwork]]);
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didFail:(NSDictionary *)info
{
    FPANE_DispatchEvent(self.context, INTERSTITIAL_DID_FAIL_EVENT);
    FPANE_Log(self.context, [NSString stringWithFormat:@"Did fail to load interstitial. Error: %@", [info objectForKey:BurstlyInfoError]]);
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad wasClicked:(NSDictionary *)info
{
    FPANE_DispatchEvent(self.context, INTERSTITIAL_WAS_CLICKED_EVENT);
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad willTakeOverFullScreen:(NSDictionary *)info
{
    FPANE_DispatchEvent(self.context, INTERSTITIAL_WILL_APPEAR_EVENT);
}

@end
