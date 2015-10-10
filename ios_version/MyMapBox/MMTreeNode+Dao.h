//
//  MMTreeNode+Dao.h
//  MyMapBox
//
//  Created by bizappman on 15/10/9.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "MMTreeNode.h"
#import "CommonUtil.h"
@interface MMTreeNode (Dao)<TreeNode>

+(MMTreeNode *)createNodeWithParentNode:(MMTreeNode *)parentNode withMarkerId:(NSString *)markerId belongRoutine:(MMRoutine *)routine;

+(MMTreeNode *)createNodeWithUUID:(NSString *)uuid withParentNode:(MMTreeNode *)parentNode withMarkerId:(NSString *)markerId belongRoutine:(MMRoutine *)routine;

+(MMTreeNode *)queryMMTreeNodeWithUUID:(NSString *)uuid;

+(void)removeTreeNode:(MMTreeNode *)treeNode;



//return subTreeNodes whose isDelete=No
-(NSArray *)allSubTreeNodes;

-(void)markDelete;

@end
