//
//  SelectSlideNumTVCTableViewController.h
//  MyMapBox
//
//  Created by bizappman on 4/28/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMarker.h"

@interface SlideNumSelectTVC : UITableViewController

@property(nonatomic)NSUInteger markerCount;
@property(nonatomic,weak)UILabel *slideNumLabel;

@end
