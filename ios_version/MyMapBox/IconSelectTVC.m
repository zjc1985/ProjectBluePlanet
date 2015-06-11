//
//  IconSelectTVC.m
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "IconSelectTVC.h"
#import "IconSelectTableViewCell.h"
#import "MMMarkerIconInfo.h"

@interface IconSelectTVC ()

@property(nonatomic,strong) NSIndexPath* checkedIndexPath;

@end

@implementation IconSelectTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // Uncheck the previous checked row
    if(self.checkedIndexPath)
    {
        UITableViewCell *uncheckCell = [tableView
                                        cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    IconSelectTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
   
    UIImage *image=[UIImage imageNamed:cell.iconName];
    if(image){
        self.iconNameLabel.text=cell.iconName;
        self.iconImageView.image=image;
    }
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [MMMarkerIconInfo allMMMarkerIconInfo].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IconSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"iconCell" forIndexPath:indexPath];
    
    MMMarkerIconInfo *iconInfo=[[MMMarkerIconInfo allMMMarkerIconInfo] objectAtIndex:indexPath.row];
    
    cell.iconName=iconInfo.iconName;
    cell.category=iconInfo.category;
    
    if ([self.iconNameLabel.text isEqualToString:iconInfo.iconName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.checkedIndexPath=indexPath;
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
