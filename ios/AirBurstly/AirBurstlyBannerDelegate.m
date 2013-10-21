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

#import "AirBurstlyBannerDelegate.h"
#import "BurstlyAdRequest.h"
#import "FPANEUtils.h"

@interface AirBurstlyBannerDelegate ()
@property (nonatomic) FREContext context;
@end

@implementation AirBurstlyBannerDelegate

- (id)initWithContext:(FREContext)context
{
    if (self = [super init])
    {
        _context = context;
    }
    return self;
}


#pragma mark - BurstlyBannerDelegate

- (void)burstlyBanner:(BurstlyBanner *)view willTakeOverFullScreen:(NSDictionary *)info
{
    [view setAdPaused:YES];
}

- (void)burstlyBanner:(BurstlyBanner *)view willDismissFullScreen:(NSDictionary *)info
{
    [view setAdPaused:NO];
}

- (void)burstlyBanner:(BurstlyBanner *)view didShow:(NSDictionary *)info
{
    FPANE_Log(self.context, [NSString stringWithFormat:@"Did show %@ banner", [info objectForKey:BurstlyInfoNetwork]]);
}

- (void)burstlyBanner:(BurstlyBanner *)view didCache:(NSDictionary *)info
{
    FPANE_Log(self.context, [NSString stringWithFormat:@"Did cache %@ banner", [info objectForKey:BurstlyInfoNetwork]]);
}

- (void)burstlyBanner:(BurstlyBanner *)view didFail:(NSDictionary *)info
{
    FPANE_Log(self.context, [NSString stringWithFormat:@"Did fail to load %@ banner. Error: %@", [info objectForKey:BurstlyInfoNetwork], [info objectForKey:BurstlyInfoError]]);
}

@end
