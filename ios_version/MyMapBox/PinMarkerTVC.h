//
//  PinMarkerTVC.h
//  MyMapBox
//
//  Created by bizappman on 6/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMRoutine+Dao.h"

@interface PinMarkerTVC : UITableViewController

//out
@property(nonatomic,strong)MMRoutine *selectedRoutine;
@property(nonatomic)BOOL needImage;
@property(nonatomic)BOOL needContent;

@end
