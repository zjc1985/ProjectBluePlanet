//
//  ThumbNailImageTVC.h
//  photoFrameWorkExercise
//
//  Created by bizappman on 9/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

@interface SelectImageTVC : UITableViewController

//in
@property (strong) PHFetchResult *assetsFetchResults;
@property (nonatomic,strong)NSString *incomingSegueName;

//out
@property(strong,nonatomic)NSArray *selectedAssetsOut;//of PHAssets

@end
