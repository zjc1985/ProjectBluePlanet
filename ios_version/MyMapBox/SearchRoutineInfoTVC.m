//
//  SearchRoutineInfoTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "SearchRoutineInfoTVC.h"
#import "SearchRoutineDetailMapVC.h"
#import "OtherUserWorldVC.h"

# define SHOW_SEARCH_ROUTINE_DETAIL_SEGUE @"showSearchRoutineDetailSegue"
# define SHOW_OTHER_USER_WORLD_SEGUE @"showOtherUserWorldSegue"

@interface SearchRoutineInfoTVC ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *desTextView;
@property (weak, nonatomic) IBOutlet UIButton *exploreButton;


@end

@implementation SearchRoutineInfoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:YES];
    self.titleLabel.text=self.routine.title;
    self.subTitleLabel.text=[NSString stringWithFormat:@"Owned By %@",self.routine.userName];
    self.desTextView.text=self.routine.mycomment;
    [self.exploreButton setTitle:[NSString stringWithFormat:@"Explore %@'s World",self.routine.userName] forState:UIControlStateNormal];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SHOW_SEARCH_ROUTINE_DETAIL_SEGUE]){
        SearchRoutineDetailMapVC *desVC=segue.destinationViewController;
        desVC.routine=self.routine;
    }else if([segue.identifier isEqualToString:SHOW_OTHER_USER_WORLD_SEGUE]){
        OtherUserWorldVC *destVC=segue.destinationViewController;
        destVC.userId=self.routine.userId;
        destVC.userName=self.routine.userName;
    }
}

@end
