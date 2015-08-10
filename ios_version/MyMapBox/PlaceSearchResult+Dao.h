//
//  GooglePlace+Dao.h
//  MyMapBox
//
//  Created by bizappman on 6/29/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "PlaceSearchResult.h"

@interface PlaceSearchResult (Dao)

+(PlaceSearchResult *)createGooglePlaceWithTitle:(NSString *)title withSubInfo:(NSString *)subInfo;

+(NSArray *)fetchAll;

-(BOOL)isLoaded;

@end
