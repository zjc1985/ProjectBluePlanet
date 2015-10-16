//
//  PinMarkerToCurrentRoutineTVC.m
//  MyMapBox
//
//  Created by bizappman on 15/10/14.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "PinMarkerSelectNodeTVC.h"
#import "MMTreeNode+Dao.h"
#import "MMRoutine+Dao.h"

typedef enum : NSUInteger {
    copyPin = 0,
    movePin = 1,
} ActionSheetIndexForPin;

@interface PinMarkerSelectNodeTVC ()<UIActionSheetDelegate>

@property (nonatomic,strong,readonly)NSArray *nodesWithNoSubNodes; //of MMTreeNode>
@property (nonatomic,strong,readonly)NSArray *nodesWithSubNodes; //of MMTreeNode>

@property (nonatomic,strong)id<TreeNode> selectNode;
@property (nonatomic,assign) BOOL isSetToRoot;

@end

@implementation PinMarkerSelectNodeTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isSetToRoot=NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - getter and setter

@synthesize nodesWithNoSubNodes=_nodesWithNoSubNodes;
@synthesize nodesWithSubNodes=_nodesWithSubNodes;

-(NSArray *)nodesWithNoSubNodes{
    if(!_nodesWithNoSubNodes){
        NSMutableArray *result=[[NSMutableArray alloc]init];
        for (MMTreeNode *node in [self.desRoutine allTreeNodes]) {
            if([[node allSubTreeNodes] count]==0){
                [result addObject:node];
            }
        }
        _nodesWithNoSubNodes=result;
    }
    return _nodesWithNoSubNodes;
}

-(NSArray *)nodesWithSubNodes{
    if(!_nodesWithSubNodes){
        NSMutableArray *result=[[NSMutableArray alloc]init];
        for (MMTreeNode *node in [self.desRoutine allTreeNodes]) {
            if([[node allSubTreeNodes] count]>0){
                [result addObject:node];
            }
        }
        _nodesWithSubNodes=result;
    }
    return _nodesWithSubNodes;
}

-(BOOL)isPinToOtherRoutine{
    if ([[[self.nodeNeedPin belongRoutine] uuid] isEqualToString:self.desRoutine.uuid]) {
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - UI Action

- (IBAction)doneClick:(id)sender {
    if(self.selectNode==nil && self.isSetToRoot==NO){
        [CommonUtil alert:NSLocalizedString(@"Please Select one marker pin to", nil)];
    }else{
        
        if([self isPinToOtherRoutine]){
#warning not finished
            NSLog(@"Pin to other routine");
            [self performSegueWithIdentifier:@"pinDoneSegue" sender:nil];
        }else{
            UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Copy",nil),
                                  NSLocalizedString(@"Move",nil),
                                  nil];
            [sheet showInView:self.view];
        }
        
    }
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.cancelButtonIndex==buttonIndex){
        return;
    }
    
    switch (buttonIndex) {
        case copyPin:{
            if([self.nodeNeedPin isKindOfClass:[MMTreeNode class]]){
                MMTreeNode *nodeNeedPin=self.nodeNeedPin;
                [nodeNeedPin copySelfTo:self.selectNode inRoutine:self.desRoutine];
            }
            break;
        }
        case movePin:{
            if([self.nodeNeedPin isKindOfClass:[MMTreeNode class]]){
                MMTreeNode *nodeNeedPin=self.nodeNeedPin;
                nodeNeedPin.parentNode=self.selectNode;
            }
            break;
        }
        default:
            break;
    }
    [self performSegueWithIdentifier:@"pinDoneSegue" sender:nil];
}

#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        self.selectNode=self.nodesWithSubNodes[indexPath.row];
        self.isSetToRoot=NO;
    }else if(indexPath.section==1){
        self.selectNode=self.nodesWithNoSubNodes[indexPath.row];
        self.isSetToRoot=NO;
    }else{
        self.selectNode=nil;
        self.isSetToRoot=YES;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger returnValue=0;
    
    switch (section) {
        case 0:{
            returnValue=[self.nodesWithSubNodes count];
            break;
        }
        case 1:{
            returnValue=[self.nodesWithNoSubNodes count];
            break;
        }
        case 2:{
            returnValue=1;
            break;
        }
        default:
            break;
    }
    
    return returnValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nodeCell" forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:{
            id<TreeNode> node=self.nodesWithSubNodes[indexPath.row];
            cell.textLabel.text=[[node belongMarker] title];
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",@([node allSubTreeNodes].count)];
            break;
        }
        case 1:{
            id<TreeNode> node=self.nodesWithNoSubNodes[indexPath.row];
            cell.textLabel.text=[[node belongMarker] title];
            cell.detailTextLabel.text=@"0";
            break;
        }
        case 2:{
            cell.textLabel.text=NSLocalizedString(@"Root", nil);
            cell.detailTextLabel.text=@"";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
