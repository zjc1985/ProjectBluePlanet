//
//  MMRoutineCachHelper.m
//  MyMapBox
//
//  Created by yufu on 15/4/27.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "MMRoutineCachHelper.h"
#import "CommonUtil.h"

@interface MMRoutineCachHelper ()

@property(nonatomic,strong)MMRoutine *currentCachRoutine;

@end

@implementation MMRoutineCachHelper

#pragma mark - cach related


 -(BOOL)startCachForRoutine:(MMRoutine *)routine withTileCach:(RMTileCache *)tilecach withTileSource:(RMMapboxSource *)tileSource{
 
     tilecach.backgroundCacheDelegate=self;
     
     if([routine.markers count]==0){
         [CommonUtil alert:@"can not offline routine with no markers in it"];
         return NO;
     }
     
     NSUInteger minZoom=12;
     NSUInteger maxZoom=16;
     
     CLLocationCoordinate2D southwest=CLLocationCoordinate2DMake([routine minLatInMarkers],[routine minLngInMarkers]);
     CLLocationCoordinate2D northEast=CLLocationCoordinate2DMake([routine maxLatInMarkers],[routine maxLngInMarkers]);
     
     NSLog(@"south west %f %f",southwest.latitude,southwest.longitude);
     NSLog(@"north east %f %f",northEast.latitude,southwest.longitude);
     
     if ([tilecach tileCountForSouthWest:southwest northEast:northEast minZoom:minZoom maxZoom:maxZoom]>500) {
         [CommonUtil alert:(@"cach size to big upper 500 tile count")];
         return NO;
     }
     if([tilecach isBackgroundCaching]){
         return NO;
     }else{
         self.currentCachRoutine=routine;
         
         [tilecach beginBackgroundCacheForTileSource:tileSource
                                           southWest:southwest
                                           northEast:northEast
                                             minZoom:minZoom
                                             maxZoom:maxZoom];
         return YES;
     }

 }
 
 - (void)tileCache:(RMTileCache *)tileCache didBackgroundCacheTile:(RMTile)tile withIndex:(NSUInteger)tileIndex ofTotalTileCount:(NSUInteger)totalTileCount{
     NSLog(@"MMRoutineCachHelper caching currrent num: %u with total count %u",tileIndex,totalTileCount);
     float progress=(float)tileIndex/(float)totalTileCount;
 
     self.currentCachRoutine.cachProgress=[NSNumber numberWithFloat: progress];
 
     if(tileIndex==totalTileCount){
         NSLog(@"%@ Cach Complete",self.currentCachRoutine.title);         
         self.currentCachRoutine=nil;
     }
 }

@end
