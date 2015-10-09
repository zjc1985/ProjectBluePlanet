//
//  MarkerInfoTVC.h
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMarker+Dao.h"
#import "BaseMarkerInfoVC.h"

@interface MarkerInfoTVC : BaseMarkerInfoVC

@property(nonatomic)NSUInteger markerCount;

@property(nonatomic,strong)MMRoutine *belongRoutine;

@end
