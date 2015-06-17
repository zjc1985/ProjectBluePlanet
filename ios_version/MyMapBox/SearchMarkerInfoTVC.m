//
//  SearchMarkerInfoTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "SearchMarkerInfoTVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MWPhotoBrowser.h"

@interface SearchMarkerInfoTVC ()

@end

@implementation SearchMarkerInfoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [self updateUI];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
