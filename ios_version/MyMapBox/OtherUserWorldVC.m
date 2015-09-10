//
//  OtherUserWorldVC.m
//  MyMapBox
//
//  Created by bizappman on 6/18/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "OtherUserWorldVC.h"
#import "OtherUserRoutineInfoTVC.h"
#import "CloudManager.h"
#import "CommonUtil.h"
#import "MMSearchedOvMarker.h"

#define SHOW_OTHER_USER_ROUTINR_INFO_SEGUE @"showOtherUserRoutineInfoSegue"

@interface OtherUserWorldVC ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *likeBarItem;
@property(nonatomic)BOOL isFollowed;

@end

@implementation OtherUserWorldVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    self.title=@"Loading...";
    [CloudManager searchRoutinesByUserId:self.userId withBlockWhenDone:^(NSError *error, NSArray *routines) {
        
        if(!error){
            self.title=[NSString stringWithFormat:@"%@'s World",self.userName];
            self.searchedRoutines=routines;
            [self updateMapUI];
        }else{
            self.title=@"";
            [CommonUtil alert:error.localizedDescription];
        }
    }];
    
    [self updateFollowStatus];
}

-(void)updateFollowStatus{
    [CloudManager existFollowee:self.userId withBlockWhenDone:^(BOOL isFollowed, NSError *error) {
        if(!error){
            self.isFollowed=isFollowed;
        }else{
            [CommonUtil alert:error.localizedDescription];
        }
    }];
}

- (IBAction)followButtonClick:(id)sender {
    if ([self.userId isEqualToString:[CloudManager currentUser].objectId]) {
        [CommonUtil alert:@"You already own this world~"];
        return;
    }
    
    
    if (self.isFollowed) {
        [CloudManager unfollow:self.userId withBlockWhenDone:^(BOOL success, NSError *error) {
            if(!error){
                if (success) {
                    self.isFollowed=NO;
                }
            }else{
                [CommonUtil alert:error.localizedDescription];
            }
        }];
    }else{
        [CloudManager follow:self.userId withBlockWhenDone:^(BOOL success, NSError *error) {
            if(!error){
                if (success) {
                    self.isFollowed=YES;
                }
            }else{
                [CommonUtil alert:error.localizedDescription];
            }
        }];
    }
}



//override
-(void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point{
    //do nothing
}

//override
-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    if([annotation.userInfo isKindOfClass:[MMSearchedOvMarker class]]){
        MMSearchedOvMarker *ovMarker=annotation.userInfo;
        [self performSegueWithIdentifier:SHOW_OTHER_USER_ROUTINR_INFO_SEGUE sender:ovMarker.belongRoutine];
    }
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SHOW_OTHER_USER_ROUTINR_INFO_SEGUE]) {
        OtherUserRoutineInfoTVC *destTVC=segue.destinationViewController;
        destTVC.routine=sender;
    }
}

#pragma mark - getter and setter
-(void)setIsFollowed:(BOOL)isFollowed{
    _isFollowed=isFollowed;
    if (isFollowed) {
        [self.likeBarItem setImage:[UIImage imageNamed:@"icon_like_filled"]];
    }else{
        [self.likeBarItem setImage:[UIImage imageNamed:@"icon_like"]];
    }
}
@end
