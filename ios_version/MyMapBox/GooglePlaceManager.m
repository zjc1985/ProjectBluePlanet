//
//  GooglePlaceManager.m
//  MyMapBox
//
//  Created by bizappman on 7/20/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "GooglePlaceManager.h"
#import "GooglePredictionResult.h"
#import <UIKit/UIKit.h>

@implementation GooglePlaceManager

+(void)autoQueryComplete:(NSString *)input withBlock:(void (^)(NSError *,NSArray *))block{
    
    NSString *urlString=[NSString stringWithFormat:@"http://45.55.10.72:8080/gmaps/api/place/queryautocomplete?input=gs%@",input];
    urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if(!error){
            NSError *jsonError;
            NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            NSArray *predictionsArray=[dictionary objectForKey:@"predictions"];
            NSMutableArray *results=[[NSMutableArray alloc]init];
            for (NSDictionary *predictionDictionary in predictionsArray) {
                GooglePredictionResult *predictionResult=[[GooglePredictionResult alloc]initWithDictionary:predictionDictionary];
                [results addObject:predictionResult];
            }
            block(jsonError,results);
        }else{
            NSLog(@"%@",error.localizedDescription);
            block(error,nil);
        }
       
    }] resume];
}

+(void)details:(NSString *)placeId withBlock:(void (^)(NSError *, GooglePlaceDetail *))block{
    NSString *urlString=[NSString stringWithFormat:@"http://45.55.10.72:8080/gmaps/api/place/details?placeid=gs%@",placeId];
    urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if(!error){
            NSError *jsonError;
            NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            NSDictionary *resultDic=[dictionary objectForKey:@"result"];
            GooglePlaceDetail *detail=[[GooglePlaceDetail alloc]initWithDictionary:resultDic];
            block(error,detail);
        }else{
            NSLog(@"%@",error.localizedDescription);
            block(error,nil);
        }
        
    }] resume];

}

@end
