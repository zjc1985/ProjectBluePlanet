//
//  MMSearchedOvMarker.h
//  MyMapBox
//
//  Created by bizappman on 6/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMSearchedRoutine;

@interface MMSearchedOvMarker : NSObject

@property (nonatomic, strong,readonly) NSString * uuid;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * offsetY;
@property (nonatomic, strong) NSNumber * offsetX;
@property (nonatomic, strong) NSString * iconUrl;
@property (nonatomic, strong) NSNumber * category;
@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * lng;

-(instancetype)initWithUUID:(NSString *)uuid withOffsetX:(NSNumber *)offsetX withOffsetY:(NSNumber *)offsetY;

@end
