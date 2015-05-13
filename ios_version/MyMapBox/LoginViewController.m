//
//  LoginViewController.m
//  MyMapBox
//
//  Created by bizappman on 5/13/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "LoginViewController.h"
#import "CommonUtil.h"
#import <AVOSCloud/AVOSCloud.h>

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)LoginClicked:(id)sender {
    NSString *userName=self.userNameTextField.text;
    NSString *pwd=self.pwdTextField.text;
    
    [AVUser logInWithUsernameInBackground:userName password:pwd block:^(AVUser *user, NSError *error) {
        if (user != nil) {
            NSLog(@"Login success");
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"Login failed");
            [CommonUtil alert:@"username or pwd not correct"];
        }
    }];
}

@end
