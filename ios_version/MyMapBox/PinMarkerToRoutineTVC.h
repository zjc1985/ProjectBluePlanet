//
//  PinMarkerToCurrentRoutineTVC.h
//  MyMapBox
//
//  Created by bizappman on 15/10/14.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtil.h"

@interface PinMarkerToRoutineTVC : UITableViewController

//in
@property (nonatomic,strong)id<TreeNode> nodeNeedPin;
@property (nonatomic,strong)MMRoutine *desRoutine;

@end
