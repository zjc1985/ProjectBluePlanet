//
//  RoutineDetailMapViewController.m
//  MyMapBox
//
//  Created by yufu on 15/4/13.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "RoutineDetailMapViewController.h"

@interface RoutineDetailMapViewController ()
@property (weak, nonatomic) IBOutlet UIToolbar *playRoutineToolBar;

@end

@implementation RoutineDetailMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.view insertSubview:self.mapView belowSubview:self.playRoutineToolBar];
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
