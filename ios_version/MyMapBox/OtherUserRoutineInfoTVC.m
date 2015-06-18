//
//  OtherUserRoutineInfoTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/18/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "OtherUserRoutineInfoTVC.h"
#import "SearchRoutineDetailMapVC.h"

@interface OtherUserRoutineInfoTVC ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;

@end

@implementation OtherUserRoutineInfoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    self.titleLabel.text=self.routine.title;
    self.descriptionLabel.text=self.routine.mycomment;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SearchRoutineDetailMapVC class]]) {
        SearchRoutineDetailMapVC *destVC=segue.destinationViewController;
        destVC.routine=self.routine;
    }
}

@end
