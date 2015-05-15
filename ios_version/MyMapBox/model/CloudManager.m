//
//  AVOSCloudManager.m
//  MyMapBox
//
//  Created by bizappman on 5/13/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "CloudManager.h"
#import "AppDelegate.h"

#define KEY_RESPONSE_ROUTINES_UPDATED @"routinesUpdate"
#define KEY_RESPONSE_ROUTINES_NEW   @"routinesNew"
#define KEY_RESPONSE_ROUTINES_DELETE @"routinesDelete"

#define KEY_RESPONSE_OV_MARKERS_UPDATED @"ovMarkersUpdate"
#define KEY_RESPONSE_OV_MARKERS_NEW @"ovMarkersNew"
#define KEY_RESPONSE_OV_MARKER_DELETE @"ovMarkersDelete"

@implementation CloudManager

+(AVUser *)currentUser{
    return [AVUser currentUser];
}


+(void)syncRoutinesAndOvMarkersWithBlockWhenDone:(void (^)(NSError *))block{
    //save db context
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    [appDelegate saveContext];
    
    //prepare request params
    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];
    
    //call cloud
    [AVCloud callFunctionInBackground:@"syncRoutines" withParameters:params block:^(id object, NSError *error) {
        if(!error){
            NSDictionary *response=object;
            
            [self handleRoutinesUpdate:[response objectForKey:KEY_RESPONSE_ROUTINES_UPDATED]];
            [self handleRoutinesNew:[response objectForKey:KEY_RESPONSE_ROUTINES_NEW]];
            [self handleRoutinesDelete:[response objectForKey:KEY_RESPONSE_ROUTINES_DELETE]];
        
            [self handleOvMarkersUpdate:[response objectForKey:KEY_RESPONSE_OV_MARKERS_UPDATED]];
            [self handleOvMarkersNew:[response objectForKey:KEY_RESPONSE_OV_MARKERS_NEW]];
            [self handleOvMarkersDelete:[response objectForKey:KEY_RESPONSE_OV_MARKER_DELETE]];
            
        }
        
        block(error);
    }];
}

+(void)syncMarkersByRoutineUUID:(NSString *)routineUUID withClockWhenDone:(void (^)(NSError *))block{
    
}

@end
