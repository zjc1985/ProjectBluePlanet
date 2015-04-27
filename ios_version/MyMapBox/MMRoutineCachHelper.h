//
//  MMRoutineCachHelper.h
//  MyMapBox
//
//  Created by yufu on 15/4/27.
//  Copyright (c) 2015年 yufu. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Mapbox-iOS-SDK/Mapbox.h>
#import "MMRoutine.h"

@interface MMRoutineCachHelper : NSObject<RMTileCacheBackgroundDelegate>

-(void)startCachForRoutine:(MMRoutine *)routine withTileCach:(RMTileCache *)tilecach withTileSource:(RMMapboxSource *)tileSource;

- (void)tileCache:(RMTileCache *)tileCache didBackgroundCacheTile:(RMTile)tile withIndex:(NSUInteger)tileIndex ofTotalTileCount:(NSUInteger)totalTileCount;

@end
