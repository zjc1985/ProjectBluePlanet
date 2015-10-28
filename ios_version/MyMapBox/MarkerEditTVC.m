//
//  MarkerEditTVC.m
//  MyMapBox
//
//  Created by bizappman on 4/17/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MarkerEditTVC.h"
#import "SlideNumSelectTVC.h"
#import "IconSelectTVC.h"
#import "CommonUtil.h"
#import "MMMarkerIconInfo.h"
#import "SelectImageTVC.h"
#import "LocalImageUrl+Dao.h"
#import "UserAlbumsTVC.h"

#import <AVOSCloud/AVOSCloud.h>

#define MARKER_EDIT_VIEW_SHOW_ALBUMS_SEGUE @"markerEditShowAlbumsSegue"

@interface MarkerEditTVC ()<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITextField *markerTitleTextField;
@property (weak, nonatomic) IBOutlet UILabel *markerSlideNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *markerIconUrlLabel;
@property (weak, nonatomic) IBOutlet UITextView *markerDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *uploadImageBtn;
@property (weak, nonatomic) IBOutlet UITableViewCell *updateLoactionCell;

@property (nonatomic, strong)NSMutableArray *uploadImageUrls; //of NSStrings

@property(strong,nonatomic) PHCachingImageManager *imageManager;

@end

@implementation MarkerEditTVC

-(NSMutableArray *)uploadImageUrls{
    if(!_uploadImageUrls){
        _uploadImageUrls=[NSMutableArray new];
    }
    return _uploadImageUrls;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

-(void)updateUI{
    if ([[self.marker allSubMarkers] count]>0) {
        [self.updateLoactionCell setHidden:NO];
    }else{
        [self.updateLoactionCell setHidden:YES];
    }
    
    self.markerTitleTextField.text=self.marker.title;
    //self.markerSlideNumLabel.text=[NSString stringWithFormat:@"%@",@([self.marker.slideNum integerValue])];
    self.markerIconUrlLabel.text=[self.marker iconUrl];
    
    self.markerDescriptionTextView.text=self.marker.mycomment;
    
    UIImage *iconImage=[UIImage imageNamed:self.marker.iconUrl];
    if(iconImage){
        self.iconImageView.image=iconImage;
    }
    
    
    if ([self.marker.localImages allObjects].count>0) {
        self.uploadImageBtn.enabled=YES;
        
        NSString *title=[NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"Upload", @"")
                         ,@([self.marker.localImages allObjects].count)
                         ,NSLocalizedString(@"Images", @"")];
        
        [self.uploadImageBtn setTitle:title forState:UIControlStateNormal];
    }else{
        self.uploadImageBtn.enabled=NO;
    }
}

#pragma mark - getter and setter
-(PHCachingImageManager *)imageManager{
    if(!_imageManager){
        _imageManager=[[PHCachingImageManager alloc]init];
    }
    return _imageManager;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"markerEditDoneSegue"]){
        self.marker.title=self.markerTitleTextField.text;
        self.marker.mycomment=self.markerDescriptionTextView.text;
        self.marker.updateTimestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
        self.marker.iconUrl=self.markerIconUrlLabel.text;
        self.marker.category=[NSNumber numberWithUnsignedInteger:[MMMarkerIconInfo findCategoryWithIconName:self.marker.iconUrl]];
        
        /*
        for (NSString *newImageUrl in self.uploadImageUrls) {
            [self.marker addImageUrl:newImageUrl];
        }
         */
    }
    
    if([segue.identifier isEqualToString:MARKER_EDIT_VIEW_SHOW_ALBUMS_SEGUE]){
        UINavigationController *navController=(UINavigationController *)segue.destinationViewController;
        UserAlbumsTVC *userAlbumsTVC=navController.viewControllers[0];
        userAlbumsTVC.incomingSegueName=MARKER_EDIT_VIEW_SHOW_ALBUMS_SEGUE;
    }
    
    if([segue.destinationViewController isKindOfClass:[SlideNumSelectTVC class]]){
        SlideNumSelectTVC *slideNumSelectTVC=segue.destinationViewController;
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"slideNum" ascending:YES];
        NSMutableArray *mutableArray=[NSMutableArray arrayWithArray:[self.allSubMarkers sortedArrayUsingDescriptors:@[sortDescriptor]]];
        slideNumSelectTVC.markersArray=mutableArray;
    }
    
    if([segue.destinationViewController isKindOfClass:[IconSelectTVC class]]){
        IconSelectTVC *iconSelectTVC=segue.destinationViewController;
        iconSelectTVC.iconNameLabel=self.markerIconUrlLabel;
        iconSelectTVC.iconImageView=self.iconImageView;
    }
}

-(IBAction)markerEditViewSelectImageAssetDone:(UIStoryboardSegue *)segue{
    if([segue.sourceViewController isKindOfClass:[SelectImageTVC class]]){
        SelectImageTVC *selectImageTVC=segue.sourceViewController;
        NSArray *assets=selectImageTVC.selectedAssetsOut;
        for (PHAsset *imageAsset in assets) {
            //do things
            [self.imageManager requestImageDataForAsset:imageAsset options:nil
                                          resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                              //do somthing

                                              NSString *imageUrl=[CommonUtil saveImageByData:imageData];
                                              //attachImage
                                              [LocalImageUrl createLocalImageUrl:imageUrl inMarker:self.marker];
                                              [self updateUI];
                                          }];
        }
        [CommonUtil alert:@"attach Complete"];
    }
}

#pragma mark ui action

- (IBAction)updateMarkerLocation:(id)sender {
    [self.marker updateLocationAccording2SubMarkers];
    [CommonUtil alert:@"Update Location Done"];
}


- (IBAction)deleteClick:(id)sender {
    UIActionSheet *actionSheet= [[UIActionSheet alloc]initWithTitle:@"Delete Routine"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:@"Delete"
                                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (IBAction)attachImageClick:(id)sender {
    [self performSegueWithIdentifier:MARKER_EDIT_VIEW_SHOW_ALBUMS_SEGUE sender:nil];
}

- (IBAction)deleteImageClick:(id)sender {
    
}


- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==actionSheet.destructiveButtonIndex){
        NSLog(@"delete marker");
        [self performSegueWithIdentifier:@"deleteMarkerUnwindSegue" sender:nil ];
    }
}

- (IBAction)uploadImageClick:(id)sender {
    [self uploadMultiImages2LeanCLoud:[self.marker.localImages allObjects]];
}

-(void)uploadMultiImages2LeanCLoud:(NSArray *)localImageUrls // of LocalImageUrl
{
    
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"upload"
                                                     message:[NSString stringWithFormat:@"upload %@ images, 0 complete",@(localImageUrls.count)]
                                                    delegate:nil
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:nil];
    [alertView show];
    
    __block NSUInteger completeNum=0;
    
    NSMutableArray *progressArray=[[NSMutableArray alloc]init];
    
    for (NSUInteger i=0; i<localImageUrls.count; i++) {
        [progressArray addObject:[NSNumber numberWithUnsignedInteger:0]];
    }
    
    for (NSUInteger i=0; i<localImageUrls.count; i++) {
        //upload
        
        LocalImageUrl *localImageUrl=localImageUrls[i];
        
        UIImage *compressImage=[CommonUtil compressForUpload:[CommonUtil loadImage:localImageUrl.fileName] scale:0.6];
        
        AVFile *imageFile=[AVFile fileWithName:@"iosUploadPic.png" data:UIImagePNGRepresentation(compressImage)];
        
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            completeNum++;
            
            alertView .message=[NSString stringWithFormat:@"upload %@ images, %@ complete",@(localImageUrls.count),@(completeNum)];
            
            if(succeeded){
                NSLog(@"upload succeed %@",imageFile.url);
                [self.marker addImageUrl:imageFile.url];
                [LocalImageUrl remove:localImageUrl];
            }
            
            if(error){
                NSLog(@"%@",error.localizedDescription);
            }
            
            if(completeNum==localImageUrls.count){
                [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];
                [self updateUI];
                self.uploadImageBtn.enabled=NO;
            }
        } progressBlock:^(NSInteger percentDone) {
            progressArray[i]=[NSNumber numberWithUnsignedInteger:percentDone];
            NSUInteger total=0;
            for (NSNumber *progress in progressArray) {
                total=total+[progress unsignedIntegerValue];
            }
            
            
            alertView.message=[NSString stringWithFormat:@"upload %@ images, %@ complete. progress:%@"
                               ,@(localImageUrls.count),@(completeNum),@(total/localImageUrls.count)];
        }];
    }
}


@end
