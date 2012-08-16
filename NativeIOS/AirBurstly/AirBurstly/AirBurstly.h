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

#import "FlashRuntimeExtensions.h"
#import "BurstlyLogger.h"
#import "OAIAdManager.h"

@interface AirBurstly : NSObject <OAIAdManagerDelegate>

+ (AirBurstly *)sharedInstance;

- (id)initWithPublisherId:(NSString *)publisherId zoneId:(NSString *)zoneId;
- (void)displayAd;

@end


// AirBurstly C interface

DEFINE_ANE_FUNCTION(initBurstly);
DEFINE_ANE_FUNCTION(displayAd);
DEFINE_ANE_FUNCTION(hideAd);


// ANE setup

void AirBurstlyContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                             uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);

void AirBurstlyContextFinalizer(FREContext ctx);

void AirBurstlyInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet );

