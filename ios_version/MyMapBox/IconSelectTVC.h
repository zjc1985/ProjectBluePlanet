//
//  IconSelectTVC.h
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMarker.h"

@interface IconSelectTVC : UITableViewController

//iconUrl
@property(nonatomic,weak)UILabel *iconNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end
