//
//  MarkerInfoTVC.m
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MarkerInfoTVC.h"
#import "MarkerEditTVC.h"

@interface MarkerInfoTVC ()

@property (weak, nonatomic) IBOutlet UILabel *markerTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *markerSlideNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *markerCostLabel;
@property (weak, nonatomic) IBOutlet UIImageView *markerIconImage;
@property (weak, nonatomic) IBOutlet UITextView *markerDescription;

@end

@implementation MarkerInfoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    [self updateUI];
}

-(void)updateUI{
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.markerTitleLabel.text=self.marker.title;
    self.markerSlideNumLabel.text=[NSString stringWithFormat:@"%u",[self.marker.slideNum integerValue]];
    //will do image thing later
    
    self.markerDescription.text=self.marker.mycomment;

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

@end
