//
//  MMOvMarker+Dao.m
//  MyMapBox
//
//  Created by bizappman on 5/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMOvMarker+Dao.h"
#import "CommonUtil.h"

@implementation MMOvMarker (Dao)

+(MMOvMarker *)queryMMOvMarkerWithUUID:(NSString *)uuid{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"MMOvMarker"
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

+(MMOvMarker *)createMMOvMarkerInRoutine:(MMRoutine *)routine withUUID:(NSString *)uuid{
    MMOvMarker *result=[self queryMMOvMarkerWithUUID:uuid];
    if(result){
        return result;
    }else{
        result=[NSEntityDescription insertNewObjectForEntityForName:@"MMOvMarker" inManagedObjectContext:[CommonUtil getContext]];
        result.uuid=uuid;
        result.belongRoutine=routine;
        result.iconUrl=@"default_default";
        result.offsetX=[NSNumber numberWithInt:0];
        result.offsetX=[NSNumber numberWithInt:0];
        
        result.isSync=[NSNumber numberWithBool:NO];
        result.isDelete=[NSNumber numberWithBool:NO];
        return result;
    }
}

+(MMOvMarker *)createMMOvMarkerInRoutine:(MMRoutine *)routine{
    NSUUID *uuid=[[NSUUID alloc]init];
    return [self createMMOvMarkerInRoutine:routine withUUID:[uuid UUIDString]];
}

-(void)markDelete{
    self.isDelete=[NSNumber numberWithBool:YES];
}

@end
