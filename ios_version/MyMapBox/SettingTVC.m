//
//  SettingTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/24/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "SettingTVC.h"
#import <AVOSCloud/AVOSCloud.h>
#import "CommonUtil.h"

#import "CloudManager.h"

@interface SettingTVC ()

@end

@implementation SettingTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)logOutClick:(id)sender {
    [AVUser logOut];
    
    //todo clean core data data
    [CommonUtil resetCoreData];
    
    [CommonUtil alert:@"logout success"];
}

- (IBAction)testFeature:(id)sender {
   
}

@end
