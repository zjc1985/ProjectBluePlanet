//
//  MMTreeNode+Dao.m
//  MyMapBox
//
//  Created by bizappman on 15/10/9.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "MMTreeNode+Dao.h"
#import "CommonUtil.h"

#define TREE_NODE_ENTITY_NAME @"MMTreeNode"
@implementation MMTreeNode (Dao)

+(MMTreeNode *)createNodeWithParentNode:(MMTreeNode *)parentNode withMarkerId:(NSString *)markerId{
    NSUUID *uuid=[[NSUUID alloc]init];
    return [self createNodeWithUUID:[uuid UUIDString] withParentNode:parentNode withMarkerId:markerId];
}

+(MMTreeNode *)createNodeWithUUID:(NSString *)uuid withParentNode:(MMTreeNode *)parentNode withMarkerId:(NSString *)markerId{
    MMTreeNode *result=[self queryMMTreeNodeWithUUID:uuid];
    if(!result){
        result=[NSEntityDescription insertNewObjectForEntityForName:TREE_NODE_ENTITY_NAME inManagedObjectContext:[CommonUtil getContext]];
        
        result.uuid=uuid;
        result.parentNode=parentNode;
        result.markerUuid=markerId;
        result.isSync=[NSNumber numberWithBool:NO];
        result.isDelete=[NSNumber numberWithBool:NO];
    }
    return result;
}

+(MMTreeNode *)queryMMTreeNodeWithUUID:(NSString *)uuid{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:TREE_NODE_ENTITY_NAME
                                       inManagedObjectContext:[CommonUtil getContext]];
    request.entity=e;
    //NSSortDescriptor *sd=[NSSortDescriptor sortDescriptorWithKey:@"markerId" ascending:YES];
    //request.sortDescriptors=@[sd];
    request.predicate= [NSPredicate predicateWithFormat:@"uuid == %@",uuid];
    NSError *error;
    NSArray *result=[[CommonUtil getContext] executeFetchRequest:request error:&error];
    if(!result){
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    return result.firstObject;
}

+(void)removeTreeNode:(MMTreeNode *)treeNode{
    [[CommonUtil getContext]deleteObject:treeNode];
}

-(NSArray *)allSubTreeNodes{
    NSMutableArray *results=[[NSMutableArray alloc]init];
    
    for (MMTreeNode *eachSubNode in [self.subNodes allObjects]) {
        if(![eachSubNode.isDelete boolValue]){
            [results addObject:eachSubNode];
        }
    }
    
    return results;
}

-(void)markDelete{
    self.isDelete=[NSNumber numberWithBool:YES];
    NSNumber *timestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
    self.updateTimestamp=timestamp;
    
    for (MMTreeNode *eachSubNode in self.subNodes) {
        [eachSubNode markDelete];
    }
}

-(NSString *)description{
    NSString *info=[NSString stringWithFormat:@"%@ node's parent node is %@. It has %@ subNodes",self.uuid,self.parentNode.uuid,@([self.subNodes allObjects].count)];
    
    for (MMTreeNode *node in self.subNodes) {
        info=[info stringByAppendingString:[NSString stringWithFormat:@" %@",node.uuid]];
    }
    return info;
}

@end
