//
//  MMSearchedRoutine.m
//  MyMapBox
//
//  Created by bizappman on 6/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMSearchedRoutine.h"
#import "MMSearchedOvMarker.h"
#import "MMSearchdeMarker.h"

@interface MMSearchedRoutine()

@property (nonatomic, strong,readwrite) NSString * uuid;

@property (nonatomic, strong) NSMutableSet *routineMarkers;
@property (nonatomic,strong) NSMutableSet *routineOvMarkers;

@end



@implementation MMSearchedRoutine

#pragma mark public method
-(instancetype)initWithUUID:(NSString *)uuid withLat:(NSNumber *)lat withLng:(NSNumber *)lng{
    self =[super init];
    if (self) {
        self.uuid=uuid;
        self.lat=lat;
        self.lng=lng;
        self.isLoad=[NSNumber numberWithBool:NO];
    }
    return self;
}

-(void)addOvMarkersObject:(MMSearchedOvMarker *)value{
    [self.routineOvMarkers addObject:value];
    value.belongRoutine=self;
}

-(void)addMarkersObject:(MMSearchdeMarker *)value{
    [self.routineMarkers addObject:value];
    value.belongRoutine=self;
}

#pragma mark getter and setter
-(NSMutableSet *)routineOvMarkers{
    if(!_routineOvMarkers){
        _routineOvMarkers=[[NSMutableSet alloc]init];
    }
    return _routineOvMarkers;
}

-(NSMutableSet *)routineMarkers{
    if(!_routineMarkers){
        _routineMarkers=[[NSMutableSet alloc] init];
    }
    return _routineMarkers;
}


-(NSMutableSet *)markers{
    return self.routineMarkers;
}

-(NSMutableSet *)ovMarkers{
    return self.routineOvMarkers;
}


@end
