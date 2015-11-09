//
//  NSMutableArray+StackExtension.m
//  MyMapBox
//
//  Created by bizappman on 15/10/27.
//  Copyright © 2015年 yufu. All rights reserved.
//

#import "NSMutableArray+StackExtension.h"

@implementation NSMutableArray (StackExtension)

-(void)push:(id)object{
    [self addObject:object];
}

-(id)pop{
    id lastObject=[self lastObject];
    [self removeLastObject];
    return lastObject;
}

@end
