//
//  GooglePlace+Dao.m
//  MyMapBox
//
//  Created by bizappman on 6/29/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "GooglePlace+Dao.h"
#import "CommonUtil.h"

@implementation GooglePlace (Dao)

+(GooglePlace *)createGooglePlaceWithPlaceId:(NSString *)placeId withTitle:(NSString *)title{
    GooglePlace *result=[self queryGooglePlaceWithPlaceId:placeId];
    if (result) {
        return result;
    }else{
        result=[NSEntityDescription insertNewObjectForEntityForName:@"GooglePlace" inManagedObjectContext:[CommonUtil getContext]];
        result.title=title;
        result.placeId=placeId;
        result.lat=[NSNumber numberWithDouble:0];
        result.lng=[NSNumber numberWithDouble:0];
        return result;
    }
}

+(NSArray *)fetchAll{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"GooglePlace"
                                       inManagedObjectContext:[CommonUtil getContext]];
    request.entity=e;
    NSSortDescriptor *sd=[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors=@[sd];
    NSError *error;
    NSArray *result=[[CommonUtil getContext] executeFetchRequest:request error:&error];
    if(!result){
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    return result;
}

+(GooglePlace *)queryGooglePlaceWithPlaceId:(NSString *)placeId{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"GooglePlace"
                                       inManagedObjectContext:[CommonUtil getContext]];
    request.entity=e;
    NSSortDescriptor *sd=[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors=@[sd];
    request.predicate= [NSPredicate predicateWithFormat:@"placeId == %@",placeId];
    NSError *error;
    NSArray *result=[[CommonUtil getContext] executeFetchRequest:request error:&error];
    if(!result){
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    return result.firstObject;
}

-(BOOL)isLoaded{
    if ([self.lat doubleValue]==0||[self.lng doubleValue]==0) {
        return NO;
    }else{
        return YES;
    }
}

@end
