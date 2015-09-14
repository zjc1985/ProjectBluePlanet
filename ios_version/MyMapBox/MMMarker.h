//
//  MMMarker.h
//  MyMapBox
//
//  Created by bizappman on 9/14/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LocalImageUrl, MMRoutine;

@interface MMMarker : NSManagedObject

@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSString * imgUrls;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSNumber * isSync;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * mycomment;
@property (nonatomic, retain) NSNumber * offsetX;
@property (nonatomic, retain) NSNumber * offsetY;
@property (nonatomic, retain) NSNumber * slideNum;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * updateTimestamp;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) MMRoutine *belongRoutine;
@property (nonatomic, retain) NSSet *localImages;
@end

@interface MMMarker (CoreDataGeneratedAccessors)

- (void)addLocalImagesObject:(LocalImageUrl *)value;
- (void)removeLocalImagesObject:(LocalImageUrl *)value;
- (void)addLocalImages:(NSSet *)values;
- (void)removeLocalImages:(NSSet *)values;

@end
