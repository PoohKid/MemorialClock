//
//  RegisterViewController.h
//  MemorialClock
//
//  Created by プー坊 on 11/09/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>


@class UIPlaceHolderTextView;

@interface RegisterViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MFMailComposeViewControllerDelegate, UIPopoverControllerDelegate> {

    int memoryId;
    UIImage *photoImage;
    NSString *name;
    NSString *message;

    IBOutlet UIToolbar *toolBar;
    IBOutlet UIBarButtonItem *backButton;
    IBOutlet UIBarButtonItem *cameraButton;
    IBOutlet UIBarButtonItem *actionButton;
    IBOutlet UIImageView *photoView;
    IBOutlet UITextField *nameTextField;
    IBOutlet UIPlaceHolderTextView *messageTextView;

    CGFloat originalMessageTextViewHeight_;
}

@property (nonatomic) int memoryId;
@property (nonatomic, retain) UIImage *photoImage;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *message;

- (IBAction)tapBackButton:(id)sender;
- (IBAction)tapCameraButton:(id)sender;
- (IBAction)tapActionButton:(id)sender;

@end
