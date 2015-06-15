//
//  ExploreRoutineVC.m
//  MyMapBox
//
//  Created by bizappman on 6/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "ExploreRoutineVC.h"
#import <Mapbox-iOS-SDK/Mapbox.h>
#import "CommonUtil.h"
#import "MMSearchedRoutine.h"
#import "CloudManager.h"

@interface ExploreRoutineVC ()<RMMapViewDelegate,UIActionSheetDelegate>

@property(nonatomic,strong) NSArray *searchedRoutines;

@end

@implementation ExploreRoutineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.minZoom=2;
    self.mapView.maxZoom=17;
    
    self.mapView.zoom=3;
    
    self.mapView.delegate=self;
    
    CLLocationCoordinate2D center=CLLocationCoordinate2DMake(31.239008, 121.470275);
    self.mapView.centerCoordinate=center;
    
    [self.view addSubview:self.mapView];
    
    [self.view sendSubviewToBack:self.mapView];
}

-(void)viewWillAppear:(BOOL)animated{
    //[self.tabBarController.tabBar setHidden:YES];
}

-(void)updateUI{
    
}

#pragma mark - getter and setter
-(NSArray *)searchedRoutines{
    if(!_searchedRoutines){
        _searchedRoutines=[[NSArray alloc]init];
    }
    return _searchedRoutines;
}

#pragma mark - UI action

typedef enum : NSUInteger {
    searchRoutineinCenter = 0
} ActionSheetIndexForSearchRoutine;


- (IBAction)searchButtonClick:(id)sender {
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Search with center location", nil];
    [sheet showInView:self.view];
}

#pragma mark - ui action delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case searchRoutineinCenter:{
            NSLog(@"search routine in center");
            NSNumber *lat=[NSNumber numberWithDouble:self.mapView.centerCoordinate.latitude];
            NSNumber *lng=[NSNumber numberWithDouble:self.mapView.centerCoordinate.longitude];
            
            [CloudManager searchRoutinesByLat:lat lng:lng
                                    withLimit:[NSNumber numberWithUnsignedInteger:5]
                                     withPage:[NSNumber numberWithUnsignedInteger:1]
                            withBlockWhenDone:^(NSError *error, NSArray *routines) {
                                if(!error){
                                    self.searchedRoutines=routines;
                                    [self updateUI];
                                }else{
                                    [CommonUtil alert:[error localizedDescription]];
                                }
            }];
            
            break;
        }
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - RMMap delegate
-(void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point{
    BOOL hidden=self.tabBarController.tabBar.hidden;
    [self.tabBarController.tabBar setHidden:!hidden];
}

@end
