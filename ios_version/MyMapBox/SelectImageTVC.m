//
//  ThumbNailImageTVC.m
//  photoFrameWorkExercise
//
//  Created by bizappman on 9/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "SelectImageTVC.h"
#import "SelectImageCell.h"
@import CoreLocation;

static NSString * const ThumbImageCell = @"thumbCell";

#define SHOW_USER_ALBUMS_SEGUE @"routineDetailShowAlbumsSegue"
#define UNWIND_SHOW_USER_ALBUMS_SEGUE @"unwindRoutineDetailShowAlbumsSegue"

#define MARKER_EDIT_VIEW_SHOW_ALBUMS_SEGUE @"markerEditShowAlbumsSegue"
#define UNWIND_MARKER_EDIT_VIEW_SHOW_ALBUMS_SEGUE @"unwindMarkerEditShowAlbumsSegue"

@interface SelectImageTVC ()

@property(strong,nonatomic)PHCachingImageManager *imageManager;
@property(strong,nonatomic)NSArray *assetsWithLocation; // of PHAsset
@property(strong,nonatomic)NSMutableArray *selectedAssets; //of PHAsset

@end


@implementation SelectImageTVC

static CGSize AssetThumbnailSize;

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    CGFloat scale = [UIScreen mainScreen].scale;
    AssetThumbnailSize = CGSizeMake(72 * scale, 72 * scale);
}

#pragma mark - getter and setter
-(NSArray *)selectedAssetsOut{
    return self.selectedAssets;
}

-(NSMutableArray *)selectedAssets{
    if(!_selectedAssets){
        _selectedAssets=[[NSMutableArray alloc]init];
    }
    return _selectedAssets;
}

-(PHCachingImageManager *)imageManager{
    if(!_imageManager){
        _imageManager=[[PHCachingImageManager alloc]init];
    }
    return _imageManager;
}

-(NSArray *)assetsWithLocation{
    if(!_assetsWithLocation){
        NSMutableArray *array=[[NSMutableArray alloc]init];
        for (PHAsset *asset in self.assetsFetchResults) {
            if(asset.location){
                [array addObject:asset];
            }
        }
        _assetsWithLocation=array;
    }
    return _assetsWithLocation;
}

#pragma mark - ui action
- (IBAction)doneClick:(id)sender {
    NSLog(@"incoming segue name:%@",self.incomingSegueName);
    
    if([self.incomingSegueName isEqualToString:SHOW_USER_ALBUMS_SEGUE]){
        [self performSegueWithIdentifier:UNWIND_SHOW_USER_ALBUMS_SEGUE sender:nil];
    }else if ([self.incomingSegueName isEqualToString:MARKER_EDIT_VIEW_SHOW_ALBUMS_SEGUE]){
        [self performSegueWithIdentifier:UNWIND_MARKER_EDIT_VIEW_SHOW_ALBUMS_SEGUE sender:nil];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetsWithLocation.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectImageCell *cell = [tableView dequeueReusableCellWithIdentifier:ThumbImageCell forIndexPath:indexPath];
    
    // Increment the cell's tag
    NSInteger currentTag=cell.tag+1;
    cell.tag=currentTag;
    
    
    PHAsset *asset=self.assetsWithLocation[indexPath.row];
    
    
    if([self.selectedAssets containsObject:asset]){
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    
    
    if(asset.location){
        cell.locationLabel.text=[NSString stringWithFormat:@"lat:%.3f lng:%.3f", asset.location.coordinate.latitude,asset.location.coordinate.longitude];
        cell.creationTimeLabel.text=[asset.creationDate description];
    }else{
        cell.locationLabel.text=@"N/A";
    }
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:AssetThumbnailSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
             // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
            if(cell.tag==currentTag){
                cell.thumbImage.image=result;
            }
    }];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    PHAsset *asset=self.assetsWithLocation[indexPath.row];
    
    if(cell.accessoryType==UITableViewCellAccessoryCheckmark){
        cell.accessoryType=UITableViewCellAccessoryNone;
        [self.selectedAssets removeObject:asset];
    }else{
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
        [self.selectedAssets addObject:asset];
    }
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
