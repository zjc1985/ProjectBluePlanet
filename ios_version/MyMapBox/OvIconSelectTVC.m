//
//  OvIconSelectTVC.m
//  MyMapBox
//
//  Created by yufu on 15/7/26.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "OvIconSelectTVC.h"

@interface OvIconSelectTVC ()

@property(strong,nonatomic)NSArray *allOvIconUrls;

@end

@implementation OvIconSelectTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - getter and setter
-(NSArray *)allOvIconUrls{
    if(!_allOvIconUrls){
        NSMutableArray *urlArray=[[NSMutableArray alloc]init];
        for (NSInteger i=0; i<12; i++) {
            NSString *url=[NSString stringWithFormat:@"ov_%i",i];
            [urlArray addObject:url];
        }
        _allOvIconUrls=urlArray;
    }
    
    return _allOvIconUrls;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allOvIconUrls.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ovIconCell" forIndexPath:indexPath];
    
    cell.textLabel.text=[self.allOvIconUrls objectAtIndex:indexPath.row];
    cell.imageView.image=[UIImage imageNamed:[self.allOvIconUrls objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedUrl=[self.allOvIconUrls objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ovIconSelectDoneSegue" sender:nil];
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
