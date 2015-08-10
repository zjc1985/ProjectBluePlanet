//
//  GooglePlaceManager.h
//  MyMapBox
//
//  Created by bizappman on 7/20/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GooglePlaceDetail.h"

@interface GooglePlaceManager : NSObject

+(void)autoQueryComplete:(NSString *)input withBlock:(void(^)(NSError *error,NSArray *autoQueryResultArray))block;

+(void)details:(NSString *)placeId withBlock:(void(^)(NSError *error,GooglePlaceDetail *placeDetail))block;

@end
