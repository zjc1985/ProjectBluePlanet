//
//  PinMarkerTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "PinMarkerTVC.h"
#import "OptionCell.h"

#define PIN_MARKER_DONE_UNWIND_SEGUE @"pinMarkerDoneUnwindSegue"

@interface PinMarkerTVC ()

@property (nonatomic,strong)NSArray *allRoutines;

@property(nonatomic,strong)NSIndexPath *checkedIndexPath;

@property(nonatomic,strong)NSIndexPath *imgOptionIndexPath;
@property(nonatomic,strong)NSIndexPath *contentOptionIndexPath;

@end

@implementation PinMarkerTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

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

#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1||indexPath.section==2) {
        return;
    }
    
    // Uncheck the previous checked row
    if(self.checkedIndexPath)
    {
        UITableViewCell *uncheckCell = [tableView
                                        cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger returnValue=0;
    
    switch (section) {
        case 0:{
            returnValue=self.allRoutines.count;
            break;
        }
        case 1:{
            returnValue=1;
        }
        case 2:{
            returnValue=1;
        }
        default:
            break;
    }
    
    return returnValue;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:{
            cell= [tableView dequeueReusableCellWithIdentifier:@"routineNameCell" forIndexPath:indexPath];
            MMRoutine *routine=[self.allRoutines objectAtIndex:indexPath.row];
            cell.textLabel.text=routine.title;
            break;
        }
        case 1:{
            OptionCell *isCopyImgOptionCell=[tableView dequeueReusableCellWithIdentifier:@"optionCell" forIndexPath:indexPath];
            isCopyImgOptionCell.optionNameLabel.text=@"need image";
            cell=isCopyImgOptionCell;
            self.imgOptionIndexPath=indexPath;
            break;
        }
        case 2:{
            OptionCell *isCopyContentOptionCell=[tableView dequeueReusableCellWithIdentifier:@"optionCell" forIndexPath:indexPath];
            isCopyContentOptionCell.optionNameLabel.text=@"need content";
            cell=isCopyContentOptionCell;
            self.contentOptionIndexPath=indexPath;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - ui action

- (IBAction)doneButtonClick:(id)sender {
    [self performSegueWithIdentifier:PIN_MARKER_DONE_UNWIND_SEGUE sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:PIN_MARKER_DONE_UNWIND_SEGUE]){
        self.selectedRoutine=[self.allRoutines objectAtIndex:self.checkedIndexPath.row];
        
        OptionCell *optionCell=[self.tableView cellForRowAtIndexPath:self.imgOptionIndexPath];
        self.needImage=optionCell.optionSwitch.on;
        
        OptionCell *contentOptionCell=[self.tableView cellForRowAtIndexPath:self.contentOptionIndexPath];
        self.needContent=optionCell.optionSwitch.on;
    }
}


@end
