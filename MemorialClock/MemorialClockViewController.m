//
//  MemorialClockViewController.m
//  MemorialClock
//
//  Created by プー坊 on 11/09/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MemorialClockAppDelegate.h"
#import "MemorialClockViewController.h"
#import "RegisterViewController.h"
#import "MemoryModel.h"
#import "NSDictionary+Null.h"
#import "MultiADBannerView.h"


typedef enum {
    ActionSheetTypeTrash = 1,
} ActionSheetType;

@interface MemorialClockViewController (Timer)
- (void)onTimer:(NSTimer *)timer;
- (void)stopTimer;
- (void)startTimer;
@end

@interface MemorialClockViewController (Private)
- (void)changeMemory;
@end

@implementation MemorialClockViewController

#pragma mark - Timer

- (void)onTimer:(NSTimer *)timer
{
    NSDate *nowTime = [NSDate date];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    self.title = [formatter stringFromDate:nowTime];
    //self.title = @"09:41:00"; //for ScreenShot
    [formatter setDateFormat:@"HH:mm"];
    NSString *nowHHmm = [formatter stringFromDate:nowTime];
    [formatter release];
    //NSLog(@"%@, %@", self.title, nowHHmm);

    //ActionSheet表示中は写真を切り替えない
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if ([prevHHmm_ isEqualToString:nowHHmm] == NO && appDelegate.actionSheet == nil) {
        [prevHHmm_ release], prevHHmm_ = [nowHHmm retain];
        [self changeMemory];
    }
}

- (void)stopTimer
{
    [prevHHmm_ release], prevHHmm_ = nil;
    [timer_ invalidate];
    [timer_ release], timer_ = nil;
}

- (void)startTimer
{
    [self stopTimer];
    timer_ = [[NSTimer scheduledTimerWithTimeInterval:0.25f
                                               target:self
                                             selector:@selector(onTimer:)
                                             userInfo:nil
                                              repeats:YES
               ] retain];

    [self onTimer:timer_];
}

#pragma mark - Initialize

- (void)dealloc
{
    [self stopTimer];

    [currentImage_ release], currentImage_ = nil;
    [currentName_ release], currentName_ = nil;
    [currentMessage_ release], currentMessage_ = nil;

    [navigationBar release], navigationBar = nil;
    [navigationItem release], navigationItem = nil;
    [toolBar release], toolBar = nil;
    [saveButton release], saveButton = nil;
    [trashButton release], trashButton = nil;
    [editButton release], editButton = nil;

    [photoContainer release], photoContainer = nil;
    [photoPane1 release], photoPane1 = nil;
    [photoView1 release], photoView1 = nil;
    [messageBackground1 release], messageBackground1 = nil;
    [nameLabel1 release], nameLabel1 = nil;
    [lineView1 release], lineView1 = nil;
    [messageLabel1 release], messageLabel1 = nil;
    [photoPane2 release], photoPane2 = nil;
    [photoView2 release], photoView2 = nil;
    [messageBackground2 release], messageBackground2 = nil;
    [nameLabel2 release], nameLabel2 = nil;
    [lineView2 release], lineView2 = nil;
    [messageLabel2 release], messageLabel2 = nil;

    [adBannerView release], adBannerView = nil;

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    GA_TRACK_CLASS

    [super viewDidLoad];

    self.title = @""; //UINavigationItemをOutletするとタイトルに反映されるようになる, nilだとデフォルト表示

    //初期化
    currentMemoryId_ = -1; //0はデフォルト画像
    isViewFirst_ = YES;

    photoPane1.alpha = 0;
    photoPane2.alpha = 0;

    //ナビゲーションバー、ツールバーの色を指定（半透明）
    navigationBar.tintColor = [UIColor colorWithRed:140/255.0 green:199/255.0 blue:224/255.0 alpha:1];
    navigationBar.translucent = YES;
    toolBar.tintColor = [UIColor colorWithRed:140/255.0 green:199/255.0 blue:224/255.0 alpha:1];
    toolBar.translucent = YES;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //フォント設定（Interface Builderから指定しても反映されないためコード上で設定）ChalkboardSE -> Noteworthy
        nameLabel1.font = [UIFont fontWithName:@"Noteworthy-Bold" size:messageLabel1.font.pointSize * 2];
        nameLabel2.font = [UIFont fontWithName:@"Noteworthy-Bold" size:messageLabel1.font.pointSize * 2];
        messageLabel1.font = [UIFont fontWithName:@"Noteworthy-Bold" size:messageLabel1.font.pointSize * 2];
        messageLabel2.font = [UIFont fontWithName:@"Noteworthy-Bold" size:messageLabel2.font.pointSize * 2];

        //影
        nameLabel1.shadowOffset = CGSizeMake(2, 2);
        nameLabel2.shadowOffset = CGSizeMake(2, 2);
        messageLabel1.shadowOffset = CGSizeMake(2, 2);
        messageLabel2.shadowOffset = CGSizeMake(2, 2);
    } else {
        //フォント設定（Interface Builderから指定しても反映されないためコード上で設定）ChalkboardSE -> Noteworthy
        nameLabel1.font = [UIFont fontWithName:@"Noteworthy-Bold" size:messageLabel1.font.pointSize];
        nameLabel2.font = [UIFont fontWithName:@"Noteworthy-Bold" size:messageLabel1.font.pointSize];
        messageLabel1.font = [UIFont fontWithName:@"Noteworthy-Bold" size:messageLabel1.font.pointSize];
        messageLabel2.font = [UIFont fontWithName:@"Noteworthy-Bold" size:messageLabel2.font.pointSize];

        //影
        nameLabel1.shadowOffset = CGSizeMake(1, 1);
        nameLabel2.shadowOffset = CGSizeMake(1, 1);
        messageLabel1.shadowOffset = CGSizeMake(1, 1);
        messageLabel2.shadowOffset = CGSizeMake(1, 1);
    }

    //広告初期化
    [adBannerView initBannerWithTitle:NSLocalizedString(@"OurMemories", nil) rootViewContoller:self];
}

- (void)viewDidUnload
{
    [self stopTimer];

    [currentImage_ release], currentImage_ = nil;
    [currentName_ release], currentName_ = nil;
    [currentMessage_ release], currentMessage_ = nil;

    [navigationBar release], navigationBar = nil;
    [navigationItem release], navigationItem = nil;
    [toolBar release], toolBar = nil;
    [saveButton release], saveButton = nil;
    [trashButton release], trashButton = nil;
    [editButton release], editButton = nil;

    [photoContainer release], photoContainer = nil;
    [photoPane1 release], photoPane1 = nil;
    [photoView1 release], photoView1 = nil;
    [messageBackground1 release], messageBackground1 = nil;
    [nameLabel1 release], nameLabel1 = nil;
    [lineView1 release], lineView1 = nil;
    [messageLabel1 release], messageLabel1 = nil;
    [photoPane2 release], photoPane2 = nil;
    [photoView2 release], photoView2 = nil;
    [messageBackground2 release], messageBackground2 = nil;
    [nameLabel2 release], nameLabel2 = nil;
    [lineView2 release], lineView2 = nil;
    [messageLabel2 release], messageLabel2 = nil;

    [adBannerView release], adBannerView = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //UIImagePickerControllerがidleTimerDisabledをNOにしてると思われるので、このタイミングで再設定する
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate resetIdleTimerDisabled];

    currentMemoryId_ = -1; //画面遷移した場合は同一IDでも再描画したいので現IDをクリア（登録1件のときに編集内容が反映されない問題に対応）
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //iPadはActionShhetがポップオーバー表示中でも画面遷移できてしまうので閉じる
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.actionSheet.visible) {
        [appDelegate.actionSheet dismissWithClickedButtonIndex:appDelegate.actionSheet.cancelButtonIndex animated:NO];
        appDelegate.actionSheet = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopTimer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Private methods

- (void)changeMemory
{
    NSDictionary *memory = [[MemoryModel sharedMemoryModel] nextMemory];
    int memoryId = [[memory objectForKey:@"memory_id"] intValue];
    NSString *name = [memory objectForKeyNull:@"name"];
    NSString *message = [memory objectForKeyNull:@"message"];
    UIImage *image = [memory objectForKeyNull:@"image"];

    /*
    if (memoryId == 0) {
        //表示なし
        currentMemoryId_ = memoryId;
        [currentImage_ release], currentImage_ = nil;
        [currentName_ release], currentName_ = nil;
        [currentMessage_ release], currentMessage_ = nil;
        photoPane1.alpha = 0;
        photoPane2.alpha = 0;
        return;
    }
    */
    if (memoryId == currentMemoryId_) {
        //同一のため変更なし
        return;
    }
    currentMemoryId_ = memoryId;
    [currentImage_ release], currentImage_ = [image retain];
    [currentName_ release], currentName_ = [name retain];
    [currentMessage_ release], currentMessage_ = [message retain];

    UIView *photoPaneFrom     = isViewFirst_ ? photoPane1 : photoPane2;
    UIView *photoPaneTo       = isViewFirst_ ? photoPane2 : photoPane1;
    UIImageView *photoView    = isViewFirst_ ? photoView2 : photoView1;
    UIView *messageBackground = isViewFirst_ ? messageBackground2 : messageBackground1;
    UILabel *nameLabel        = isViewFirst_ ? nameLabel2 : nameLabel1;
    UIImageView *lineView     = isViewFirst_ ? lineView2 : lineView1;
    UILabel *messageLabel     = isViewFirst_ ? messageLabel2 : messageLabel1;

    //縦向きの場合はAspectFill、横向きの場合はAspectFit（標準のアルバムと同じ、はず）
    if (image.size.height > image.size.width) {
        //Portrait
        photoView.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        //Landscape
        photoView.contentMode = UIViewContentModeScaleAspectFit;
    }
    photoView.image = image;

    //メッセージsizeおよび内容を設定、表示／非表示を切り替え
    if ([name length] > 0 || [message length] > 0) {
        //size算出
        CGSize size;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            size = [message sizeWithFont:messageLabel.font constrainedToSize:CGSizeMake(768, 320)]; //@56
        } else {
            size = [message sizeWithFont:messageLabel.font constrainedToSize:CGSizeMake(320, 160)]; //@29
        }

        //frame設定
        float width = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 768 : 320;
        float top = toolBar.frame.origin.y;
        if ([message length] > 0) {
            top -= size.height;
            messageLabel.frame = CGRectMake(0, top, width, size.height);
        }
        if ([name length] > 0 && [message length] > 0) {
            top -= lineView.frame.size.height;
            lineView.frame = CGRectMake(0, top, width, lineView.frame.size.height);
        }
        if ([name length] > 0) {
            top -= nameLabel.frame.size.height;
            nameLabel.frame = CGRectMake(0, top, width, nameLabel.frame.size.height);
        }
        messageBackground.frame = CGRectMake(0, top, width, toolBar.frame.origin.y - top);

        //text, alpha設定
        nameLabel.text          = name;
        messageLabel.text       = message;
        messageBackground.alpha = 0.5;
        nameLabel.alpha         = ([name length] > 0) ? 1 : 0;
        lineView.alpha          = ([name length] > 0 && [message length] > 0) ? 0.5 : 0;
        messageLabel.alpha      = ([message length] > 0) ? 1 : 0;
    } else {
        //text, alpha設定
        nameLabel.text          = name;
        messageLabel.text       = message;
        messageBackground.alpha = 0;
        nameLabel.alpha         = 0;
        lineView.alpha          = 0;
        messageLabel.alpha      = 0;
    }

    //切り替えアニメーション
    [UIView animateWithDuration:0.5f
                     animations:^{
                         photoPaneFrom.alpha = 0;
                         photoPaneTo.alpha = 1;
                     }];

    //ボタンの有効・無効を設定
    BOOL enabled = (currentMemoryId_ == 0) ? NO : YES;
    saveButton.enabled = enabled;
    trashButton.enabled = enabled;
    editButton.enabled = enabled;

    isViewFirst_ = !isViewFirst_;
}

#pragma mark - IBAction

- (IBAction)tapAddButton:(id)sender
{
    GA_TRACK_METHOD

    NSString *nibName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"RegisterViewController-iPad"
                                                                               : @"RegisterViewController";
    RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:nibName bundle:nil];
    registerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:registerViewController animated:YES];
    [registerViewController release];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.alertView = [[[UIAlertView alloc] initWithTitle:nil
                                                        message:error ? NSLocalizedString(@"Failed", nil)
                                                                      : NSLocalizedString(@"Saved", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil] autorelease];
    [appDelegate.alertView show];
}

- (IBAction)tapSaveButton:(id)sender
{
    GA_TRACK_METHOD

    if (currentImage_) {
        UIImageWriteToSavedPhotosAlbum(currentImage_, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (IBAction)tapTrashButton:(id)sender
{
    GA_TRACK_METHOD

    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;

    //既に表示中のActionSheetを閉じる
    if (appDelegate.actionSheet.visible) {
        NSInteger fromTag = appDelegate.actionSheet.tag;
        [appDelegate.actionSheet dismissWithClickedButtonIndex:appDelegate.actionSheet.cancelButtonIndex animated:YES];
        appDelegate.actionSheet = nil;
        //同一のActionSheetなら閉じて終了、別のActionSheetなら新規に開く
        if (fromTag == ActionSheetTypeTrash) {
            return;
        }
    }

    appDelegate.actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"Delete Photo", nil), nil] autorelease];
    appDelegate.actionSheet.tag = ActionSheetTypeTrash;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [appDelegate.actionSheet showFromBarButtonItem:sender animated:YES];
    } else {
        [appDelegate.actionSheet showInView:self.view];
    }
}

- (IBAction)tapEditButton:(id)sender
{
    GA_TRACK_METHOD

    NSString *nibName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"RegisterViewController-iPad"
                                                                               : @"RegisterViewController";
    RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:nibName bundle:nil];
    registerViewController.memoryId = currentMemoryId_;
    registerViewController.photoImage = currentImage_;
    registerViewController.name = currentName_;
    registerViewController.message = currentMessage_;
    registerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:registerViewController animated:YES];
    [registerViewController release];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.alertView = nil;
}

/*
- (void)alertViewCancel:(UIAlertView *)alertView
{
    NSLog(@"alertViewCancel");
}
*/

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;

    if (actionSheet.tag == ActionSheetTypeTrash) {
        switch (buttonIndex) {
            case 0: //Delete Photo
                [[MemoryModel sharedMemoryModel] removeMemory:currentMemoryId_];
                [self changeMemory];

                //表示を変更したので前回時刻をリセット
                NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
                [formatter setDateFormat:@"HH:mm"];
                [prevHHmm_ release], prevHHmm_ = [[formatter stringFromDate:[NSDate date]] retain];
                break;
            default: //Cancel
                break;
        }
    }

    appDelegate.actionSheet = nil; //必ず呼ばれること！！
}

@end
