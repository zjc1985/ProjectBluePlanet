//
//  BaseDetailMapVC.h
//  MyMapBox
//
//  Created by bizappman on 6/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapbox-iOS-SDK/Mapbox.h>
#import "CommonUtil.h"

@interface BaseDetailMapVC : UIViewController

//in
@property(nonatomic,strong) id<Routine> routine;
@property(nonatomic,strong) id<Marker> parentMarker;
@property(nonatomic,strong,readonly) NSArray *markArray; //of id Marker


@property(nonatomic,strong) id<Marker> currentMarker;
@property(nonatomic,strong) RMMapView *mapView;

//slide show related
@property (nonatomic, assign) NSInteger slideIndicator;

-(RMMapView *)defaultRMMapView;

-(void)addMarkerWithTitle:(NSString *)title withCoordinate:(CLLocationCoordinate2D)coordinate withCustomData:(id)customData;

-(void)updateUIInNormalMode;

-(void)updateUIInSlideMode;

-(void)updateMapUI;

-(void)slidePlayClick;

-(void)slideNextClick;

-(void)slidePrevClick;

-(void)handleCurrentSlideMarkers:(NSArray *)currentSlideMarkers;

-(void)showMarkInfoViewByMMMarker:(id<Marker>)marker;

-(void)hideMarkerInfoView;

@end
