//
//  BaseMarkerInfoVC.m
//  MyMapBox
//
//  Created by bizappman on 6/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "BaseMarkerInfoVC.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "MWPhotoBrowser.h"

@interface BaseMarkerInfoVC ()<MWPhotoBrowserDelegate>

@end

@implementation BaseMarkerInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(markerImageClicked)];
    singleTap.numberOfTapsRequired = 1;
    [self.markerImage setUserInteractionEnabled:YES];
    [self.markerImage addGestureRecognizer:singleTap];
}

-(void)markerImageClicked{
    if ([self.marker imageUrlsArray].count>0) {
        self.photos=[NSMutableArray array];
        for (NSString *urlString in [self.marker imageUrlsArray]) {
            NSURL *url=[NSURL URLWithString:urlString];
            [self.photos addObject:[MWPhoto photoWithURL:url]];
        }
        
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        
        [browser setCurrentPhotoIndex:0];
        
        [self.navigationController pushViewController:browser animated:YES];
        [browser showNextPhotoAnimated:YES];
        [browser showPreviousPhotoAnimated:YES];
    }
}

-(void)updateUI{
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.markerIconImage.image=[UIImage imageNamed:[self.marker iconUrl]];
    self.markerTitleLabel.text=[self.marker title];
    self.markerSubInfoLabel.text=[self.marker subDescription];
    
    NSString *imageUrlString=[[self.marker imageUrlsArray] firstObject];
    if(imageUrlString){
        NSURL *url=[NSURL URLWithString:imageUrlString];
        [self.markerImage sd_setImageWithURL:url
                            placeholderImage:[UIImage imageNamed:@"defaultMarkerImage"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       if(!error){
                                           self.markerImage.contentMode=UIViewContentModeScaleAspectFill;
                                       }
                                   }
         ];
        
    }
    
    if (![self.marker mycomment].length) {
        self.markerDescription.text=@"No Description";
    }else{
        self.markerDescription.text=[self.marker mycomment];
    }
    
    [self.tabBarController.tabBar setHidden:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    return nil;
}

@end
