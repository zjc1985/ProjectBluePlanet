//
//  RegisterVC.m
//  MyMapBox
//
//  Created by bizappman on 7/28/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "RegisterVC.h"
#import "CommonUtil.h"
#import <AVOSCloud/AVOSCloud.h>

@interface RegisterVC ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;


@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)backtoLoginClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registerClick:(id)sender {
    if ([self isInputValid]) {
        AVUser *user=[AVUser user];
        user.email=self.emailTextField.text;
        user.password=self.passwordTextField.text;
        user.username=self.userNameTextField.text;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [CommonUtil alert:@"regiester succeed"];
                [self performSegueWithIdentifier:@"registerDoneSegue" sender:nil];
            }else{
                if(error){
                    [CommonUtil alert:error.localizedDescription];
                }else{
                    [CommonUtil alert:@"error happen when registering"];
                }
            }
        }];
    }
}

-(BOOL)isInputValid{
    BOOL returnValue=YES;
    
    if([self isBlankString:self.emailTextField.text]||[self isBlankString:self.passwordTextField.text]||[self isBlankString:self.repeatTextField.text]||[self isBlankString:self.userNameTextField.text]){
        [CommonUtil alert:@"exist blank input"];
        returnValue=NO;
    }
    
    NSString *password=self.passwordTextField.text;
    NSString *repeatPassword=self.repeatTextField.text;
    
    if(![password isEqualToString:repeatPassword]){
        [CommonUtil alert:@"password not same"];
        returnValue=NO;
    }
    
    return returnValue;
}

- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
