//
//  LikedWorldTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/24/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "LikedWorldTVC.h"
#import <AVOSCloud/AVOSCloud.h>
#import "CommonUtil.h"

#import "CloudManager.h"

#import "OtherUserWorldVC.h"

#define SHOW_LIKED_USER_WORLD_SEGUE @"showLikedUserWorldSegue"

@interface LikedWorldTVC ()

@property(nonatomic,strong)NSArray *avusers;

@end

@implementation LikedWorldTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.refreshControl=[[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    [self reloadData];
}

-(void)reloadData{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [CloudManager queryFollowees:^(NSError *error, NSArray *user) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.refreshControl endRefreshing];
        if (!error) {
            self.avusers=user;
            [self.tableView reloadData];
        }else{
            [CommonUtil alert:error.localizedDescription];
        }
    }];
}

#pragma mark - getter and setter
-(NSArray *)avusers{
    if(!_avusers){
        _avusers=[[NSArray alloc]init];
    }
    return _avusers;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.avusers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    
    AVUser *otherUser=[self.avusers objectAtIndex:indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%@'s world",otherUser.username];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AVUser *user=[self.avusers objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SHOW_LIKED_USER_WORLD_SEGUE sender:user];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SHOW_LIKED_USER_WORLD_SEGUE]){
        OtherUserWorldVC *destVC=segue.destinationViewController;
        AVUser *user=sender;
        destVC.userId=user.objectId;
        destVC.userName=user.username;
    }
}

@end
