//
//  CommonUtil.h
//  MyMapBox
//
//  Created by bizappman on 4/14/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MMMarker.h"
@import CoreData;
@import CoreLocation;

#define tourMapId  @"lionhart586.gkihab1d"
#define streetMapId @"lionhart586.lnmjhd7b"

#define tileJsonTourMap @"tileJSONTourMap"
#define tileJsonDetailMap @"tileJSONDetailMap"

@protocol Marker <NSObject>
@required
-(NSArray *)imageUrlsArray;
-(NSString *)iconUrl;
-(NSString *)title;
-(NSString *)subDescription;
-(NSString *)mycomment;
-(NSNumber *)lat;
-(NSNumber *)lng;
-(NSNumber *)slideNum;
@end

@protocol Routine <NSObject>
@required
-(NSString *)title;
-(NSArray *)allOvMarks;
-(NSArray *)allMarks;
//return node whose parentNode==nil and isDelete=NO
-(NSArray *)headTreeNodes;
-(NSArray *)allTreeNodes;//of id<TreeNode>
-(double)minLatInMarkers;
-(double)minLngInMarkers;
-(double)maxLatInMarkers;
-(double)maxLngInMarkers;
-(NSNumber *)lat;
-(NSNumber *)lng;
-(NSString *)uuid;
-(void)updateLocation;
-(NSUInteger)maxSlideNum;
@end

@protocol TreeNode <NSObject>
@required
-(id<Routine>)belongRoutine;
-(id<Marker>)belongMarker;
-(NSArray *)allSubTreeNodes; //of id<TreeNode>
@end

@interface CommonUtil : NSObject

+(NSString *)dataFilePath;

+(NSString *)saveImage:(UIImage *)image;

+(NSString *)saveImageByData:(NSData *)imageData;

+(UIImage *)loadImage:(NSString *)filePath;

+(void)alert:(NSString *)content;

+(NSManagedObjectContext *)getContext;

+(long long)currentUTCTimeStamp;

+(void)resetCoreData;

+(BOOL)isFastNetWork;

+(NSNumber *)dataNetworkTypeFromStatusBar;

+(CLLocationCoordinate2D) minLocationInMMMarkers:(NSArray *) markers;  //of MMMarker

+(CLLocationCoordinate2D) maxLocationInMMMarkers:(NSArray *) markers; //of MMMarker

+(UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale;

+(BOOL)isBlankString:(NSString *)string;

@end
