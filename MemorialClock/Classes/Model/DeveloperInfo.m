//
//  DeveloperInfo.m
//  MemorialClock
//
//  Created by プー坊 on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DeveloperInfo.h"


static DeveloperInfo *sharedDeveloperInfo_ = nil;

@implementation DeveloperInfo

//--------------------------------------------------------------//
#pragma mark -- Initialize --
//--------------------------------------------------------------//

+ (DeveloperInfo *)sharedDeveloperInfo
{
    @synchronized(self) {
        if (!sharedDeveloperInfo_) {
            sharedDeveloperInfo_ = [[self alloc] init];
        }
    }
    return sharedDeveloperInfo_;
}

- (id)init{
    self = [super init];

    if (!self) {
        return nil;
    }

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Developer-Info" ofType:@"plist"];
    developerInfo_ = [[NSDictionary dictionaryWithContentsOfFile:plistPath] retain];
    //NSLog(@"developerInfo_: %@", developerInfo_);

    return self;
}

- (void)dealloc
{
    [developerInfo_ release], developerInfo_ = nil;
    [super dealloc];
}

//--------------------------------------------------------------//
#pragma mark -- public methods --
//--------------------------------------------------------------//

- (NSString *)adMobUnitID
{
    //NSLog(@"AdMobUnitID: %@", [developerInfo_ objectForKey:@"AdMobUnitID"]);
    return [developerInfo_ objectForKey:@"AdMobUnitID"];
}

- (NSArray *)testDevices
{
    //NSLog(@"TestDevices: %@", [developerInfo_ objectForKey:@"TestDevices"]);
    return [developerInfo_ objectForKey:@"TestDevices"];
}

- (NSString *)googleAnalyticsAccountID
{
    //NSLog(@"GoogleAnalyticsAccountID: %@", [developerInfo_ objectForKey:@"GoogleAnalyticsAccountID"]);
    return [developerInfo_ objectForKey:@"GoogleAnalyticsAccountID"];
}

- (NSInteger)googleAnalyticsDispatchPeriod
{
    //NSLog(@"GoogleAnalyticsDispatchPeriod: %d", [[developerInfo_ objectForKey:@"GoogleAnalyticsDispatchPeriod"] integerValue]);
    return [[developerInfo_ objectForKey:@"GoogleAnalyticsDispatchPeriod"] integerValue];
}

//--------------------------------------------------------------//
#pragma mark -- Singleton --
//--------------------------------------------------------------//

+ (id)allocWithZone:(NSZone*)zone
{
    @synchronized(self) {
        if (!sharedDeveloperInfo_) {
            sharedDeveloperInfo_ = [super allocWithZone:zone];
            return sharedDeveloperInfo_;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;
}

- (oneway void)release
{
}

- (id)autorelease
{
    return self;
}

@end
