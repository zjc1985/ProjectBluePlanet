//
//  PrivacyVC.m
//  MyMapBox
//
//  Created by bizappman on 8/27/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "PrivacyVC.h"

@interface PrivacyVC ()
@property (weak, nonatomic) IBOutlet UITextView *policyTV;

@end

@implementation PrivacyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.policyTV.text=NSLocalizedStringFromTable(@"privacy",@"PrivacyPolicy", nil);
}


- (IBAction)cancelClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
