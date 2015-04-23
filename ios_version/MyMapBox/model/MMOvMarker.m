//
//  MMOvMarker.m
//  MyMapBox
//
//  Created by bizappman on 4/23/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMOvMarker.h"

@implementation MMOvMarker


-(instancetype)initWithRoutineId:(NSString *)routineId
{
    self=[super init];
    
    if(self){
        self.category=CategoryOverview;
        self.routineId=routineId;
        
    }
    
    return self;
}

@end
