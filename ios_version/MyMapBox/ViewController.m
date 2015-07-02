//
//  ViewController.m
//  MyMapBox
//
//  Created by bizappman on 4/9/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "ViewController.h"
#import <Mapbox-iOS-SDK/Mapbox.h>
#import "RoutineInfoViewController.h"
#import "CommonUtil.h"
#import "RoutineAddTVC.h"
#import "RoutineEditTVC.h"
#import "LoginViewController.h"

#import "MMRoutine.h"
#import "MMRoutine+Dao.h"

#import "MMOvMarker.h"

#import "MMRoutineCachHelper.h"
#import "CloudManager.h"

#define SHOW_ROUTINE_INFO_SEGUE @"showRoutineInfoSegue"
#define ADD_ROUTINE_SEGUE @"AddRoutineInfoSegue"
#define LOGIN_SEGUE @"LoginSegue"
#define VIEW_TITLE_NAME @"My World"

@interface ViewController ()<RMMapViewDelegate>

@property(nonatomic,strong) MMRoutineCachHelper *routineCachHelper;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.minZoom=3;
    self.mapView.maxZoom=17;
    
    self.mapView.zoom=3;
    
    self.mapView.bouncingEnabled=YES;
    
    self.mapView.delegate=self;
    
    CLLocationCoordinate2D center=CLLocationCoordinate2DMake(31.239689, 121.499755);
    self.mapView.centerCoordinate=center;
    
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    
    NSLog(@"view did load");
}

- (void)syncRoutines {
    self.title=@"Syncing";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [CloudManager syncRoutinesAndOvMarkersWithBlockWhenDone:^(NSError *error) {
        
        self.title=VIEW_TITLE_NAME;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if(error){
            NSLog(@"error happend: %@",error.localizedDescription);
        }
        [self updateMapUI];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"view will appear");
    [self.tabBarController.tabBar setHidden:NO];
    
    if(![CloudManager currentUser]){
        [self performSegueWithIdentifier:LOGIN_SEGUE sender:self];
    }else{
        [self updateMapUI];
        
        if([CommonUtil isFastNetWork]){
            [self syncRoutines];
        }
    }
}



//overide
-(NSArray *)allRoutines{
    return [MMRoutine fetchAllModelRoutines];
}

#pragma mark - getters and setters

-(MMRoutineCachHelper *)routineCachHelper{
    if(!_routineCachHelper){
        _routineCachHelper=[[MMRoutineCachHelper alloc]init];
    }
    return _routineCachHelper;
}

#pragma mark -segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:SHOW_ROUTINE_INFO_SEGUE]){
       //prepare for RoutineInfoViewController
        RoutineInfoViewController *routineInfoVC=(RoutineInfoViewController *)segue.destinationViewController;
        RMAnnotation *annotation=(RMAnnotation *)sender;
        MMOvMarker *ovMarker=(MMOvMarker *)annotation.userInfo;
        routineInfoVC.routine=ovMarker.belongRoutine;
        routineInfoVC.mapView=self.mapView;
        routineInfoVC.routineCachHelper=self.routineCachHelper;
    }else if ([segue.identifier isEqualToString:ADD_ROUTINE_SEGUE]){
        UINavigationController *navController=(UINavigationController *)segue.destinationViewController;
        RoutineAddTVC *routineAddTVC=navController.viewControllers[0];
        routineAddTVC.currentLat=self.mapView.centerCoordinate.latitude;
        routineAddTVC.currentLng=self.mapView.centerCoordinate.longitude;
    }else if([segue.identifier isEqualToString:LOGIN_SEGUE]){
        //LoginViewController *loginVC=segue.destinationViewController;
        
    }
    
    
}

-(IBAction)AddRoutineDone:(UIStoryboardSegue *)segue{
    // get something from addRoutineTVC
    if([segue.sourceViewController isKindOfClass:[RoutineAddTVC class]]){
        RoutineAddTVC *routineAddTVC=segue.sourceViewController;
        self.currentRoutine=routineAddTVC.addedRoutine;
        //[self updateMapUI];
    }
}



-(IBAction)deleteRoutineDone:(UIStoryboardSegue *)segue{
    RoutineEditTVC *routineEditTVC=segue.sourceViewController;
    MMRoutine *routine=routineEditTVC.routine;
    
    if([[self.currentRoutine uuid] isEqualToString:routine.uuid]){
        self.currentRoutine=nil;
    }
    
    if (routine) {
        if([routine.isSync boolValue]){
            NSLog(@"prepare to mark delete routine id: %@",routine.uuid);
            [routine markDelete];
        }else{
            NSLog(@"prepare to mark remove routine id: %@",routine.uuid);
            [MMRoutine removeRoutine:routine];
        }
    }
}

#pragma mark - RMMapViewDelegate

-(void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point{
}


//create delegate
-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if(annotation.isUserLocationAnnotation)
        return nil;
    
    if([annotation isKindOfClass:[RMPolylineAnnotation class]]){
        RMShapeAnnotation *lineAnnotation=(RMShapeAnnotation *)annotation;
        RMShape *lineShape=[[RMShape alloc]initWithView:self.mapView];
        for (CLLocation *eachLocation in lineAnnotation.points) {
            [lineShape addLineToCoordinate:eachLocation.coordinate];
        }
        return lineShape;
    }
    
    
    if ([annotation.userInfo isKindOfClass:[MMRoutine class]]) {
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"overview_point.png"]];
        
        return marker;
    }else if ([annotation.userInfo isKindOfClass:[MMOvMarker class]]){
        MMOvMarker *ovMarker=annotation.userInfo;
        
        CGPoint anchorPoint;
        anchorPoint.x=0.5;
        anchorPoint.y=1;
        
        UIImage *iconImage=[UIImage imageNamed:ovMarker.iconUrl];
        if(!iconImage){
            iconImage=[UIImage imageNamed:@"default_default.png"];
        }
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage: iconImage anchorPoint:anchorPoint];
        //RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"default_default"]anchorPoint:anchorPoint];
        
        
        marker.canShowCallout=YES;
        
        marker.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        //[marker setFrame:CGRectMake(0, 0, 32, 37)];
        
        return marker;
    }
    
    return nil;
}

-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    if([annotation.userInfo isKindOfClass:[MMOvMarker class]]){
        MMOvMarker *ovMarker=annotation.userInfo;
        self.currentRoutine=ovMarker.belongRoutine;
    }
    
    [self performSegueWithIdentifier:SHOW_ROUTINE_INFO_SEGUE sender:annotation];
}

-(void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    NSLog(@"tap on label");
}


-(BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation{
    if([annotation.userInfo isKindOfClass:[MMRoutine class]]){
        return NO;
    }else{
        return YES;
    }
}

-(void) mapView:(RMMapView *)mapView annotation:(RMAnnotation *)annotation didChangeDragState:(RMMapLayerDragState)newState fromOldState:(RMMapLayerDragState)oldState{
    
    if(newState==RMMapLayerDragStateNone){
        NSString *subTitle=[NSString stringWithFormat:@"lat: %f lng: %f",annotation.coordinate.latitude,annotation.coordinate.longitude];
        annotation.subtitle=subTitle;
        if ([annotation.userInfo isKindOfClass:[MMOvMarker class]]) {
            MMOvMarker *ovMarker=(MMOvMarker *)annotation.userInfo;
            ovMarker.lat=[NSNumber numberWithDouble: annotation.coordinate.latitude];
            ovMarker.lng=[NSNumber numberWithDouble: annotation.coordinate.longitude];
            NSLog(@"Drage end update marker id:%@ location",ovMarker.uuid);
            
            MMRoutine *belongRoutine=ovMarker.belongRoutine;
            
            CGPoint offset= [self calculateOffsetFrom:belongRoutine to:ovMarker];
            
            ovMarker.offsetX=[NSNumber numberWithDouble: offset.x];
            ovMarker.offsetY=[NSNumber numberWithDouble: offset.y];
            ovMarker.updateTimestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
            
            [self updateMapUI];
        }
    }
}


- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction{
    NSLog(@"MapZoom End");
    [self updateMapUINeedPanToCurrentRoutine:NO];
}








@end
