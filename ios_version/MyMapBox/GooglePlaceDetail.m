//
//  GooglePlaceDetail.m
//  MyMapBox
//
//  Created by bizappman on 7/21/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "GooglePlaceDetail.h"

@interface GooglePlaceDetail()

@property (nonatomic, strong) NSDictionary * dictionary;

@end

@implementation GooglePlaceDetail

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self=[super init];
    if(self){
        self.dictionary=dictionary;
    }
    return self;
}

-(NSString *)address{
    return [self.dictionary objectForKey:@"formatted_address"];
}

-(NSString *)placeid{
    return [self.dictionary objectForKey:@"place_id"];
}

-(NSString *)name{
    return [self.dictionary objectForKey:@"name"];
}

-(NSNumber *)lat{
    NSDictionary *geometryDic=[self.dictionary objectForKey:@"geometry"];
    NSDictionary *locationDic=[geometryDic objectForKey:@"location"];
    NSNumber *lat=[locationDic objectForKey:@"lat"];
    return lat;
}

-(NSNumber *)lng{
    NSDictionary *geometryDic=[self.dictionary objectForKey:@"geometry"];
    NSDictionary *locationDic=[geometryDic objectForKey:@"location"];
    NSNumber *lng=[locationDic objectForKey:@"lng"];
    return lng;
}



@end
