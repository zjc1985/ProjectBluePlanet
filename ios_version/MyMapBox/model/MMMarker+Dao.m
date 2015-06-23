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

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng withUUID:(NSString *)uuid{
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
        
        return result;
    }

}

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withLat:(double)lat withLng:(double)lng{
    NSUUID *uuid=[[NSUUID alloc]init];
    return [self createMMMarkerInRoutine:routine
                                 withLat:lat
                                 withLng:lng
                                withUUID:[uuid UUIDString]];
}

+(MMMarker *)createMMMarkerInRoutine:(MMRoutine *)routine withSearchMarker:(MMSearchdeMarker *)searchedMarker{
    MMMarker *marker=[self createMMMarkerInRoutine:routine withLat:[searchedMarker.lat doubleValue] withLng:[searchedMarker.lng doubleValue]];
    
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

-(void)markDelete{
    self.isDelete=[NSNumber numberWithBool:YES];
    self.updateTimestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
}


-(NSString *)categoryName{
    return [MMMarker CategoryNameWithMMMarkerCategory:[self.category integerValue]];
}

-(NSString *)subDescription{
    return [NSString stringWithFormat:@"%@ %u",[self categoryName],[self.slideNum integerValue]];
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
    
    return dic;
}


@end
