//
//  MMRoutine+Extension.h
//  MyMapBox
//
//  Created by bizappman on 5/11/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMRoutine.h"
#import "CommonUtil.h"

#define KEY_ROUTINE_DESCRITPION @"description"
#define KEY_ROUTINE_TITLE @"title"
#define KEY_ROUTINE_IS_DELETE @"isDelete"
#define KEY_ROUTINE_UPDATE_TIME @"updateTime"
#define KEY_ROUTINE_LAT @"lat"
#define KEY_ROUTINE_LNG @"lng"
#define KEY_ROUTINE_IS_SYNCED @"isSynced"
#define KEY_ROUTINE_UUID @"uuid"

@interface MMRoutine (Dao)<Routine>

+(MMRoutine *)createMMRoutineWithLat:(double)lat withLng:(double)lng;

+(MMRoutine *)createMMRoutineWithLat:(double)lat withLng:(double)lng withUUID:(NSString *)uuid;

+(MMRoutine *)queryMMRoutineWithUUID:(NSString *)uuid;

+(void)removeRoutine:(MMRoutine *)routine;

//fetch all routines in db whose isDelete is no
+(NSArray *)fetchAllModelRoutines;

+(NSArray *)fetchALLRoutinesIncludeMarkDelete;

//fetch routines whose cachprogress is 1
+(NSArray *)fetchAllCachedModelRoutines;

//+(MMRoutine *)fetchRoutineById:(NSString *)id;

//return all markers whose isDelete is NO
-(NSArray *)allMarks;

-(NSUInteger)maxSlideNum;

-(BOOL)isMarkersSyncWithCloud;

-(void)deleteSelf;

-(void)updateLocation;

-(NSDictionary *)convertToDictionary;

@end
