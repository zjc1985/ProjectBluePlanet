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

#import <AVOSCloud/AVOSCloud.h>

@interface MarkerEditTVC ()<UIActionSheetDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *markerTitleTextField;
@property (weak, nonatomic) IBOutlet UILabel *markerSlideNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *markerIconUrlLabel;
@property (weak, nonatomic) IBOutlet UITextView *markerDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

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
    self.markerSlideNumLabel.text=[NSString stringWithFormat:@"%u",[self.marker.slideNum integerValue]];
    self.markerIconUrlLabel.text=[self.marker iconUrl];
    
    self.markerDescriptionTextView.text=self.marker.mycomment;
    
    UIImage *iconImage=[UIImage imageNamed:self.marker.iconUrl];
    if(iconImage){
        self.iconImageView.image=iconImage;
    }
}

#pragma mark segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"markerEditDoneSegue"]){
        self.marker.title=self.markerTitleTextField.text;
        self.marker.mycomment=self.markerDescriptionTextView.text;
        self.marker.slideNum=[NSNumber numberWithInteger:[self.markerSlideNumLabel.text integerValue]];
        self.marker.updateTimestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
        self.marker.iconUrl=self.markerIconUrlLabel.text;
        self.marker.category=[NSNumber numberWithUnsignedInteger:[MMMarkerIconInfo findCategoryWithIconName:self.marker.iconUrl]];
        
        for (NSString *newImageUrl in self.uploadImageUrls) {
            [self.marker addImageUrl:newImageUrl];
        }
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

- (IBAction)uploadImageClick:(id)sender {
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

#pragma mark UIImagePicker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage *originalImage=info[UIImagePickerControllerEditedImage];
    
    //compress image
    CGFloat compressScale=0.6;
    NSData *imageData=UIImagePNGRepresentation([CommonUtil compressForUpload:originalImage scale:compressScale]);
    NSLog(@"upload image size : %u k",imageData.length/1000);
    
    
    AVFile *imageFile=[AVFile fileWithName:@"iosUploadPic.png" data:imageData];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"upload" message:@"progress:0%" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alertView show];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"upload succeed %@",imageFile.url);
            [self.uploadImageUrls addObject:imageFile.url];
        }else{
            NSLog(@"fail");
            if(error){
                NSLog(@"%@",error.localizedDescription);
            }
        }
        
        [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];
    } progressBlock:^(NSInteger percentDone) {
        alertView.message=[NSString stringWithFormat:@"progress: %u%%",percentDone];
    }];
    
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
