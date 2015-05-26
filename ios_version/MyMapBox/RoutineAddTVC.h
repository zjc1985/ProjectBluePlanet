//
//  RoutineAddTVC.h
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMRoutine+Dao.h"

@interface RoutineAddTVC : UITableViewController

//in
@property(nonatomic)double currentLat;
@property(nonatomic)double currentLng;

//out
@property(nonatomic,strong) MMRoutine *addedRoutine;

@end
