//
//  MMRoutine.h
//  MyMapBox
//
//  Created by yufu on 15/4/19.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMMarker.h"

@interface MMRoutine : MMMarker

@property(nonatomic,strong)NSMutableArray *ovMarkers;
@property(nonatomic,strong)NSMutableArray *markers;


-(void)addMarker:(MMMarker *)marker;

-(void)updateLocation;

@end
