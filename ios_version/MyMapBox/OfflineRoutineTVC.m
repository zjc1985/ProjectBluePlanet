//
//  OfflineRoutineTVC.m
//  MyMapBox
//
//  Created by bizappman on 4/28/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "OfflineRoutineTVC.h"
#import "OfflineRoutineTableViewCell.h"

@interface OfflineRoutineTVC ()

@property(nonatomic,strong)NSTimer *timer;

@end

@implementation OfflineRoutineTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"offlineVC view did load");
    self.timer=[NSTimer scheduledTimerWithTimeInterval:0.5
                                                target:self
                                              selector:@selector(updateALLTableCell)
                                              userInfo:nil repeats:YES];
}


-(void)viewDidDisappear:(BOOL)animated{
    [self.timer invalidate];
    self.timer=nil;
}

-(void)updateALLTableCell{
    NSLog(@"refresh data");
    
    NSUInteger count=[self.modelRoutines count];
    
    NSUInteger numFinishCach=0;
    
    for (MMRoutine *each in self.modelRoutines) {
        if(each.cachProgress==1){
            numFinishCach++;
        }
    }
    
    if(numFinishCach==count){
        [self.timer invalidate];
        self.timer=nil;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.modelRoutines count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OfflineRoutineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"offlineStatue" forIndexPath:indexPath];
    
    MMRoutine *eachRoutine=self.modelRoutines[indexPath.row];
    
    cell.routineTitleLabel.text=eachRoutine.title;
    NSLog(@"%f",eachRoutine.cachProgress);
    cell.routineProgressLabel.text=[NSString stringWithFormat:@"%u%%", (NSUInteger)(eachRoutine.cachProgress*100)];
    cell.routineProgressBar.progress=eachRoutine.cachProgress;
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
