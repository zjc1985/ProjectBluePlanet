//
//  GooglePlace+Dao.h
//  MyMapBox
//
//  Created by bizappman on 6/29/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "GooglePlace.h"

@interface GooglePlace (Dao)

+(GooglePlace *)createGooglePlaceWithPlaceId:(NSString *)placeId withTitle:(NSString *)title;

+(NSArray *)fetchAll;

-(BOOL)isLoaded;

@end
