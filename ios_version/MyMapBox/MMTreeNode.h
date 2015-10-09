//
//  MMTreeNode.h
//  MyMapBox
//
//  Created by bizappman on 15/10/9.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMRoutine, MMTreeNode;

@interface MMTreeNode : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * updateTimestamp;
@property (nonatomic, retain) NSString * markerUuid;
@property (nonatomic, retain) NSNumber * isSync;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) MMTreeNode *parentNode;
@property (nonatomic, retain) NSSet *subNodes;
@property (nonatomic, retain) MMRoutine *belongRoutine;
@end

@interface MMTreeNode (CoreDataGeneratedAccessors)

- (void)addSubNodesObject:(MMTreeNode *)value;
- (void)removeSubNodesObject:(MMTreeNode *)value;
- (void)addSubNodes:(NSSet *)values;
- (void)removeSubNodes:(NSSet *)values;

@end
