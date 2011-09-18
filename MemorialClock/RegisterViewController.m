//
//  RegisterViewController.m
//  MemorialClock
//
//  Created by プー坊 on 11/09/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIPlaceHolderTextView.h"
#import "MemoryModel.h"

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
    UIActionSheet *actionSheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
        actionSheet.tag = ActionSheetTypeCameraEnable;
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Choose from Library", nil];
        actionSheet.tag = ActionSheetTypeCameraDisable;
    }
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (IBAction)tapActionButton:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Save", @"Send Mail", nil];
    actionSheet.tag = ActionSheetTypeAction;
    [actionSheet showInView:self.view];
    [actionSheet release];
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
                        return;
                }
                break;
            case ActionSheetTypeCameraDisable:
                switch (buttonIndex) {
                    case 0:
                        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        break;
                    default: //Cancel
                        return;
                }
                break;
        }
        if ([UIImagePickerController isSourceTypeAvailable:sourceType] == NO) {
            return;
        }
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = sourceType;
        imagePickerController.delegate = self;
        [self presentModalViewController:imagePickerController animated:YES];
        [imagePickerController release];

    } else if (actionSheet.tag == ActionSheetTypeAction) {
        switch (buttonIndex) {
            case 0: //Save
                if (self.memoryId == 0) {
                    //add
                    self.memoryId = [[MemoryModel sharedMemoryModel] addMemory:nameTextField.text
                                                                       message:messageTextView.text
                                                                         image:photoView.image];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:@"Saved"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                    [alertView release];
                } else {
                    //change
                }
                break;
            case 1: //Send Mail
                break;
            default: //Cancel
                return;
        }
    } else {
        return;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self dismissModalViewControllerAnimated:YES];
    self.photoImage = image;
    photoView.image = image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
