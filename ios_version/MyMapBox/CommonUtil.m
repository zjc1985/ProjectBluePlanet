//
//  CommonUtil.m
//  MyMapBox
//
//  Created by bizappman on 4/14/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "CommonUtil.h"
#import "AppDelegate.h"

@implementation CommonUtil
+(double)minLatInMarkers:(NSArray *)markerArray{
    MMMarker *first=[markerArray firstObject];
    double minLat=[first.lat doubleValue];
    
    for (MMMarker *each in markerArray) {
        if([each.lat doubleValue]<minLat){
            minLat=[each.lat doubleValue];
        }
    }
    
    return minLat;
}

+(double)minLngInMarkers:(NSArray *)markerArray{
    MMMarker *first=[markerArray firstObject];
    double minLng=[first.lng doubleValue];
    for (MMMarker *each in markerArray) {
        if([each.lng doubleValue]<minLng){
            minLng=[each.lng doubleValue];
        }
    }
    return minLng;
}

+(double)maxLatInMarkers:(NSArray *)markerArray{
    MMMarker *first=[markerArray firstObject];
    double maxLat=[first.lat doubleValue];
    for (MMMarker *each in markerArray) {
        if([each.lat doubleValue]>maxLat){
            maxLat=[each.lat doubleValue];
        }
    }
    return maxLat;
}

+(double)maxLngInMarkers:(NSArray *)markerArray{
    MMMarker *first=[markerArray firstObject];
    double maxLng=[first.lng doubleValue];
    for (MMMarker *each in markerArray) {
        if([each.lng doubleValue]>maxLng){
            maxLng=[each.lng doubleValue];
        }
    }
    return maxLng;
}

+(NSString *)appDocumentDirectoryPath{
    NSArray *path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[path objectAtIndex:0];
    return documentDirectory;
}


+(NSString *)dataFilePath{
    return [[self appDocumentDirectoryPath] stringByAppendingPathComponent:@"data.plist"];
}

+(NSString *)saveImage:(UIImage *)image{
    NSData *pngData = UIImagePNGRepresentation(image);
    NSUUID *uuid=[[NSUUID alloc]init];
    NSString *fileName=[NSString stringWithFormat:@"%@.png",[uuid UUIDString]];
    NSString *filePath = [[self appDocumentDirectoryPath] stringByAppendingPathComponent:fileName];
    [pngData writeToFile:filePath atomically:YES];
    return fileName;
}

+(NSString *)saveImageByData:(NSData *)imageData{
    NSUUID *uuid=[[NSUUID alloc]init];
    NSString *fileName=[NSString stringWithFormat:@"%@.png",[uuid UUIDString]];
    NSString *filePath = [[self appDocumentDirectoryPath] stringByAppendingPathComponent:fileName];
    
    [imageData writeToFile:filePath atomically:YES];
    return fileName;
}

+(UIImage *)loadImage:(NSString *)fileName{
    NSString *filePath = [[self appDocumentDirectoryPath] stringByAppendingPathComponent:fileName];
    //NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    return image;
}

+(void)alert:(NSString *)content{
    UIAlertView *theAlert=[[UIAlertView alloc] initWithTitle:@"alert" message:content delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [theAlert show];
}

+(NSManagedObjectContext *)getContext{
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    return [appDelegate managedObjectContext];
}

+(void)resetCoreData{
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    [appDelegate resetCoreData];
}

+(long long)currentUTCTimeStamp{
     return (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
}

+(BOOL)isFastNetWork{
    NSNumber *networkType=[self dataNetworkTypeFromStatusBar];
    NSLog(@"net work type: %@",@([networkType integerValue]));
    if([networkType integerValue]>1){
        return YES;
    }else{
        return NO;
    }
}

/*
 0 = No wifi or cellular
 1 = 2G and earlier? (not confirmed)
 2 = 3G? (not yet confirmed)
 3 = 4G
 4 = LTE
 5 = Wifi
 */
+(NSNumber *)dataNetworkTypeFromStatusBar {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"]    subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    return [dataNetworkItemView valueForKey:@"dataNetworkType"];
}

+(CLLocationCoordinate2D)minLocationInMMMarkers:(NSArray *)markers{
    MMMarker *first=[markers firstObject];
    double minLng=[first.lng doubleValue];
    double minlat=[first.lat doubleValue];
    
    for (MMMarker *each in markers) {
        if([each.lng doubleValue]<minLng){
            minLng=[each.lng doubleValue];
        }
        
        if([each.lat doubleValue]<minlat){
            minlat=[each.lat doubleValue];
        }
    }
    
    return CLLocationCoordinate2DMake(minlat, minLng);
}

+(CLLocationCoordinate2D)maxLocationInMMMarkers:(NSArray *)markers{
    MMMarker *first=[markers firstObject];
    double maxLat=[first.lat doubleValue];
    double maxlng=[first.lng doubleValue];
    
    for (MMMarker *each in markers) {
        if([each.lat doubleValue]>maxLat){
            maxLat=[each.lat doubleValue];
        }
        if([each.lng doubleValue]>maxlng){
            maxlng=[each.lng doubleValue];
        }
    }
    return CLLocationCoordinate2DMake(maxLat, maxlng);
}

+ (UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale
{
    // Calculate new size given scale factor.
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    // Scale the original image to match the new size.
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImage;
}

+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+(double)refineAverage:(NSMutableArray*)numbers{
    NSMutableArray *refineArray=[[NSMutableArray alloc]init];
    double e=[self average:numbers];
    double d=[self sDeviation:numbers];
    
    for (NSNumber *number in numbers) {
        if (fabs([number doubleValue]-e)<=d) {
            [refineArray addObject:number];
        }
    }
    
    return [self average:refineArray];
}

+(double)average:(NSMutableArray *)numbers{
    double sum=0;
    double result=0;
    
    for (NSNumber *number in numbers) {
        sum=sum+[number doubleValue];
    }
    
    result=sum/[numbers count];
    return result;
}

+(double)sDeviation:(NSMutableArray *)numbers{
    if([numbers count]==0){
        return 0;
    }
    double e=[self average:numbers];
    double sum=0;
    for (NSNumber *number in numbers) {
        sum=sum+([number doubleValue]-e)*([number doubleValue]-e);
    }
    return pow(sum/[numbers count], 0.5);
}

@end
