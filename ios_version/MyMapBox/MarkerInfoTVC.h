//
//  MarkerInfoTVC.h
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMarker.h"

@interface MarkerInfoTVC : UITableViewController


@property(nonatomic)NSUInteger markerCount;
@property(nonatomic,strong)MMMarker *marker;

@end
