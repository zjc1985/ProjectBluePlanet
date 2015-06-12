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

#import "CloudManager.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)searchRoutineByLatLng:(id)sender {
    [CloudManager searchRoutinesByLat:[NSNumber numberWithDouble:31.233080]
                                  lng:[NSNumber numberWithDouble:121.469827]
                            withLimit:[NSNumber numberWithUnsignedInteger:5]
                             withPage:[NSNumber numberWithUnsignedInteger:1]
                    withBlockWhenDone:^(NSError *error, NSArray *routines) {
                        if(!error){
                            NSLog(@"fetch success");
                        }
    }];
}

- (IBAction)showNetworkTypeClick:(id)sender {
    NSNumber *type=[CommonUtil dataNetworkTypeFromStatusBar];
    [CommonUtil alert:[NSString stringWithFormat:@"net type: %ld",(long)[type integerValue]]];
}


-(void)viewWillAppear:(BOOL)animated{
}

- (IBAction)syncClick:(id)sender {
    [CloudManager syncRoutinesAndOvMarkersWithBlockWhenDone:^(NSError *error) {
        NSLog(@"sync complete");
        [CommonUtil alert:@"sync complete"];
    }];
}

- (IBAction)logoutClick:(id)sender {
    [AVUser logOut];
    
    //todo clean core data data
    [CommonUtil resetCoreData];
    
    [CommonUtil alert:@"logout success"];
}


@end
