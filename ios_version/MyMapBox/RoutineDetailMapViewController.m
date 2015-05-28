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
#import "CloudManager.h"

@interface RoutineDetailMapViewController ()<RMMapViewDelegate,UIActionSheetDelegate>

@property(nonatomic,strong) MMMarker *currentMarker;

@property (weak, nonatomic) IBOutlet UIButton *locateButton;
@property (weak, nonatomic) IBOutlet UIButton *syncButton;
@property (weak, nonatomic) IBOutlet UIToolbar *playRoutineToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SlidePlayButton;

@property(nonatomic,strong) RMMapView *mapView;

//slide show related
@property (nonatomic, assign) NSInteger slideIndicator;


@end

@implementation RoutineDetailMapViewController

#define tourMapId  @"lionhart586.gkihab1d"
#define streetMapId @"lionhart586.lnmjhd7b"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.slideIndicator=-1;
    
    self.locateButton.layer.borderWidth=0.5f;
    self.locateButton.layer.cornerRadius = 4.5;
    self.syncButton.layer.borderWidth=0.5f;
    self.syncButton.layer.cornerRadius=4.5;
    
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
    
    
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    
    NSLog(@"RoutineDetailMapViewTVC did load");
}

-(void)viewWillAppear:(BOOL)animated{
    if([CommonUtil isFastNetWork]){
        [CloudManager syncMarkersByRoutineUUID:self.routine.uuid withBlockWhenDone:^(NSError *error) {
            if(error){
                NSLog(@"error happened :%@",error.localizedDescription);
            }
            
            [self updateMapUI];
        }];
    }
    
    [self updateMapUI];
}

-(void)updateMapUI{
    NSLog(@"update ui");
    if(self.slideIndicator<0){
        [self updateUIInNormalMode];
    }else{
        [self updateUIInSlideMode];
    }
}

-(void)updateUIInSlideMode{
    [self.SlidePlayButton setImage:[UIImage imageNamed:@"icon_stop"]];
    
    [self.mapView removeAllAnnotations];
    
    NSMutableArray *markersNeedToShow=[[NSMutableArray alloc]init];
    NSMutableArray *currentSlideIndicatorMarkers=[[NSMutableArray alloc]init];
    NSArray *markersSortedBySlideNum=[self markersSortedBySlideNum];
    
    for (NSUInteger i=0; i<self.slideIndicator+1; i++) {
        [markersNeedToShow addObjectsFromArray:[markersSortedBySlideNum objectAtIndex:i]];
        if (i==self.slideIndicator) {
            [currentSlideIndicatorMarkers addObjectsFromArray:[markersSortedBySlideNum objectAtIndex:i]];
        }
    }
    
    for (MMMarker *marker in markersNeedToShow) {
        [self addMarkerWithTitle:marker.title
                  withCoordinate:CLLocationCoordinate2DMake([marker.lat doubleValue], [marker.lng doubleValue])
                  withCustomData:marker];
    }
    
    [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:[CommonUtil minLocationInMMMarkers:currentSlideIndicatorMarkers]
                                                 northEast:[CommonUtil maxLocationInMMMarkers:currentSlideIndicatorMarkers]
                                                  animated:YES];
    [self.mapView setZoom:self.mapView.zoom-0.5 animated:YES];
}

-(NSArray *)markersSortedBySlideNum{
    NSMutableArray *result=[[NSMutableArray alloc]init];
    NSArray *allMarkers=[self.routine allMarks];
    for (NSUInteger i=1; i<allMarkers.count+1; i++) {
        NSMutableArray *markersWithSameSlideNum=[[NSMutableArray alloc]init];
        for (MMMarker *marker in allMarkers) {
            if ([marker.slideNum unsignedIntegerValue] ==i) {
                [markersWithSameSlideNum addObject:marker];
            }
        }
        
        if(markersWithSameSlideNum.count>0){
            [result addObject:markersWithSameSlideNum];
        }
    }
    return result;
}

-(void)updateUIInNormalMode{
    [self.SlidePlayButton setImage:[UIImage imageNamed:@"icon_play"]];
    
    [self.mapView removeAllAnnotations];
    
    for (MMMarker *marker in [self.routine allMarks]) {
        [self addMarkerWithTitle:marker.title
                  withCoordinate:CLLocationCoordinate2DMake([marker.lat doubleValue], [marker.lng doubleValue])
                  withCustomData:marker];
    }
    
    if ([[self.routine allMarks] count]>0) {
        if(self.currentMarker){
            NSLog(@"center to currentMarker");
            [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([self.currentMarker.lat doubleValue], [self.currentMarker.lng doubleValue]) animated:YES];
        }else{
            NSLog(@"zoom to fit all markers");
            
            CLLocationCoordinate2D minLocation=CLLocationCoordinate2DMake([self.routine minLatInMarkers], [self.routine minLngInMarkers]);
            CLLocationCoordinate2D maxLocation=CLLocationCoordinate2DMake([self.routine maxLatInMarkers], [self.routine maxLngInMarkers]);
            
            //[self addMarkerWithTitle:@"southweat" withCoordinate:minLocation withCustomData:nil];
            //[self addMarkerWithTitle:@"northEast" withCoordinate:maxLocation withCustomData:nil];
            
            [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:minLocation
                                                         northEast:maxLocation
                                                          animated:YES];
            
            
            [self.mapView setZoom:self.mapView.zoom-0.5 animated:YES];
        }
    }else{
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([self.routine.lat doubleValue], [self.routine.lng doubleValue]) animated:YES];
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
    if(self.slideIndicator<0){
        self.slideIndicator=0;
    }else{
        self.currentMarker=nil;
        self.slideIndicator=-1;
    }
    [self updateMapUI];
}

- (IBAction)slidePrevClick:(id)sender {
    if(self.slideIndicator>0){
        self.slideIndicator--;
        [self updateMapUI];
    }
}

- (IBAction)slideNextClick:(id)sender {
    if(self.slideIndicator>=0 && self.slideIndicator<[self markersSortedBySlideNum].count-1){
        self.slideIndicator++;
        [self updateMapUI];
    }

}

- (IBAction)refreshButtonClick:(id)sender {
    NSString *currentRoutineUUID=self.routine.uuid;
    [CloudManager syncMarkersByRoutineUUID:self.routine.uuid withBlockWhenDone:^(NSError *error) {
        if(!error){
            self.routine=[MMRoutine queryMMRoutineWithUUID:currentRoutineUUID];
            if(self.routine){
                [self updateMapUI];
            }
        }
    }];
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
        markerInfoTVC.markerCount=[[self.routine allMarks] count];
    }
}

-(IBAction)DeleteMarkerDone:(UIStoryboardSegue *)segue{
    NSLog(@"prepare delete marker");
    MarkerEditTVC *markerEditTVC=segue.sourceViewController;
    MMMarker *marker=markerEditTVC.marker;
    if(marker){
        if([marker.isSync boolValue]){
            NSLog(@"mark delete marker id %@",marker.uuid);
            [marker markDelete];
        }else{
            [MMMarker removeMMMarker:marker];
        }
    }
}


#pragma mark - UIActionSheetDelegate


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    MMMarker *newMarker=nil;
    switch (buttonIndex) {
        case addMarkerInCenter:{
            NSLog(@"add marker in center");
            newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                withLat:self.mapView.centerCoordinate.latitude
                                                withLng:self.mapView.centerCoordinate.longitude];
            break;
        }
        case addMarkerWithImage :{
            NSLog(@"add marker with image");
            break;
        }
        case addMarkerInCurrentLocation:{
            NSLog(@"add marker in current location");
            newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                withLat:self.mapView.userLocation.coordinate.latitude
                                                withLng:self.mapView.userLocation.coordinate.longitude];
            break;
        }
        default:
            break;
    }
    if(newMarker){
        [self addMarkerWithTitle:newMarker.title withCoordinate:CLLocationCoordinate2DMake([newMarker.lat doubleValue], [newMarker.lng doubleValue])
                  withCustomData:newMarker];
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
        
        UIImage *iconImage=[UIImage imageNamed:modelMarker.iconUrl];
        
        if(!iconImage){
            iconImage=[UIImage imageNamed:@"default_default.png"];
        }
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:iconImage anchorPoint:anchorPoint];
        //RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"default_default"]anchorPoint:anchorPoint];
        
        marker.canShowCallout=YES;
        
        marker.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return marker;
    }else{
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"overview_star"]];
        
        marker.canShowCallout=YES;
        
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
            marker.lat=[NSNumber numberWithDouble:annotation.coordinate.latitude];
            marker.lng=[NSNumber numberWithDouble:annotation.coordinate.longitude];
            marker.updateTimestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
            NSLog(@"Drage end update marker id:%@ location",marker.uuid);
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
