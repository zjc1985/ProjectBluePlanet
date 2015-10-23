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
#import "MMMarker+Dao.h"
#import "CommonUtil.h"
#import "MMSearchedOvMarker.h"
#import "MMSearchdeMarker.h"
#import "GooglePredictionResult.h"

#define KEY_RESPONSE_ROUTINES_UPDATED @"routinesUpdate"
#define KEY_RESPONSE_ROUTINES_NEW   @"routinesNew"
#define KEY_RESPONSE_ROUTINES_DELETE @"routinesDelete"

#define KEY_RESPONSE_OV_MARKERS_UPDATED @"ovMarkersUpdate"
#define KEY_RESPONSE_OV_MARKERS_NEW @"ovMarkersNew"
#define KEY_RESPONSE_OV_MARKER_DELETE @"ovMarkersDelete"

#define KEY_REQUEST_ROUTINE_ID @"routineId"
#define KEY_REQUEST_SYNC_MARKERS @"syncMarkers"

#define KEY_RESPONSE_MARKERS_UPDATED @"markersUpdate"
#define KEY_RESPONSE_MARKERS_NEW @"markersNew"
#define KEY_RESPONSE_MARKERS_DELETE @"markersDelete"

@implementation CloudManager
#pragma mark - place query feature
+(void)autoQueryComplete:(NSString *)input withBlock:(void (^)(NSError *, NSArray *))block{
    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];
    NSString *inputString=[input stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [params setObject:inputString forKey:@"input"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [AVCloud callFunctionInBackground:@"autocomplete" withParameters:params block:^(id object, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if(!error){
            NSDictionary *dictionary=object;
            NSArray *predictionsArray=[dictionary objectForKey:@"predictions"];
            NSMutableArray *results=[[NSMutableArray alloc]init];
            for (NSDictionary *predictionDictionary in predictionsArray) {
                GooglePredictionResult *predictionResult=[[GooglePredictionResult alloc]initWithDictionary:predictionDictionary];
                [results addObject:predictionResult];
            }
            block(nil,results);
        }else{
            NSLog(@"%@",error.localizedDescription);
            block(error,nil);
        }
    }];
}

+(void)details:(NSString *)placeId withLanguage:(NSString *)language withBlock:(void (^)(NSError *, GooglePlaceDetail *))block{
    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];
    [params setObject:placeId forKey:@"placeid"];
    [params setObject:language forKey:@"language"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [AVCloud callFunctionInBackground:@"details" withParameters:params block:^(id object, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if(!error){
            NSDictionary *dictionary=object;
            NSDictionary *resultDic=[dictionary objectForKey:@"result"];
            GooglePlaceDetail *detail=[[GooglePlaceDetail alloc]initWithDictionary:resultDic];
            block(error,detail);
        }else{
            NSLog(@"%@",error.localizedDescription);
            block(error,nil);
        }
    }];
}

#pragma mark - like routine feature

+(void)likeRoutine:(NSString *)routineId withBlockWhenDone:(void (^)(NSError *))block{
    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];
    [params setObject:routineId forKey:@"routineId"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [AVCloud callFunctionInBackground:@"likeRoutine" withParameters:params block:^(id object, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        block(error);
    }];
}

+(void)unLikedRoutine:(NSString *)routineId withBlockWhenDone:(void (^)(NSError *))block{
    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];
    [params setObject:routineId forKey:@"routineId"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [AVCloud callFunctionInBackground:@"unlikeRoutine" withParameters:params block:^(id object, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        block(error);
    }];
}

+(void)existLikedRoutine:(NSString *)routineId withBlockWhenDone:(void (^)(BOOL, NSError *))block{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AVQuery *query = [AVQuery queryWithClassName:@"LikedRoutine"];
    [query whereKey:@"user" equalTo:[self currentUser]];
    [query whereKey:@"routineId" equalTo:routineId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        BOOL isLike=NO;
        if (!error) {
            if (objects.count>0) {
                isLike=YES;
            }else{
                isLike=NO;
            }
        } else {
            // 输出错误信息
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        block(isLike,error);
    }];
}

+(void)queryLikedRoutines:(void (^)(NSError *, NSArray *))block{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [AVCloud callFunctionInBackground:@"queryLikedRoutines" withParameters:nil block:^(id object, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSMutableArray *routines=[[NSMutableArray alloc]init];
        
        if (!error) {
            NSDictionary *response=object;
            for (NSDictionary *eachSearchResult in response) {
                
                
                //handle routine
                NSDictionary *routineDic=[eachSearchResult objectForKey:@"searchedRoutine"];
                MMSearchedRoutine *searchedRoutine=[[MMSearchedRoutine alloc]initWithUUID:[routineDic objectForKey:@"uuid"]
                                                                                  withLat:[routineDic objectForKey:@"lat"]
                                                                                  withLng:[routineDic objectForKey:@"lng"]];
                searchedRoutine.title=[routineDic objectForKey:@"title"];
                searchedRoutine.mycomment=[routineDic objectForKey:@"description"];
                searchedRoutine.userId=[routineDic objectForKey:@"userId"];
                searchedRoutine.userName=[routineDic objectForKey:@"userName"];
                
                //handle ovMarkers
                for (NSDictionary *ovMarkerDic in [eachSearchResult objectForKey:@"searchedOvMarkers"]) {
                    MMSearchedOvMarker *searchedOvMarker=[[MMSearchedOvMarker alloc]initWithUUID:[ovMarkerDic objectForKey:@"uuid"]
                                                                                     withOffsetX:[ovMarkerDic objectForKey:@"offsetX"]
                                                                                     withOffsetY:[ovMarkerDic objectForKey:@"offsetY"]];
                    searchedOvMarker.offsetX=[NSNumber numberWithInteger:0];
                    searchedOvMarker.offsetY=[NSNumber numberWithInteger:0];
                    
                    searchedOvMarker.iconUrl=[ovMarkerDic objectForKey:@"iconUrl"];
                    [searchedRoutine addOvMarkersObject:searchedOvMarker];
                }
                
                [routines addObject:searchedRoutine];
            }
        }else{
            NSLog(@"%@",error.localizedDescription);
        }
        
        block(error,routines);
    }];
}

#pragma mark - follow feature
+(void)follow:(NSString *)userId withBlockWhenDone:(void (^)(BOOL success,NSError *))block{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[AVUser currentUser] follow:userId andCallback:^(BOOL succeeded, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        block(succeeded,error);
    }];

}

+(void)unfollow:(NSString *)userId withBlockWhenDone:(void (^)(BOOL,NSError *))block{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[AVUser currentUser] unfollow:userId andCallback:^(BOOL succeeded, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        block(succeeded,error);
    }];
}

+(void)queryFollowees:(void (^)(NSError *, NSArray *))block{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AVQuery *query= [AVUser followeeQuery:@"USER_OBJECT_ID"];
    [query whereKey:@"user" equalTo:[self currentUser]];
    [query includeKey:@"followee"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *user, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        block(error,user);
    }];
}

+(void)existFollowee:(NSString *)userId withBlockWhenDone:(void (^)(BOOL, NSError *))block{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self queryFollowees:^(NSError *error, NSArray *user) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        BOOL result=NO;
        for (AVUser *eachUser in user) {
            if ([eachUser.objectId isEqualToString:userId]) {
                result=YES;
            }
        }        
        block(result,error);
    }];
}


+(void)queryMarkersByRoutineId:(NSString *)routineId withBlockWhenDone:(void (^)(NSError *, NSArray *))block{
    NSLog(@"CloudManager.queryMarkersByRoutineId");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];
    [params setObject:routineId forKey:@"routineId"];
    
    [AVCloud callFunctionInBackground:@"fetchMarkersByRoutineId" withParameters:params block:^(id object, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSMutableArray *markers=[[NSMutableArray alloc]init];
        
        if(!error){
            NSDictionary *response=object;
            NSArray *markersDic=[response objectForKey:@"returnValue"];
            for (NSDictionary *markerDic in markersDic) {
                MMSearchdeMarker *searchMarker=[[MMSearchdeMarker alloc]initWithUUID:[markerDic objectForKey:@"id"]withLat:[markerDic objectForKey:@"lat"] withLng:[markerDic objectForKey:@"lng"]];
                
                searchMarker.title=[markerDic objectForKey:@"title"];
                searchMarker.mycomment=[markerDic objectForKey:@"mycomment"];
                
                NSMutableArray *imageUrls=[[NSMutableArray alloc]init];
                for (NSString *url in [markerDic objectForKey:@"imgUrls"]) {
                    [imageUrls addObject: [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                }
                searchMarker.imgUrls=imageUrls;
                searchMarker.iconUrl=[markerDic objectForKey:@"iconUrl"];
                searchMarker.slideNum=[markerDic objectForKey:@"slideNum"];
                searchMarker.category=[markerDic objectForKey:@"category"];
                
                [markers addObject:searchMarker];
            }
        }
        
        block(error,markers);
    }];
}

+(void)searchRoutinesByUserId:(NSString *)userId withBlockWhenDone:(void (^)(NSError *, NSArray *))block{
    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];
    [params setObject:userId forKey:@"userId"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [AVCloud callFunctionInBackground:@"searchRoutinesByUserId" withParameters:params block:^(id object, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSMutableArray *routines=[[NSMutableArray alloc]init];
        
        if (!error) {
            NSDictionary *response=object;
            for (NSDictionary *eachSearchResult in response) {
                
                
                //handle routine
                NSDictionary *routineDic=[eachSearchResult objectForKey:@"searchedRoutine"];
                MMSearchedRoutine *searchedRoutine=[[MMSearchedRoutine alloc]initWithUUID:[routineDic objectForKey:@"uuid"]
                                                                                  withLat:[routineDic objectForKey:@"lat"]
                                                                                  withLng:[routineDic objectForKey:@"lng"]];
                searchedRoutine.title=[routineDic objectForKey:@"title"];
                searchedRoutine.mycomment=[routineDic objectForKey:@"description"];
                //handle ovMarkers
                for (NSDictionary *ovMarkerDic in [eachSearchResult objectForKey:@"searchedOvMarkers"]) {
                    MMSearchedOvMarker *searchedOvMarker=[[MMSearchedOvMarker alloc]initWithUUID:[ovMarkerDic objectForKey:@"uuid"]
                                                                                     withOffsetX:[ovMarkerDic objectForKey:@"offsetX"]
                                                                                     withOffsetY:[ovMarkerDic objectForKey:@"offsetY"]];
                    searchedOvMarker.offsetX=[NSNumber numberWithInteger:0];
                    searchedOvMarker.offsetY=[NSNumber numberWithInteger:0];
                    
                    searchedOvMarker.iconUrl=[ovMarkerDic objectForKey:@"iconUrl"];
                    [searchedRoutine addOvMarkersObject:searchedOvMarker];
                }
                
                [routines addObject:searchedRoutine];
            }
        }
        
        block(error,routines);
    }];

}

+(void)searchRoutinesByLat:(NSNumber *)lat lng:(NSNumber *)lng withLimit:(NSNumber *)limit withPage:(NSNumber *)page withBlockWhenDone:(void (^)(NSError *, NSArray *))block{
    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];
    [params setObject:lat forKey:@"lat"];
    [params setObject:lng forKey:@"lng"];
    [params setObject:limit forKey:@"limit"];
    [params setObject:page forKey:@"page"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [AVCloud callFunctionInBackground:@"searchRoutinesByLatlng" withParameters:params block:^(id object, NSError *error) {
        NSMutableArray *routines=[[NSMutableArray alloc]init];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (!error) {
            NSDictionary *response=object;
            for (NSDictionary *eachSearchResult in response) {
                
                
                //handle routine
                NSDictionary *routineDic=[eachSearchResult objectForKey:@"searchedRoutine"];
                MMSearchedRoutine *searchedRoutine=[[MMSearchedRoutine alloc]initWithUUID:[routineDic objectForKey:@"uuid"]
                                                                                  withLat:[routineDic objectForKey:@"lat"]
                                                                                  withLng:[routineDic objectForKey:@"lng"]];
                searchedRoutine.title=[routineDic objectForKey:@"title"];
                searchedRoutine.mycomment=[routineDic objectForKey:@"description"];
                searchedRoutine.userId=[routineDic objectForKey:@"userId"];
                searchedRoutine.userName=[routineDic objectForKey:@"userName"];
                
                //handle ovMarkers
                for (NSDictionary *ovMarkerDic in [eachSearchResult objectForKey:@"searchedOvMarkers"]) {
                    MMSearchedOvMarker *searchedOvMarker=[[MMSearchedOvMarker alloc]initWithUUID:[ovMarkerDic objectForKey:@"uuid"]
                                                                                     withOffsetX:[ovMarkerDic objectForKey:@"offsetX"]
                                                                                     withOffsetY:[ovMarkerDic objectForKey:@"offsetY"]];
                    searchedOvMarker.offsetX=[NSNumber numberWithInteger:0];
                    searchedOvMarker.offsetY=[NSNumber numberWithInteger:0];
                    
                    searchedOvMarker.iconUrl=[ovMarkerDic objectForKey:@"iconUrl"];
                    [searchedRoutine addOvMarkersObject:searchedOvMarker];
                }
                
                [routines addObject:searchedRoutine];
            }
        }
        
        block(error,routines);
    }];

}

+(AVUser *)currentUser{
    return [AVUser currentUser];
}



+(void)syncMarkersByRoutineUUID:(NSString *)routineUUID withBlockWhenDone:(void (^)(NSError *))block{
    //save db context
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    [appDelegate saveContext];
    
    MMRoutine *belongRoutine=[MMRoutine queryMMRoutineWithUUID:routineUUID];
    
    if (belongRoutine) {
        if([belongRoutine.isSync boolValue]){
            [self doSyncMarker:belongRoutine block:block];
        }else{
            [self syncRoutinesAndOvMarkersWithBlockWhenDone:^(NSError *error) {
                if(!error){
                    [self doSyncMarker:belongRoutine block:block];
                }
            }];
        }
    }else{
        NSLog(@"syncMarkersByRoutineUUID: not found related routine with uuid %@",routineUUID);
    }
}

+ (void)doSyncMarker:(MMRoutine *)belongRoutine block:(void (^)(NSError *))block {
    //prepare request params
    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];
    [params setValue:[self allMarkerDictionaryWith:belongRoutine] forKey:KEY_REQUEST_SYNC_MARKERS];
    [params setValue:belongRoutine.uuid forKey:KEY_REQUEST_ROUTINE_ID];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //call cloud
    [AVCloud callFunctionInBackground:@"syncMarkersByRoutineId" withParameters:params block:^(id object, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if(!error){
            NSDictionary *response=object;
            
            [self handleMarkersNew:[response objectForKey:KEY_RESPONSE_MARKERS_NEW]];
            [self handleMarkersUpdate:[response objectForKey:KEY_RESPONSE_MARKERS_UPDATED]];
            [self handleMarkersDelete:[response objectForKey:KEY_RESPONSE_MARKERS_DELETE]];
            
            //server will not return client new object when sync, so need set these objects isSynced to YES after sync
            for (MMMarker *each in [belongRoutine allMarks]) {
                if(![each.isSync boolValue]){
                    each.isSync=[NSNumber numberWithBool:YES];
                    each.updateTimestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
                }
            }
            
        }
        
        block(error);
    }];
}

+(void)handleMarkersDelete:(NSArray *)array{
    for (NSDictionary *markerDic in array) {
        MMMarker *marker=[MMMarker queryMMMarkerWithUUID:[markerDic objectForKey:KEY_MARKER_UUID]];
        if(marker){
            [MMMarker removeMMMarker:marker];
        }
    }
}

+(void)handleMarkersNew:(NSArray *)array{
    for (NSDictionary *markerDic in array) {
        MMRoutine *routine=[MMRoutine queryMMRoutineWithUUID:[markerDic objectForKey:KEY_MARKER_ROUTINE_ID]];
        
        if(routine){
            NSNumber *lat=[markerDic objectForKey:KEY_MARKER_LAT];
            NSNumber *lng=[markerDic objectForKey:KEY_MARKER_LNG];
            
            MMMarker *marker=[MMMarker createMMMarkerInRoutine:routine
                                                       withLat:[lat doubleValue]
                                                       withLng:[lng doubleValue]
                                                      withUUID:[markerDic objectForKey:KEY_MARKER_UUID]
                                              withParentMarker:nil];
            marker.iconUrl=[self iconUrlToName:[markerDic objectForKey:KEY_MARKER_ICON_URL]];
            marker.category=[markerDic objectForKey:KEY_MARKER_CATEGORY];
            marker.title=[markerDic objectForKey:KEY_MARKER_TITLE];
            marker.slideNum=[markerDic objectForKey:KEY_MARKER_SLIDE_NUM];
            marker.mycomment=[markerDic objectForKey:KEY_MARKER_MYCOMMENT];
            marker.offsetX=[markerDic objectForKey:KEY_MARKER_OFFSETX];
            marker.offsetY=[markerDic objectForKey:KEY_MARKER_OFFSETY];
            marker.isSync=[NSNumber numberWithBool:YES];
            marker.updateTimestamp=[markerDic objectForKey:KEY_MARKER_UPDATE_TIME];
            marker.imgUrls=[markerDic objectForKey:KEY_MARKER_IMAGE_URLS];
        }
    }
    
    //handle parent marker
    for (NSDictionary *markerDic in array) {
        MMMarker *marker=[MMMarker queryMMMarkerWithUUID:[markerDic objectForKey:KEY_MARKER_UUID]];
        MMMarker *parentMarker=[MMMarker queryMMMarkerWithUUID:[markerDic objectForKey:KEY_MARKER_PARENT_UUID]];
        if(parentMarker){
            marker.parentMarker=parentMarker;
        }
    }
}

+(void)handleMarkersUpdate:(NSArray *)array{
    for (NSDictionary *markerDic in array) {
        MMMarker *marker=[MMMarker queryMMMarkerWithUUID:[markerDic objectForKey:KEY_MARKER_UUID]];
        if(marker){
            marker.iconUrl=[self iconUrlToName: [markerDic objectForKey:KEY_MARKER_ICON_URL]];
            marker.category=[markerDic objectForKey:KEY_MARKER_CATEGORY];
            marker.title=[markerDic objectForKey:KEY_MARKER_TITLE];
            marker.slideNum=[markerDic objectForKey:KEY_MARKER_SLIDE_NUM];
            marker.lat=[markerDic objectForKey:KEY_MARKER_LAT];
            marker.lng=[markerDic objectForKey:KEY_MARKER_LNG];
            marker.mycomment=[markerDic objectForKey:KEY_MARKER_MYCOMMENT];
            marker.offsetX=[markerDic objectForKey:KEY_MARKER_OFFSETX];
            marker.offsetY=[markerDic objectForKey:KEY_MARKER_OFFSETY];
            marker.isSync=[NSNumber numberWithBool:YES];
            marker.updateTimestamp=[markerDic objectForKey:KEY_MARKER_UPDATE_TIME];
            marker.imgUrls=[markerDic objectForKey:KEY_MARKER_IMAGE_URLS];
            MMRoutine *routine=[MMRoutine queryMMRoutineWithUUID:[markerDic objectForKey:KEY_MARKER_ROUTINE_ID]];
            if(routine){
                marker.belongRoutine=routine;
            }
        }
    }
    
    //handle parent marker
    for (NSDictionary *markerDic in array) {
        MMMarker *marker=[MMMarker queryMMMarkerWithUUID:[markerDic objectForKey:KEY_MARKER_UUID]];
        MMMarker *parentMarker=[MMMarker queryMMMarkerWithUUID:[markerDic objectForKey:KEY_MARKER_PARENT_UUID]];
        if(parentMarker){
            marker.parentMarker=parentMarker;
        }
    }
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [AVCloud callFunctionInBackground:@"syncRoutines" withParameters:params block:^(id object, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
                    
                    for (MMOvMarker *eachOvMarker in each.ovMarkers) {
                        if(![eachOvMarker.isSync boolValue]){
                            eachOvMarker.isSync=[NSNumber numberWithBool:YES];
                            eachOvMarker.updateTimestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
                        }
                    }
                }
            }
            
        }
        
        block(error);
    }];
}

+(NSArray *)allMarkerDictionaryWith:(MMRoutine *)routine{
    NSMutableArray *result=[[NSMutableArray alloc]init];
    NSArray *allMarkers=[routine.markers allObjects];
    for (MMMarker *each in allMarkers) {
        [result addObject:[each convertToDictionary]];
    }
    return result;
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
            ovMarker.iconUrl=[self iconUrlToName: [ovMarkerDic objectForKey:KEY_OVMARKER_ICON_URL]];
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
        ovMarker.iconUrl=[self iconUrlToName:[ovMarkerDic objectForKey:KEY_OVMARKER_ICON_URL]];
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
            [self doSyncMarker:routine block:^(NSError *error){
                if(!error){
                    [MMRoutine removeRoutine:routine];
                }
            }];
        }
    }
}


+(NSString *)iconUrlToName:(NSString *)url{
    NSString *trimUrl=[url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *strArray=[trimUrl componentsSeparatedByString:@"/"];
    NSString *result= [strArray lastObject];
    if(result){
        return result;
    }else{
        return @"default_default.png";
    }
}



@end
