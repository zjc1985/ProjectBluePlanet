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

@interface CommonUtil : NSObject

+(NSString *)dataFilePath;

+(void)alert:(NSString *)content;

+(NSManagedObjectContext *)getContext;

+(long long)currentUTCTimeStamp;

+(void)resetCoreData;

+(BOOL)isFastNetWork;

+(NSNumber *)dataNetworkTypeFromStatusBar;

+(CLLocationCoordinate2D) minLocationInMMMarkers:(NSArray *) markers;  //of MMMarker

+(CLLocationCoordinate2D) maxLocationInMMMarkers:(NSArray *) markers; //of MMMarker

+(UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale;

@end
