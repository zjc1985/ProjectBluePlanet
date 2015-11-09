//
//  MMSearchdeMarker.m
//  MyMapBox
//
//  Created by bizappman on 6/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMSearchdeMarker.h"
#import "MMMarker+Dao.h"
#import "MMSearchedRoutine.h"

@interface MMSearchdeMarker()

@property (nonatomic, strong,readwrite) NSString * uuid;
@property (nonatomic,strong,readwrite) NSString *parentMarkerUuid;

@end

@implementation MMSearchdeMarker

-(instancetype)initWithUUID:(NSString *)uuid withParentUuid:(NSString *)parentMarkerUuid withLat:(NSNumber *)lat withLng:(NSNumber *)lng{
    self =[super init];
    if (self) {
        self.uuid=uuid;
        self.parentMarkerUuid=parentMarkerUuid;
        self.lat=lat;
        self.lng=lng;
        self.iconUrl=@"event_default.png";
    }
    return self;
}

-(NSArray *)allSubMarkers{
    MMSearchedRoutine *belongRoutine= self.belongRoutine;
    NSMutableArray *result=[[NSMutableArray alloc]init];
    for (MMSearchdeMarker *marker in [belongRoutine allMarks]) {
        if ([marker.parentMarkerUuid isEqualToString:self.uuid]) {
            [result addObject:marker];
        }
    }
    return result;
}

-(NSArray *)imageUrlsArrayIncludeSubMarkers{
    NSMutableArray *results=[[NSMutableArray alloc]initWithArray:[self imageUrlsArray]];
    
    for (MMMarker *marker in [self allSubMarkers]) {
        [results addObjectsFromArray:[marker imageUrlsArrayIncludeSubMarkers]];
    }
    
    return results;
}


-(NSArray *)imageUrlsArray{
    return self.imgUrls;
}

-(NSString *)subDescription{
     return [NSString stringWithFormat:@"%@ %u",[MMMarker CategoryNameWithMMMarkerCategory:[self.category integerValue]],[self.slideNum integerValue]];
}

-(void)copySelfTo:(MMMarker *)parentMarker inRoutine:(MMRoutine *)routine{
    MMRoutine *belongRoutine;
    if (parentMarker) {
        belongRoutine=parentMarker.belongRoutine;
    }else{
        belongRoutine=routine;
    }
    MMMarker *copyMarker=[MMMarker createMMMarkerInRoutine:belongRoutine
                                                   withLat:[self.lat doubleValue]
                                                   withLng:[self.lng doubleValue] withParentMarker:parentMarker];
    copyMarker.title=self.title;
    copyMarker.mycomment=self.mycomment;
    copyMarker.iconUrl=self.iconUrl;
    copyMarker.slideNum=self.slideNum;

    for (NSString *url in self.imgUrls) {
        [copyMarker addImageUrl:url];
    }
    
    for (MMSearchdeMarker *eachSubMarker in [self allSubMarkers]) {
        [eachSubMarker copySelfTo:copyMarker inRoutine:belongRoutine];
    }
}

@end
