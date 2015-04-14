//
//  RoutineInfoViewController.m
//  MyMapBox
//
//  Created by bizappman on 4/13/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "RoutineInfoViewController.h"
#import "RoutineDetailMapViewController.h"

@interface RoutineInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;

@end

@implementation RoutineInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text=@"one testing title";
    //self.descriptionTextField.text=@"one testing description";
}

- (IBAction)showRoutineDetailClick:(id)sender {
    NSLog(@"Show Routine Detail click");
}


- (IBAction)PinRoutineClick:(id)sender {
    NSLog(@"Pin Routine Detail click");
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:[RoutineDetailMapViewController class]]){
        RoutineDetailMapViewController *routineDetailMapVC=(RoutineDetailMapViewController *)segue.destinationViewController;
    }
}


@end
