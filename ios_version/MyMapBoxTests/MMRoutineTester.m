//
//  MMRoutineTester.m
//  MyMapBox
//
//  Created by bizappman on 4/20/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MMRoutine.h"

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
    NSLog(@"id:%@",routine.id);
    XCTAssertNotNil(routine.id);
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
