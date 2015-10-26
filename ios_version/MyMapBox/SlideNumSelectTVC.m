//
//  SelectSlideNumTVCTableViewController.m
//  MyMapBox
//
//  Created by bizappman on 4/28/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "SlideNumSelectTVC.h"
#import "MarkerEditTVC.h"

@interface SlideNumSelectTVC ()

@property(nonatomic,strong) NSIndexPath* checkedIndexPath;

@end

@implementation SlideNumSelectTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.editing=YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.markersArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"slideNumTableViewCell" forIndexPath:indexPath];
    
    MMMarker *marker=[self.markersArray objectAtIndex:indexPath.row];
    marker.slideNum=[NSNumber numberWithInteger:indexPath.row+1];
    cell.textLabel.text=marker.title;
    cell.detailTextLabel.text=[marker.slideNum description];
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSLog(@"move row from %@ to %@",@(fromIndexPath.row),@(toIndexPath.row));
    
    MMMarker *marker=[self.markersArray objectAtIndex:fromIndexPath.row];
    NSLog(@"from Marker %@",marker.title);
    
    [self.markersArray removeObjectAtIndex:fromIndexPath.row];
    [self.markersArray insertObject:marker atIndex:toIndexPath.row];
    [self.tableView reloadData];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation



@end
