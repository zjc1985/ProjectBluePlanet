//
//  MMMarkerIconInfo.h
//  MyMapBox
//
//  Created by bizappman on 6/2/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMMarker+Dao.h"

@interface MMMarkerIconInfo : NSObject

@property(nonatomic,strong)NSString *iconName;
@property(nonatomic)MMMarkerCategory category;

+(NSArray *)allMMMarkerIconInfo;

+(MMMarkerCategory)findCategoryWithIconName:(NSString *)iconName;

@end
