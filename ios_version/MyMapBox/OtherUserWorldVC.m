//
//  OtherUserWorldVC.m
//  MyMapBox
//
//  Created by bizappman on 6/18/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "OtherUserWorldVC.h"
#import "OtherUserRoutineInfoTVC.h"
#import "CloudManager.h"
#import "CommonUtil.h"
#import "MMSearchedOvMarker.h"

#define SHOW_OTHER_USER_ROUTINR_INFO_SEGUE @"showOtherUserRoutineInfoSegue"

@interface OtherUserWorldVC ()

@end

@implementation OtherUserWorldVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    self.title=@"Loading...";
    [CloudManager searchRoutinesByUserId:self.userId withBlockWhenDone:^(NSError *error, NSArray *routines) {
        
        if(!error){
            self.title=[NSString stringWithFormat:@"%@'s World",self.userName];
            self.searchedRoutines=routines;
            [self updateMapUI];
        }else{
            self.title=@"";
            [CommonUtil alert:error.localizedDescription];
        }
    }];
}

-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    if([annotation.userInfo isKindOfClass:[MMSearchedOvMarker class]]){
        MMSearchedOvMarker *ovMarker=annotation.userInfo;
        [self performSegueWithIdentifier:SHOW_OTHER_USER_ROUTINR_INFO_SEGUE sender:ovMarker.belongRoutine];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SHOW_OTHER_USER_ROUTINR_INFO_SEGUE]) {
        OtherUserRoutineInfoTVC *destTVC=segue.destinationViewController;
        destTVC.routine=sender;
    }
}
@end
