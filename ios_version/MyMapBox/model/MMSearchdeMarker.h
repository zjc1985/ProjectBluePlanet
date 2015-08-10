//
//  MMSearchdeMarker.h
//  MyMapBox
//
//  Created by bizappman on 6/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonUtil.h"

@class MMSearchedRoutine;

@interface MMSearchdeMarker : NSObject<Marker>

@property (nonatomic, strong,readonly) NSString * uuid;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * mycomment;
@property (nonatomic, strong) NSString * iconUrl;
@property (nonatomic, strong) NSNumber * slideNum;
@property (nonatomic, strong) NSNumber * category;
@property (nonatomic, strong) NSNumber * offsetX;
@property (nonatomic, strong) NSNumber * offsetY;
@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * lng;
@property (nonatomic, strong) NSArray  * imgUrls;

@property (nonatomic, weak) MMSearchedRoutine *belongRoutine;

-(instancetype)initWithUUID:(NSString *)uuid withLat:(NSNumber *)lat withLng:(NSNumber *)lng;

@end
