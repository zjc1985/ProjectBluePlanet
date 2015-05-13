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

@end
