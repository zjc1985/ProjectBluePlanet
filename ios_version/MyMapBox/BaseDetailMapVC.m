//
//  BaseDetailMapVC.m
//  MyMapBox
//
//  Created by bizappman on 6/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "BaseDetailMapVC.h"


@interface BaseDetailMapVC ()

@end

@implementation BaseDetailMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(RMMapView *)defaultRMMapView{
    
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
    
    return [[RMMapView alloc] initWithFrame:self.view.bounds
                                    andTilesource:tileSource];
}

-(void)addMarkerWithTitle:(NSString *)title withCoordinate:(CLLocationCoordinate2D)coordinate withCustomData:(id)customData{
    RMAnnotation *annotation=[[RMAnnotation alloc] initWithMapView:self.mapView
                                                        coordinate:coordinate
                                                          andTitle:title];
    annotation.userInfo=customData;
    [self.mapView addAnnotation:annotation];
}

-(void)updateMapUI{
    if(self.slideIndicator<0){
        [self updateUIInNormalMode];
    }else{
        [self updateUIInSlideMode];
        //strange that some marker will not animated until call updateUISlidemode twice...
        [self updateUIInSlideMode];
    }
}

-(void)updateUIInSlideMode{
    NSLog(@"update ui in slide mode");
    
    [self.mapView removeAllAnnotations];
    
    NSArray *markersSortedBySlideNum=[self markersSortedBySlideNum];
    
    NSMutableArray *markersNeedToShow=[[NSMutableArray alloc]init];
    NSMutableArray *markersNeedInView=[[NSMutableArray alloc]init];
    NSMutableArray *currentSlideIndicatorMarkers=[[NSMutableArray alloc]init];
    
    
    for (NSInteger i=0; i<self.slideIndicator+1; i++) {
        [markersNeedToShow addObjectsFromArray:[markersSortedBySlideNum objectAtIndex:i]];
        
        if (i==self.slideIndicator) {
            [currentSlideIndicatorMarkers addObjectsFromArray:[markersSortedBySlideNum objectAtIndex:i]];
            [markersNeedInView addObjectsFromArray:[markersSortedBySlideNum objectAtIndex:i]];
            if((i-1)>=0){
                [markersNeedInView addObjectsFromArray:[markersSortedBySlideNum objectAtIndex:i-1]];
            }
        }
    }
    
    for (id marker in markersNeedToShow) {
        [self addMarkerWithTitle:[marker title]
                  withCoordinate:CLLocationCoordinate2DMake([[marker lat] doubleValue], [[marker lng] doubleValue])
                  withCustomData:marker];
    }
    
    if(self.currentMarker){
        NSLog(@"center to currentMarker");
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([[self.currentMarker lat] doubleValue], [[self.currentMarker lng] doubleValue]) animated:YES];
    }else{
        [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:[CommonUtil minLocationInMMMarkers:markersNeedInView]
                                                     northEast:[CommonUtil maxLocationInMMMarkers:markersNeedInView]
                                                      animated:YES];
    }
    
    [self.mapView setZoom:self.mapView.zoom-0.5 animated:YES];
    
    [self animateMMMarkers:currentSlideIndicatorMarkers];
}

-(void)animateMMMarkers:(NSArray *)markers{
    // move marker up and down:
    CABasicAnimation *hover = [CABasicAnimation animationWithKeyPath:@"position"];
    // fromValue and toValue will be relative instead of absolute values
    hover.additive = YES;
    hover.fromValue = [NSValue valueWithCGPoint:CGPointZero];
    // y increases downwards on iOS
    hover.toValue = [NSValue valueWithCGPoint:CGPointMake(0.0, -15.0)];
    // Animate back to normal afterwards
    hover.autoreverses = YES;
    // The duration for one part of the animation (1 up and 1 down)
    hover.duration = 1;
    // The number of times the animation should repeat
    hover.repeatCount = INFINITY;
    // adding easing to our animation
    //hover.timingFunction = [CAMediaTimingFunction functionWithName:
    //                        kCAMediaTimingFunctionEaseInEaseOut];
    
    for (id eachMMMarker in markers) {
        for (RMAnnotation *eachAnnotation in [self.mapView annotations]) {
            id marker=eachAnnotation.userInfo;
            if([[marker uuid] isEqualToString:[eachMMMarker uuid]]){
                NSLog(@"Add animated to marker:%@",[eachMMMarker title]);
                [eachAnnotation.layer addAnimation:hover forKey:@"hover"];
            }
        }
    }
}

-(NSArray *)markersSortedBySlideNum{
    NSMutableArray *result=[[NSMutableArray alloc]init];
    NSArray *allMarkers=[self.routine allMarks];
    
    for (NSUInteger i=1; i<allMarkers.count+1; i++) {
        NSMutableArray *markersWithSameSlideNum=[[NSMutableArray alloc]init];
        for (id marker in allMarkers) {
            if ([[marker slideNum] unsignedIntegerValue] ==i) {
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
    NSLog(@"update ui in normal mode");
    
    [self.mapView removeAllAnnotations];
    
    for (id marker in [self.routine allMarks]) {
        [self addMarkerWithTitle:[marker title]
                  withCoordinate:CLLocationCoordinate2DMake([[marker lat] doubleValue], [[marker lng] doubleValue])
                  withCustomData:marker];
    }
    
    if ([[self.routine allMarks] count]>0) {
        if(self.currentMarker){
            NSLog(@"center to currentMarker");
            [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([[self.currentMarker lat] doubleValue], [[self.currentMarker lng] doubleValue]) animated:YES];
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
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([[self.routine lat] doubleValue], [[self.routine lng] doubleValue]) animated:YES];
    }
}

-(void)slidePlayClick{
    self.currentMarker=nil;
    if(self.slideIndicator<0){
        self.slideIndicator=0;
    }else{
        self.currentMarker=nil;
        self.slideIndicator=-1;
    }
    [self updateMapUI];
}

-(void)slideNextClick{
    self.currentMarker=nil;
    if(self.slideIndicator>=0 && self.slideIndicator<[self markersSortedBySlideNum].count-1){
        self.slideIndicator++;
        [self updateMapUI];
    }
}

-(void)slidePrevClick{
    self.currentMarker=nil;
    if(self.slideIndicator>0){
        self.slideIndicator--;
        [self updateMapUI];
    }
}


#pragma mark - getter and setter
-(RMMapView *)mapView{
    if(!_mapView){
        _mapView=[self defaultRMMapView];
    }
    return _mapView;
}



@end
