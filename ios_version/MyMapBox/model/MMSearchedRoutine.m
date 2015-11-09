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

#pragma mark - Routine protocal
-(NSArray *)allMarks{
    return [self.markers allObjects];
}

-(NSArray *)allOvMarks{
    return [self.ovMarkers allObjects];
}

-(NSArray *)headMarkers{
    NSMutableArray *result=[[NSMutableArray alloc]init];
    
    for (MMSearchdeMarker *marker in [self allMarks]) {
        if (!marker.parentMarkerUuid) {
            [result addObject:marker];
        }
    }
    return result;
}

-(NSUInteger)maxSlideNum{
    NSAssert(false, @"MMSearchRoutine shouldn't call maxSlideNum");
    return 0;
}

-(void)updateLocation{
    
}

-(double)minLatInMarkers{
    MMSearchdeMarker *first=[[self.markers allObjects] firstObject];
    double minLat=[first.lat doubleValue];
    
    for (MMSearchdeMarker *each in self.markers) {
        if([each.lat doubleValue]<minLat){
            minLat=[each.lat doubleValue];
        }
    }
    
    return minLat;
}



-(double)minLngInMarkers{
    MMSearchdeMarker *first=[[self.markers allObjects] firstObject];
    double minLng=[first.lng doubleValue];
    for (MMSearchdeMarker *each in self.markers) {
        if([each.lng doubleValue]<minLng){
            minLng=[each.lng doubleValue];
        }
    }
    return minLng;
}

-(double)maxLatInMarkers{
    MMSearchdeMarker *first=[[self.markers allObjects] firstObject];
    double maxLat=[first.lat doubleValue];
    for (MMSearchdeMarker *each in self.markers) {
        if([each.lat doubleValue]>maxLat){
            maxLat=[each.lat doubleValue];
        }
    }
    return maxLat;
}

-(double)maxLngInMarkers{
    MMSearchdeMarker *first=[[self.markers allObjects] firstObject];
    double maxLng=[first.lng doubleValue];
    for (MMSearchdeMarker *each in self.markers) {
        if([each.lng doubleValue]>maxLng){
            maxLng=[each.lng doubleValue];
        }
    }
    return maxLng;
}


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


-(NSSet *)markers{
    return self.routineMarkers;
}

-(NSSet *)ovMarkers{
    return self.routineOvMarkers;
}


@end
