//
//  AVOSCloudManager.m
//  MyMapBox
//
//  Created by bizappman on 5/13/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "CloudManager.h"
#import "AppDelegate.h"
#import "MMRoutine+Dao.h"
#import "MMOvMarker+Dao.h"
#import "CommonUtil.h"

#define KEY_RESPONSE_ROUTINES_UPDATED @"routinesUpdate"
#define KEY_RESPONSE_ROUTINES_NEW   @"routinesNew"
#define KEY_RESPONSE_ROUTINES_DELETE @"routinesDelete"

#define KEY_RESPONSE_OV_MARKERS_UPDATED @"ovMarkersUpdate"
#define KEY_RESPONSE_OV_MARKERS_NEW @"ovMarkersNew"
#define KEY_RESPONSE_OV_MARKER_DELETE @"ovMarkersDelete"

@implementation CloudManager

+(void)contextWillSave:(NSNotification *)notify{
    NSLog(@"Context will save");
}

+(AVUser *)currentUser{
    return [AVUser currentUser];
}


+(void)syncRoutinesAndOvMarkersWithBlockWhenDone:(void (^)(NSError *))block{
    //save db context
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    [appDelegate saveContext];
    
    //prepare request params
    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];
    
    [params setValue:[self allRoutinesDictionary] forKey:@"syncRoutines"];
    [params setValue:[self allOvMarkersDictionary] forKey:@"syncOvMarkers"];
    
    //call cloud
    [AVCloud callFunctionInBackground:@"syncRoutines" withParameters:params block:^(id object, NSError *error) {
        if(!error){
            NSDictionary *response=object;
            
            [self handleRoutinesUpdate:[response objectForKey:KEY_RESPONSE_ROUTINES_UPDATED]];
            [self handleRoutinesNew:[response objectForKey:KEY_RESPONSE_ROUTINES_NEW]];
            [self handleRoutinesDelete:[response objectForKey:KEY_RESPONSE_ROUTINES_DELETE]];
        
            [self handleOvMarkersUpdate:[response objectForKey:KEY_RESPONSE_OV_MARKERS_UPDATED]];
            [self handleOvMarkersNew:[response objectForKey:KEY_RESPONSE_OV_MARKERS_NEW]];
            [self handleOvMarkersDelete:[response objectForKey:KEY_RESPONSE_OV_MARKER_DELETE]];
            
            //server will not return client new object when sync, so need set these objects isSynced to YES after sync
            for (MMRoutine *each in [MMRoutine fetchAllModelRoutines]) {
                if(![each.isSync boolValue]){
                    each.isSync=[NSNumber numberWithBool:YES];
                    each.updateTimestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
                }
            }
            
        }
        
        block(error);
    }];
}

+(NSArray *)allRoutinesDictionary{
    NSMutableArray *result=[[NSMutableArray alloc]init];
    NSArray *allMMRoutines=[MMRoutine fetchALLRoutinesIncludeMarkDelete];
    for (MMRoutine *each in allMMRoutines) {
        [result addObject:[each convertToDictionary]];
    }
    return result;
}

+(NSArray *)allOvMarkersDictionary{
    NSMutableArray *result=[[NSMutableArray alloc]init];
    NSArray *allOvMarkers=[MMOvMarker fetchAllMMovMarkersIncludeMarkDelete];
    for (MMOvMarker *each in allOvMarkers) {
        [result addObject:[each convertToDictionary]];
    }
    return result;
}

+(void)handleOvMarkersUpdate:(NSArray *)array{
    for (NSDictionary *ovMarkerDic in array) {
        
        MMOvMarker *ovMarker=[MMOvMarker queryMMOvMarkerWithUUID:[ovMarkerDic objectForKey:KEY_OVMARKER_UUID]];
        if(ovMarker){
            ovMarker.offsetX=[ovMarkerDic objectForKey:KEY_OVMARKER_OFFSET_X];
            ovMarker.offsetY=[ovMarkerDic objectForKey:KEY_OVMARKER_OFFSET_Y];
            
            MMRoutine *belongRoutine=[MMRoutine queryMMRoutineWithUUID:[ovMarkerDic objectForKey:KEY_OVMARKER_ROUTINE_ID]];
            if(belongRoutine){
                ovMarker.belongRoutine=belongRoutine;
            }
            
            ovMarker.updateTimestamp=[ovMarkerDic objectForKey:KEY_OVMARKER_UPDATE_TIME];
            ovMarker.iconUrl=[ovMarkerDic objectForKey:KEY_OVMARKER_ICON_URL];
            ovMarker.isSync=[NSNumber numberWithBool:YES];
        }
    }
}

+(void)handleOvMarkersDelete:(NSArray *)array{
    for (NSDictionary *ovMarkerDic in array) {
        MMOvMarker *ovMarker=[MMOvMarker queryMMOvMarkerWithUUID:[ovMarkerDic objectForKey:KEY_OVMARKER_UUID]];
        [MMOvMarker removeMMOvMarker:ovMarker];
    }
}

+(void)handleOvMarkersNew:(NSArray *)array{
    for (NSDictionary *ovMarkerDic in array) {
        MMRoutine *belongRoutine=[MMRoutine queryMMRoutineWithUUID:[ovMarkerDic objectForKey:KEY_OVMARKER_ROUTINE_ID]];
        MMOvMarker *ovMarker=[MMOvMarker createMMOvMarkerInRoutine:belongRoutine
                                                          withUUID:[ovMarkerDic objectForKey:KEY_OVMARKER_UUID]];
        ovMarker.updateTimestamp=[ovMarkerDic objectForKey:KEY_OVMARKER_UPDATE_TIME];
        ovMarker.iconUrl=[ovMarkerDic objectForKey:KEY_OVMARKER_ICON_URL];
        ovMarker.isSync=[NSNumber numberWithBool:YES];
        ovMarker.offsetX=[ovMarkerDic objectForKey:KEY_OVMARKER_OFFSET_X];
        ovMarker.offsetY=[ovMarkerDic objectForKey:KEY_OVMARKER_OFFSET_Y];
    }
}

+(void)handleRoutinesUpdate:(NSArray *)array{
    for (NSDictionary *routineDic in array) {
        MMRoutine *routine=[MMRoutine queryMMRoutineWithUUID:[routineDic objectForKey:KEY_ROUTINE_UUID]];
        if(routine){
            routine.mycomment=[routineDic objectForKey:KEY_ROUTINE_DESCRITPION];
            routine.title=[routineDic objectForKey:KEY_ROUTINE_TITLE];
            routine.lat=[routineDic objectForKey:KEY_ROUTINE_LAT];
            routine.lng=[routineDic objectForKey:KEY_ROUTINE_LNG];
            routine.isSync=[NSNumber numberWithBool:YES];
            routine.updateTimestamp=[routineDic objectForKey:KEY_ROUTINE_UPDATE_TIME];
        }
    }
}

+(void)handleRoutinesNew:(NSArray *)array{
    for (NSDictionary *routineDic in array) {
        NSNumber *lat=[routineDic objectForKey:KEY_ROUTINE_LAT];
        NSNumber *lng=[routineDic objectForKey:KEY_ROUTINE_LNG];
        MMRoutine *routine=[MMRoutine createMMRoutineWithLat:[lat doubleValue] withLng:[lng doubleValue] withUUID:[routineDic objectForKey:KEY_ROUTINE_UUID]];
        
        routine.mycomment=[routineDic objectForKey:KEY_ROUTINE_DESCRITPION];
        routine.title=[routineDic objectForKey:KEY_ROUTINE_TITLE];
        routine.isSync=[NSNumber numberWithBool:YES];
        routine.updateTimestamp=[routineDic objectForKey:KEY_ROUTINE_UPDATE_TIME];
    }
}

+(void)handleRoutinesDelete:(NSArray *)array{
    for (NSDictionary *routineDic in array) {
        MMRoutine *routine=[MMRoutine queryMMRoutineWithUUID:[routineDic objectForKey:KEY_ROUTINE_UUID]];
        if(routine){
            [MMRoutine removeRoutine:routine];
        }
    }
}



+(void)syncMarkersByRoutineUUID:(NSString *)routineUUID withClockWhenDone:(void (^)(NSError *))block{
    
}

@end
