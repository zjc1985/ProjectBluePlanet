//
//  AVOSCloudManager.h
//  MyMapBox
//
//  Created by bizappman on 5/13/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>
#import "MMSearchedRoutine.h"

@interface CloudManager : NSObject

+(AVUser *)currentUser;

+(void)syncRoutinesAndOvMarkersWithBlockWhenDone:(void (^)(NSError *error))block;

+(void)syncMarkersByRoutineUUID:(NSString *)routineUUID withBlockWhenDone:(void (^)(NSError *error))block;

+(void)searchRoutinesByLat:(NSNumber *)lat lng:(NSNumber *)lng withLimit:(NSNumber *)limit withPage:(NSNumber *)page withBlockWhenDone:(void (^)(NSError *error,NSArray *routines))block;

+(void)queryMarkersByRoutineId:(NSString *)routineId withBlockWhenDone:(void (^)(NSError *error,NSArray *markers))block;

@end
