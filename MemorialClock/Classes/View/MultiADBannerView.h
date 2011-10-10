//
//  MultiADBannerView.h
//  MemorialClock
//
//  Created by プー坊 on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <iAd/iAd.h>
#import "GADBannerView.h"


typedef enum {
    AdBannerStateEmpty,
    AdBannerStateAdMob,
    AdBannerStateIAd,
} AdBannerState;

@interface MultiADBannerView : UIView <ADBannerViewDelegate, GADBannerViewDelegate> {
    IBOutlet UIView *contentView;
    IBOutlet UIView *emptyView;
    IBOutlet UILabel *emptyLabel;

    AdBannerState adBannerState_;
    BOOL isIAdValid_;
    BOOL isAdMobRequested_;
    BOOL isAdMobValid_;
    
    ADBannerView *iAdBannerView_;
    GADBannerView *adMobBannerView_;
}

- (void)initBannerWithTitle:(NSString *)title rootViewContoller:(UIViewController *)rootViewController;

@end
