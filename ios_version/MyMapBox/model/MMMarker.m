//
//  MMMarker.m
//  MyMapBox
//
//  Created by bizappman on 4/23/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMMarker.h"

@implementation MMMarker

-(instancetype)initWithRoutineId:(NSString *)routineId
{
    self=[super init];
    
    if(self){
        self.category=CategoryInfo;
        self.routineId=routineId;
    }
    
    return self;
}

@end
