//
//  CommonUtil.m
//  MyMapBox
//
//  Created by bizappman on 4/14/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil

+(NSString *)dataFilePath{
    NSArray *path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[path objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"data.plist"];
}

@end
