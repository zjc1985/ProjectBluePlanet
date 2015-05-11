//
//  MarkerEditTVC.m
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MarkerEditTVC.h"
#import "SlideNumSelectTVC.h"

@interface MarkerEditTVC ()<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITextField *markerTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *markerCostTextField;
@property (weak, nonatomic) IBOutlet UILabel *markerSlideNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *markerIconNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *markerDescriptionTextView;

@end

@implementation MarkerEditTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

-(void)updateUI{
    self.markerTitleTextField.text=self.marker.title;
    self.markerSlideNumLabel.text=[NSString stringWithFormat:@"%u",[self.marker.slideNum integerValue]];
    self.markerIconNameLabel.text=self.marker.iconUrl;
    self.markerDescriptionTextView.text=self.marker.mycomment;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"markerEditDoneSegue"]){
        self.marker.title=self.markerTitleTextField.text;
        self.marker.mycomment=self.markerDescriptionTextView.text;
        self.marker.slideNum=[NSNumber numberWithInteger:[self.markerSlideNumLabel.text integerValue]];
    }
    
    if([segue.destinationViewController isKindOfClass:[SlideNumSelectTVC class]]){
        SlideNumSelectTVC *slideNumSelectTVC=segue.destinationViewController;
        slideNumSelectTVC.slideNumLabel=self.markerSlideNumLabel;
        slideNumSelectTVC.markerCount=self.markerCount;
    }
}

- (IBAction)deleteClick:(id)sender {
    UIActionSheet *actionSheet= [[UIActionSheet alloc]initWithTitle:@"Delete Routine"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:@"Delete"
                                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==actionSheet.destructiveButtonIndex){
        NSLog(@"delete marker");
        [self performSegueWithIdentifier:@"deleteMarkerUnwindSegue" sender:nil ];
    }
}

@end
