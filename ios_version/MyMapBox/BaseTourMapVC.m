//
//  BaseTourMapVC.m
//  MyMapBox
//
//  Created by bizappman on 6/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "BaseTourMapVC.h"
#import "CommonUtil.h"

@interface BaseTourMapVC ()

@end

@implementation BaseTourMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

-(RMMapView *)defaultRMMapView{
    RMMapView *mapView;
    RMMapboxSource *tileSource=nil;
    
    NSString *filePath=[CommonUtil dataFilePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSMutableDictionary *dictionary= [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        NSString *tileJSON=[dictionary objectForKey:tileJsonTourMap];
        NSLog(@"found tileJSON in file");
        tileSource= [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
    }else{
        tileSource =[[RMMapboxSource alloc] initWithMapID:tourMapId];
        NSMutableDictionary *dictionary= [NSMutableDictionary dictionaryWithCapacity:10];
        [dictionary setObject:tileSource.tileJSON forKey:tileJsonTourMap];
        [dictionary writeToFile:filePath atomically:YES];
    }
    
    mapView=[[RMMapView alloc] initWithFrame:self.view.bounds
                                andTilesource:tileSource];
    return mapView;
}

#pragma mark - getter and setter
-(RMMapView *)mapView{
    if(!_mapView){
        _mapView=[self defaultRMMapView];
    }
    return _mapView;
}


@end
