//
//  MMRoutine+Extension.h
//  MyMapBox
//
//  Created by bizappman on 5/11/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMRoutine.h"

@interface MMRoutine (Dao)

+(MMRoutine *)createMMRoutineWithLat:(double)lat withLng:(double)lng;

+(void)removeRoutine:(MMRoutine *)routine;

+(NSArray *)fetchAllModelRoutines;

+(NSArray *)fetchAllCachedModelRoutines;

+(MMRoutine *)fetchRoutineById:(NSString *)id;




-(void)markDelete;

-(double)minLatInMarkers;

-(double)maxLatInMarkers;

-(double)minLngInMarkers;

-(double)maxLngInMarkers;

-(void)updateLocation;

@end
