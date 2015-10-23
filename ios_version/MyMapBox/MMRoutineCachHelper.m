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
     
     NSUInteger minZoom=8;
     NSUInteger maxZoom=16;
     
     double minLat=[CommonUtil minLatInMarkers:[routine allMarks]];
     double minLng=[CommonUtil minLngInMarkers:[routine allMarks]];
     double maxLat=[CommonUtil maxLatInMarkers:[routine allMarks]];
     double maxLng=[CommonUtil maxLngInMarkers:[routine allMarks]];
     
     CLLocationCoordinate2D southwest=CLLocationCoordinate2DMake(minLat,minLng);
     CLLocationCoordinate2D northEast=CLLocationCoordinate2DMake(maxLat,maxLng);
     
     NSLog(@"south west %f %f",southwest.latitude,southwest.longitude);
     NSLog(@"north east %f %f",northEast.latitude,southwest.longitude);
     
     /*
     if ([tilecach tileCountForSouthWest:southwest northEast:northEast minZoom:minZoom maxZoom:maxZoom]>500) {
         [CommonUtil alert:(@"cach size to big upper 500 tile count")];
         return NO;
     }
      */
     
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
 
 -(void)tileCache:(RMTileCache *)tileCache didBackgroundCacheTile:(RMTile)tile withIndex:(NSUInteger)tileIndex ofTotalTileCount:(NSUInteger)totalTileCount{
     NSLog(@"MMRoutineCachHelper caching currrent num: %lu with total count %lu",(unsigned long)tileIndex,(unsigned long)totalTileCount);
     float progress=(float)tileIndex/(float)totalTileCount;
 
     self.currentCachRoutine.cachProgress=[NSNumber numberWithFloat: progress];
 
     
 }

-(void)tileCache:(RMTileCache *)tileCache didReceiveError:(NSError *)error whenCachingTile:(RMTile)tile{
    NSLog(@"Cach error:%@",error.localizedDescription);
    self.currentCachRoutine.cachProgress=[NSNumber numberWithUnsignedInteger:0];
    self.currentCachRoutine=nil;
}

-(void)tileCacheDidCancelBackgroundCache:(RMTileCache *)tileCache{
    NSLog(@"Cach cancel");
    self.currentCachRoutine.cachProgress=[NSNumber numberWithUnsignedInteger:0];
    self.currentCachRoutine=nil;
}

-(void)tileCacheDidFinishBackgroundCache:(RMTileCache *)tileCache{
    NSLog(@"Cach did finish");
    self.currentCachRoutine.cachProgress=[NSNumber numberWithUnsignedInteger:1];
    self.currentCachRoutine=nil;
}

@end
