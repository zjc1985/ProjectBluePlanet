//
//  LocalImageUrl.h
//  MyMapBox
//
//  Created by bizappman on 9/14/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMMarker;

@interface LocalImageUrl : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) MMMarker *belongMarker;


@end
