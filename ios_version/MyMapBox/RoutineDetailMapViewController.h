//
//  RoutineDetailMapViewController.h
//  MyMapBox
//
//  Created by yufu on 15/4/13.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "ViewController.h"
#import <Mapbox-iOS-SDK/Mapbox.h>

#import "MMRoutine.h"

typedef enum : NSUInteger {
    addMarkerInCenter = 0,
    addMarkerWithImage = 1,
    addMarkerInCurrentLocation = 2,
} ActionSheetIndexForAddMarker;

@interface RoutineDetailMapViewController:UIViewController

@property(nonatomic,strong)MMRoutine *routine;



@end
