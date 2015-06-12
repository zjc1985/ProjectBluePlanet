//
//  MarkerInfoTVC.m
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MarkerInfoTVC.h"
#import "MarkerEditTVC.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "MWPhotoBrowser.h"

@interface MarkerInfoTVC ()<MWPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UILabel *markerTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *markerSubInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *markerIconImage;
@property (weak, nonatomic) IBOutlet UITextView *markerDescription;
@property (weak, nonatomic) IBOutlet UIImageView *markerImage;

@property (nonatomic, strong) NSMutableArray *photos; //of MWPhotos

@end

@implementation MarkerInfoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(markerImageClicked)];
    singleTap.numberOfTapsRequired = 1;
    [self.markerImage setUserInteractionEnabled:YES];
    [self.markerImage addGestureRecognizer:singleTap];
}

-(void)viewDidAppear:(BOOL)animated{
    [self updateUI];
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
    self.markerIconImage.image=[UIImage imageNamed:self.marker.iconUrl];
    self.markerTitleLabel.text=self.marker.title;
    self.markerSubInfoLabel.text=[self.marker subDescription];
    
    NSString *imageUrlString=[[self.marker imageUrlsArray] firstObject];
    if(imageUrlString){
        NSURL *url=[NSURL URLWithString:imageUrlString];
        [self.markerImage sd_setImageWithURL:url
                            placeholderImage:[UIImage imageNamed:@"login_image"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       if(!error){
                                           self.markerImage.contentMode=UIViewContentModeScaleAspectFill;
                                       }
                                   }
         ];
        
    }
    
    if (!self.marker.mycomment.length) {
        self.markerDescription.text=@"No Description";
    }else{
        self.markerDescription.text=self.marker.mycomment;
    }
    
    [self.tabBarController.tabBar setHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [self updateUI];
}

-(IBAction)markerEditDone:(UIStoryboardSegue *) segue{
    NSLog(@"marker edit done");
    //[self updateUI];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"editMarkerSegue"]) {
        UINavigationController *navController=(UINavigationController *)segue.destinationViewController;
        MarkerEditTVC *markerEditTVC=navController.viewControllers[0];
        markerEditTVC.marker=self.marker;
        markerEditTVC.markerCount=self.markerCount;
    }
}

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
