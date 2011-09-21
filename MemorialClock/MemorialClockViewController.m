//
//  MemorialClockViewController.m
//  MemorialClock
//
//  Created by プー坊 on 11/09/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MemorialClockViewController.h"
#import "RegisterViewController.h"
#import "MemoryModel.h"
#import "NSDictionary+Null.h"


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
    [formatter setDateFormat:@"HH:mm"];
    NSString *nowHHmm = [formatter stringFromDate:nowTime];
    [formatter release];
    //NSLog(@"%@, %@", self.title, nowHHmm);

    if ([prevHHmm_ isEqualToString:nowHHmm] == NO) {
        [prevHHmm_ release], prevHHmm_ = [nowHHmm retain];
        [self changeMemory];
    }
}

#pragma mark - Initialize

- (void)dealloc
{
    [prevHHmm_ release], prevHHmm_ = nil;
    [timer_ invalidate];
    [timer_ release], timer_ = nil;

    [currentImage_ release], currentImage_ = nil;
    [currentName_ release], currentName_ = nil;
    [currentMessage_ release], currentMessage_ = nil;

    [navigationBar release], navigationBar = nil;
    [navigationItem release], navigationItem = nil;
    [toolBar release], toolBar = nil;

    [photoContainer release], photoContainer = nil;
    [photoPane1 release], photoPane1 = nil;
    [photoView1 release], photoView1 = nil;
    [messageBackground1 release], messageBackground1 = nil;
    [messageLabel1 release], messageLabel1 = nil;
    [photoPane2 release], photoPane2 = nil;
    [photoView2 release], photoView2 = nil;
    [messageBackground2 release], messageBackground2 = nil;
    [messageLabel2 release], messageLabel2 = nil;

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
    [super viewDidLoad];

    self.title = @""; //UINavigationItemをOutletするとタイトルに反映されるようになる, nilだとデフォルト表示

    //初期化
    currentMemoryId_ = 0;
    isViewFirst_ = YES;

    photoPane1.alpha = 0;
    photoPane2.alpha = 0;

    [prevHHmm_ release], prevHHmm_ = nil;
    [timer_ invalidate];
    [timer_ release];
    timer_ = [[NSTimer scheduledTimerWithTimeInterval:0.25f
                                               target:self
                                             selector:@selector(onTimer:)
                                             userInfo:nil
                                              repeats:YES
               ] retain];

    [self onTimer:timer_];
}

- (void)viewDidUnload
{
    [prevHHmm_ release], prevHHmm_ = nil;
    [timer_ invalidate];
    [timer_ release], timer_ = nil;

    [currentImage_ release], currentImage_ = nil;
    [currentName_ release], currentName_ = nil;
    [currentMessage_ release], currentMessage_ = nil;

    [navigationBar release], navigationBar = nil;
    [navigationItem release], navigationItem = nil;
    [toolBar release], toolBar = nil;

    [photoContainer release], photoContainer = nil;
    [photoPane1 release], photoPane1 = nil;
    [photoView1 release], photoView1 = nil;
    [messageBackground1 release], messageBackground1 = nil;
    [messageLabel1 release], messageLabel1 = nil;
    [photoPane2 release], photoPane2 = nil;
    [photoView2 release], photoView2 = nil;
    [messageBackground2 release], messageBackground2 = nil;
    [messageLabel2 release], messageLabel2 = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    if (memoryId == currentMemoryId_) {
        //同一のため変更なし
        return;
    }
    currentMemoryId_ = memoryId;
    [currentImage_ release], currentImage_ = [image retain];
    [currentName_ release], currentName_ = [name retain];
    [currentMessage_ release], currentMessage_ = [message retain];

    UIView *photoPaneFrom =     isViewFirst_ ? photoPane1 : photoPane2;
    UIView *photoPaneTo =       isViewFirst_ ? photoPane2 : photoPane1;
    UIImageView *photoView =    isViewFirst_ ? photoView2 : photoView1;
//    UIView *messageBackground = isViewFirst_ ? messageBackground2 : messageBackground1;
    UILabel *messageLabel =     isViewFirst_ ? messageLabel2 : messageLabel1;

    photoView.image = image;
//    messageBackground; //大きさを変える
    messageLabel.text = [NSString stringWithFormat:@"%@\n\n%@", name, message];

    [UIView animateWithDuration:0.5f
                     animations:^{
                         photoPaneFrom.alpha = 0;
                         photoPaneTo.alpha = 1;
                     }];

    isViewFirst_ = !isViewFirst_;
}

#pragma mark - IBAction

- (IBAction)tapAddButton:(id)sender
{
    RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    registerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:registerViewController animated:YES];
    [registerViewController release];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:error ? @"Failed" : @"Saved"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (IBAction)tapSaveButton:(id)sender
{
    if (currentImage_) {
        UIImageWriteToSavedPhotosAlbum(currentImage_, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (IBAction)tapTrashButton:(id)sender
{
}

- (IBAction)tapEditButton:(id)sender
{
    RegisterViewController *registerViewController = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];

    registerViewController.memoryId = currentMemoryId_;
    registerViewController.photoImage = currentImage_;
    registerViewController.name = currentName_;
    registerViewController.message = currentMessage_;

    registerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:registerViewController animated:YES];
    [registerViewController release];
}

@end
