//
//  RoutineEditTVC.m
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "RoutineEditTVC.h"
#import "CommonUtil.h"
#import "MMRoutine+Dao.h"
#import "OvIconSelectTVC.h"

@interface RoutineEditTVC ()<UITextFieldDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITableViewCell *ovIconTableCell;
@property (strong ,nonatomic)NSString *selectedIconUrl;
@property (weak, nonatomic) MMRoutine *routine;

@end

@implementation RoutineEditTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleTextField.text=self.routine.title;
    self.descriptionTextView.text=self.routine.mycomment;
    self.ovIconTableCell.imageView.image=[UIImage imageNamed:self.ovMarker.iconUrl];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)deleteRoutineClick:(id)sender {
    UIActionSheet *actionSheet= [[UIActionSheet alloc]initWithTitle:@"Delete Routine"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:@"Delete"
                                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"EditRoutineDoneSegue"]){
        self.routine.title=self.titleTextField.text;
        self.routine.mycomment=self.descriptionTextView.text;
        self.routine.updateTimestamp=[NSNumber numberWithLongLong: [CommonUtil currentUTCTimeStamp]];
        self.ovMarker.iconUrl=self.selectedIconUrl;
    }else if ([segue.identifier isEqualToString:@"editOvIconSelectSegue"]){
        UINavigationController *navController=(UINavigationController *)segue.destinationViewController;
        OvIconSelectTVC *selectTVC=navController.viewControllers[0];
        selectTVC.selectedUrl=self.ovMarker.iconUrl;
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==actionSheet.destructiveButtonIndex){
        [self performSegueWithIdentifier:@"deleteRoutineUnwindSegue" sender:nil];
    }
}

-(IBAction)ovIconSelectDone:(UIStoryboardSegue *)segue{
    if([segue.sourceViewController isKindOfClass:[OvIconSelectTVC class]]){
        OvIconSelectTVC *ovIconSelectTVC=segue.sourceViewController;
        self.selectedIconUrl=ovIconSelectTVC.selectedUrl;
        self.ovIconTableCell.imageView.image=[UIImage imageNamed:ovIconSelectTVC.selectedUrl];
    }
}

#pragma mark - getter and setter
-(MMRoutine *)routine{
    return self.ovMarker.belongRoutine;
}



@end
