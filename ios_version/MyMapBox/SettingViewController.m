//
//  SettingViewController.m
//  MyMapBox
//
//  Created by yufu on 15/5/13.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "SettingViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "CommonUtil.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutClick:(id)sender {
    [AVUser logOut];
    
    //todo clean core data data
    
    [CommonUtil alert:@"logout success"];
}


@end
