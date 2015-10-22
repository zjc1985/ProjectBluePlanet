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

#import "LocalImageUrl+Dao.h"

#import <AVOSCloud/AVOSCloud.h>

@interface MarkerEditTVC ()<UIActionSheetDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *markerTitleTextField;
@property (weak, nonatomic) IBOutlet UILabel *markerSlideNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *markerIconUrlLabel;
@property (weak, nonatomic) IBOutlet UITextView *markerDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *uploadImageBtn;

@property (nonatomic, strong)NSMutableArray *uploadImageUrls; //of NSStrings

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
    self.markerTitleTextField.text=self.marker.title;
    self.markerSlideNumLabel.text=[NSString stringWithFormat:@"%@",@([self.marker.slideNum integerValue])];
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


#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"markerEditDoneSegue"]){
        self.marker.title=self.markerTitleTextField.text;
        self.marker.mycomment=self.markerDescriptionTextView.text;
        self.marker.slideNum=[NSNumber numberWithInteger:[self.markerSlideNumLabel.text integerValue]];
        self.marker.updateTimestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
        self.marker.iconUrl=self.markerIconUrlLabel.text;
        self.marker.category=[NSNumber numberWithUnsignedInteger:[MMMarkerIconInfo findCategoryWithIconName:self.marker.iconUrl]];
        
        /*
        for (NSString *newImageUrl in self.uploadImageUrls) {
            [self.marker addImageUrl:newImageUrl];
        }
         */
    }
    
    if([segue.destinationViewController isKindOfClass:[SlideNumSelectTVC class]]){
        SlideNumSelectTVC *slideNumSelectTVC=segue.destinationViewController;
        slideNumSelectTVC.slideNumLabel=self.markerSlideNumLabel;
        slideNumSelectTVC.markerCount=self.markerCount;
    }
    
    if([segue.destinationViewController isKindOfClass:[IconSelectTVC class]]){
        IconSelectTVC *iconSelectTVC=segue.destinationViewController;
        iconSelectTVC.iconNameLabel=self.markerIconUrlLabel;
        iconSelectTVC.iconImageView=self.iconImageView;
    }
}

#pragma mark ui action

- (IBAction)deleteClick:(id)sender {
    UIActionSheet *actionSheet= [[UIActionSheet alloc]initWithTitle:@"Delete Routine"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:@"Delete"
                                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (IBAction)attachImageClick:(id)sender {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *picker=[[UIImagePickerController alloc] init];
        picker.delegate=self;
        picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        
        picker.allowsEditing=YES;
        
        [self presentViewController:picker animated:YES completion:nil];
    }else{
        [CommonUtil alert:@"Not support photo library"];
    }
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


#pragma mark UIImagePicker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage *originalImage=info[UIImagePickerControllerEditedImage];
    
    NSString *imageUrl=[CommonUtil saveImage:originalImage];
    //attachImage
    [LocalImageUrl createLocalImageUrl:imageUrl inMarker:self.marker];
    [CommonUtil alert:@"attach Complete"];
    [self updateUI];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


@end
