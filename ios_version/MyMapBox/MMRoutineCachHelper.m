//
//  MMRoutineCachHelper.m
//  MyMapBox
//
//  Created by yufu on 15/4/27.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "MMRoutineCachHelper.h"

@interface MMRoutineCachHelper ()

@property(nonatomic,strong)MMRoutine *currentCachRoutine;

@end

@implementation MMRoutineCachHelper

#pragma mark - cach related


 -(void)startCachForRoutine:(MMRoutine *)routine withTileCach:(RMTileCache *)tilecach withTileSource:(RMMapboxSource *)tileSource{
 
     tilecach.backgroundCacheDelegate=self;
 
     self.currentCachRoutine=routine;
 
     [tilecach beginBackgroundCacheForTileSource:tileSource
                                       southWest:CLLocationCoordinate2DMake(31.216571, 121.391336)
                                       northEast:CLLocationCoordinate2DMake(31.237347, 121.416280)
                                         minZoom:12
                                         maxZoom:16];
 
 }
 
 - (void)tileCache:(RMTileCache *)tileCache didBackgroundCacheTile:(RMTile)tile withIndex:(NSUInteger)tileIndex ofTotalTileCount:(NSUInteger)totalTileCount{
     NSLog(@"MMRoutineCachHelper caching currrent num: %u with total count %u",tileIndex,totalTileCount);
     float progress=(float)tileIndex/(float)totalTileCount;
 
     self.currentCachRoutine.cachProgress=progress;
 
     if(tileIndex==totalTileCount){
         NSLog(@"Cach Complete");
         self.currentCachRoutine=nil;
     }
 }



@end
