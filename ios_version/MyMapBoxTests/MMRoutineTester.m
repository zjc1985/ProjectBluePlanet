//
//  MMRoutineTester.m
//  MyMapBox
//
//  Created by bizappman on 4/20/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MMRoutine+Dao.h"
#import "CommonUtil.h"

@interface MMRoutineTester : XCTestCase

@end

@implementation MMRoutineTester

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    MMRoutine *routine=[[MMRoutine alloc]init];
    NSLog(@"id:%@",routine.uuid);
    XCTAssertNotNil(routine.uuid);
}

-(void)testTimeStamp{
    MMRoutine *routine=[MMRoutine createMMRoutineWithLat:13.2 withLng:13.2];
    NSString *uuid=routine.uuid;
    
    long long time=[CommonUtil currentUTCTimeStamp];
    routine.updateTimestamp=[NSNumber numberWithLongLong:time];
    
    routine=[MMRoutine queryMMRoutineWithUUID:uuid];
    
    XCTAssertEqual(time, [routine.updateTimestamp longLongValue]);
    
    [MMRoutine removeRoutine:routine];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
