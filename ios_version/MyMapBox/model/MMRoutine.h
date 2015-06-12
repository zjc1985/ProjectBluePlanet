//
//  MMRoutine.h
//  MyMapBox
//
//  Created by bizappman on 5/11/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMMarker, MMOvMarker;

@interface MMRoutine : NSManagedObject

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * mycomment;
@property (nonatomic, retain) NSNumber * isSync;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * updateTimestamp;
@property (nonatomic, retain) NSNumber * cachProgress;
@property (nonatomic, retain) NSSet *markers;
@property (nonatomic, retain) NSSet *ovMarkers;
@end

@interface MMRoutine (CoreDataGeneratedAccessors)

- (void)addMarkersObject:(MMMarker *)value;
- (void)removeMarkersObject:(MMMarker *)value;
- (void)addMarkers:(NSSet *)values;
- (void)removeMarkers:(NSSet *)values;

- (void)addOvMarkersObject:(MMOvMarker *)value;
- (void)removeOvMarkersObject:(MMOvMarker *)value;
- (void)addOvMarkers:(NSSet *)values;
- (void)removeOvMarkers:(NSSet *)values;

@end
