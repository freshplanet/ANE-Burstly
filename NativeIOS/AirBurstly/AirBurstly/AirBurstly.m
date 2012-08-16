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

FREContext AirBurstlyCtx = nil;


@interface AirBurstly ()
{
    NSString *_publisherId;
    NSString *_zoneId;
    OAIAdManager *_adManager;
}
@end


@implementation AirBurstly

#pragma mark - Singleton

static AirBurstly *sharedInstance = nil;

+ (AirBurstly *)sharedInstance
{
    if (!sharedInstance)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return self;
}


#pragma mark - Burstly

- (id)initWithPublisherId:(NSString *)publisherId zoneId:(NSString *)zoneId
{
    self = [super init];
    if (self)
    {
        if (AirBurstlyCtx)
        {
            // Save parameters
            _publisherId = [publisherId retain];
            _zoneId = [zoneId retain];
            
            // Setup ad manager
            _adManager = [[OAIAdManager alloc] initWithDelegate:self];
            
            // Turn on Burstly debug logs
            [BurstlyLogger setLogLevel:AS_LOG_LEVEL_DEBUG];
        }
    }
    return self;
}

- (void)dealloc
{
    [_publisherId release];
    [_zoneId release];
    [_adManager release];
    [super dealloc];
}

- (void)displayAd
{
    UIViewController *viewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [viewController.view addSubview:_adManager.view];
    [_adManager setPaused:NO];
    [_adManager requestRefreshAd];
}

- (void)hideAd
{
    [_adManager setPaused:YES];
    [_adManager.view removeFromSuperview];
}


#pragma mark - OAIAdManagerDelegate

- (NSString *)publisherId
{
    return _publisherId;
}

- (NSString*)getZone
{
    return _zoneId;
}

- (UIViewController*)viewControllerForModalPresentation
{
    return [[[UIApplication sharedApplication] keyWindow] rootViewController];
}

- (Anchor)burstlyAnchor
{
    // The ad will attach to the anchor point at the bottom center.
    return Anchor_Bottom;
}

- (CGPoint)burstlyAnchorPoint
{
    // Set anchor to bottom/center.
    UIViewController *viewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    return CGPointMake(viewController.view.frame.size.width / 2, viewController.view.frame.size.height);
}

- (void)adManager:(OAIAdManager*)manager viewDidChangeSize:(CGSize)newSize fromOldSize:(CGSize)oldSize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [_adManager requestRefreshAd];
    });
}

@end


#pragma mark - AirBurstly C Interface

DEFINE_ANE_FUNCTION(initBurstly)
{
    uint32_t stringLength;
    
    // Retrieve publisherId from FRE
    const uint8_t *publisherIdString;
    NSString *publisherId = nil;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &publisherIdString) == FRE_OK)
    {
        publisherId = [NSString stringWithUTF8String:(char *)publisherIdString];
    }
    
    // Retrieve zoneId from FRE
    const uint8_t *zoneIdString;
    NSString *zoneId = nil;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &zoneIdString) == FRE_OK)
    {
        zoneId = [NSString stringWithUTF8String:(char *)zoneIdString];
    }
    
    [[AirBurstly sharedInstance] initWithPublisherId:publisherId zoneId:zoneId];
    
    return nil;
}

DEFINE_ANE_FUNCTION(displayAd)
{
    [[AirBurstly sharedInstance] displayAd];
    
    return nil;
}

DEFINE_ANE_FUNCTION(hideAd)
{
    [[AirBurstly sharedInstance] hideAd];
    
    return nil;
}


#pragma mark - ANE setup

// ContextInitializer()
// 
// The context initializer is called when the runtime creates the extension context instance.
void AirBurstlyContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                             uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 3;
    *numFunctionsToTest = nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    func[0].name = (const uint8_t*) "initBurstly";
    func[0].functionData = NULL;
    func[0].function = &initBurstly;
    
    func[1].name = (const uint8_t*) "displayAd";
    func[1].functionData = NULL;
    func[1].function = &displayAd;
    
    func[2].name = (const uint8_t*) "hideAd";
    func[2].functionData = NULL;
    func[2].function = &hideAd;
    
    *functionsToSet = func;
    
    AirBurstlyCtx = ctx;
}

// ContextFinalizer()
//
// Set when the context extension is created.
void AirBurstlyContextFinalizer(FREContext ctx) { }

// AirBurstlyInitializer()
//
// The extension initializer is called the first time the ActionScript side of the extension
// calls ExtensionContext.createExtensionContext() for any context.
void AirBurstlyInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet )
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirBurstlyContextInitializer;
	*ctxFinalizerToSet = &AirBurstlyContextFinalizer;
}