//
//  MemorialClockAppDelegate.m
//  MemorialClock
//
//  Created by プー坊 on 11/09/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MemorialClockAppDelegate.h"

#import "MemorialClockViewController.h"
#import "RegisterViewController.h"
#import "NSString+Escape.h"

@implementation MemorialClockAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

@synthesize alertView, actionSheet, popoverController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    //自動ロックをOFF
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)setPopoverController:(UIPopoverController *)aPopoverController
{
    popoverController.delegate = nil; //必須
    [popoverController release], popoverController = [aPopoverController retain];
}

//クエリ文字列を解析
- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithCapacity:6] autorelease];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];

    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] unescapeString];
        NSString *val = [[elements objectAtIndex:1] unescapeString];

        [dict setObject:val forKey:key];
    }
    //NSLog(@"dict: %@", dict);
    return dict;
}

//URLスキームを受信
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //コマンド取得
    NSString *command = nil;
    NSArray *pathComponents = [url pathComponents]; // "/", "command"
    if ([pathComponents count] == 2) {
        command = [pathComponents objectAtIndex:1];
    }
    //クエリ文字列を解析
    NSDictionary *query = [self parseQueryString:[url query]];

    if ([command isEqualToString:@"regist"]) {
        //AlertViewを閉じる
        [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:NO];
        self.alertView = nil;
        //ActionSheetを閉じる
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:NO];
        self.actionSheet = nil;
        //PopoverControllerを閉じる
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;

        //モーダル遷移を閉じる（チェーン内のすべてのオブジェクトを閉じる）
        [self.window.rootViewController dismissModalViewControllerAnimated:NO];

        //登録画面を開く
        NSString *nibName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"RegisterViewController-iPad"
                                                                                   : @"RegisterViewController";
        RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:nibName bundle:nil];
        registerViewController.name = [query objectForKey:@"name"];
        registerViewController.message = [query objectForKey:@"message"];
        registerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.window.rootViewController presentModalViewController:registerViewController animated:NO];
        [registerViewController release];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
