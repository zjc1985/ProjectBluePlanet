//
//  LocalImageUrl+Dao.m
//  MyMapBox
//
//  Created by bizappman on 9/14/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "LocalImageUrl+Dao.h"
#import "CommonUtil.h"

@implementation LocalImageUrl (Dao)

+(LocalImageUrl *)createLocalImageUrl:(NSString *)url inMarker:(MMMarker *)marker{
    LocalImageUrl *result=[NSEntityDescription insertNewObjectForEntityForName:@"LocalImageUrl" inManagedObjectContext:[CommonUtil getContext]];
    result.url=url;
    result.belongMarker=marker;
    return result;
}

-(void)prepareForDeletion{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:self.url error:&error];
    if(error){
        NSLog(@"error happen when deleting marker local image %@",error.localizedDescription);
    }
}

@end
