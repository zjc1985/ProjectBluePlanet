//
//  RoutineEditTVC.m
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "RoutineEditTVC.h"

@interface RoutineEditTVC ()<UITextFieldDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation RoutineEditTVC

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

- (IBAction)deleteRoutineClick:(id)sender {
    UIActionSheet *actionSheet= [[UIActionSheet alloc]initWithTitle:@"Delete Routine"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:@"Delete"
                                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}




-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==actionSheet.destructiveButtonIndex){
        NSLog(@"Delete confirm");
        [self performSegueWithIdentifier:@"deleteRoutineUnwindSegue" sender:nil];
    }
}



@end
