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
#import "Math.h"

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

-(void)testMapMarkerUUID{
    NSLog(@"id: %@",self.marker.id);
}

-(double)average:(double [])numbers andSize:(NSUInteger )size{
    double sum=0;
    double result=0;
    for (NSUInteger i=0; i<size; i++) {
        sum=sum+numbers[i];
    }
    result=sum/size;
    return result;
}

-(void)testAverage{
    double numbers[6]={2,2,2,3,3,3};
    double result=[self average:numbers andSize:6];
    XCTAssertEqual(2.5, result);
}

-(void)testPow{
    XCTAssertEqual(4, pow(16, 0.5));
}


@end
