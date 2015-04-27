//
//  OfflineRoutineVC.h
//  MyMapBox
//
//  Created by bizappman on 4/27/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapbox-iOS-SDK/Mapbox.h>
#import "MMMarkerManager.h"

@interface OfflineRoutineVC : UIViewController <RMTileCacheBackgroundDelegate>

@property(nonatomic,strong)NSMutableArray *routineArray;

@end
