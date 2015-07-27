//
//  RoutineAddTVC.m
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "RoutineAddTVC.h"
#import "MMOvMarker+Dao.h"
#import "AddRoutineOvIconSelectTVC.h"

@interface RoutineAddTVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong,nonatomic) NSString *selectOvIconUrl;
@property (strong, nonatomic) IBOutlet UITableViewCell *ovIconTableCell;

@end

@implementation RoutineAddTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set default ov iconUrl
    self.selectOvIconUrl=@"ov_0";
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter and setter
-(void)setSelectOvIconUrl:(NSString *)selectOvIconUrl{
    _selectOvIconUrl=selectOvIconUrl;
    self.ovIconTableCell.imageView.image=[UIImage imageNamed:selectOvIconUrl];
}

#define ADD_ROUTINE_DONE_UNWIND_SEGUE @"AddRoutineDoneSegue"

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:ADD_ROUTINE_DONE_UNWIND_SEGUE]){
        MMRoutine *newRoutine=[MMRoutine createMMRoutineWithLat:self.currentLat
                                                        withLng:self.currentLng];
        //create default ovMarker
        MMOvMarker *ovMarker= [MMOvMarker createMMOvMarkerInRoutine:newRoutine];
        ovMarker.iconUrl=self.selectOvIconUrl;
        
        newRoutine.title=self.titleTextField.text;
        newRoutine.mycomment=self.descriptionTextView.text;
    }
}

-(IBAction)AddRoutineOvIconSelectDone:(UIStoryboardSegue *)segue{
    if([segue.sourceViewController isKindOfClass:[AddRoutineOvIconSelectTVC class]]){
        AddRoutineOvIconSelectTVC *ovIconSelectTVC=segue.sourceViewController;
        self.selectOvIconUrl=ovIconSelectTVC.selectedUrl;
    }
}

@end
