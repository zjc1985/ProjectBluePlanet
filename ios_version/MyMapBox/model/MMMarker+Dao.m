//
//  MMMarker+Dao.m
//  MyMapBox
//
//  Created by bizappman on 5/11/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMMarker+Dao.h"
#import "CommonUtil.h"

@implementation MMMarker (Dao)

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng{
    MMMarker *marker=[NSEntityDescription insertNewObjectForEntityForName:@"MMMarker" inManagedObjectContext:[CommonUtil getContext]];
    
    NSUUID *uuid=[[NSUUID alloc]init];
    marker.uuid=[uuid UUIDString];
    
    marker.belongRoutine=routine;
    marker.title=@"New Marker";
    marker.mycomment=@"";
    marker.category=[NSNumber numberWithInt:CategoryInfo];
    marker.iconUrl=@"default_default";
    
    marker.lat=[NSNumber numberWithDouble:lat];
    marker.lng=[NSNumber numberWithDouble:lng];
    
    marker.isSync=[NSNumber numberWithBool:NO];
    marker.isDelete=[NSNumber numberWithBool:NO];
    marker.offsetX=[NSNumber numberWithDouble:0];
    marker.offsetY=[NSNumber numberWithDouble:0];
    marker.slideNum=[NSNumber numberWithInt:1];
    
    return marker;
}

+(void)removeMMMarker:(MMMarker *)marker{
    [[CommonUtil getContext] deleteObject:marker];
}

-(void)markDelete{
    self.isDelete=[NSNumber numberWithBool:YES];
}


@end
