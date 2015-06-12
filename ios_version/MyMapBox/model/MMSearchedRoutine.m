//
//  MMSearchedRoutine.m
//  MyMapBox
//
//  Created by bizappman on 6/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMSearchedRoutine.h"
#import "MMSearchdeMarker.h"

@interface MMSearchedRoutine()

@property (nonatomic, strong,readwrite) NSString * uuid;

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


#pragma mark getter and setter

-(NSMutableSet *)markers{
    if(!_markers){
        _markers=[[NSMutableSet alloc]init];
    }
    return _markers;
}

-(NSMutableSet *)ovMarkers{
    if(!_ovMarkers){
        _ovMarkers=[[NSMutableSet alloc]init];
    }
    return _ovMarkers;
}


@end
