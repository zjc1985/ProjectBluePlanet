//
//  MyMapBoxTests.m
//  MyMapBoxTests
//
//  Created by bizappman on 4/9/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import "CommonUtil.h"

@interface MyMapBoxTests : XCTestCase

@end

@implementation MyMapBoxTests

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
    XCTAssert(YES, @"Pass");
}

-(void)testGetManagedContext{
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    XCTAssertNotNil(appDelegate.managedObjectContext);
}

-(void)testGetUtcTime{
    NSLog(@"====================");
    
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSLog(@"utc time 1:%lld",[CommonUtil currentUTCTimeStamp]);
    NSLog(@"utc time 2: %lld",milliseconds);
    XCTAssert(YES, @"Pass");
}



@end
