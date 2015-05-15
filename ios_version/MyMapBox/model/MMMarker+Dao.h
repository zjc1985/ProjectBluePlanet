//
//  MMMarker+Dao.h
//  MyMapBox
//
//  Created by bizappman on 5/11/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMMarker.h"

typedef enum : NSUInteger {
    CategoryArrivalLeave = 1,
    CategorySight = 2,
    CategoryHotel = 3,
    CategoryFood=4,
    CategoryInfo=5,
    CategoryOverview=6
} MMMarkerCategory;

@interface MMMarker (Dao)

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng;

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng withUUID:(NSString *)uuid;

+(MMMarker *)queryMMMarkerWithUUID:(NSString *)uuid;

+(void)removeMMMarker:(MMMarker *)marker;

-(void)markDelete;

@end
