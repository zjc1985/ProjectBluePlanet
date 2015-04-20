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

#import "MMMarkerManager.h"

#define SHOW_ROUTINE_INFO_SEGUE @"showRoutineInfoSegue"

@interface ViewController ()<RMMapViewDelegate,RMTileCacheBackgroundDelegate>

@property (weak, nonatomic) IBOutlet UIButton *locateButton;
@property(nonatomic,strong) RMMapView *mapView;
@property(nonatomic,strong) MMMarkerManager *markerManager;

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
    NSString *filePath=[CommonUtil dataFilePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSMutableDictionary *dictionary= [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        NSString *tileJSON=[dictionary objectForKey:@"tileJSONTourMap"];
        NSLog(@"found tileJSON in file");
        tileSource= [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
    }else{
        tileSource =[[RMMapboxSource alloc] initWithMapID:streetMapId];
        //RMMapboxSource *detailSource=[[RMMapboxSource alloc] initWithMapID:@"lionhart586.lnmjhd7b"];
        NSMutableDictionary *dictionary= [NSMutableDictionary dictionaryWithCapacity:10];
        [dictionary setObject:tileSource.tileJSON forKey:@"tileJSONTourMap"];
        //[dictionary setObject:detailSource.tileJSON forKey:@"tileJSONDetailMap"];
        [dictionary writeToFile:filePath atomically:YES];
    }
    
    self.mapView=[[RMMapView alloc] initWithFrame:self.view.bounds
                                    andTilesource:tileSource];
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
    

    [self addMarkerWithTitle:@"Boundary" withCoordinate:CLLocationCoordinate2DMake(31.216571, 121.391336)];
    [self addMarkerWithTitle:@"Boundary" withCoordinate:CLLocationCoordinate2DMake(31.237347, 121.416280)];
}
#pragma getters and setters
-(MMMarkerManager *)markerManager{
    if(!_markerManager){
        _markerManager=[[MMMarkerManager alloc]init];
    }
    return _markerManager;
}

#pragma segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:SHOW_ROUTINE_INFO_SEGUE]){
       //prepare for RoutineInfoViewController
        RoutineInfoViewController *routineInfoVC=segue.destinationViewController;
        //routineInfoVC.mapView=self.mapView;
    }
}

-(IBAction)AddRoutineDone:(UIStoryboardSegue *)segue{
    // get something from addRoutineTVC
    if([segue.sourceViewController isKindOfClass:[RoutineAddTVC class]]){
        RoutineAddTVC *routineAddTVC=(RoutineAddTVC *)segue.sourceViewController;
        MMRoutine *addedRoutine=[self.markerManager createMMRoutine];
        addedRoutine.title=routineAddTVC.routineTitle;
        addedRoutine.myComment=routineAddTVC.routineDescription;
        
        
        //and draw marker
        [self addMarkerWithTitle: addedRoutine.title withCoordinate:self.mapView.centerCoordinate];
    }
}


-(void)alert:(NSString *)content{
    UIAlertView *theAlert=[[UIAlertView alloc] initWithTitle:@"alert" message:content delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [theAlert show];
}


- (IBAction)addMarker:(id)sender {
    
    //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(37.743584, -122.472331) animated:YES];
    
    [self addMarkerWithTitle:@"One Location" withCoordinate:self.mapView.centerCoordinate];
}

- (IBAction)locateButtonClick {
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(31.216571, 121.391336) animated:YES];
}


-(void)addMarkerWithTitle:(NSString *)title withCoordinate:(CLLocationCoordinate2D)coordinate{
    RMAnnotation *annotation=[[RMAnnotation alloc] initWithMapView:self.mapView
                                                        coordinate:coordinate
                                                          andTitle:title];
    [self.mapView addAnnotation:annotation];

}

#pragma cach related

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


#pragma RMMapViewDelegate

-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if(annotation.isUserLocationAnnotation)
        return nil;
    RMMarker *marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"rocket" tintColor:
                        [UIColor colorWithRed:0.224 green:0.671 blue:0.780 alpha:1.000]];
    
    marker.canShowCallout = YES;
    
    marker.rightCalloutAccessoryView = [UIButton
                                        buttonWithType:UIButtonTypeDetailDisclosure];


    return marker;
}



-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    [self performSegueWithIdentifier:SHOW_ROUTINE_INFO_SEGUE sender:annotation];
}

-(void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    NSLog(@"tap on label");
}


-(BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation{
    return YES;
}

-(void) mapView:(RMMapView *)mapView annotation:(RMAnnotation *)annotation didChangeDragState:(RMMapLayerDragState)newState fromOldState:(RMMapLayerDragState)oldState{
    
    NSLog(@"change drag state %u",newState);
    
    if(newState==RMMapLayerDragStateNone){
        NSLog(@"Drage End");
        NSString *subTitle=[NSString stringWithFormat:@"lat: %f lng: %f",annotation.coordinate.latitude,annotation.coordinate.longitude];
        annotation.subtitle=subTitle;
        NSLog(@"current zoom: %f",mapView.zoom);
        NSLog(@"tileSources num %lu",(unsigned long)[mapView.tileSources count]);
        NSLog(@"tileSources isCacheable %u",[mapView.tileSource isCacheable]);
    }
}






@end
