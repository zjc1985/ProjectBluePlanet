//
//  PinMarkerRoutineSelectTVC.m
//  MyMapBox
//
//  Created by bizappman on 15/10/15.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "PinMarkerRoutineSelectTVC.h"
#import "MMRoutine+Dao.h"
#import "PinMarkerSelectNodeTVC.h"

@interface PinMarkerRoutineSelectTVC ()

@property(nonatomic,strong,readonly) NSArray *allRoutines;
@property(nonatomic,strong,readonly) id<Routine> currentRoutine;

@end


@implementation PinMarkerRoutineSelectTVC

@synthesize allRoutines=_allRoutines;
@synthesize currentRoutine=_currentRoutine;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - UI Action
- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter and setter
-(NSArray *)allRoutines{
    if(!_allRoutines){
        _allRoutines=[MMRoutine fetchAllModelRoutines];
    }
    return _allRoutines;
}

-(id<Routine>)currentRoutine{
    if(!_currentRoutine){
        _currentRoutine=[self.nodeNeedPin belongRoutine];
    }
    
    return _currentRoutine;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"pinMarkerSelectNodeSegue"]){
        if(sender){
            PinMarkerSelectNodeTVC *selectNodeTVC=segue.destinationViewController;
            selectNodeTVC.nodeNeedPin=self.nodeNeedPin;
            selectNodeTVC.desRoutine=sender;
        }
    }
}


#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id<Routine> selectRoutine;
    if (indexPath.section==0){
        selectRoutine=self.currentRoutine;
    }else{
        selectRoutine=self.allRoutines[indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"pinMarkerSelectNodeSegue" sender:selectRoutine];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Current Routine", @"Current Routine");
            break;
        case 1:
            sectionName = NSLocalizedString(@"My Other Routine", @"My Other Routine");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger returnValue=0;
    
    switch (section) {
        case 0:{
            returnValue=1;
            break;
        }
        case 1:{
            returnValue=self.allRoutines.count;
        }
        default:
            break;
    }
    return returnValue;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RoutineNameCell" forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:{
            cell.textLabel.text=[self.currentRoutine title];
            break;
        }
        case 1:{
            id<Routine> routine=self.allRoutines[indexPath.row];
            cell.textLabel.text=[routine title];
            break;
        }
        default:
            break;
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



@end
