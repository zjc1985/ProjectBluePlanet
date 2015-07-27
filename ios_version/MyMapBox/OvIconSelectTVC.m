//
//  OvIconSelectTVC.m
//  MyMapBox
//
//  Created by yufu on 15/7/26.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "OvIconSelectTVC.h"

@interface OvIconSelectTVC ()



@end

@implementation OvIconSelectTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedUrl=[self.allOvIconUrls objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ovIconSelectDoneSegue" sender:nil];
}

-(NSString *)reUseCellName{
    return @"ovIconCell";
}

@end
