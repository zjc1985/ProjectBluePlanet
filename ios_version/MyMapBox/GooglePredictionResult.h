//
//  GAutoQueryResult.h
//  MyMapBox
//
//  Created by bizappman on 7/21/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GooglePredictionResult : NSObject

@property(nonatomic,strong,readonly)NSString *description;
@property(nonatomic,strong,readonly)NSString *placeId;

-(instancetype)initWithDictionary: (NSDictionary*) dictionary;
@end
