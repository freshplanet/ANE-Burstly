//
//  BurstlyAdRequest.h
//  BurstlyConvenienceLayer
//
//  Created by Abishek Ashok on 7/10/12.
//  Copyright (c) 2012 Burstly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BurstlyUserInfo.h"

// Use BurstlyTestAdNetwork to force requests to point to 
// a specific ad network that would otherwise be mediated.
// Should be used in testing mode only. Works only on 
// the simulator. 
typedef enum {
    kBurstlyTestAdmob,
    kBurstlyTestGreystripe,
    kBurstlyTestInmobi,
    kBurstlyTestIad,
    kBurstlyTestJumptap,
    kBurstlyTestMillennial,
    kBurstlyTestRewards
} BurstlyTestAdNetwork;

@interface BurstlyAdRequest : NSObject

@property (nonatomic,retain) BurstlyUserInfo *userInfo;

// Used to transmit custom publisher targeting data key-value pairs
// back to the ad server. This string should represent a set
// of comma-delimited key-value pairs that can consist of integer,
// float, or string (must be single-quote delimited) values.
// - (NSString *)pubTargeting {
//    return @"gender='m',age=21";
// }
@property (nonatomic, retain) NSString *targettingParameters;

// Used to transmit custom creative-specific data key-value pairs
// to customize landing page URLs back to the ad server. This string 
// should represent a set of comma-delimited key-value pairs
//  that can consist of integer, float, or string
//  (must be single-quote delimited) values.
@property (nonatomic, retain) NSString *adParameters;

// Is integration mode enabled.
@property (nonatomic, readonly, getter =isIntegrationMode) BOOL integrationMode;

// Returns an auto-released BurstlyAdRequest
+ (BurstlyAdRequest *)request;

- (NSString *)getIntegrationModeAppId;
- (void)setIntegrationModeWithTestNetwork:(BurstlyTestAdNetwork)aTestNetwork filterDeviceMacAddresses:(NSArray *)deviceMacAddresses;

@end
