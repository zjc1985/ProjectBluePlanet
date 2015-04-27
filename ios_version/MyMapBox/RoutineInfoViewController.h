//
//  RoutineInfoViewController.h
//  MyMapBox
//
//  Created by bizappman on 4/13/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapbox-iOS-SDK/Mapbox.h>
#import "MMRoutine.h"

@interface RoutineInfoViewController : UITableViewController

@property(nonatomic,strong)MMRoutine *routine;
@property(nonatomic,strong)RMMapView *mapView;

@end
