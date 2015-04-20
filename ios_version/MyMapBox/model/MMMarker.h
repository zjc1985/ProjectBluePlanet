//
//  MapMarker.h
//  MyMapBox
//
//  Created by yufu on 15/4/19.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CategoryArrivalLeave = 1,
    CategorySight = 2,
    CategoryHotel = 3,
    CategoryFood=4,
    CategoryInfo=5,
    CategoryOverview=6
} MMMarkerCategory;


@interface MMMarker : NSObject

@property(nonatomic,strong)NSString *id;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *myComment;
@property(nonatomic,assign)NSUInteger slideNum;
@property(nonatomic,assign)NSUInteger category;

@property(nonatomic,assign)double lat;
@property(nonatomic,assign)double lng;

@end
