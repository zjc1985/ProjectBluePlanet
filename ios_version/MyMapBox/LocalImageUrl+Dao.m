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

+(LocalImageUrl *)createLocalImageUrl:(NSString *)fileName inMarker:(MMMarker *)marker{
    LocalImageUrl *result=[NSEntityDescription insertNewObjectForEntityForName:@"LocalImageUrl" inManagedObjectContext:[CommonUtil getContext]];
    result.fileName=fileName;
    result.belongMarker=marker;
    return result;
}

+(void)remove:(LocalImageUrl *)localImageUrl{
    [[CommonUtil getContext] deleteObject:localImageUrl];
}

-(void)prepareForDeletion{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    NSArray *path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[path objectAtIndex:0];
    NSString *filePath=[documentDirectory stringByAppendingPathComponent:self.fileName];
    NSLog(@"delete file at %@",filePath);
    [fileManager removeItemAtPath: filePath error:&error];
    
    if(error){
        NSLog(@"error happen when deleting marker local image %@",error.localizedDescription);
    }
}

@end
