//
//  RoutineInfoViewController.m
//  MyMapBox
//
//  Created by bizappman on 4/13/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "RoutineInfoViewController.h"
#import "RoutineDetailMapViewController.h"
#import "RoutineEditTVC.h"
#import "OfflineRoutineTVC.h"
#import "CommonUtil.h"
#import "MMRoutine+Dao.h"
#import "CloudManager.h"

@interface RoutineInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (weak,nonatomic) MMRoutine *routine;
@property (weak, nonatomic) IBOutlet UITableViewCell *offlineRoutineCell;

@end

@implementation RoutineInfoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.offlineRoutineCell.hidden=YES;
    
    NSLog(@"RoutineInfoVC did load");
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:YES];
    
    self.titleLabel.text=self.routine.title;
    self.descriptionTextField.text=self.routine.mycomment;
}

- (IBAction)showRoutineDetailClick:(id)sender {
    NSLog(@"Show Routine Detail click");
}


- (IBAction)PinRoutineClick:(id)sender {
    NSLog(@"Pin Routine Detail click");
}

#pragma mark - getter and setter
-(MMRoutine *)routine{
    return self.ovMarker.belongRoutine;
}


#pragma mark - Navigation

-(IBAction)EditRoutineDone:(UIStoryboardSegue *)segue{
    if([segue.sourceViewController isKindOfClass:[RoutineEditTVC class]]){
        NSLog(@"Edit Routine Done");
    }
}

-(void)rollback{
    NSLog(@"roll back");
}

#define EDIT_ROUTINE_INFO_SEGUE @"EditRoutineInfoSegue"



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EDIT_ROUTINE_INFO_SEGUE]) {
        UINavigationController *navController=(UINavigationController *)segue.destinationViewController;
        RoutineEditTVC *routineEditTVC=navController.viewControllers[0];
        routineEditTVC.ovMarker=self.ovMarker;
    }
    
    if([segue.destinationViewController isKindOfClass:[RoutineDetailMapViewController class]]){
        RoutineDetailMapViewController *routineDetailMapVC=(RoutineDetailMapViewController *)segue.destinationViewController;
        routineDetailMapVC.routine=self.routine;
        routineDetailMapVC.treeNodeArray=self.routine.headTreeNodes;
    }
    
    if([segue.destinationViewController isKindOfClass:[OfflineRoutineTVC class]]){
        if([CommonUtil isFastNetWork]){
            
            
            if([self.routine isMarkersSyncWithCloud]){
                [self prepareCach:segue];
            }else{
                [CloudManager syncMarkersByRoutineUUID:self.routine.uuid withBlockWhenDone:^(NSError *error) {
                    [self prepareCach:segue];
                }];
            }
        }else{
            [CommonUtil alert:@"Please turn on wifi or lte to offline"];
        }
    }
}

- (void)prepareCach:(UIStoryboardSegue *)segue {
    BOOL succeedbegin=NO;
    
    NSMutableArray *cachedRoutines=[[MMRoutine fetchAllCachedModelRoutines] mutableCopy];
    
    if ([self.routine.cachProgress floatValue]==1) {
        NSLog(@"%@ already cached",self.routine.title);
    }else{
        succeedbegin=[self.routineCachHelper startCachForRoutine:self.routine
                                                    withTileCach:self.mapView.tileCache
                                                  withTileSource:self.mapView.tileSources[1]];
    }
    
    
    if(succeedbegin){
        [cachedRoutines addObject:self.routine];
    }
    
    OfflineRoutineTVC *offlineTVC=segue.destinationViewController;
    offlineTVC.modelRoutines=cachedRoutines;
}


@end
