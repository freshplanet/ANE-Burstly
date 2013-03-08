//
//  BurstlyCurrency.h
//  Burstly
//
//  Created by Nick Remizevich on 8/15/11.
//  Copyright (c) 2011 Burstly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BurstlyCurrencyUpdateInfo.h"

@class BurstlyCurrency;

extern NSString * BurstlyCurrencyBalancesUpdateNotification;



@protocol BurstlyCurrencyDelegate <NSObject>

@optional

- (void)currencyManager:(BurstlyCurrency *)manager didUpdateBalances:(NSDictionary *)balances;
- (void)currencyManager:(BurstlyCurrency *)manager didFailToUpdateBalanceWithError:(NSError *)error;

@end


@interface BurstlyCurrency : NSObject {
    id<BurstlyCurrencyDelegate> delegate_;
    NSString *publisherId_;
    NSString *userId_;
}

+ (BurstlyCurrency *) sharedCurrencyManager;

- (NSInteger) currentBalanceForCurrency:(NSString *)currency;
- (NSInteger) increaseBalance:(NSUInteger)amount forCurrency:(NSString *)currency;
- (NSInteger) decreaseBalance:(NSUInteger)amount forCurrency:(NSString *)currency;

- (void) checkForUpdate;


- (void)setPublisherId: (NSString*)publisherId;
- (void)setPublisherId: (NSString*)publisherId andUserId: (NSString*)userId;

@property (nonatomic, assign) id<BurstlyCurrencyDelegate> delegate;
@property (nonatomic, readonly) NSString *publisherId;
@property (nonatomic, readonly) NSString *userId;

@end
