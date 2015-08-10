//
//  MMSearchedOvMarker.m
//  MyMapBox
//
//  Created by bizappman on 6/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMSearchedOvMarker.h"

@interface MMSearchedOvMarker()

@property (nonatomic, strong,readwrite) NSString * uuid;

@end

@implementation MMSearchedOvMarker

-(instancetype)initWithUUID:(NSString *)uuid withOffsetX:(NSNumber *)offsetX withOffsetY:(NSNumber *)offsetY{
    self =[super init];
    if (self) {
        self.uuid=uuid;
        self.offsetX=offsetX;
        self.offsetY=offsetY;
        self.iconUrl=@"event_default.png";
    }
    return self;
}

@end
