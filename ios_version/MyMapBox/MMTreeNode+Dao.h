//
//  MMTreeNode+Dao.h
//  MyMapBox
//
//  Created by bizappman on 15/10/9.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "MMTreeNode.h"

@interface MMTreeNode (Dao)

+(MMTreeNode *)createNodeWithParentNode:(MMTreeNode *)parentNode withMarkerId:(NSString *)markerId;

+(MMTreeNode *)createNodeWithUUID:(NSString *)uuid withParentNode:(MMTreeNode *)parentNode withMarkerId:(NSString *)markerId;

+(MMTreeNode *)queryMMTreeNodeWithUUID:(NSString *)uuid;

+(void)removeTreeNode:(MMTreeNode *)treeNode;



//return subTreeNodes whose isDelete=No
-(NSArray *)allSubTreeNodes;

-(void)markDelete;

@end
