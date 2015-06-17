//
//  MMSearchdeMarker.m
//  MyMapBox
//
//  Created by bizappman on 6/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMSearchdeMarker.h"
#import "MMMarker+Dao.h"

@interface MMSearchdeMarker()

@property (nonatomic, strong,readwrite) NSString * uuid;

@end

@implementation MMSearchdeMarker

-(instancetype)initWithUUID:(NSString *)uuid withLat:(NSNumber *)lat withLng:(NSNumber *)lng{
    self =[super init];
    if (self) {
        self.uuid=uuid;
        self.lat=lat;
        self.lng=lng;
        self.iconUrl=@"event_default.png";
    }
    return self;
}

-(NSArray *)imageUrlsArray{
    return self.imgUrls;
}

-(NSString *)subDescription{
     return [NSString stringWithFormat:@"%@ %u",[MMMarker CategoryNameWithMMMarkerCategory:[self.category integerValue]],[self.slideNum integerValue]];
}

@end
