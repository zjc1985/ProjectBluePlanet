//
//  AVOSCloudTester.m
//  MyMapBox
//
//  Created by bizappman on 5/13/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <AVOSCloud/AVOSCloud.h>
#import "CloudManager.h"
#import "MMRoutine+Dao.h"
#import "MMMarker+Dao.h"

@interface AVOSCloudTester : XCTestCase

@end

@implementation AVOSCloudTester

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    AVUser *user=[AVUser currentUser];
    if (user) {
        NSLog(@"Has current user");
    }else{
        NSLog(@"No current user found");
    }
    
    XCTAssert(YES, @"Pass");
}

-(void)testQueryRoutine{
    //D3E26085-70FC-4663-B8FB-AF6DD9EE0984
    MMRoutine *routine=[MMRoutine queryMMRoutineWithUUID:@"71e091ee-a165-4c73-83d1-94051f66d327"];
    XCTAssertNotNil(routine);
}

-(void)testSync{
    [CloudManager syncRoutinesAndOvMarkersWithBlockWhenDone:nil];
    [NSThread sleepForTimeInterval:50];
    XCTAssert(YES, @"Pass");
}

@end
