//
//  MMMarker.h
//  MyMapBox
//
//  Created by bizappman on 4/23/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMBaseMarker.h"

@interface MMMarker :MMBaseMarker

@property(nonatomic,strong)NSString *routineId;

-(instancetype)initWithRoutineId:(NSString *)routineId;

@end
