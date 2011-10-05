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
    ActionSheetTypeCameraEnable,
    ActionSheetTypeCameraDisable,
    ActionSheetTypeAction,
} ActionSheetType;

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

    [photoView release], photoView = nil;
    [nameTextField release], nameTextField = nil;
    [messageTextView release], messageTextView = nil;

    popoverController_.delegate = nil;
    [popoverController_ release], popoverController_ = nil;

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //Photo初期表示
    photoView.image = self.photoImage;

    //Name初期表示＋プレースホルダ（ImagePicker表示中にUnloadされることがあるので、入力内容の通知を受けプロパティに保持する）
    nameTextField.text = self.name;
    nameTextField.placeholder = @"Name";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];

    //Message初期表示＋プレースホルダ（ImagePicker表示中にUnloadされることがあるので、入力内容の通知を受けプロパティに保持する）
    messageTextView.text = self.message;
    messageTextView.placeholder = @"Message";
    messageTextView.placeholderColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChanged:) name:UITextViewTextDidChangeNotification object:nil];

    //フォント設定
    nameTextField.font = [UIFont fontWithName:@"Noteworthy-Bold" size:nameTextField.font.pointSize];
    messageTextView.font = [UIFont fontWithName:@"Noteworthy-Bold" size:messageTextView.font.pointSize];

    //キーボード表示
    [nameTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    NSLog(@"viewDidUnload");

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //propertyは解放しないこと

    [photoView release], photoView = nil;
    [nameTextField release], nameTextField = nil;
    [messageTextView release], messageTextView = nil;

    popoverController_.delegate = nil;
    [popoverController_ release], popoverController_ = nil;

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

#pragma mark - IBAction

- (IBAction)tapBackButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)tapCameraButton:(id)sender
{
    //ラーメン大陸
    //写真を撮る、写真をライブラリから選択
    //Twitter
    //Take Photo or Video..., Choose from Library...
    //写真やビデオを撮る..., ライブラリから選択...
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        appDelegate.actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:@"Take Photo", @"Choose from Library", nil] autorelease];
        appDelegate.actionSheet.tag = ActionSheetTypeCameraEnable;
    } else {
        appDelegate.actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:@"Choose from Library", nil] autorelease];
        appDelegate.actionSheet.tag = ActionSheetTypeCameraDisable;
    }
    [appDelegate.actionSheet showInView:self.view];
}

- (IBAction)tapActionButton:(id)sender
{
    MemorialClockAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Save", @"Send Mail", nil] autorelease];
    appDelegate.actionSheet.tag = ActionSheetTypeAction;
    [appDelegate.actionSheet showInView:self.view];
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
                        sourceType = UIImagePickerControllerSourceTypeCamera;
                        break;
                    case 1:
                        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        break;
                    default: //Cancel
                        break;
                }
                break;
            case ActionSheetTypeCameraDisable:
                switch (buttonIndex) {
                    case 0:
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
                popoverController_.delegate = nil;
                [popoverController_ release];
                popoverController_ = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
                popoverController_.delegate = self;
                [popoverController_ presentPopoverFromRect:self.view.bounds inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                //iPhone用：ImagePickerをモーダル表示
                [self presentModalViewController:imagePickerController animated:YES];
            }
            [imagePickerController release];
        }

    } else if (actionSheet.tag == ActionSheetTypeAction) {
        switch (buttonIndex) {
            case 0: //Save
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
                                                                    message:@"Saved"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil] autorelease];
                [appDelegate.alertView show];
                break;
            case 1: //Send Mail
                {
                    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
                    mailComposeViewController.mailComposeDelegate = self;

                    //メールタイトル設定
                    [mailComposeViewController setSubject:@"OurMemories"]; //卒業時計

                    //メール本文を設定
                    NSString *messageBody;
                    if (photoView.image) {
                        messageBody = [NSString stringWithFormat:
                                       @"Happy Graduation!\n"                                   //卒業おめでとう！
                                       @"\n"
                                       @"Please save your photo album first.\n"                 //まず写真をアルバムに保存してください。
                                       @"\n"
                                       @"Please click the link below and then.\n"               //その後で下のリンクをクリックしてください。
                                       @"Then \"OurMemories\" open the registration screen.\n"  //すると"卒業時計"の登録画面が開きます。
                                       @"\n"
                                       @"memorialclock:///regist?name=%@&message=%@\n",
                                       [nameTextField.text escapeString], [messageTextView.text escapeString]];
                    } else {
                        messageBody = [NSString stringWithFormat:
                                       @"Happy Graduation!\n"                                   //卒業おめでとう！
                                       @"\n"
                                       @"Please click the link below.\n"                        //下のリンクをクリックしてください。
                                       @"Then \"OurMemories\" open the registration screen.\n"  //すると"卒業時計"の登録画面が開きます。
                                       @"\n"
                                       @"memorialclock:///regist?name=%@&message=%@\n",
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
                break;
            default: //Cancel
                break;
        }
    }

    appDelegate.actionSheet = nil; //必ず呼ばれること！！
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    if (popoverController_) {
        [popoverController_ dismissPopoverAnimated:YES];
        popoverController_.delegate = nil;
        [popoverController_ release], popoverController_ = nil;
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
    popoverController_.delegate = nil;
    [popoverController_ release], popoverController_ = nil;
}

@end
