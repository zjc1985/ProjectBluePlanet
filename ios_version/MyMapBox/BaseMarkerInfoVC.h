//
//  BaseMarkerInfoVC.h
//  MyMapBox
//
//  Created by bizappman on 6/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtil.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "MWPhotoBrowser.h"

@interface BaseMarkerInfoVC : UITableViewController<MWPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UILabel *markerTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *markerSubInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *markerIconImage;
@property (weak, nonatomic) IBOutlet UITextView *markerDescription;
@property (weak, nonatomic) IBOutlet UIImageView *markerImage;

@property (nonatomic, strong) NSMutableArray *photos; //of MWPhotos

@property(nonatomic,strong)id<TreeNode> node;
@property(nonatomic,strong,readonly)id<Marker> marker;

-(void)updateUI;

-(void)markerImageClicked;

@end
