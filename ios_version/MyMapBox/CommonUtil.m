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

+(NSString *)dataFilePath{
    NSArray *path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[path objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"data.plist"];
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
    NSLog(@"net work type: %i",[networkType integerValue]);
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
@end
