//
//  MapMarker.h
//  MyMapBox
//
//  Created by yufu on 15/4/19.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMMarker : NSObject

@property(nonatomic,strong)NSString *id;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *myComment;
@property(nonatomic,assign)NSInteger *slideNum;
@property(nonatomic,assign)NSInteger *category;

@property(nonatomic,assign)double lat;
@property(nonatomic,assign)double lng;

@end
