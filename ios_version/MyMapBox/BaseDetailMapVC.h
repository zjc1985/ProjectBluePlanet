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

@property(nonatomic,strong) RMMapView *mapView;
@property(nonatomic,strong) id<Routine> routine;
@property(nonatomic,strong) id currentMarker;

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

@end
