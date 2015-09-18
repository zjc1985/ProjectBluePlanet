//
//  LocalImageUrl+Dao.h
//  MyMapBox
//
//  Created by bizappman on 9/14/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "LocalImageUrl.h"

@interface LocalImageUrl (Dao)

+(LocalImageUrl *)createLocalImageUrl:(NSString *)fileName inMarker:(MMMarker *)marker;

+(void)remove:(LocalImageUrl *)localImageUrl;
@end
