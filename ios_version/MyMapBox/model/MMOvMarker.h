//
//  MMOvMarker.h
//  MyMapBox
//
//  Created by bizappman on 4/23/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMBaseMarker.h"

@interface MMOvMarker : MMBaseMarker

@property(nonatomic,strong)NSString *routineId;

-(instancetype)initWithRoutineId:(NSString *)routineId;

@end
