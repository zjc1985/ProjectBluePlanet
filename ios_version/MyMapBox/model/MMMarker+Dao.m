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

+(MMMarker *)queryMMMarkerWithUUID:(NSString *)uuid{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"MMMarker"
                                       inManagedObjectContext:[CommonUtil getContext]];
    request.entity=e;
    NSSortDescriptor *sd=[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors=@[sd];
    request.predicate= [NSPredicate predicateWithFormat:@"uuid == %@",uuid];
    NSError *error;
    NSArray *result=[[CommonUtil getContext] executeFetchRequest:request error:&error];
    if(!result){
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    return result.firstObject;
}

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng withUUID:(NSString *)uuid{
    MMMarker *result=[self queryMMMarkerWithUUID:uuid];
    if(result){
        return result;
    }else{
        result=[NSEntityDescription insertNewObjectForEntityForName:@"MMMarker" inManagedObjectContext:[CommonUtil getContext]];
        
        result.uuid=uuid;
        result.belongRoutine=routine;
        result.title=@"New Marker";
        result.mycomment=@"";
        result.category=[NSNumber numberWithInt:CategoryInfo];
        result.iconUrl=@"default_default";
        
        result.lat=[NSNumber numberWithDouble:lat];
        result.lng=[NSNumber numberWithDouble:lng];
        
        result.isSync=[NSNumber numberWithBool:NO];
        result.isDelete=[NSNumber numberWithBool:NO];
        result.offsetX=[NSNumber numberWithDouble:0];
        result.offsetY=[NSNumber numberWithDouble:0];
        result.slideNum=[NSNumber numberWithInt:1];
        
        return result;
    }

}

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng{
    NSUUID *uuid=[[NSUUID alloc]init];
    return [self createMMMarkerInRoutine:routine
                                 withLat:lat
                                 withLng:lng
                                withUUID:[uuid UUIDString]];
}

+(void)removeMMMarker:(MMMarker *)marker{
    [[CommonUtil getContext] deleteObject:marker];
}

-(void)markDelete{
    self.isDelete=[NSNumber numberWithBool:YES];
}


@end
