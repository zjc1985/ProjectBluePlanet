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
#import "MMSearchedOvMarker.h"
#import "CloudManager.h"
#import "SearchRoutineInfoTVC.h"

#define SHOW_SEARCH_ROUTINE_INFO_SEGUE @"showSearchRoutineInfoSegue"

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
    [self.mapView removeAllAnnotations];
    for (MMSearchedRoutine *routine in self.searchedRoutines) {
        [self addMarkerWithTitle:routine.title
                  withCoordinate:CLLocationCoordinate2DMake([routine.lat doubleValue], [routine.lng doubleValue])
                  withCustomData:routine];
        for (MMSearchedOvMarker *ovMarker in routine.ovMarkers) {
            
            //need to refine ovMarker lat lng here
            [self adjustLocationByOffsetFrom:routine to:ovMarker];
            
            [self addMarkerWithTitle:routine.title
                      withCoordinate:CLLocationCoordinate2DMake([ovMarker.lat doubleValue], [ovMarker.lng doubleValue])
                      withCustomData:ovMarker];
            
            [self addLineFrom:[[CLLocation alloc]initWithLatitude:[routine.lat doubleValue]
                                                        longitude:[routine.lng doubleValue]]
                           to:[[CLLocation alloc]initWithLatitude:[ovMarker.lat doubleValue]
                                                        longitude:[ovMarker.lng doubleValue]]];
        }
        
    }
}

-(void)adjustLocationByOffsetFrom:(MMSearchedRoutine *)parent to:(MMSearchedOvMarker *)to{
    CGPoint parentPoint=[self.mapView coordinateToPixel:CLLocationCoordinate2DMake([parent.lat doubleValue],
                                                                                   [parent.lng doubleValue])];
    CGPoint newPoint=parentPoint;
    newPoint.x=newPoint.x+[to.offsetX doubleValue];
    newPoint.y=newPoint.y+[to.offsetY doubleValue];
    CLLocationCoordinate2D coordinate=[self.mapView pixelToCoordinate:newPoint];
    to.lat=[NSNumber numberWithDouble:coordinate.latitude];
    to.lng=[NSNumber numberWithDouble:coordinate.longitude];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SHOW_SEARCH_ROUTINE_INFO_SEGUE]){
        SearchRoutineInfoTVC *desTVC=(SearchRoutineInfoTVC *)segue.destinationViewController;
        MMSearchedRoutine  *routine=(MMSearchedRoutine *)sender;
        desTVC.routine=routine;
    }
}


#pragma mark - RMMap delegate
-(void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point{
    BOOL hidden=self.tabBarController.tabBar.hidden;
    [self.tabBarController.tabBar setHidden:!hidden];
}

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
    
    
    if ([annotation.userInfo isKindOfClass:[MMSearchedRoutine class]]) {
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"overview_point.png"]];
        
        return marker;
    }else if ([annotation.userInfo isKindOfClass:[MMSearchedOvMarker class]]){
        MMSearchedOvMarker *ovMarker=annotation.userInfo;
        
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


-(void) mapView:(RMMapView *)mapView annotation:(RMAnnotation *)annotation didChangeDragState:(RMMapLayerDragState)newState fromOldState:(RMMapLayerDragState)oldState{
    if(newState==RMMapLayerDragStateNone){
        if ([annotation.userInfo isKindOfClass:[MMSearchedOvMarker class]]) {
            MMSearchedOvMarker *ovMarker=(MMSearchedOvMarker *)annotation.userInfo;
            ovMarker.lat=[NSNumber numberWithDouble: annotation.coordinate.latitude];
            ovMarker.lng=[NSNumber numberWithDouble: annotation.coordinate.longitude];

            MMSearchedRoutine *belongRoutine=ovMarker.belongRoutine;
            
            CGPoint offset= [self calculateOffsetFrom:belongRoutine to:ovMarker];
            
            ovMarker.offsetX=[NSNumber numberWithDouble: offset.x];
            ovMarker.offsetY=[NSNumber numberWithDouble: offset.y];

            [self updateUI];
        }
    }
}

-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    if([annotation.userInfo isKindOfClass:[MMSearchedOvMarker class]]){
        MMSearchedOvMarker *ovMarker=annotation.userInfo;
        [self performSegueWithIdentifier:SHOW_SEARCH_ROUTINE_INFO_SEGUE sender:ovMarker.belongRoutine];
    }
}

-(CGPoint)calculateOffsetFrom:(MMSearchedRoutine *)from to:(MMSearchedOvMarker *)to{
    CGPoint parentPoint=[self.mapView coordinateToPixel:CLLocationCoordinate2DMake([from.lat doubleValue],
                                                                                   [from.lng doubleValue])];
    CGPoint subPoint=[self.mapView coordinateToPixel:CLLocationCoordinate2DMake([to.lat doubleValue],
                                                                                [to.lng doubleValue])];
    //NSLog(@"parent: x :%f  y: %f",parentPoint.x,parentPoint.y);
    //NSLog(@"sub: x :%f  y: %f",subPoint.x,parentPoint.y);
    CGPoint result;
    result.x=subPoint.x-parentPoint.x;
    result.y=subPoint.y-parentPoint.y;
    NSLog(@"offset: x :%f  y: %f",result.x,result.y);
    return result;
}

-(BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation{
    if([annotation.userInfo isKindOfClass:[MMSearchedRoutine class]]){
        return NO;
    }else{
        return YES;
    }
}

- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction{
    [self updateUI];
}

@end
