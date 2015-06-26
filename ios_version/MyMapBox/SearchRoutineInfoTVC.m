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

#import "CloudManager.h"

# define SHOW_SEARCH_ROUTINE_DETAIL_SEGUE @"showSearchRoutineDetailSegue"
# define SHOW_OTHER_USER_WORLD_SEGUE @"showOtherUserWorldSegue"

@interface SearchRoutineInfoTVC ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *desTextView;
@property (weak, nonatomic) IBOutlet UIButton *exploreButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *likeBarButton;

@property(nonatomic)BOOL isLiked;

@end

@implementation SearchRoutineInfoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isLiked=NO;
    [self updateLikedStatus];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:YES];
    self.titleLabel.text=self.routine.title;
    self.subTitleLabel.text=[NSString stringWithFormat:@"Owned By %@",self.routine.userName];
    self.desTextView.text=self.routine.mycomment;
    [self.exploreButton setTitle:[NSString stringWithFormat:@"Explore %@'s World",self.routine.userName] forState:UIControlStateNormal];
    
    
}


-(void)updateLikedStatus{
    [CloudManager existLikedRoutine:self.routine.uuid withBlockWhenDone:^(BOOL isLiked, NSError *error) {
        if(!error){
            self.isLiked=isLiked;
        }else{
            [CommonUtil alert:error.localizedDescription];
        }
        
    }];
}
- (IBAction)likeButtonClick:(id)sender {
    if([self.routine.userId isEqualToString:[CloudManager currentUser].objectId]){
        [CommonUtil alert:@"You already own this routine."];
        return;
    }
    
    if(self.isLiked){
        [CloudManager unLikedRoutine:self.routine.uuid withBlockWhenDone:^(NSError *error) {
            if(!error){
                self.isLiked=NO;
            }else{
                [CommonUtil alert:error.localizedDescription];
            }
        }];
    }else{
        [CloudManager likeRoutine:self.routine.uuid withBlockWhenDone:^(NSError *error) {
            if(!error){
                self.isLiked=YES;
            }else{
                [CommonUtil alert:error.localizedDescription];
            }
        }];
    }
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

#pragma mark - getter and setter
-(void)setIsLiked:(BOOL)isLiked{
    _isLiked=isLiked;
    if (_isLiked) {
        [self.likeBarButton setImage:[UIImage imageNamed:@"icon_like_filled"]];
    }else{
        [self.likeBarButton setImage:[UIImage imageNamed:@"icon_like"]];
    }
}




@end
