//
//  AVOSCloudManager.h
//  MyMapBox
//
//  Created by bizappman on 5/13/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@interface CloudManager : NSObject

+(AVUser *)currentUser;

@end