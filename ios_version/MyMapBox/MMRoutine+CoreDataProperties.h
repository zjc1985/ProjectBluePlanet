//
//  MMRoutine+CoreDataProperties.h
//  MyMapBox
//
//  Created by bizappman on 15/10/22.
//  Copyright © 2015年 yufu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MMRoutine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMRoutine (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *cachProgress;
@property (nullable, nonatomic, retain) NSNumber *isDelete;
@property (nullable, nonatomic, retain) NSNumber *isSync;
@property (nullable, nonatomic, retain) NSNumber *lat;
@property (nullable, nonatomic, retain) NSNumber *lng;
@property (nullable, nonatomic, retain) NSString *mycomment;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *updateTimestamp;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSSet<MMMarker *> *markers;
@property (nullable, nonatomic, retain) NSSet<MMOvMarker *> *ovMarkers;

@end

@interface MMRoutine (CoreDataGeneratedAccessors)

- (void)addMarkersObject:(MMMarker *)value;
- (void)removeMarkersObject:(MMMarker *)value;
- (void)addMarkers:(NSSet<MMMarker *> *)values;
- (void)removeMarkers:(NSSet<MMMarker *> *)values;

- (void)addOvMarkersObject:(MMOvMarker *)value;
- (void)removeOvMarkersObject:(MMOvMarker *)value;
- (void)addOvMarkers:(NSSet<MMOvMarker *> *)values;
- (void)removeOvMarkers:(NSSet<MMOvMarker *> *)values;

@end

NS_ASSUME_NONNULL_END
