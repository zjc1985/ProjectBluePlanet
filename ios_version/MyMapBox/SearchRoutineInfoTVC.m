//
//  SearchRoutineInfoTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "SearchRoutineInfoTVC.h"
#import "SearchRoutineDetailMapVC.h"

# define SHOW_SEARCH_ROUTINE_DETAIL_SEGUE @"showSearchRoutineDetailSegue"

@interface SearchRoutineInfoTVC ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *desTextView;


@end

@implementation SearchRoutineInfoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:YES];
    self.titleLabel.text=self.routine.title;
    self.desTextView.text=self.routine.mycomment;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SHOW_SEARCH_ROUTINE_DETAIL_SEGUE]){
        SearchRoutineDetailMapVC *desVC=segue.destinationViewController;
        desVC.routine=self.routine;
    }
}

@end
