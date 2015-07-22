//
//  GooglePlaceDetail.h
//  MyMapBox
//
//  Created by bizappman on 7/21/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GooglePlaceDetail : NSObject

@property(nonatomic,strong,readonly)NSString *address;
@property(nonatomic,strong,readonly)NSString *placeid;
@property(nonatomic,strong,readonly)NSString *name;
@property(nonatomic,strong,readonly)NSNumber *lat;
@property(nonatomic,strong,readonly)NSNumber *lng;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
