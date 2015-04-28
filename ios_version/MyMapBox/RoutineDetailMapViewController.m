//
//  RoutineDetailMapViewController.m
//  MyMapBox
//
//  Created by yufu on 15/4/13.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "RoutineDetailMapViewController.h"
#import "CommonUtil.h"
#import "MarkerInfoTVC.h"
#import "MarkerEditTVC.h"

@interface RoutineDetailMapViewController ()<RMMapViewDelegate,UIActionSheetDelegate>

@property(nonatomic,strong) MMMarker *currentMarker;

@property (weak, nonatomic) IBOutlet UIButton *locateButton;
@property (weak, nonatomic) IBOutlet UIToolbar *playRoutineToolBar;

@property(nonatomic,strong) RMMapView *mapView;

@end

@implementation RoutineDetailMapViewController

#define tourMapId  @"lionhart586.gkihab1d"
#define streetMapId @"lionhart586.lnmjhd7b"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locateButton.layer.borderWidth=0.5f;
    self.locateButton.layer.cornerRadius = 4.5;
    
    RMMapboxSource *tileSource=nil;
    NSString *filePath=[CommonUtil dataFilePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSMutableDictionary *dictionary= [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        NSString *tileJSON=[dictionary objectForKey:tileJsonDetailMap];
        NSLog(@"found tileJSON in file");
        tileSource= [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
    }else{
        tileSource =[[RMMapboxSource alloc] initWithMapID:streetMapId];
    }
    
    self.mapView=[[RMMapView alloc] initWithFrame:self.view.bounds
                                    andTilesource:tileSource];
    //self.mapView.minZoom=3;
    self.mapView.maxZoom=17;
    
    self.mapView.zoom=15;
    
    self.mapView.bouncingEnabled=YES;
    
    self.mapView.delegate=self;
    
    self.mapView.showsUserLocation=YES;
    
    self.mapView.displayHeadingCalibration=YES;
    
    //[self.mapView setUserTrackingMode:RMUserTrackingModeFollowWithHeading animated:YES];
    
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    
    NSLog(@"RoutineDetailMapViewTVC did load");
}

-(void)viewDidAppear:(BOOL)animated{
    [self updateMapUI];
}

-(void)updateMapUI{
    NSLog(@"update ui");
    [self.mapView removeAllAnnotations];
    
    for (MMMarker *marker in self.routine.markers) {
        [self addMarkerWithTitle:marker.title
                  withCoordinate:CLLocationCoordinate2DMake(marker.lat, marker.lng)
                  withCustomData:marker];
    }
    
    if ([self.routine.markers count]>0) {
        if(self.currentMarker){
            NSLog(@"center to currentMarker");
            [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.currentMarker.lat, self.currentMarker.lng) animated:YES];
        }else{
            NSLog(@"zoom to fit all markers");
            [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:CLLocationCoordinate2DMake([self.routine minLatInMarkers], [self.routine minLngInMarkers])
                                                         northEast:CLLocationCoordinate2DMake([self.routine maxLatInMarkers], [self.routine maxLngInMarkers])
                                                          animated:YES];
        }
        
        [self.mapView setZoom:self.mapView.zoom-1 animated:YES];
        
    }else{
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.routine.lat, self.routine.lng) animated:YES];
    }
    
}

-(void)addMarkerWithTitle:(NSString *)title withCoordinate:(CLLocationCoordinate2D)coordinate withCustomData:(id)customData{
    RMAnnotation *annotation=[[RMAnnotation alloc] initWithMapView:self.mapView
                                                        coordinate:coordinate
                                                          andTitle:title];
    annotation.userInfo=customData;
    [self.mapView addAnnotation:annotation];
}


#pragma mark - UI action
- (IBAction)PlayButtonClick:(id)sender {
    
    [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:CLLocationCoordinate2DMake(31.216571, 121.391336)
                                                 northEast:CLLocationCoordinate2DMake(31.237347, 121.416280)
                                                  animated:YES];

}

- (IBAction)locateButtonClick:(id)sender {
    NSLog(@"Locate Button CLick");
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (IBAction)addMarker:(id)sender {
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Add Marker in Center",@"Add Marker with Image",@"Add Marker in Current Location", nil];
    [sheet showInView:self.view];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"markerDetailSegue"]) {
        MarkerInfoTVC *markerInfoTVC=segue.destinationViewController;
        markerInfoTVC.marker=((RMAnnotation *)sender).userInfo;
        markerInfoTVC.markerCount=[self.routine.markers count];
    }
}

-(IBAction)DeleteMarkerDone:(UIStoryboardSegue *)segue{
    NSLog(@"prepare delete marker");
    MarkerEditTVC *markerEditTVC=segue.sourceViewController;
    MMMarker *marker=markerEditTVC.marker;
    if(marker){
        NSLog(@"delete marker id %@",marker.id);
        [self.routine deleteMarker:markerEditTVC.marker];
    }
    
}


#pragma mark - UIActionSheetDelegate


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    MMMarker *newMarker=nil;
    switch (buttonIndex) {
        case addMarkerInCenter:{
            NSLog(@"add marker in center");
            newMarker=[[MMMarker alloc]initWithRoutineId:self.routine.id];
            newMarker.lat=self.mapView.centerCoordinate.latitude;
            newMarker.lng=self.mapView.centerCoordinate.longitude;
            break;
        }
        case addMarkerWithImage :{
            NSLog(@"add marker with image");
            break;
        }
        case addMarkerInCurrentLocation:{
            NSLog(@"add marker in current location");
            newMarker=[[MMMarker alloc]initWithRoutineId:self.routine.id];
            newMarker.lat=self.mapView.userLocation.coordinate.latitude;
            newMarker.lng=self.mapView.userLocation.coordinate.longitude;
            break;
        }
        default:
            break;
    }
    if(newMarker){
        [self.routine addMarker:newMarker];
        [self addMarkerWithTitle:newMarker.title withCoordinate:CLLocationCoordinate2DMake(newMarker.lat, newMarker.lng) withCustomData:newMarker];
    }
}

#pragma mark - RMMapViewDelegate

-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if(annotation.isUserLocationAnnotation)
        return nil;
    
    
    
    if ([annotation.userInfo isKindOfClass:[MMMarker class]]){
        MMMarker *modelMarker=annotation.userInfo;
        
        CGPoint anchorPoint;
        anchorPoint.x=0.5;
        anchorPoint.y=1;
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:modelMarker.iconUrl]anchorPoint:anchorPoint];
        
        marker.canShowCallout=YES;
        
        marker.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return marker;
    }

    return nil;
}

-(void) mapView:(RMMapView *)mapView annotation:(RMAnnotation *)annotation didChangeDragState:(RMMapLayerDragState)newState fromOldState:(RMMapLayerDragState)oldState{
    
    NSLog(@"change drag state %u",newState);
    
    if(newState==RMMapLayerDragStateNone){
        NSString *subTitle=[NSString stringWithFormat:@"lat: %f lng: %f",annotation.coordinate.latitude,annotation.coordinate.longitude];
        annotation.subtitle=subTitle;
        if ([annotation.userInfo isKindOfClass:[MMMarker class]]) {
            MMMarker *marker=(MMMarker *)annotation.userInfo;
            marker.lat=annotation.coordinate.latitude;
            marker.lng=annotation.coordinate.longitude;
            NSLog(@"Drage end update marker id:%@ location",marker.id);
            [self.routine updateLocation];
        }
    }
}


-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    self.currentMarker=annotation.userInfo;
    [self performSegueWithIdentifier:@"markerDetailSegue" sender:annotation];
}

-(void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    NSLog(@"tap on label");
}


-(BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation{
    return YES;
}

@end
