//
//  BurstlyAdError.h
//  BurstlyConvenienceLayer
//
//  Created by Abishek Ashok on 7/6/12.
//  Copyright (c) 2012 Burstly. All rights reserved.
//


#import <Foundation/Foundation.h>

@class BurstlyAdRequest;


extern NSString * const BurstlyErrorDomain;

// NSError codes for Burstly error domain.
typedef enum {
    // The ad request is invalid. This is most likely due to 
    // an invalid appId/zoneId or an invalid reference
    // to your top-most view controller. Refer to the 
    // NSLocalizedDescriptionKey in the userInfo dictionary
    // for more details. 
    BurstlyErrorInvalidRequest,
    
    // The server returned no ads for this zone. Contact
    // your Burstly admin with the errant zoneid for more details.
    BurstlyErrorNoFill,
    
    // There was an error loading data due to network delays
    BurstlyErrorNetworkFailure,
    
    // The AdServer experienced an error eg.server timeout
    BurstlyErrorServerError,
    
    // The timeout you specified via the requestTimeout property
    // has fired.
    BurstlyErrorInterstitialTimedOut,
    
    // The request was throttled. This happens when you send
    // back to back requests within an extremely short time
    // interval.
    BurstlyErrorRequestThrottled,
    
    // The Banner/Interstitial was misconfigured.
    BurstlyErrorConfigurationError
} BurstlyError;

@interface BurstlyAdError : NSError

@end
