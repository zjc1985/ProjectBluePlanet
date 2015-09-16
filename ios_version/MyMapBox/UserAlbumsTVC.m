//
//  RootAlbumsListTVC.m
//  photoFrameWorkExercise
//
//  Created by bizappman on 9/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "UserAlbumsTVC.h"
#import "SelectImageTVC.h"

@import Photos;

static NSString * const AllPhotosReuseIdentifier = @"AllPhotosCell";
static NSString * const CollectionCellReuseIdentifier = @"CollectionCell";

static NSString * const AllPhotosSegue = @"showAllPhotos";
static NSString * const CollectionSegue = @"showCollection";

@interface UserAlbumsTVC ()

@property (strong) PHFetchResult *userAlbumFetchResult;

@end

@implementation UserAlbumsTVC

-(void)viewDidLoad{
    [super viewDidLoad];
    
    PHFetchResult *userAlbums=[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    self.userAlbumFetchResult=userAlbums;
}


- (IBAction)cancelClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:AllPhotosSegue]){
        SelectImageTVC *thumbNailImageTVC=segue.destinationViewController;
    
        PHFetchOptions *options=[[PHFetchOptions alloc]init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        
        thumbNailImageTVC.assetsFetchResults=[PHAsset fetchAssetsWithOptions:options];
    }else if ([segue.identifier isEqualToString:CollectionSegue]){
        SelectImageTVC * thumbNailImageTVC=segue.destinationViewController;
        NSIndexPath *indexPath=[self.tableView indexPathForCell:sender];
        PHCollection *collection=self.userAlbumFetchResult[indexPath.row];
        
        if([collection isKindOfClass:[PHAssetCollection class]]){
            PHAssetCollection *assetCollection=(PHAssetCollection *)collection;
            
            PHFetchOptions *options=[[PHFetchOptions alloc]init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            
            PHFetchResult *assetsFetchResult=[PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            thumbNailImageTVC.assetsFetchResults=assetsFetchResult;
        }
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows=0;
    if(section ==0){
        numberOfRows=1;
    }else{
        numberOfRows=self.userAlbumFetchResult.count;
    }
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    NSString *localizedTitle=nil;
    if(indexPath.section==0){
        cell=[tableView dequeueReusableCellWithIdentifier:AllPhotosReuseIdentifier forIndexPath:indexPath];
        localizedTitle=NSLocalizedString(@"All Photos", @"");
    }else{
        cell=[tableView dequeueReusableCellWithIdentifier:CollectionCellReuseIdentifier forIndexPath:indexPath];
        PHCollection *collection=self.userAlbumFetchResult[indexPath.row];
        localizedTitle=collection.localizedTitle;
    }
    cell.textLabel.text=localizedTitle;
    return cell;
}





@end
