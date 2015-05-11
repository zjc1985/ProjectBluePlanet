//
//  MMMarker+Dao.h
//  MyMapBox
//
//  Created by bizappman on 5/11/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMMarker.h"
#import "MMRoutine+Dao.h"

@interface MMMarker (Dao)

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine;

@end
