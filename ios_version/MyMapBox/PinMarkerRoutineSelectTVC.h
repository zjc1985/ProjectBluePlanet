//
//  PinMarkerRoutineSelectTVC.h
//  MyMapBox
//
//  Created by bizappman on 15/10/15.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtil.h"

@interface PinMarkerRoutineSelectTVC : UITableViewController

//in
@property(nonatomic,strong) id<Marker> markerNeedPin;
@property(nonatomic) BOOL needShowCurrentRoutine;

@end
