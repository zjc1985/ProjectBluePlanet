//
//  MMMarker+CoreDataProperties.h
//  MyMapBox
//
//  Created by bizappman on 15/10/22.
//  Copyright © 2015年 yufu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MMMarker.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMMarker (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *category;
@property (nullable, nonatomic, retain) NSString *iconUrl;
@property (nullable, nonatomic, retain) NSString *imgUrls;
@property (nullable, nonatomic, retain) NSNumber *isDelete;
@property (nullable, nonatomic, retain) NSNumber *isSync;
@property (nullable, nonatomic, retain) NSNumber *lat;
@property (nullable, nonatomic, retain) NSNumber *lng;
@property (nullable, nonatomic, retain) NSString *mycomment;
@property (nullable, nonatomic, retain) NSNumber *offsetX;
@property (nullable, nonatomic, retain) NSNumber *offsetY;
@property (nullable, nonatomic, retain) NSNumber *slideNum;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *updateTimestamp;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) MMRoutine *belongRoutine;
@property (nullable, nonatomic, retain) NSSet<LocalImageUrl *> *localImages;
@property (nullable, nonatomic, retain) MMMarker *parentMarker;
@property (nullable, nonatomic, retain) NSSet<MMMarker *> *subMarkers;

@end

@interface MMMarker (CoreDataGeneratedAccessors)

- (void)addLocalImagesObject:(LocalImageUrl *)value;
- (void)removeLocalImagesObject:(LocalImageUrl *)value;
- (void)addLocalImages:(NSSet<LocalImageUrl *> *)values;
- (void)removeLocalImages:(NSSet<LocalImageUrl *> *)values;

- (void)addSubMarkersObject:(MMMarker *)value;
- (void)removeSubMarkersObject:(MMMarker *)value;
- (void)addSubMarkers:(NSSet<MMMarker *> *)values;
- (void)removeSubMarkers:(NSSet<MMMarker *> *)values;

@end

NS_ASSUME_NONNULL_END
