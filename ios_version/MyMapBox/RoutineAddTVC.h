//
//  RoutineAddTVC.h
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMarkerManager.h"

@interface RoutineAddTVC : UITableViewController

@property(nonatomic,strong)MMMarkerManager *markerManager;
@property(nonatomic)double currentLat;
@property(nonatomic)double currentLng;

@end
