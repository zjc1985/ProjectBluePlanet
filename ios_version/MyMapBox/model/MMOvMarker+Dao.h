//
//  MMOvMarker+Dao.h
//  MyMapBox
//
//  Created by bizappman on 5/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMOvMarker.h"


@interface MMOvMarker (Dao)

+(MMOvMarker *)createMMOvMarkerInRoutine:(MMRoutine *)routine;

-(void)markDelete;

@end
