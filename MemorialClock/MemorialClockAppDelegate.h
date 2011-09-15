//
//  MemorialClockAppDelegate.h
//  MemorialClock
//
//  Created by プー坊 on 11/09/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MemorialClockViewController;

@interface MemorialClockAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MemorialClockViewController *viewController;

@end
