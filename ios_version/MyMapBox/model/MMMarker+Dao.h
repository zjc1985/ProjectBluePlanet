//
//  MMMarker+Dao.h
//  MyMapBox
//
//  Created by bizappman on 5/11/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMMarker.h"
#import "CommonUtil.h"
#import "MMSearchdeMarker.h"

#define KEY_MARKER_ICON_URL @"iconUrl"
#define KEY_MARKER_UUID @"uuid"
#define KEY_MARKER_CATEGORY @"category"
#define KEY_MARKER_TITLE @"title"
#define KEY_MARKER_SLIDE_NUM @"slideNum"
#define KEY_MARKER_LAT @"lat"
#define KEY_MARKER_LNG @"lng"
#define KEY_MARKER_MYCOMMENT @"mycomment"
#define KEY_MARKER_ADDRESS @"address"
#define KEY_MARKER_OFFSETX @"offsetX"
#define KEY_MARKER_OFFSETY @"offsetY"
#define KEY_MARKER_ROUTINE_ID @"routineId"
#define KEY_MARKER_IS_DELETE @"isDelete"
#define KEY_MARKER_IS_SYNCED @"isSynced"
#define KEY_MARKER_UPDATE_TIME @"updateTime"
#define KEY_MARKER_IMAGE_URLS @"imgUrls"

typedef enum : NSUInteger {
    CategoryArrivalLeave = 1,
    CategorySight = 2,
    CategoryHotel = 3,
    CategoryFood=4,
    CategoryInfo=5,
    CategoryOverview=6
} MMMarkerCategory;

@interface MMMarker (Dao)<Marker>

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng withParentMarker:(MMMarker *)parentMarker;

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng withUUID:(NSString *)uuid withParentMarker:(MMMarker *)parentMarker;

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withSearchMarker:(MMSearchdeMarker *)searchedMarker withParentMarker:(MMMarker *)parentMarker;

+(MMMarker *)queryMMMarkerWithUUID:(NSString *)uuid;

+(void)removeMMMarker:(MMMarker *)marker;

+(NSString *)CategoryNameWithMMMarkerCategory:(MMMarkerCategory)categoryNum;

-(NSArray *)allSubMarkers;

-(void)deleteSelf;

-(NSString *)categoryName;

-(NSString *)subDescription;

-(NSArray *)imageUrlsArray;

-(void)addImageUrl:(NSString *)imgUrl;

-(void)removeImageUrl:(NSString *)imgUrl;

-(NSDictionary *)convertToDictionary;

//if parentNode is nil copy mmarker to given routine root position
-(void)copySelfTo:(MMMarker *)parentNode inRoutine:(MMRoutine *)routine;

@end
