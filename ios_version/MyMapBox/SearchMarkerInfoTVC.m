//
//  SearchMarkerInfoTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "SearchMarkerInfoTVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MWPhotoBrowser.h"
#import "PinMarkerTVC.h"
#import "MMMarker+Dao.h"
#import "SearchRoutineDetailMapVC.h"
#import "PinMarkerRoutineSelectTVC.h"

@interface SearchMarkerInfoTVC ()


@end

@implementation SearchMarkerInfoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [self updateUI];
}

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSearchDetailMapSegue"]){
        SearchRoutineDetailMapVC *desVC=segue.destinationViewController;
        desVC.parentMarker=self.marker;
        MMSearchdeMarker *marker=self.marker;
        desVC.routine=marker.belongRoutine;
    }else if ([segue.identifier isEqualToString:@"searchPinMarkerSegue"]){
        UINavigationController *navController=(UINavigationController *)segue.destinationViewController;
        PinMarkerRoutineSelectTVC *pinRoutineSelectTVC=navController.viewControllers[0];
        
        pinRoutineSelectTVC.markerNeedPin=self.marker;
        pinRoutineSelectTVC.needShowCurrentRoutine=NO;
    }
}

#pragma mark - ui action
- (IBAction)pinClick:(id)sender {
    [self performSegueWithIdentifier:@"searchPinMarkerSegue" sender:nil];
}

- (IBAction)detailClick:(id)sender {
    [self performSegueWithIdentifier:@"showSearchDetailMapSegue" sender:nil];
}


@end
