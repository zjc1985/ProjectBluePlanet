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

#import "MMRoutine.h"
#import "MMRoutine+Dao.h"

#import "MMOvMarker.h"

#import "MMRoutineCachHelper.h"

#define SHOW_ROUTINE_INFO_SEGUE @"showRoutineInfoSegue"
#define ADD_ROUTINE_SEGUE @"AddRoutineInfoSegue"

@interface ViewController ()<RMMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *locateButton;

@property(nonatomic,strong) RMMapView *mapView;
@property(nonatomic,strong) MMRoutine *currentRoutine;

@property(nonatomic,strong) MMRoutineCachHelper *routineCachHelper;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locateButton.layer.borderWidth=0.5f;
    self.locateButton.layer.cornerRadius = 4.5;
    
    
     [[RMConfiguration sharedInstance] setAccessToken:@"pk.eyJ1IjoibGlvbmhhcnQ1ODYiLCJhIjoiR1JHd2NnYyJ9.iCg5vA7qQaRxf2Z-T_vEjg"];
    
    RMMapboxSource *tileSource=nil;
    RMMapboxSource *detailTileSource=nil;
    
    NSString *filePath=[CommonUtil dataFilePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSMutableDictionary *dictionary= [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        NSString *tileJSON=[dictionary objectForKey:tileJsonTourMap];
        NSString *detailTileJSON=[dictionary objectForKey:tileJsonDetailMap];
        NSLog(@"found tileJSON in file");
        tileSource= [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
        detailTileSource=[[RMMapboxSource alloc]initWithTileJSON:detailTileJSON];
        
    }else{
        tileSource =[[RMMapboxSource alloc] initWithMapID:tourMapId];
        detailTileSource=[[RMMapboxSource alloc] initWithMapID:streetMapId];
        NSMutableDictionary *dictionary= [NSMutableDictionary dictionaryWithCapacity:10];
        [dictionary setObject:tileSource.tileJSON forKey:tileJsonTourMap];
        [dictionary setObject:detailTileSource.tileJSON forKey:tileJsonDetailMap];
        [dictionary writeToFile:filePath atomically:YES];
    }
    
    self.mapView=[[RMMapView alloc] initWithFrame:self.view.bounds
                                    andTilesource:tileSource];
    
    [self.mapView addTileSource:detailTileSource];
    
    self.mapView.minZoom=3;
    self.mapView.maxZoom=17;
    
    self.mapView.zoom=15;
    
    self.mapView.bouncingEnabled=YES;
    
    self.mapView.delegate=self;
    
    CLLocationCoordinate2D center=CLLocationCoordinate2DMake(31.239689, 121.499755);
    self.mapView.centerCoordinate=center;
    
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    

    [self addMarkerWithTitle:@"Boundary" withCoordinate:CLLocationCoordinate2DMake(31.216571, 121.391336)withCustomData:nil];
    [self addMarkerWithTitle:@"Boundary" withCoordinate:CLLocationCoordinate2DMake(31.237347, 121.416280)withCustomData:nil];
    
    [self ShowTourMapSource];
    
    NSLog(@"view did load");
}

-(void)ShowTourMapSource{
    [self.mapView setHidden:NO forTileSourceAtIndex:0];
    [self.mapView setHidden:YES forTileSourceAtIndex:1];
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"view will appear");
    [self updateMapUI];
}

-(void)updateMapUI{
    [self updateMapUINeedPanToCurrentRoutine:YES];
}

-(void)updateMapUINeedPanToCurrentRoutine:(BOOL) needPan{
    [self.mapView removeAllAnnotations];
    for (MMRoutine *eachRoutine in [MMRoutine fetchAllModelRoutines]) {
        [self addMarkerWithTitle:eachRoutine.title
                  withCoordinate:CLLocationCoordinate2DMake([eachRoutine.lat doubleValue], [eachRoutine.lng doubleValue])
                  withCustomData:eachRoutine];
        
        for (MMOvMarker *ovMarker in eachRoutine.ovMarkers) {
            [self adjustLocationByOffsetFrom:eachRoutine to:ovMarker];
            
            [self addMarkerWithTitle:eachRoutine.title
                      withCoordinate:CLLocationCoordinate2DMake([ovMarker.lat doubleValue], [ovMarker.lng doubleValue])
                      withCustomData:ovMarker];
            
            [self addLineFrom:[[CLLocation alloc]initWithLatitude:[eachRoutine.lat doubleValue]
                                                        longitude:[eachRoutine.lng doubleValue]]
                           to:[[CLLocation alloc]initWithLatitude:[ovMarker.lat doubleValue]
                                                        longitude:[ovMarker.lng doubleValue]]];
        }
    }
    
    if(self.currentRoutine && needPan){
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([self.currentRoutine.lat doubleValue],
                                                                     [self.currentRoutine.lng doubleValue])
                                 animated:YES];
    }
}



-(void)adjustLocationByOffsetFrom:(MMRoutine *)parent to:(MMOvMarker *)to{
    CGPoint parentPoint=[self.mapView coordinateToPixel:CLLocationCoordinate2DMake([parent.lat doubleValue],
                                                                                   [parent.lng doubleValue])];
    CGPoint newPoint=parentPoint;
    newPoint.x=newPoint.x+[to.offsetX doubleValue];
    newPoint.y=newPoint.y+[to.offsetY doubleValue];
    CLLocationCoordinate2D coordinate=[self.mapView pixelToCoordinate:newPoint];
    to.lat=[NSNumber numberWithDouble:coordinate.latitude];
    to.lng=[NSNumber numberWithDouble:coordinate.longitude];
}

-(void)addMarkerWithTitle:(NSString *)title withCoordinate:(CLLocationCoordinate2D)coordinate withCustomData:(id)customData{
    RMAnnotation *annotation=[[RMAnnotation alloc] initWithMapView:self.mapView
                                                        coordinate:coordinate
                                                          andTitle:title];
    annotation.userInfo=customData;
    [self.mapView addAnnotation:annotation];
}

-(void)addLineFrom:(CLLocation *)from to:(CLLocation *)to{
    NSArray *pointArray=[[NSArray alloc]initWithObjects:from,to,nil];
    RMPolylineAnnotation *line=[[RMPolylineAnnotation alloc]initWithMapView:self.mapView points:pointArray];
    [self.mapView addAnnotation:line];
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
    NSLog(@"mark delete Routine");
    RoutineEditTVC *routineEditTVC=segue.sourceViewController;
    MMRoutine *routine=routineEditTVC.routine;
    if (routine) {
        NSLog(@"prepare to mark delete routine id: %@",routine.uuid);
        [routine markDelete];
    }
}

- (IBAction)locateButtonClick {
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(31.216571, 121.391336) animated:YES];
}

#pragma mark - cach related

- (IBAction)downloadCach:(id)sender {
    MMRoutine *tempRoutine=[[MMRoutine fetchAllModelRoutines] firstObject];
    if(tempRoutine){
        [self.routineCachHelper startCachForRoutine:tempRoutine withTileCach:self.mapView.tileCache withTileSource:self.mapView.tileSources[1]];
    }
}

#pragma mark - RMMapViewDelegate

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
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"overview_point"]];
        
        return marker;
    }else if ([annotation.userInfo isKindOfClass:[MMOvMarker class]]){
        MMOvMarker *ovMarker=annotation.userInfo;
        
        CGPoint anchorPoint;
        anchorPoint.x=0.5;
        anchorPoint.y=1;
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:ovMarker.iconUrl]anchorPoint:anchorPoint];
        
        marker.canShowCallout=YES;
        
        marker.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
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
            
            [self updateMapUI];
        }
    }
}

-(CGPoint)calculateOffsetFrom:(MMRoutine *)from to:(MMOvMarker *)to{
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

- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction{
    NSLog(@"MapZoom End");
    [self updateMapUINeedPanToCurrentRoutine:NO];
}








@end
