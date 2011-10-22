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
    UIAlertView *alertView;
    UIActionSheet *actionSheet;
    UIPopoverController *popoverController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MemorialClockViewController *viewController;

@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) UIPopoverController *popoverController;

- (void)resetIdleTimerDisabled;

@end
