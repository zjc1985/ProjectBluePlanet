//
//  MMMarkerIconInfo.m
//  MyMapBox
//
//  Created by bizappman on 6/2/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMMarkerIconInfo.h"

@implementation MMMarkerIconInfo

+(MMMarkerIconInfo *)initWithIconName:(NSString *)iconName withCategory:(MMMarkerCategory) category {
    MMMarkerIconInfo *iconInfo=[[MMMarkerIconInfo alloc]init];
    iconInfo.iconName=iconName;
    iconInfo.category=category;
    return iconInfo;
}

+(MMMarkerCategory)findCategoryWithIconName:(NSString *)iconName{
    MMMarkerCategory result=CategoryInfo;
    
    for (MMMarkerIconInfo *iconInfo in [self allMMMarkerIconInfo]) {
        if ([iconInfo.iconName isEqualToString:iconName]) {
            result=iconInfo.category;
            break;
        }
    }
    return result;
}

+(NSArray *)allMMMarkerIconInfo{
    NSMutableArray *result=[NSMutableArray new];
    
    //arrive leave
    [result addObject:[MMMarkerIconInfo initWithIconName:@"al_default.png" withCategory:CategoryArrivalLeave]];
    [result addObject:[MMMarkerIconInfo initWithIconName:@"al_1.png" withCategory:CategoryArrivalLeave]];
    
    //sight
    [result addObject:[MMMarkerIconInfo initWithIconName:@"default_default.png" withCategory:CategorySight]];
    [result addObject:[MMMarkerIconInfo initWithIconName:@"sight_default.png" withCategory:CategorySight]];
    [result addObject:[MMMarkerIconInfo initWithIconName:@"sight_1.png" withCategory:CategorySight]];
    [result addObject:[MMMarkerIconInfo initWithIconName:@"sight_2.png" withCategory:CategorySight]];
    
    //info event
    [result addObject:[MMMarkerIconInfo initWithIconName:@"event_default.png" withCategory:CategoryInfo]];
    [result addObject:[MMMarkerIconInfo initWithIconName:@"event_1.png" withCategory:CategoryInfo]];
    [result addObject:[MMMarkerIconInfo initWithIconName:@"event_2.png" withCategory:CategoryInfo]];
    
    //food
    [result addObject:[MMMarkerIconInfo initWithIconName:@"food_default.png" withCategory:CategoryFood]];
    [result addObject:[MMMarkerIconInfo initWithIconName:@"food_1.png" withCategory:CategoryFood]];

    //hotel
    [result addObject:[MMMarkerIconInfo initWithIconName:@"hotel_default.png" withCategory:CategoryHotel]];
    [result addObject:[MMMarkerIconInfo initWithIconName:@"hotel_1.png" withCategory:CategoryHotel]];

    return result;
}

@end
