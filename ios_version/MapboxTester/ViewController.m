//
//  ViewController.m
//  MyMapBox
//
//  Created by bizappman on 4/9/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "ViewController.h"
#import <Mapbox-iOS-SDK/Mapbox.h>

@interface ViewController ()<RMMapViewDelegate,RMTileCacheBackgroundDelegate>

@property(nonatomic,strong) RMMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RMConfiguration sharedInstance] setAccessToken:@"pk.eyJ1IjoibGlvbmhhcnQ1ODYiLCJhIjoiR1JHd2NnYyJ9.iCg5vA7qQaRxf2Z-T_vEjg"];
    RMMapboxSource *titleSource=[[RMMapboxSource alloc] initWithMapID:@"lionhart586.gkihab1d"];
    self.mapView=[[RMMapView alloc] initWithFrame:self.view.bounds
                                    andTilesource:titleSource];
    self.mapView.minZoom=3;
    self.mapView.maxZoom=17;
    
    self.mapView.zoom=15;
    
    self.mapView.bouncingEnabled=YES;
    
    self.mapView.delegate=self;
    
    self.mapView.adjustTilesForRetinaDisplay=YES;
    
    self.mapView.tileCache.backgroundCacheDelegate=self;
    
    CLLocationCoordinate2D center=CLLocationCoordinate2DMake(31.239689, 121.499755);
    self.mapView.centerCoordinate=center;
    [self.view addSubview:self.mapView];
    
    /*
    self.navigationItem.leftBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.leftBarButtonItem.tintColor = self.navigationController.navigationBar.tintColor;
    */
    
    

    RMAnnotation *annotation=[[RMAnnotation alloc] initWithMapView:self.mapView coordinate:CLLocationCoordinate2DMake(37.743584,-122.472331) andTitle:@"cach bound"];
    
    [self.mapView addAnnotation:annotation];
    
    RMAnnotation *annotation2=[[RMAnnotation alloc] initWithMapView:self.mapView coordinate:CLLocationCoordinate2DMake(37.803965,-122.405895) andTitle:@"cach bound"];
    
    [self.mapView addAnnotation:annotation2];
    
    RMSphericalTrapezium rect = [self.mapView latitudeLongitudeBoundingBox];
    
    [self.mapView.tileCache beginBackgroundCacheForTileSource:self.mapView.tileSource
                                                    southWest:rect.southWest
                                                    northEast:rect.northEast                                                      minZoom:9
                                                      maxZoom:17];
}




- (IBAction)addMarker:(id)sender {
    
    RMAnnotation *annotation=[[RMAnnotation alloc] initWithMapView:self.mapView coordinate:self.mapView.centerCoordinate andTitle:@"One Location"];
    
    [self.mapView addAnnotation:annotation];

    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(37.743584, -122.472331) animated:YES];
     
}
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
                                                    southWest:CLLocationCoordinate2DMake(37.743584, -122.472331)
                                                    northEast:CLLocationCoordinate2DMake(37.803965, -122.405895)
                                                      minZoom:12
                                                      maxZoom:15];
}




-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if(annotation.isUserLocationAnnotation)
        return nil;
    RMMarker *marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"rocket" tintColor:
                        [UIColor colorWithRed:0.224 green:0.671 blue:0.780 alpha:1.000]];
    
    marker.canShowCallout = YES;

    return marker;
}

-(BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation{
    return YES;
}

-(void) mapView:(RMMapView *)mapView annotation:(RMAnnotation *)annotation didChangeDragState:(RMMapLayerDragState)newState fromOldState:(RMMapLayerDragState)oldState{
    
    NSLog(@"change drag state %lu",newState);
    
    if(newState==RMMapLayerDragStateNone){
        NSLog(@"Drage End");
        NSString *subTitle=[NSString stringWithFormat:@"lat: %f lng: %f",annotation.coordinate.latitude,annotation.coordinate.longitude];
        annotation.subtitle=subTitle;
        NSLog(@"current zoom: %f",mapView.zoom);
        NSLog(@"tileSources num %lu",(unsigned long)[mapView.tileSources count]);
        NSLog(@"tileSources isCacheable %u",[mapView.tileSource isCacheable]);

    }
}

- (void)tileCache:(RMTileCache *)tileCache didBeginBackgroundCacheWithCount:(NSUInteger)tileCount forTileSource:(id<RMTileSource>)tileSource{
    NSLog(@"begin background cach. tileCount:%lu ",(unsigned long)tileCount);
}

- (void)tileCache:(RMTileCache *)tileCache didBackgroundCacheTile:(RMTile)tile withIndex:(NSUInteger)tileIndex ofTotalTileCount:(NSUInteger)totalTileCount{
    NSLog(@"caching currrent num: %lu with total count %lu",(unsigned long)tileIndex,(unsigned long)totalTileCount);
    
    if(tileIndex==totalTileCount){
        RMAnnotation *annotation=[[RMAnnotation alloc] initWithMapView:self.mapView coordinate:self.mapView.centerCoordinate andTitle:@"cach complete"];
        
        [self.mapView addAnnotation:annotation];
    }
}




@end
