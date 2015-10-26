//
//  MMMarker+Dao.m
//  MyMapBox
//
//  Created by bizappman on 5/11/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MMMarker+Dao.h"
#import "CommonUtil.h"
#import "MMRoutine.h"
#import "LocalImageUrl+Dao.h"

@implementation MMMarker (Dao)

+(MMMarker *)queryMMMarkerWithUUID:(NSString *)uuid{
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"MMMarker"
                                       inManagedObjectContext:[CommonUtil getContext]];
    request.entity=e;
    NSSortDescriptor *sd=[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors=@[sd];
    request.predicate= [NSPredicate predicateWithFormat:@"uuid == %@",uuid];
    NSError *error;
    NSArray *result=[[CommonUtil getContext] executeFetchRequest:request error:&error];
    if(!result){
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    return result.firstObject;
}

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng withUUID:(NSString *)uuid withParentMarker:(MMMarker *)parentMarker{
    MMMarker *result=[self queryMMMarkerWithUUID:uuid];
    if(result){
        return result;
    }else{
        result=[NSEntityDescription insertNewObjectForEntityForName:@"MMMarker" inManagedObjectContext:[CommonUtil getContext]];
        
        result.uuid=uuid;
        result.belongRoutine=routine;
        result.title=@"New Marker";
        result.mycomment=@"";
        result.category=[NSNumber numberWithInt:CategoryInfo];
        result.iconUrl=@"event_default.png";
        result.imgUrls=@"[]";
        
        result.lat=[NSNumber numberWithDouble:lat];
        result.lng=[NSNumber numberWithDouble:lng];
        
        result.isSync=[NSNumber numberWithBool:NO];
        result.isDelete=[NSNumber numberWithBool:NO];
        result.offsetX=[NSNumber numberWithDouble:0];
        result.offsetY=[NSNumber numberWithDouble:0];
        result.slideNum=[NSNumber numberWithInt:1];
        result.parentMarker=parentMarker;
        return result;
    }

}

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng withParentMarker:(MMMarker *)parentMarker{
    NSUUID *uuid=[[NSUUID alloc]init];
    return [self createMMMarkerInRoutine:routine
                                 withLat:lat
                                 withLng:lng
                                withUUID:[uuid UUIDString]
                                withParentMarker:parentMarker];
}

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withSearchMarker:(MMSearchdeMarker *)searchedMarker withParentMarker:(MMMarker *)parentMarker{
    MMMarker *marker=[self createMMMarkerInRoutine:routine
                                           withLat:[searchedMarker.lat doubleValue]
                                           withLng:[searchedMarker.lng doubleValue]
                                  withParentMarker:parentMarker];
    
    marker.title=searchedMarker.title;
    marker.iconUrl=searchedMarker.iconUrl;
    marker.category=searchedMarker.category;
    
    return marker;
}

+(void)removeMMMarker:(MMMarker *)marker{
    [[CommonUtil getContext] deleteObject:marker];
}

+(NSString *)CategoryNameWithMMMarkerCategory:(MMMarkerCategory)categoryNum{
    NSString *categoryName;
    switch (categoryNum) {
        case CategoryArrivalLeave:
            categoryName=@"Arrive & Leave";
            break;
        case CategorySight:
            categoryName=@"Sight";
            break;
        case CategoryHotel:
            categoryName=@"Hotel";
            break;
        case CategoryFood:
            categoryName=@"Food";
            break;
        case CategoryInfo:
            categoryName=@"Info";
            break;
        case CategoryOverview:
            categoryName=@"Overview";
            break;
        default:
            categoryName=@"Info";
            break;
    }
    return categoryName;
}

-(NSArray *)allSubMarkers{
    NSMutableArray *results=[[NSMutableArray alloc]init];
    
    for(MMMarker *marker in [self.subMarkers allObjects]){
        if(![marker.isDelete boolValue]){
            [results addObject:marker];
        }
    }
    return results;
}

-(NSArray *)imageUrlsArray{
    NSError *error;
    NSData *data=[self.imgUrls dataUsingEncoding:NSUTF8StringEncoding];
    if(data){
        NSArray *jsonObject=[NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingAllowFragments
                                                              error:&error];
        
        NSMutableArray *result=[[NSMutableArray alloc]init];
        
        if(jsonObject!=nil && error==nil){
            for (NSString *url in jsonObject) {
                [result addObject: [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
            return result;
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}

-(void)addImageUrl:(NSString *)imgUrl{
    NSMutableArray *imageArray=[[NSMutableArray alloc]initWithArray:[self imageUrlsArray]];
    [imageArray addObject:imgUrl];
    
    NSError *error;
    NSData *data= [NSJSONSerialization dataWithJSONObject:imageArray
                                    options:NSJSONWritingPrettyPrinted
                                                    error:&error];
    if(!error){
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.imgUrls=jsonString;
    }
}

-(void)removeImageUrl:(NSString *)imgUrl{
    NSMutableArray *imageArray=[[NSMutableArray alloc]initWithArray:[self imageUrlsArray]];
    [imageArray removeObject:imgUrl];
    
    NSError *error;
    NSData *data= [NSJSONSerialization dataWithJSONObject:imageArray
                                                  options:NSJSONWritingPrettyPrinted
                                                    error:&error];
    if(!error){
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.imgUrls=jsonString;
    }
}

-(void)deleteSelf{
    if(self.isSync){
        self.isDelete=[NSNumber numberWithBool:YES];
        for (MMMarker *each in self.subMarkers) {
            [each deleteSelf];
        }
        self.updateTimestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
    }else{
        [MMMarker removeMMMarker:self];
    }
}

-(NSString *)categoryName{
    return [MMMarker CategoryNameWithMMMarkerCategory:[self.category integerValue]];
}

-(NSString *)subDescription{
    return [NSString stringWithFormat:@"%@ %@",[self categoryName],@([self.slideNum integerValue])];
}

-(NSDictionary *)convertToDictionary{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    
    [dic setValue:self.iconUrl forKey:KEY_MARKER_ICON_URL];
    [dic setValue:self.uuid forKey:KEY_MARKER_UUID];
    [dic setValue:self.category forKey:KEY_MARKER_CATEGORY];
    [dic setValue:self.title forKey:KEY_MARKER_TITLE];
    [dic setValue:self.slideNum forKey:KEY_MARKER_SLIDE_NUM];
    [dic setValue:self.lat forKey:KEY_MARKER_LAT];
    [dic setValue:self.lng forKey:KEY_MARKER_LNG];
    [dic setValue:self.mycomment forKey:KEY_MARKER_MYCOMMENT];
    [dic setValue:@"" forKey:KEY_MARKER_ADDRESS];
    [dic setValue:self.offsetX forKey:KEY_MARKER_OFFSETX];
    [dic setValue:self.offsetY forKey:KEY_MARKER_OFFSETY];
    [dic setValue:self.belongRoutine.uuid forKey:KEY_MARKER_ROUTINE_ID];
    [dic setValue:self.isDelete forKey:KEY_MARKER_IS_DELETE];
    [dic setValue:self.isSync forKey:KEY_MARKER_IS_SYNCED];
    [dic setValue:self.updateTimestamp forKey:KEY_MARKER_UPDATE_TIME];
    [dic setValue:self.imgUrls forKey:KEY_MARKER_IMAGE_URLS];
    if(self.parentMarker){
        [dic setValue:self.parentMarker.uuid forKey:KEY_MARKER_PARENT_UUID];
    }
    return dic;
}

-(void)copySelfTo:(MMMarker *)parentMarker inRoutine:(MMRoutine *)routine{
    MMRoutine *belongRoutine;
    if (parentMarker) {
        belongRoutine=parentMarker.belongRoutine;
    }else{
        belongRoutine=routine;
    }
    MMMarker *copyMarker=[MMMarker createMMMarkerInRoutine:belongRoutine
                                                   withLat:[self.lat doubleValue]
                                                   withLng:[self.lng doubleValue] withParentMarker:parentMarker];
    copyMarker.title=self.title;
    copyMarker.mycomment=self.mycomment;
    copyMarker.iconUrl=self.iconUrl;
    copyMarker.imgUrls=self.imgUrls;
    //copy local image
    if([[self.localImages allObjects] count]>0){
        for (NSString *imgUrl in [self.localImages allObjects]) {
            UIImage *copyImage=[CommonUtil loadImage:imgUrl];
            NSString *copyImgUrl=[CommonUtil saveImage:copyImage];
            [LocalImageUrl createLocalImageUrl:copyImgUrl inMarker:copyMarker];
        }
    }
    
    for (MMMarker *eachSubMarker in [self allSubMarkers]) {
        [eachSubMarker copySelfTo:copyMarker inRoutine:belongRoutine];
    }
}

-(void)updateLocationAccording2SubMarkers{
    if(self.allSubMarkers==0){
        return;
    }
    
    NSMutableArray *latArray=[[NSMutableArray alloc]init];
    NSMutableArray *lngArray=[[NSMutableArray alloc]init];
    
    for (MMMarker *eachMarker in self.allSubMarkers) {
        [latArray addObject:eachMarker.lat];
        [lngArray addObject:eachMarker.lng];
    }
    
    self.lat=[NSNumber numberWithDouble: [CommonUtil refineAverage:latArray]];
    self.lng=[NSNumber numberWithDouble: [CommonUtil refineAverage:lngArray]];
    
    NSNumber *timestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
    self.updateTimestamp=timestamp;
}

#pragma mark - setters



@end
