//
//  SearchRoutineDetailMapVC.m
//  MyMapBox
//
//  Created by bizappman on 6/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "SearchRoutineDetailMapVC.h"
#import "SearchMarkerInfoTVC.h"
#import "MMSearchdeMarker.h"
#import "CloudManager.h"
#import "MarkerInfoView.h"
#import "MMMarker+Dao.h"
#import "NSMutableArray+StackExtension.h"

#define SHOW_SEARCH_MARKER_DETAIL_SEGUE @"showSearchMarkerDetailSegue"

@interface SearchRoutineDetailMapVC ()<RMMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *slidePlayButton;

@property (weak, nonatomic) IBOutlet MarkerInfoView *markerInfoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *markerInfoHeightConstraint;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *markerInfoImages;


@end

@implementation SearchRoutineDetailMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init markerInfoView
    [self.markerInfoView setHidden:YES];
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(markerInfoViewClick)];
    tapGesture.numberOfTapsRequired=1;
    [self.markerInfoView addGestureRecognizer:tapGesture];
    
    
    self.slideIndicator=-1;
    
    self.mapView.maxZoom=17;
    
    self.mapView.zoom=15;
    
    CLLocationCoordinate2D center=CLLocationCoordinate2DMake([[self.routine lat] doubleValue], [[self.routine lng] doubleValue]);
    self.mapView.centerCoordinate=center;


    self.mapView.delegate=self;
    
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
}

-(void)viewDidAppear:(BOOL)animated{
    MMSearchedRoutine *searchRoutine=self.routine;
    
    if([searchRoutine.isLoad boolValue]){
        [self updateMapUI];
    }else{
        self.title=@"Loading...";
        [CloudManager queryMarkersByRoutineId:[self.routine uuid] withBlockWhenDone:^(NSError *error, NSArray *markers) {
            self.title=@"";
            if(!error){
                
                for (MMSearchdeMarker *eachMarker in markers) {
                    [searchRoutine addMarkersObject:eachMarker];
                }
                searchRoutine.isLoad=[NSNumber numberWithBool:YES];
                [self updateMapUI];
            }else{
                [CommonUtil alert:[error localizedDescription]];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

-(void)updateUIInSlideMode{
    [self.slidePlayButton setImage:[UIImage imageNamed:@"icon_stop"]];
    
    [super updateUIInSlideMode];
}



-(void)updateUIInNormalMode{
    
    [self.slidePlayButton setImage:[UIImage imageNamed:@"icon_play"]];
    
    [super updateUIInNormalMode];
}

#pragma mark - UI action
- (IBAction)PlayButtonClick:(id)sender {
    [self slidePlayClick];
    
    if(!self.currentMarker){
        [self.markerInfoView setHidden:YES];
    }
}

- (IBAction)PrevButtonClick:(id)sender {
    [self slidePrevClick];
}

- (IBAction)NextButtonClick:(id)sender {
    [self slideNextClick];
}

-(void)markerInfoViewClick{
    if(self.currentMarker){
        [self performSegueWithIdentifier:SHOW_SEARCH_MARKER_DETAIL_SEGUE sender:self.currentMarker];
    }
}

-(void)hideMarkerInfoView{
    [self.markerInfoView setHidden:YES];
}



#pragma mark - getter and setter

#pragma mark - override
-(void)handleCurrentSlideMarkers:(NSArray *)currentSlideMarkers{
    self.currentMarker=currentSlideMarkers.firstObject;
}

#pragma mark - RMMapViewDelegate

-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if(annotation.isUserLocationAnnotation)
        return nil;
    
    if ([annotation.userInfo isKindOfClass:[MMSearchdeMarker class]]){
        MMSearchdeMarker *modelMarker=annotation.userInfo;
        
        CGPoint anchorPoint;
        anchorPoint.x=0.5;
        anchorPoint.y=1;
        
        UIImage *iconImage;
        
        if ([modelMarker allSubMarkers].count>0) {
            iconImage=[UIImage imageNamed:@"collection_default.png"];
        }else{
            iconImage=[UIImage imageNamed:modelMarker.iconUrl];
        }
        
        if(!iconImage){
            iconImage=[UIImage imageNamed:@"default_default.png"];
        }
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:iconImage anchorPoint:anchorPoint];
        //RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"default_default"]anchorPoint:anchorPoint];
        
        marker.canShowCallout=YES;
        
        marker.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return marker;
    }else{
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"overview_star"]];
        
        marker.canShowCallout=YES;
        
        return marker;
    }
    
    return nil;
}


-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    if ([annotation.userInfo isKindOfClass:[MMSearchdeMarker class]]) {
        self.currentMarker=annotation.userInfo;
        [self performSegueWithIdentifier:SHOW_SEARCH_MARKER_DETAIL_SEGUE sender:annotation.userInfo];
    }
}

-(BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation{
    return NO;
}

-(void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    if(annotation.isUserLocationAnnotation)
        return;
    
    if ([annotation.userInfo isKindOfClass:[MMSearchdeMarker class]]){
        MMSearchdeMarker *modelMarker=annotation.userInfo;
        [self showMarkInfoViewByMMMarker:modelMarker];
        self.currentMarker=modelMarker;
    }
}

#define MARKER_INFO_HEIGHT_CONSTRAINT_FULL 170;
#define MARKER_INFO_HEIGHT_CONSTRAINT_IMAGE_ONLY 130;
#define MARKER_INFO_HEIGHT_CONSTRAINT_COMMENT_ONLY 120;

-(void)showMarkInfoViewByMMMarker:(id<Marker>)inComingMarker{
    MMSearchdeMarker *marker=(MMSearchdeMarker *)inComingMarker;
    self.markerInfoView.markerInfoTitleLabel.text=marker.title;
    self.markerInfoView.markerInfoSubLabel.text=[NSString stringWithFormat:@"%@ %@",[MMMarker CategoryNameWithMMMarkerCategory:[marker.category unsignedIntegerValue]],marker.slideNum];
    self.markerInfoView.markerInfoContentLabel.text=marker.mycomment;
    
    [self setMarkerInfoImageHidden:YES];
    
    if([[marker imageUrlsArrayIncludeSubMarkers] count]>0){
        if([CommonUtil isBlankString:marker.mycomment]){
            self.markerInfoHeightConstraint.constant=MARKER_INFO_HEIGHT_CONSTRAINT_IMAGE_ONLY;
        }else{
            self.markerInfoHeightConstraint.constant=MARKER_INFO_HEIGHT_CONSTRAINT_FULL;
        }
        
        NSMutableArray *httpImageUrlArray=[[NSMutableArray alloc]initWithArray:[marker imageUrlsArrayIncludeSubMarkers]];
        for (NSUInteger i=0; i<3; i++) {
            NSString *urlString=[httpImageUrlArray pop];
            if(urlString){
                UIImageView *imageView=[self.markerInfoImages objectAtIndex:i];
                imageView.clipsToBounds=YES;
                imageView.contentMode=UIViewContentModeScaleAspectFill;
                NSURL *url=[NSURL URLWithString:urlString];
                [imageView sd_setImageWithURL:url
                             placeholderImage:[UIImage imageNamed:@"defaultMarkerImage"]
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                        if(!error){
                                            [imageView setHidden:NO];
                                            imageView.contentMode=UIViewContentModeScaleAspectFill;
                                        }
                                    }
                 ];
            }
        }
        
    }else{
        self.markerInfoHeightConstraint.constant=MARKER_INFO_HEIGHT_CONSTRAINT_COMMENT_ONLY;
    }
    
    
    
    [self.markerInfoView setHidden:NO];
}

-(void)setMarkerInfoImageHidden:(BOOL)needHide{
    for (UIImageView *imageView in self.markerInfoImages) {
        [imageView setHidden:needHide];
    }
}

-(void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point{
    [self.markerInfoView setHidden:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SHOW_SEARCH_MARKER_DETAIL_SEGUE]) {
        SearchMarkerInfoTVC *desTVC=segue.destinationViewController;
        desTVC.marker=sender;
    }
}

@end
