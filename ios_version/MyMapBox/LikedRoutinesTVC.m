//
//  LikedRoutinesTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/25/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "LikedRoutinesTVC.h"
#import "CloudManager.h"
#import "MMSearchedRoutine.h"
#import "SearchRoutineInfoTVC.h"

#define SHOW_LIKED_ROUTINE_SEGUE @"showLikedRoutineSegue"

@interface LikedRoutinesTVC ()

@property(nonatomic,strong)NSArray *routines;

@end

@implementation LikedRoutinesTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl=[[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    [self reloadData];
    [self.tabBarController.tabBar setHidden:YES];
}

-(void)reloadData{
    [CloudManager queryLikedRoutines:^(NSError *error, NSArray *searchRoutines) {
        [self.refreshControl endRefreshing];
        if(!error){
            self.routines=searchRoutines;
            [self.tableView reloadData];
        }else{
            [CommonUtil alert:error.localizedDescription];
        }
    }];
}

#pragma mark - getter and setter
-(NSArray *)routines{
    if(!_routines){
        _routines=[[NSArray alloc]init];
    }
    return _routines;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.routines.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"likedRoutineCell" forIndexPath:indexPath];
    
    MMSearchedRoutine *routine=[self.routines objectAtIndex:indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%@",routine.title];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"owned by %@",routine.userName];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MMSearchedRoutine *routine=[self.routines objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SHOW_LIKED_ROUTINE_SEGUE  sender:routine];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SHOW_LIKED_ROUTINE_SEGUE]) {
        SearchRoutineInfoTVC *destTVC=segue.destinationViewController;
        destTVC.routine=sender;
    }
}

@end
