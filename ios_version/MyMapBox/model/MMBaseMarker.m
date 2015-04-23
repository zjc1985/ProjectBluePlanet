//
//  MapMarker.m
//  MyMapBox
//
//  Created by yufu on 15/4/19.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "MMBaseMarker.h"

@implementation MMBaseMarker


-(instancetype)init
{
    self=[super init];
    if(self){
        self.id=[[NSUUID UUID] UUIDString];
        self.title=@"One Location";
        self.myComment=@"";
        self.slideNum=1;
        self.category=2;
        self.lat=0;
        self.lng=0;
        self.offsetX=0;
        self.offsetX=0;
        self.iconUrl=@"default_default.png";
        self.isDelete=NO;
    }
    
    return self;
}

@end

