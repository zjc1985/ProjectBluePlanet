//
//  BaseTourMapVC.h
//  MyMapBox
//
//  Created by bizappman on 6/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapbox-iOS-SDK/Mapbox.h>

@interface BaseTourMapVC : UIViewController

@property(nonatomic,strong) RMMapView *mapView;

-(RMMapView *)defaultRMMapView;

-(void)addMarkerWithTitle:(NSString *)title withCoordinate:(CLLocationCoordinate2D)coordinate withCustomData:(id)customData;

-(void)addLineFrom:(CLLocation *)from to:(CLLocation *)to;

@end
