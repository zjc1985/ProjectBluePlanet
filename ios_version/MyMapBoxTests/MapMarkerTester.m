//
//  MapMarkerTester.m
//  MyMapBox
//
//  Created by yufu on 15/4/19.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MMMarker.h"

@interface MapMarkerTester : XCTestCase

@property(nonatomic,strong)MMMarker *marker;

@end

@implementation MapMarkerTester


- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.marker=[[MMMarker alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testMapMarkerBasic{
    self.marker.lat=121.123;
    double expected=121.123;
    XCTAssertEqual(self.marker.lat, expected);
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
