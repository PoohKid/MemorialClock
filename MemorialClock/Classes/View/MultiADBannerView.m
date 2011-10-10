//
//  MultiADBannerView.m
//  MemorialClock
//
//  Created by プー坊 on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MultiADBannerView.h"
#import "DeveloperInfo.h"


@implementation MultiADBannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"MultiADBannerView" owner:self options:nil] objectAtIndex:0]];
    contentView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);

    //Initial Ad state
    adBannerState_ = AdBannerStateEmpty;
    isIAdValid_ = NO;
    isAdMobRequested_ = NO;
    isAdMobValid_ = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    iAdBannerView_.delegate = nil;
    [iAdBannerView_ release], iAdBannerView_ = nil;
    adMobBannerView_.delegate = nil;
    [adMobBannerView_ release], adMobBannerView_ = nil;

    [contentView release], contentView = nil;
    [emptyView release], emptyView = nil;
    [emptyLabel release], emptyLabel = nil;

    [super dealloc];
}

#pragma mark - Public Methods

- (void)initBannerWithTitle:(NSString *)title rootViewContoller:(UIViewController *)rootViewController
{
    emptyLabel.text = title;
    //return; //for ScreenShot

    //iAd
    [iAdBannerView_ removeFromSuperview];
    iAdBannerView_.delegate = nil;
    [iAdBannerView_ release];
    iAdBannerView_ = [[ADBannerView alloc] initWithFrame:CGRectZero];
    iAdBannerView_.delegate = self;
    iAdBannerView_.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;

    //AdMob
    [adMobBannerView_ removeFromSuperview];
    adMobBannerView_.delegate = nil;
    [adMobBannerView_ release];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adMobBannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake(0, 0, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height)];
    } else {
        adMobBannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake(0, 0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
    }
    adMobBannerView_.center = contentView.center; //iPadでサイズが合わないので中央寄せ
    adMobBannerView_.delegate = self;
    adMobBannerView_.adUnitID = [[DeveloperInfo sharedDeveloperInfo] adMobUnitID];
    adMobBannerView_.rootViewController = rootViewController;
}

#pragma mark - ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"bannerViewDidLoadAd:");

    isIAdValid_ = YES;

    UIView *fromView;
    switch (adBannerState_) {
        case AdBannerStateEmpty:
            fromView = emptyView;
            break;
        case AdBannerStateAdMob:
            fromView = adMobBannerView_;
            break;
        default: //AdBannerStateIAd
            return;
    }
    [UIView transitionFromView:fromView
                        toView:iAdBannerView_
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:nil];
    adBannerState_ = AdBannerStateIAd;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"bannerView:didFailToReceiveAdWithError:%@", [error localizedDescription]);

    isIAdValid_ = NO;

    if (isAdMobRequested_ == NO) {
        GADRequest *request = [GADRequest request];
        NSMutableArray *testDevices = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
        [testDevices addObject:GAD_SIMULATOR_ID];
        [testDevices addObjectsFromArray:[[DeveloperInfo sharedDeveloperInfo] testDevices]];
        request.testDevices = testDevices;
        [adMobBannerView_ loadRequest:request];
        isAdMobRequested_ = YES;
    }

    if (adBannerState_ != AdBannerStateIAd) {
        return;
    }
    if (isAdMobValid_) {
        [UIView transitionFromView:iAdBannerView_
                            toView:adMobBannerView_
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        completion:nil];
        adBannerState_ = AdBannerStateAdMob;
    } else {
        [UIView transitionFromView:iAdBannerView_
                            toView:emptyView
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        completion:nil];
        adBannerState_ = AdBannerStateEmpty;
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"bannerViewActionShouldBegin:willLeaveApplication:");
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    NSLog(@"bannerViewActionDidFinish:");
    //
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    NSLog(@"adViewDidReceiveAd:");

    isAdMobValid_ = YES;

    if (adBannerState_ != AdBannerStateEmpty) {
        return;
    }
    [UIView transitionFromView:emptyView
                        toView:adMobBannerView_
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:nil];
    adBannerState_ = AdBannerStateAdMob;
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);

    isAdMobValid_ = NO;

    if (adBannerState_ != AdBannerStateAdMob) {
        return;
    }
    [UIView transitionFromView:adMobBannerView_
                        toView:emptyView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:nil];
    adBannerState_ = AdBannerStateEmpty;
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
    NSLog(@"adViewWillPresentScreen:");
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView
{
    NSLog(@"adViewWillDismissScreen:");
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView
{
    NSLog(@"adViewDidDismissScreen:");
    //
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView
{
    NSLog(@"adViewWillLeaveApplication:");
}

@end
