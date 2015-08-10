//
//  AddRoutineOvIconSelectTVC.m
//  MyMapBox
//
//  Created by bizappman on 7/27/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "AddRoutineOvIconSelectTVC.h"

@interface AddRoutineOvIconSelectTVC ()

@end

@implementation AddRoutineOvIconSelectTVC

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedUrl=[self.allOvIconUrls objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"AddRoutineOvIconSelectDoneSegue" sender:nil];
}

-(NSString *)reUseCellName{
    return @"addRoutineOvIconCell";
}


@end
