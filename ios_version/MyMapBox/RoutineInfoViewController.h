//
//  RoutineInfoViewController.h
//  MyMapBox
//
//  Created by bizappman on 4/13/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapbox-iOS-SDK/Mapbox.h>
#import "MMOvMarker+Dao.h"
#import "MMRoutineCachHelper.h"

@interface RoutineInfoViewController : UITableViewController

@property(nonatomic,strong)MMOvMarker *ovMarker;
@property(nonatomic,strong)RMMapView *mapView;
@property(nonatomic,strong)MMRoutineCachHelper *routineCachHelper;

@end
