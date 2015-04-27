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

#import "MMMarkerManager.h"

#define SHOW_ROUTINE_INFO_SEGUE @"showRoutineInfoSegue"

@interface ViewController ()<RMMapViewDelegate,RMTileCacheBackgroundDelegate>

@property (weak, nonatomic) IBOutlet UIButton *locateButton;

@property(nonatomic,strong) RMMapView *mapView;
@property(nonatomic,strong) MMMarkerManager *markerManager;
@property(nonatomic,strong) MMRoutine *currentRoutine;

@end

@implementation ViewController

#define tourMapId  @"lionhart586.gkihab1d"
#define streetMapId @"lionhart586.lnmjhd7b"

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
        NSString *tileJSON=[dictionary objectForKey:@"tileJSONTourMap"];
        NSString *detailTileJSON=[dictionary objectForKey:@"tileJSONDetailMap"];
        NSLog(@"found tileJSON in file");
        tileSource= [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
        detailTileSource=[[RMMapboxSource alloc]initWithTileJSON:detailTileJSON];
        
    }else{
        tileSource =[[RMMapboxSource alloc] initWithMapID:tourMapId];
        detailTileSource=[[RMMapboxSource alloc] initWithMapID:streetMapId];
        NSMutableDictionary *dictionary= [NSMutableDictionary dictionaryWithCapacity:10];
        [dictionary setObject:tileSource.tileJSON forKey:@"tileJSONTourMap"];
        [dictionary setObject:detailTileSource.tileJSON forKey:@"tileJSONDetailMap"];
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
    
    self.mapView.tileCache.backgroundCacheDelegate=self;
    
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
    for (MMRoutine *eachRoutine in self.markerManager.modelRoutines) {
        [self addMarkerWithTitle:eachRoutine.title withCoordinate:CLLocationCoordinate2DMake(eachRoutine.lat, eachRoutine.lng) withCustomData:eachRoutine];
        
        for (MMOvMarker *ovMarker in eachRoutine.ovMarkers) {
            [self adjustLocationByOffsetFrom:eachRoutine to:ovMarker];
            
            [self addMarkerWithTitle:eachRoutine.title withCoordinate:CLLocationCoordinate2DMake(ovMarker.lat, ovMarker.lng) withCustomData:ovMarker];
            
            [self addLineFrom:[[CLLocation alloc]initWithLatitude:eachRoutine.lat longitude:eachRoutine.lng]
                           to:[[CLLocation alloc]initWithLatitude:ovMarker.lat longitude:ovMarker.lng]];
        }
    }
    
    if(self.currentRoutine && needPan){
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.currentRoutine.lat, self.currentRoutine.lng) animated:YES];
    }
}



-(void)adjustLocationByOffsetFrom:(MMBaseMarker *)parent to:(MMBaseMarker *)to{
    CGPoint parentPoint=[self.mapView coordinateToPixel:CLLocationCoordinate2DMake(parent.lat, parent.lng)];
    CGPoint newPoint=parentPoint;
    newPoint.x=newPoint.x+to.offsetX;
    newPoint.y=newPoint.y+to.offsetY;
    CLLocationCoordinate2D coordinate=[self.mapView pixelToCoordinate:newPoint];
    to.lat=coordinate.latitude;
    to.lng=coordinate.longitude;
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
-(MMMarkerManager *)markerManager{
    if(!_markerManager){
        _markerManager=[[MMMarkerManager alloc]init];
    }
    return _markerManager;
}



#pragma mark -segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:SHOW_ROUTINE_INFO_SEGUE]){
       //prepare for RoutineInfoViewController
        RoutineInfoViewController *routineInfoVC=(RoutineInfoViewController *)segue.destinationViewController;
        RMAnnotation *annotation=(RMAnnotation *)sender;
        MMOvMarker *ovMarker=(MMOvMarker *)annotation.userInfo;
        routineInfoVC.routine=[self.markerManager fetchRoutineById:ovMarker.routineId];
    }else if ([segue.identifier isEqualToString:@"AddRoutineInfoSegue"]){
        UINavigationController *navController=(UINavigationController *)segue.destinationViewController;
        RoutineAddTVC *routineAddTVC=navController.viewControllers[0];
        routineAddTVC.currentLat=self.mapView.centerCoordinate.latitude;
        routineAddTVC.currentLng=self.mapView.centerCoordinate.longitude;
        routineAddTVC.markerManager=self.markerManager;
    }
}

-(IBAction)AddRoutineDone:(UIStoryboardSegue *)segue{
    // get something from addRoutineTVC
    if([segue.sourceViewController isKindOfClass:[RoutineAddTVC class]]){
        //[self updateMapUI];
    }
}



-(IBAction)deleteRoutineDone:(UIStoryboardSegue *)segue{
    NSLog(@"delete Routine");
    RoutineEditTVC *routineEditTVC=segue.sourceViewController;
    MMRoutine *routine=routineEditTVC.routine;
    if (routine) {
        NSLog(@"prepare to delete routine id: %@",routine.id);
        [self.markerManager deleteMMRoutine:routine];
    }
}


-(void)alert:(NSString *)content{
    UIAlertView *theAlert=[[UIAlertView alloc] initWithTitle:@"alert" message:content delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [theAlert show];
}

- (IBAction)locateButtonClick {
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(31.216571, 121.391336) animated:YES];
}

#pragma mark - cach related

- (IBAction)downloadCach:(id)sender {
    [self startBackgroundCach];
}

-(void)startBackgroundCach{
    if ([self.mapView.tileSource isKindOfClass :[RMAbstractWebMapSource class]]) {
        NSLog(@"is map source");
    }else{
        NSLog(@"not map source");
    }
    
    
    [self.mapView.tileCache beginBackgroundCacheForTileSource:self.mapView.tileSource
                                                    southWest:CLLocationCoordinate2DMake(31.216571, 121.391336)
                                                    northEast:CLLocationCoordinate2DMake(31.237347, 121.416280)
                                                      minZoom:12
                                                      maxZoom:15];
}

- (void)tileCache:(RMTileCache *)tileCache didBeginBackgroundCacheWithCount:(NSUInteger)tileCount forTileSource:(id<RMTileSource>)tileSource{
    NSLog(@"begin background cach. tileCount:%lu ",(unsigned long)tileCount);
}

- (void)tileCache:(RMTileCache *)tileCache didBackgroundCacheTile:(RMTile)tile withIndex:(NSUInteger)tileIndex ofTotalTileCount:(NSUInteger)totalTileCount{
    NSLog(@"caching currrent num: %lu with total count %lu",(unsigned long)tileIndex,(unsigned long)totalTileCount);
    
    if(tileIndex==totalTileCount){
        //[self alert:@"cach complete"];
        NSLog(@"Cach Complete");
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
        MMRoutine *routine=annotation.userInfo;
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:routine.iconUrl]];
        
        //annotation.enabled=NO;
        
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
        self.currentRoutine=[self.markerManager fetchRoutineById:ovMarker.routineId];
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
            MMOvMarker *marker=(MMOvMarker *)annotation.userInfo;
            marker.lat=annotation.coordinate.latitude;
            marker.lng=annotation.coordinate.longitude;
            NSLog(@"Drage end update marker id:%@ location",marker.id);
            
            MMRoutine *belongRoutine=[self.markerManager fetchRoutineById:marker.routineId];
            
            CGPoint offset= [self calculateOffsetFrom:belongRoutine to:marker];
            
            marker.offsetX=offset.x;
            marker.offsetY=offset.y;
            
            [self updateMapUI];
        }
    }
}

-(CGPoint)calculateOffsetFrom:(MMBaseMarker *)from to:(MMBaseMarker *)to{
    CGPoint parentPoint=[self.mapView coordinateToPixel:CLLocationCoordinate2DMake(from.lat, from.lng)];
    CGPoint subPoint=[self.mapView coordinateToPixel:CLLocationCoordinate2DMake(to.lat, to.lng)];
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
