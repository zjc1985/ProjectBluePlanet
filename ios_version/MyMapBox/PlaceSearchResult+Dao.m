//
//  GooglePlace+Dao.m
//  MyMapBox
//
//  Created by bizappman on 6/29/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "PlaceSearchResult+Dao.h"
#import "CommonUtil.h"

@implementation PlaceSearchResult (Dao)

+(PlaceSearchResult *)createGooglePlaceWithTitle:(NSString *)title withSubInfo:(NSString *)subInfo{
    PlaceSearchResult *result=[self queryPlaceWithTitle:title withSubInfo:subInfo];
    if (result) {
        return result;
    }else{
        result=[NSEntityDescription insertNewObjectForEntityForName:@"PlaceSearchResult" inManagedObjectContext:[CommonUtil getContext]];
        result.title=title;
        result.subInfo=subInfo;
        result.lat=[NSNumber numberWithDouble:0];
        result.lng=[NSNumber numberWithDouble:0];
        return result;
    }
}

+(NSArray *)fetchAll{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"PlaceSearchResult"
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

+(PlaceSearchResult *)queryPlaceWithTitle:(NSString *)title withSubInfo:(NSString *)subInfo{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"PlaceSearchResult"
                                       inManagedObjectContext:[CommonUtil getContext]];
    request.entity=e;
    NSSortDescriptor *sd=[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors=@[sd];
    request.predicate= [NSPredicate predicateWithFormat:@"(title == %@) AND (subInfo == %@)",title,subInfo];
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
