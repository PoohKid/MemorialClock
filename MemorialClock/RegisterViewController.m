//
//  RegisterViewController.m
//  MemorialClock
//
//  Created by プー坊 on 11/09/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MemorialClockAppDelegate.h"
#import "RegisterViewController.h"
#import "UIPlaceHolderTextView.h"
#import "MemoryModel.h"
#import "NSString+Escape.h"


typedef enum {
    ActionSheetTypeCameraEnable = 1,
    ActionSheetTypeCameraDisable,
    ActionSheetTypeMailEnable,
    ActionSheetTypeMailDisable,
} ActionSheetType;

typedef enum {
    ActionTypeNone,
    ActionTypeSave,
    ActionTypeMail,
} ActionType;

@implementation RegisterViewController

@synthesize memoryId;
@synthesize photoImage;
@synthesize name;
@synthesize message;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [photoImage release], photoImage = nil;
    [name release], name = nil;
    [message release], message = nil;

    [toolBar release], toolBar = nil;
    [backButton release], backButton = nil;
    [cameraButton release], cameraButton = nil;
    [actionButton release], actionButton = nil;
    [photoView release], photoView = nil;
    [nameTextField release], nameTextField = nil;
    [messageTextView release], messageTextView = nil;

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    GA_TRACK_CLASS

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //ツールバーの色を指定（半透明）
    toolBar.tintColor = [UIColor colorWithRed:140/255.0 green:199/255.0 blue:224/255.0 alpha:1];
    toolBar.translucent = YES;

    backButton.title = NSLocalizedString(@"Back", nil);

    //Photo初期表示
    photoView.image = self.photoImage;

    //Name初期表示＋プレースホルダ（ImagePicker表示中にUnloadされることがあるので、入力内容の通知を受けプロパティに保持する）
    nameTextField.text = self.name;
    nameTextField.placeholder = NSLocalizedString(@"Name", nil);

    //Message初期表示＋プレースホルダ（ImagePicker表示中にUnloadされることがあるので、入力内容の通知を受けプロパティに保持する）
    messageTextView.text = self.message;
    messageTextView.placeholder = NSLocalizedString(@"Message", nil);
    messageTextView.placeholderColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //フォント設定
        nameTextField.font = [UIFont fontWithName:@"Noteworthy-Bold" size:nameTextField.font.pointSize * 2];
        messageTextView.font = [UIFont fontWithName:@"Noteworthy-Bold" size:messageTextView.font.pointSize * 2];
        //最小フォントサイズ
        nameTextField.minimumFontSize *= 2;
    } else {
        //フォント設定
        nameTextField.font = [UIFont fontWithName:@"Noteworthy-Bold" size:nameTextField.font.pointSize];
        messageTextView.font = [UIFont fontWithName:@"Noteworthy-Bold" size:messageTextView.font.pointSize];
    }
    //messageTextViewのオリジナルの高さを保存
    originalMessageTextViewHeight_ = messageTextView.frame.size.height;
}

- (void)viewDidUnload
{
    //NSLog(@"viewDidUnload");

    //propertyは解放しないこと

    [toolBar release], toolBar = nil;
    [backButton release], backButton = nil;
    [cameraButton release], cameraButton = nil;
    [actionButton release], actionButton = nil;
    [photoView release], photoView = nil;
    [nameTextField release], nameTextField = nil;
    [messageTextView release], messageTextView = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //UITextField, UITextView変更の通知の開始
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChanged:) name:UITextViewTextDidChangeNotification object:nil];

    //キーボード表示・非表示の通知の開始
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    //キーボード表示
    [nameTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //iPadはActionShhetがポップオーバー表示中でも画面遷移できてしまうので閉じる
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.actionSheet.visible) {
        [appDelegate.actionSheet dismissWithClickedButtonIndex:appDelegate.actionSheet.cancelButtonIndex animated:NO];
        appDelegate.actionSheet = nil;
    }
    //ImagePickerも閉じる
    if (appDelegate.popoverController) {
        [appDelegate.popoverController dismissPopoverAnimated:NO];
        appDelegate.popoverController = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    //UITextField, UITextView変更の通知を終了
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];

    //キーボード表示・非表示の通知を終了
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - IBAction

- (IBAction)tapBackButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)tapCameraButton:(id)sender
{
    GA_TRACK_METHOD

    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;

    //既に表示中のImagePickerを閉じる
    if (appDelegate.popoverController) {
        [appDelegate.popoverController dismissPopoverAnimated:YES];
        appDelegate.popoverController = nil;
        return; //ImagePickerは自ボタンからの遷移なので閉じて終了
    }
    //既に表示中のActionSheetを閉じる
    if (appDelegate.actionSheet.visible) {
        NSInteger fromTag = appDelegate.actionSheet.tag;
        [appDelegate.actionSheet dismissWithClickedButtonIndex:appDelegate.actionSheet.cancelButtonIndex animated:YES];
        appDelegate.actionSheet = nil;
        //同一のActionSheetなら閉じて終了、別のActionSheetなら新規に開く
        if (fromTag == ActionSheetTypeCameraEnable ||
            fromTag == ActionSheetTypeCameraDisable) {
            return;
        }
    }

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        appDelegate.actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"Take Photo", nil),
                                                                        NSLocalizedString(@"Choose from Library", nil),
                                                                        nil] autorelease];
        appDelegate.actionSheet.tag = ActionSheetTypeCameraEnable;
    } else {
        appDelegate.actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"Choose from Library", nil),
                                                                        nil] autorelease];
        appDelegate.actionSheet.tag = ActionSheetTypeCameraDisable;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [appDelegate.actionSheet showFromBarButtonItem:sender animated:YES];
    } else {
        [appDelegate.actionSheet showInView:self.view];
    }
}

- (IBAction)tapActionButton:(id)sender
{
    GA_TRACK_METHOD

    BOOL canSendMail = NO;
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		if ([mailClass canSendMail]) {
            canSendMail = YES;
		}
	}

    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;

    //既に表示中のImagePickerを閉じる
    if (appDelegate.popoverController) {
        [appDelegate.popoverController dismissPopoverAnimated:YES];
        appDelegate.popoverController = nil;
    }
    //既に表示中のActionSheetを閉じる
    if (appDelegate.actionSheet.visible) {
        NSInteger fromTag = appDelegate.actionSheet.tag;
        [appDelegate.actionSheet dismissWithClickedButtonIndex:appDelegate.actionSheet.cancelButtonIndex animated:YES];
        appDelegate.actionSheet = nil;
        //同一のActionSheetなら閉じて終了、別のActionSheetなら新規に開く
        if (fromTag == ActionSheetTypeMailEnable ||
            fromTag == ActionSheetTypeMailDisable) {
            return;
        }
    }

    if (canSendMail) {
        appDelegate.actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"Save", nil),
                                                                        NSLocalizedString(@"Send Mail", nil),
                                                                        nil] autorelease];
        appDelegate.actionSheet.tag = ActionSheetTypeMailEnable;
    } else {
        appDelegate.actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"Save", nil),
                                                                        nil] autorelease];
        appDelegate.actionSheet.tag = ActionSheetTypeMailDisable;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [appDelegate.actionSheet showFromBarButtonItem:sender animated:YES];
    } else {
        [appDelegate.actionSheet showInView:self.view];
    }
}

#pragma mark - UITextFieldTextDidChangeNotification

- (void)textFieldChanged:(NSNotification *)notification
{
    self.name = nameTextField.text;
}

#pragma mark - UITextViewTextDidChangeNotification

- (void)textViewChanged:(NSNotification *)notification
{
    self.message = messageTextView.text;
}

#pragma mark - UIKeyboardNotification

//キーボードが表示された場合
- (void)keyboardWillShow:(NSNotification *)aNotification {
    //キーボードのCGRectを取得
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //キーボードのanimationDurationを取得
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    //messageTextViewの高さを調整
    CGRect frame = messageTextView.frame;
    frame.size.height = originalMessageTextViewHeight_ - keyboardRect.size.height;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         messageTextView.frame = frame;
                     }];
}

//キーボードが非表示にされた場合
- (void)keyboardWillHide:(NSNotification *)aNotification {
    //messageTextViewの高さを調整
    CGRect frame = messageTextView.frame;
    frame.size.height = originalMessageTextViewHeight_;
    messageTextView.frame = frame; //アニメーションすると見た目がおかしくなる
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.alertView = nil;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;

    if (actionSheet.tag == ActionSheetTypeCameraEnable ||
        actionSheet.tag == ActionSheetTypeCameraDisable) {

        UIImagePickerControllerSourceType sourceType = -1;
        switch (actionSheet.tag) {
            case ActionSheetTypeCameraEnable:
                switch (buttonIndex) {
                    case 0:
                        GA_TRACK_EVENT(NSStringFromClass([self class]),  NSStringFromSelector(_cmd), @"Camera", -1);
                        sourceType = UIImagePickerControllerSourceTypeCamera;
                        break;
                    case 1:
                        GA_TRACK_EVENT(NSStringFromClass([self class]),  NSStringFromSelector(_cmd), @"PhotoLibrary", -1);
                        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        break;
                    default: //Cancel
                        break;
                }
                break;
            case ActionSheetTypeCameraDisable:
                switch (buttonIndex) {
                    case 0:
                        GA_TRACK_EVENT(NSStringFromClass([self class]),  NSStringFromSelector(_cmd), @"PhotoLibrary", -1);
                        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        break;
                    default: //Cancel
                        break;
                }
                break;
        }
        if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = sourceType;
            imagePickerController.delegate = self;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                //iPad用：Popover表示
                appDelegate.popoverController = [[[UIPopoverController alloc] initWithContentViewController:imagePickerController] autorelease];
                appDelegate.popoverController.delegate = self;
                [appDelegate.popoverController presentPopoverFromBarButtonItem:cameraButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                //iPhone用：ImagePickerをモーダル表示
                [self presentModalViewController:imagePickerController animated:YES];
            }
            [imagePickerController release];
        }

    } else if (actionSheet.tag == ActionSheetTypeMailEnable ||
               actionSheet.tag == ActionSheetTypeMailDisable) {

        ActionType actionType = ActionTypeNone;
        switch (actionSheet.tag) {
            case ActionSheetTypeMailEnable:
                switch (buttonIndex) {
                    case 0: //Save
                        actionType = ActionTypeSave;
                        break;
                    case 1: //Send Mail
                        actionType = ActionTypeMail;
                        break;
                    default: //Cancel
                        break;
                }
                break;
            case ActionSheetTypeMailDisable:
                switch (buttonIndex) {
                    case 0: //Save
                        actionType = ActionTypeSave;
                        break;
                    default: //Cancel
                        break;
                }
                break;
        }
        switch (actionType) {
            case ActionTypeSave:
                GA_TRACK_EVENT(NSStringFromClass([self class]),  NSStringFromSelector(_cmd), @"Save", -1);
                if (self.memoryId == 0) {
                    //add
                    self.memoryId = [[MemoryModel sharedMemoryModel] addMemory:nameTextField.text
                                                                       message:messageTextView.text
                                                                         image:photoView.image];
                } else {
                    //change
                    [[MemoryModel sharedMemoryModel] changeMemory:self.memoryId
                                                             name:nameTextField.text
                                                          message:messageTextView.text
                                                            image:photoView.image];
                }
                appDelegate.alertView = [[[UIAlertView alloc] initWithTitle:nil
                                                                    message:NSLocalizedString(@"Saved", nil)
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                          otherButtonTitles:nil] autorelease];
                [appDelegate.alertView show];
                break;
            case ActionTypeMail:
                GA_TRACK_EVENT(NSStringFromClass([self class]),  NSStringFromSelector(_cmd), @"Send Mail", -1);
                {
                    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
                    if (mailComposeViewController) {
                        mailComposeViewController.mailComposeDelegate = self;

                        //メールタイトル設定
                        [mailComposeViewController setSubject:NSLocalizedString(@"OurMemories", nil)];

                        //メール本文を設定
                        NSString *messageString = @"";
                        if (NO) {
                        } else if ([nameTextField.text length] > 0 && [messageTextView.text length] > 0) {  //name + message
                            messageString = [NSString stringWithFormat:@"%@\n%@", nameTextField.text, messageTextView.text];
                        } else if ([nameTextField.text length] > 0) {
                            messageString = [NSString stringWithFormat:@"%@", nameTextField.text];      //name のみ
                        } else if ([messageTextView.text length] > 0) {
                            messageString = [NSString stringWithFormat:@"%@", messageTextView.text];    //message のみ
                        }
                        NSString *messageBody;
                        if (photoView.image) {
                            messageBody = [NSString stringWithFormat:
                                           @"%@\n"
                                           @"\n"
                                           @"----\n"
                                           @"%@\n"
                                           @"%@\n"
                                           @"%@\n"
                                           @"\n"
                                           @"%@\n"
                                           @"1.%@\n"
                                           @"2.%@\n"
                                           @"3.%@\n"
                                           @"4.%@\n"
                                           @"5.%@\n"
                                           @"6.%@\n"
                                           @"7.%@\n"
                                           @"\n"
                                           @"%@\n"
                                           @"%@\n"
                                           @"%@\n"
                                           @"\n"
                                           @"memorialclock:///regist?name=%@&message=%@\n",
                                           messageString,
                                           NSLocalizedString(@"MailBody 1", nil),
                                           NSLocalizedString(@"MailBody 2", nil),
                                           NSLocalizedString(@"MailBody 3", nil),
                                           NSLocalizedString(@"HowToUse title", nil),
                                           NSLocalizedString(@"HowToUse 1", nil),
                                           NSLocalizedString(@"HowToUse 2", nil),
                                           NSLocalizedString(@"HowToUse 3", nil),
                                           NSLocalizedString(@"HowToUse 4", nil),
                                           NSLocalizedString(@"HowToUse 5", nil),
                                           NSLocalizedString(@"HowToUse 6", nil),
                                           NSLocalizedString(@"HowToUse 7", nil),
                                           NSLocalizedString(@"HowToUse footer 1", nil),
                                           NSLocalizedString(@"HowToUse footer 2", nil),
                                           NSLocalizedString(@"HowToUse footer 3", nil),
                                           [nameTextField.text escapeString], [messageTextView.text escapeString]];
                        } else {
                            messageBody = [NSString stringWithFormat:
                                           @"%@\n"
                                           @"\n"
                                           @"----\n"
                                           @"%@\n"
                                           @"%@\n"
                                           @"%@\n"
                                           @"\n"
                                           @"%@\n"
                                           @"1.%@\n"
                                           @"2.%@\n"
                                           @"3.%@\n"
                                           @"4.%@\n"
                                           @"5.%@\n"
                                           @"\n"
                                           @"%@\n"
                                           @"%@\n"
                                           @"%@\n"
                                           @"\n"
                                           @"memorialclock:///regist?name=%@&message=%@\n",
                                           messageString,
                                           NSLocalizedString(@"MailBody 1", nil),
                                           NSLocalizedString(@"MailBody 2", nil),
                                           NSLocalizedString(@"MailBody 3", nil),
                                           NSLocalizedString(@"HowToUse title", nil),
                                           NSLocalizedString(@"HowToUse 1", nil),
                                           NSLocalizedString(@"HowToUse 3", nil),
                                           NSLocalizedString(@"HowToUse 4", nil),
                                           NSLocalizedString(@"HowToUse 6", nil),
                                           NSLocalizedString(@"HowToUse 7", nil),
                                           NSLocalizedString(@"HowToUse footer 1", nil),
                                           NSLocalizedString(@"HowToUse footer 2", nil),
                                           NSLocalizedString(@"HowToUse footer 3", nil),
                                           [nameTextField.text escapeString], [messageTextView.text escapeString]];
                        }
                        [mailComposeViewController setMessageBody:messageBody isHTML:NO];

                        //画像を添付
                        if (photoView.image) {
                            NSData *data = [[NSData alloc] initWithData:UIImageJPEGRepresentation(photoView.image, 1.0f)];
                            [mailComposeViewController addAttachmentData:data mimeType:@"image/jpg" fileName:@"photo"];
                            [data release];
                        }

                        //MFMailComposeViewController表示
                        [self presentModalViewController:mailComposeViewController animated:YES];
                        [mailComposeViewController release];
                    }
                }
                break;
            default: //ActionTypeNone(Cancel)
                break;
        }
    }

    appDelegate.actionSheet = nil; //必ず呼ばれること！！
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.popoverController) {
        [appDelegate.popoverController dismissPopoverAnimated:YES];
        appDelegate.popoverController = nil;
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }

    //NSLog(@"%f, %f", image.size.width, image.size.height); //カメラ撮影時: 1536.000000, 2048.000000

    //iPad/iPad 2   1024x768    iPhoneと縦横比が異なる / ただしカメラ撮影と縦横比が同じ
    //Retina        960x640
    //iPhone 3G/3GS 480x320

    //画像リサイズ（iPadに合わせる）
    //  理由1.画面に表示するだけならオリジナルサイズは要らないので、サイズを縮小する
    //  理由2.カメラ撮影時、UIImage->NSData->ファイルに保存->UIImageで90度左に回転する現象を、drawInRect:をはさむことで解消する

    size_t resize_w = 768; //iPad(portrait)横の値で固定
    size_t resize_h = floor(resize_w * image.size.height / image.size.width);
    //NSLog(@"%lu, %lu", resize_w, resize_h); //768, 1024

    UIGraphicsBeginImageContext(CGSizeMake(resize_w, resize_h));
    [image drawInRect:CGRectMake(0, 0, resize_w, resize_h)];
    self.photoImage = UIGraphicsGetImageFromCurrentImageContext();
    photoView.contentMode = (self.photoImage.size.height > self.photoImage.size.width) ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
    photoView.image = self.photoImage;
    UIGraphicsEndImageContext();
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES]; //Popoverの場合は呼ばれない？（カメラ時は？）
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.popoverController = nil;
}

@end
