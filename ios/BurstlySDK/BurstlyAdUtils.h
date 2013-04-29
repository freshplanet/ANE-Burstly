//
//  BurstlyAdUtils.h
//  BurstlyConvenienceLayer
//
//  Created by Abishek Ashok on 10/28/12.
//  Copyright (c) 2012 Burstly. All rights reserved.
//

#import "BurstlyLoggerConstants.h"


@interface BurstlyAdUtils: NSObject

+ (NSString*)version;

+ (void)setLogLevel:(AS_LogLevel)level;
+ (AS_LogLevel)logLevel;

@end