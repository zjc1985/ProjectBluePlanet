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

+(MMOvMarker *)createMMOvMarkerInRoutine:(MMRoutine *)routine{
    MMOvMarker *ovMarker=[NSEntityDescription insertNewObjectForEntityForName:@"MMOvMarker" inManagedObjectContext:[CommonUtil getContext]];
    NSUUID *uuid=[[NSUUID alloc]init];
    ovMarker.uuid=[uuid UUIDString];
    ovMarker.belongRoutine=routine;
    ovMarker.iconUrl=@"default_default";
    ovMarker.offsetX=[NSNumber numberWithInt:0];
    ovMarker.offsetX=[NSNumber numberWithInt:0];
    
    ovMarker.isSync=[NSNumber numberWithBool:NO];
    ovMarker.isDelete=[NSNumber numberWithBool:NO];
    
    return ovMarker;
}

-(void)markDelete{
    self.isDelete=[NSNumber numberWithBool:YES];
}

@end
