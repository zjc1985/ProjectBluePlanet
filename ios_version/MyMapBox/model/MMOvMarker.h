//
//  MMOvMarker.h
//  MyMapBox
//
//  Created by bizappman on 5/11/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMRoutine;

@interface MMOvMarker : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * updateTimestamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * offsetY;
@property (nonatomic, retain) NSNumber * offsetX;
@property (nonatomic, retain) NSNumber * isSync;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) MMRoutine *belongRoutine;

@end
