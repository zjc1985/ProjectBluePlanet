//
//  MMOvMarker+Dao.h
//  MyMapBox
//
//  Created by bizappman on 5/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMOvMarker.h"

#define KEY_OVMARKER_OFFSET_X @"offsetX"
#define KEY_OVMARKER_OFFSET_Y @"offsetY"
#define KEY_OVMARKER_ROUTINE_ID @"routineId"
#define KEY_OVMARKER_IS_DELETE @"isDelete"
#define KEY_OVMARKER_UPDATE_TIME @"updateTime"
#define KEY_OVMARKER_ICON_URL @"iconUrl"
#define KEY_OVMARKER_IS_SYNCED @"isSynced"
#define KEY_OVMARKER_UUID @"uuid"

@interface MMOvMarker (Dao)

+(MMOvMarker *)createMMOvMarkerInRoutine:(MMRoutine *)routine;

+(MMOvMarker *)createMMOvMarkerInRoutine:(MMRoutine *)routine withUUID:(NSString *)uuid;

+(MMOvMarker *)queryMMOvMarkerWithUUID:(NSString *)uuid;

-(void)markDelete;

@end
