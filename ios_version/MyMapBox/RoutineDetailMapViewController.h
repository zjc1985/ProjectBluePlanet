//
//  RoutineDetailMapViewController.h
//  MyMapBox
//
//  Created by yufu on 15/4/13.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "ViewController.h"
#import <Mapbox-iOS-SDK/Mapbox.h>

#import "BaseDetailMapVC.h"

typedef enum : NSUInteger {
    addMarkerInCenter = 0,
    addMarkerWithImage = 1,
    addMarkerInCurrentLocation = 2,
} ActionSheetIndexForAddMarker;


typedef enum : NSUInteger {
    addSearchResult2Routine = 0,
    clearSearchResult = 1,
} ActionSheetIndexForSearchResult;

typedef enum : NSUInteger {
    navigation_google = 1,
    navigation_default = 0,
} ActionSheetIndexForNavigation;


@interface RoutineDetailMapViewController:BaseDetailMapVC


@end
