//
//  BurstlyAdUtils.h
//  BurstlyConvenienceLayer
//
//  Created by Abishek Ashok on 10/28/12.
//  Copyright (c) 2012 Burstly. All rights reserved.
//


typedef enum {
	BurstlyLogLevelNone	=	0,
	BurstlyLogLevelVerbose	=	1
} BurstlyLogLevel;

@interface BurstlyAdUtils: NSObject {
}

+ (NSString*)version;

+ (void)setLogLevel:(BurstlyLogLevel)level;
+ (BurstlyLogLevel)logLevel;

@end