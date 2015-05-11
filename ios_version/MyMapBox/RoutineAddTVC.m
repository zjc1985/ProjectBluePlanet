//
//  RoutineAddTVC.m
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "RoutineAddTVC.h"

@interface RoutineAddTVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation RoutineAddTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#define ADD_ROUTINE_DONE_UNWIND_SEGUE @"AddRoutineDoneSegue"

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:ADD_ROUTINE_DONE_UNWIND_SEGUE]){
        MMRoutine *newRoutine=[MMRoutine createMMRoutineWithLat:self.currentLat
                                                        withLng:self.currentLng];
        newRoutine.title=self.titleTextField.text;
        newRoutine.mycomment=self.descriptionTextView.text;
    }
}

@end
