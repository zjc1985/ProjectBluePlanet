//
//  MMMarkerManager.m
//  MyMapBox
//
//  Created by bizappman on 4/20/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMMarkerManager.h"

@interface MMMarkerManager()



@end

@implementation MMMarkerManager

#pragma mark - getters and setters
-(NSMutableArray *)modelRoutines{
    if(!_modelRoutines){
        _modelRoutines=[[NSMutableArray alloc]init];
    }
    return _modelRoutines;
}

#pragma mark - interface method

-(void)deleteMMRoutine:(MMRoutine *)routine{
    [self.modelRoutines removeObject:routine];
}

-(MMRoutine *)fetchRoutineById:(NSString *)id{
    for(MMRoutine *routine in self.modelRoutines){
        if([routine.id isEqualToString:id]){
            return routine;
        }
    }
    return nil;
}

-(MMRoutine *)createMMRoutineWithLat:(double)lat withLng:(double)lng{
    MMRoutine *routine=[[MMRoutine alloc]initWithLat:lat withlng:lng];
    
    //create ovmarker
    [routine addDefaultOvMarker];
    
    [self.modelRoutines addObject:routine];
    return routine;
}

@end
