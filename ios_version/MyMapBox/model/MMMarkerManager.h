//
//  MMMarkerManager.h
//  MyMapBox
//
//  Created by bizappman on 4/20/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MMRoutine.h"
#import "MMOvMarker.h"

@interface MMMarkerManager : NSObject

@property(nonatomic,strong) MMRoutine *currentRoutine;

-(NSMutableArray *)fetchAllModelRoutines;

-(NSMutableArray *)fetchAllCachedModelRoutines;

-(MMRoutine *)createMMRoutineWithLat:(double)lat withLng:(double)lng;

-(void)deleteMMRoutine:(MMRoutine *)routine;

-(MMRoutine *)fetchRoutineById:(NSString *)id;

@end



