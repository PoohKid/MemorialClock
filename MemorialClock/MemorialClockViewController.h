//
//  MemorialClockViewController.h
//  MemorialClock
//
//  Created by プー坊 on 11/09/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MultiADBannerView;

@interface MemorialClockViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
    NSTimer *timer_;
    NSString *prevHHmm_;

    int currentMemoryId_;
    UIImage *currentImage_;
    NSString *currentName_;
    NSString *currentMessage_;
    BOOL isViewFirst_;

    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UINavigationItem *navigationItem;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UIBarButtonItem *saveButton;
    IBOutlet UIBarButtonItem *trashButton;
    IBOutlet UIBarButtonItem *editButton;

    IBOutlet UIView *photoContainer;
    IBOutlet UIView *photoPane1;
    IBOutlet UIImageView *photoView1;
    IBOutlet UIView *messageBackground1;
    IBOutlet UILabel *messageLabel1;
    IBOutlet UIView *photoPane2;
    IBOutlet UIImageView *photoView2;
    IBOutlet UIView *messageBackground2;
    IBOutlet UILabel *messageLabel2;

    IBOutlet MultiADBannerView *adBannerView;
}

- (IBAction)tapAddButton:(id)sender;
- (IBAction)tapSaveButton:(id)sender;
- (IBAction)tapTrashButton:(id)sender;
- (IBAction)tapEditButton:(id)sender;

@end
