//
//  MMRoutine.m
//  MyMapBox
//
//  Created by yufu on 15/4/19.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "MMRoutine.h"
#import "Math.h"

@implementation MMRoutine

#pragma getters and setters
-(NSMutableArray*)ovMarkers{
    if(!_ovMarkers){
        _ovMarkers=[[NSMutableArray alloc]init];
    }
    return _ovMarkers;
}

-(NSMutableArray *)markers{
    if(!_markers){
        _markers=[[NSMutableArray alloc]init];
    }
    return _markers;
}

#pragma interface method

-(void)addMarker:(MMMarker *)marker{
    [self.markers addObject:marker];
    [self updateLocation];
}

-(void)updateLocation{
    NSMutableArray *latArray=[[NSMutableArray alloc]init];
    NSMutableArray *lngArray=[[NSMutableArray alloc]init];
    
    for (MMMarker *eachMarker in self.markers) {
        [latArray addObject:[NSNumber numberWithDouble:eachMarker.lat]];
        [lngArray addObject:[NSNumber numberWithDouble:eachMarker.lng]];
    }
    
    self.lat=[self refineAverage:latArray];
    self.lng=[self refineAverage:lngArray];
}

-(double)refineAverage:(NSMutableArray*)numbers{
    NSMutableArray *refineArray=[[NSMutableArray alloc]init];
    double e=[self average:numbers];
    double d=[self sDeviation:numbers];
    
    for (NSNumber *number in numbers) {
        if (fabs([number doubleValue]-e)-e<=d) {
            [refineArray addObject:number];
        }
    }
    
    return [self average:refineArray];
}

-(double)average:(NSMutableArray *)numbers{
    double sum=0;
    double result=0;

    for (NSNumber *number in numbers) {
        sum=sum+[number doubleValue];
    }
    
    result=sum/[numbers count];
    return result;
}

-(double)sDeviation:(NSMutableArray *)numbers{
    if([numbers count]==0){
        return 0;
    }
    double e=[self average:numbers];
    double sum=0;
    for (NSNumber *number in numbers) {
        sum=sum+([number doubleValue]-e)*([number doubleValue]-e);
    }
    return pow(sum/[numbers count], 0.5);
}


@end
