//
//  OtherUserRoutineInfoTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/18/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "OtherUserRoutineInfoTVC.h"
#import "SearchRoutineDetailMapVC.h"
#import "CloudManager.h"

@interface OtherUserRoutineInfoTVC ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *likeBarButton;

@property(nonatomic)BOOL isLiked;

@end

@implementation OtherUserRoutineInfoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateLikedStatus];
}

-(void)viewWillAppear:(BOOL)animated{
    self.titleLabel.text=self.routine.title;
    self.descriptionLabel.text=self.routine.mycomment;
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
    if ([segue.destinationViewController isKindOfClass:[SearchRoutineDetailMapVC class]]) {
        SearchRoutineDetailMapVC *destVC=segue.destinationViewController;
        destVC.routine=self.routine;
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
