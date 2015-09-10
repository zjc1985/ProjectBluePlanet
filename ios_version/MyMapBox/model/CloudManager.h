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
#import "GooglePlaceDetail.h"

@interface CloudManager : NSObject

+(AVUser *)currentUser;

+(void)autoQueryComplete:(NSString *)input withBlock:(void(^)(NSError *error,NSArray *autoQueryResultArray))block;

+(void)details:(NSString *)placeId withLanguage:(NSString *)language withBlock:(void(^)(NSError *error,GooglePlaceDetail *placeDetail))block;

+(void)likeRoutine:(NSString *)routineId withBlockWhenDone:(void (^)(NSError *error))block;

+(void)unLikedRoutine:(NSString *)routineId withBlockWhenDone:(void (^)(NSError *error))block;

+(void)queryLikedRoutines:(void (^)(NSError *error,NSArray *searchRoutines))block;

+(void)existLikedRoutine:(NSString *)routineId withBlockWhenDone:(void (^)(BOOL isLiked,NSError *error))block;

+(void)follow:(NSString *)userId withBlockWhenDone:(void (^)(BOOL success,NSError *error))block;

+(void)unfollow:(NSString *)userId withBlockWhenDone:(void (^)(BOOL success,NSError *error))block;

+(void)queryFollowees:(void (^)(NSError *error,NSArray *user))block;

+(void)existFollowee:(NSString *)userId withBlockWhenDone:(void (^)(BOOL isFollowed,NSError *error))block;

+(void)syncRoutinesAndOvMarkersWithBlockWhenDone:(void (^)(NSError *error))block;

+(void)syncMarkersByRoutineUUID:(NSString *)routineUUID withBlockWhenDone:(void (^)(NSError *error))block;

+(void)searchRoutinesByLat:(NSNumber *)lat lng:(NSNumber *)lng withLimit:(NSNumber *)limit withPage:(NSNumber *)page withBlockWhenDone:(void (^)(NSError *error,NSArray *routines))block;

+(void)searchRoutinesByUserId:(NSString *)userId withBlockWhenDone:(void (^)(NSError *error,NSArray *routines))block;

+(void)queryMarkersByRoutineId:(NSString *)routineId withBlockWhenDone:(void (^)(NSError *error,NSArray *markers))block;

@end
