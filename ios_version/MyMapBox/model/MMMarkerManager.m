//
//  MMMarkerManager.m
//  MyMapBox
//
//  Created by bizappman on 4/20/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMMarkerManager.h"

@interface MMMarkerManager()

@property(nonatomic,strong)NSMutableArray *modelRoutines;

@end

@implementation MMMarkerManager

#pragma getters and setters
-(NSMutableArray *)modelRoutines{
    if(!_modelRoutines){
        _modelRoutines=[[NSMutableArray alloc]init];
    }
    return _modelRoutines;
}

#pragma interface method

-(MMRoutine *)createMMRoutine{
    MMRoutine *routine=[[MMRoutine alloc]init];
    
    //create ovmarker
    MMMarker *ovMarker=[[MMMarker alloc]init];
    ovMarker.category=CategoryOverview;
    
    [self.modelRoutines addObject:routine];
    return routine;
}

@end
