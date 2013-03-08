//
//  BurstlyCurrencyUpdateInfo.h
//  Burstly
//
//  Created by Fedor Kudrys on 01.11.12.
//  Copyright (c) 2012 Burstly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BurstlyCurrencyUpdateInfo : NSObject

@property (nonatomic, readonly) NSString * currency;
@property (nonatomic, readonly) NSInteger oldTotal;
@property (nonatomic, readonly) NSInteger newTotal;
@property (nonatomic, readonly) NSInteger change;

@end
