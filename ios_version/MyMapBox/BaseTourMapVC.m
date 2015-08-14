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
    [line setLineWidth:0.8];
    [self.mapView addAnnotation:line];
}

-(RMMapView *)defaultRMMapView{
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
    
     RMMapView *view= [[RMMapView alloc] initWithFrame:self.view.bounds
                                    andTilesource:tileSource];
    
    [view addTileSource:detailTileSource];
    
    [view setHidden:NO forTileSourceAtIndex:0];
    [view setHidden:YES forTileSourceAtIndex:1];
    
    return view;
}

-(CGPoint)calculateOffsetFrom:(id)from to:(id)to{
    CGPoint parentPoint=[self.mapView coordinateToPixel:CLLocationCoordinate2DMake([[from lat] doubleValue],
                                                                                   [[from lng] doubleValue])];
    CGPoint subPoint=[self.mapView coordinateToPixel:CLLocationCoordinate2DMake([[to lat] doubleValue],
                                                                                [[to lng] doubleValue])];
    //NSLog(@"parent: x :%f  y: %f",parentPoint.x,parentPoint.y);
    //NSLog(@"sub: x :%f  y: %f",subPoint.x,parentPoint.y);
    CGPoint result;
    result.x=subPoint.x-parentPoint.x;
    result.y=subPoint.y-parentPoint.y;
    NSLog(@"offset: x :%f  y: %f",result.x,result.y);
    return result;
}

-(void)adjustLocationByOffsetFrom:(id )parent to:(id )to{
    CGPoint parentPoint=[self.mapView coordinateToPixel:CLLocationCoordinate2DMake([[parent lat] doubleValue],
                                                                                   [[parent lng] doubleValue])];
    CGPoint newPoint=parentPoint;
    newPoint.x=newPoint.x+[[to offsetX] doubleValue];
    newPoint.y=newPoint.y+[[to offsetY] doubleValue];
    CLLocationCoordinate2D coordinate=[self.mapView pixelToCoordinate:newPoint];
    
    [to setLat:[NSNumber numberWithDouble:coordinate.latitude]];
    [to setLng:[NSNumber numberWithDouble:coordinate.longitude]];
}

-(void)updateMapUI{
    [self updateMapUINeedPanToCurrentRoutine:YES];
}

-(void)updateMapUINeedPanToCurrentRoutine:(BOOL) needPan{
    [self.mapView removeAllAnnotations];
    for (id<Routine> eachRoutine in [self allRoutines]) {
        [self addMarkerWithTitle:[eachRoutine title]
                  withCoordinate:CLLocationCoordinate2DMake([[eachRoutine lat] doubleValue], [[eachRoutine lng] doubleValue])
                  withCustomData:eachRoutine];
        
        for (id ovMarker in [eachRoutine allOvMarks]) {
            [self adjustLocationByOffsetFrom:eachRoutine to:ovMarker];
            
            [self addMarkerWithTitle:[eachRoutine title]
                      withCoordinate:CLLocationCoordinate2DMake([[ovMarker lat] doubleValue], [[ovMarker lng] doubleValue])
                      withCustomData:ovMarker];
            
            [self addLineFrom:[[CLLocation alloc]initWithLatitude:[[eachRoutine lat] doubleValue]
                                                        longitude:[[eachRoutine lng] doubleValue]]
                           to:[[CLLocation alloc]initWithLatitude:[[ovMarker lat] doubleValue]
                                                        longitude:[[ovMarker lng] doubleValue]]];
        }
    }
    
    if(self.currentRoutine && needPan){
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([[self.currentRoutine lat] doubleValue],
                                                                     [[self.currentRoutine lng] doubleValue])
                                 animated:YES];
    }
}

-(NSArray *)allRoutines{
    NSAssert(false, @"Please overide it in son class");
    return nil;
}

#pragma mark - getter and setter
-(RMMapView *)mapView{
    if(!_mapView){
        _mapView=[self defaultRMMapView];
    }
    return _mapView;
}


@end
