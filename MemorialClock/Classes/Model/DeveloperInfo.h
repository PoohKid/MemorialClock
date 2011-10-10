//
//  DeveloperInfo.h
//  MemorialClock
//
//  Created by プー坊 on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DeveloperInfo : NSObject {
    NSDictionary *developerInfo_;
}

+ (DeveloperInfo *)sharedDeveloperInfo;

//GoogleAdMobAdsSDK
- (NSString *)adMobUnitID;
- (NSArray *)testDevices;

//GoogleAnalyticsSDK
- (NSString *)googleAnalyticsAccountID;
- (NSInteger)googleAnalyticsDispatchPeriod;

@end
