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



@protocol Routine <NSObject>
@required
-(NSString *)title;
-(NSArray *)allOvMarks;
-(NSArray *)allMarks;
//return mark whose parentNode==nil and isDelete=NO
-(NSArray *)headMarkers;
-(NSNumber *)lat;
-(NSNumber *)lng;
-(NSString *)uuid;
-(void)updateLocation;
-(NSUInteger)maxSlideNum;
@end

@protocol Marker <NSObject>
@required
-(NSArray *)imageUrlsArray;
-(NSArray *)imageUrlsArrayIncludeSubMarkers;
-(NSString *)iconUrl;
-(NSString *)title;
-(NSString *)subDescription;
-(NSString *)mycomment;
-(NSNumber *)lat;
-(NSNumber *)lng;
-(NSNumber *)slideNum;
-(NSArray *) allSubMarkers;
-(id<Routine>)belongRoutine;
@end


@interface CommonUtil : NSObject

+(double)minLatInMarkers:(NSArray *)markerArray;
+(double)minLngInMarkers:(NSArray *)markerArray;
+(double)maxLatInMarkers:(NSArray *)markerArray;
+(double)maxLngInMarkers:(NSArray *)markerArray;

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

+(double)refineAverage:(NSMutableArray*)numbers;

@end
