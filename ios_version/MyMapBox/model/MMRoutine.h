//
//  MMRoutine.h
//  MyMapBox
//
//  Created by yufu on 15/4/19.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMMarker.h"
#import "MMOvMarker.h"


@interface MMRoutine : MMBaseMarker

@property(nonatomic,strong)NSMutableArray *ovMarkers; //of MMOvMarker
@property(nonatomic,strong)NSMutableArray *markers; //of MMMarker
@property(nonatomic)BOOL isLoadMarkers;

@property(nonatomic)float cachProgress;

-(instancetype)initWithLat:(double)lat withlng:(double)lng;

-(void)addMarker:(MMMarker *)marker;

-(void)deleteMarker:(MMMarker *)marker;

-(double)minLatInMarkers;

-(double)maxLatInMarkers;

-(double)minLngInMarkers;

-(double)maxLngInMarkers;

-(MMOvMarker *)addDefaultOvMarker;

-(void)updateLocation;

@end
