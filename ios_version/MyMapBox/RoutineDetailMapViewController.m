//
//  RoutineDetailMapViewController.m
//  MyMapBox
//
//  Created by yufu on 15/4/13.
//  Copyright (c) 2015年 yufu. All rights reserved.
//
#import <GoogleMaps/GoogleMaps.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "RoutineDetailMapViewController.h"
#import "CommonUtil.h"
#import "MarkerInfoTVC.h"
#import "MarkerEditTVC.h"
#import "CloudManager.h"
#import "ApplePlaceSearchTVC.h"


#import "MMRoutine+Dao.h"

#define SHOW_SEARCH_MODAL_SEGUE @"showSearchModalSegue"

@interface RoutineDetailMapViewController ()<RMMapViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *playRoutineToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SlidePlayButton;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *activityBarButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@property(nonatomic,strong) GooglePlaceDetail *searchResult;
@property(nonatomic,strong) UIActionSheet *searchRMMarkerActionSheet;

@end

@implementation RoutineDetailMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init ui
    self.slideIndicator=-1;
    
    UIBarButtonItem *searchButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonClick:)];
    UIBarButtonItem *addButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMarker:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addButton,searchButton, nil];
    
    //init map
    self.mapView.maxZoom=17;
    
    self.mapView.zoom=15;
    
    self.mapView.bouncingEnabled=YES;
    
    self.mapView.delegate=self;
    
    self.mapView.showsUserLocation=YES;
    
    self.mapView.displayHeadingCalibration=YES;
    
    
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    
    NSLog(@"RoutineDetailMapViewTVC did load");
    
    [self updateMapUI];
    
    if([CommonUtil isFastNetWork]){
        [self syncMarkers];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
}

-(void)viewDidAppear:(BOOL)animated{
    [self updateMapUI];
}

-(void)updateMapUI{
    [super updateMapUI];
    
    if(self.searchResult){
        CLLocationCoordinate2D coord=CLLocationCoordinate2DMake([self.searchResult.lat doubleValue], [self.searchResult.lng doubleValue]);
        [self addMarkerWithTitle:self.searchResult.name withCoordinate:coord withCustomData:self.searchResult];
        [self.mapView setCenterCoordinate:coord animated:YES];
    }
}

-(void)updateUIInSlideMode{
    [self.SlidePlayButton setImage:[UIImage imageNamed:@"icon_stop"]];
    
    [super updateUIInSlideMode];
}



-(void)updateUIInNormalMode{
    
    [self.SlidePlayButton setImage:[UIImage imageNamed:@"icon_play"]];

    [super updateUIInNormalMode];
}

#pragma mark - getter and setter
-(UIBarButtonItem *)activityBarButton{
    if(!_activityBarButton){
        _activityBarButton=[[UIBarButtonItem alloc]initWithCustomView:self.activityIndicator];
    }
    return _activityBarButton;
}


-(UIActionSheet *)searchRMMarkerActionSheet{
    if(!_searchRMMarkerActionSheet){
        _searchRMMarkerActionSheet=[[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:@"Add to Routine",@"Clear Search Result", nil];
    }
    return _searchRMMarkerActionSheet;
}

#pragma mark - UI action
-(void)updateToolBarButtonNeedRefreshing:(BOOL)needRefresh{
    NSMutableArray *toolbarItems = [[NSMutableArray alloc] initWithArray:self.toolbar.items];
    
    if (needRefresh){
        //Replace refresh button with loading spinner
        [toolbarItems replaceObjectAtIndex:[toolbarItems indexOfObject:self.refreshBarButton] withObject:self.activityBarButton];
        
        //Animate the loading spinner
        [self.activityIndicator startAnimating];
    }
    else{
        //Replace loading spinner with refresh button
        [toolbarItems replaceObjectAtIndex:[toolbarItems indexOfObject:self.activityBarButton] withObject:self.refreshBarButton];
        [self.activityIndicator stopAnimating];
    }
    
    //Set the toolbar items
    [self.toolbar setItems:toolbarItems];
}

- (IBAction)PlayButtonClick:(id)sender {
    [self slidePlayClick];
}

- (IBAction)PrevButtonClick:(id)sender {
    [self slidePrevClick];
}

- (IBAction)NextButtonClick:(id)sender {
    [self slideNextClick];
}

- (IBAction)refreshButtonClick:(id)sender {
    [self syncMarkers];
}

-(void)syncMarkers{
    [self updateToolBarButtonNeedRefreshing:YES];
    NSString *currentRoutineUUID=[self.routine uuid];
    [CloudManager syncMarkersByRoutineUUID:[self.routine uuid] withBlockWhenDone:^(NSError *error) {
        [self updateToolBarButtonNeedRefreshing:NO];
        if(!error){
            self.routine=[MMRoutine queryMMRoutineWithUUID:currentRoutineUUID];
            if(self.routine){
                [self updateMapUI];
            }
        }
    }];
}

- (IBAction)locateButtonClick:(id)sender {
    NSLog(@"Locate Button CLick");
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (IBAction)addMarker:(id)sender {
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Add Marker in Center",@"Add Marker with Image",@"Add Marker in Current Location", nil];
    [sheet showInView:self.view];
}

-(IBAction)searchButtonClick:(id)sender{
    [self performSegueWithIdentifier:SHOW_SEARCH_MODAL_SEGUE sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"markerDetailSegue"]) {
        MarkerInfoTVC *markerInfoTVC=segue.destinationViewController;
        markerInfoTVC.marker=((RMAnnotation *)sender).userInfo;
        markerInfoTVC.markerCount=[[self.routine allMarks] count];
    }else if ([segue.identifier isEqualToString:SHOW_SEARCH_MODAL_SEGUE]){
        UINavigationController *navController=(UINavigationController *)segue.destinationViewController;
        ApplePlaceSearchTVC *desTVC=navController.viewControllers[0];
        desTVC.minLocation=CLLocationCoordinate2DMake([self.routine minLatInMarkers], [self.routine minLngInMarkers]);
        desTVC.maxLocation=CLLocationCoordinate2DMake([self.routine maxLatInMarkers], [self.routine maxLngInMarkers]);
    }
}

-(IBAction)searchDone:(UIStoryboardSegue *)segue{
    ApplePlaceSearchTVC *sourceTVC=segue.sourceViewController;
    self.searchResult=sourceTVC.selectedPlace;
}

-(IBAction)DeleteMarkerDone:(UIStoryboardSegue *)segue{
    self.currentMarker=nil;
    
    NSLog(@"prepare delete marker");
    MarkerEditTVC *markerEditTVC=segue.sourceViewController;
    MMMarker *marker=markerEditTVC.marker;
    if(marker){
        if([marker.isSync boolValue]){
            NSLog(@"mark delete marker id %@",marker.uuid);
            [marker markDelete];
        }else{
            [MMMarker removeMMMarker:marker];
        }
    }
}


#pragma mark - UIActionSheetDelegate


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet==self.searchRMMarkerActionSheet){
        switch (buttonIndex) {
            case addSearchResult2Routine:{
                MMMarker *newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                              withLat:[self.searchResult.lat doubleValue]
                                                              withLng:[self.searchResult.lng doubleValue]];
                newMarker.title=self.searchResult.name;
                newMarker.category=[NSNumber numberWithUnsignedInteger:CategorySight];
                newMarker.iconUrl=@"sight_default.png";
                break;
            }
            case clearSearchResult:{
                
                break;
            }
            default:
                break;
        }
        
        self.searchResult=nil;
        [self updateMapUI];
    }else{
        MMMarker *newMarker=nil;
        switch (buttonIndex) {
            case addMarkerInCenter:{
                NSLog(@"add marker in center");
                newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                    withLat:self.mapView.centerCoordinate.latitude
                                                    withLng:self.mapView.centerCoordinate.longitude];
                break;
            }
            case addMarkerWithImage :{
                NSLog(@"add marker with image");
                [self showUIImagePicker];
                break;
            }
            case addMarkerInCurrentLocation:{
                NSLog(@"add marker in current location");
                newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                    withLat:self.mapView.userLocation.coordinate.latitude
                                                    withLng:self.mapView.userLocation.coordinate.longitude];
                break;
            }
            default:
                break;
        }
        if(newMarker){
            [self addMarkerWithTitle:newMarker.title withCoordinate:CLLocationCoordinate2DMake([newMarker.lat doubleValue], [newMarker.lng doubleValue])
                      withCustomData:newMarker];
        }
    }
    
}

-(void)showUIImagePicker{
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

#pragma mark - image Picker delagate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Image Select");
    }];
    
    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    
    [library assetForURL:url resultBlock:^(ALAsset *asset){
        CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
        if(location){
            MMMarker *newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                          withLat:location.coordinate.latitude
                                                          withLng:location.coordinate.longitude];
            newMarker.category=[NSNumber numberWithUnsignedInteger:CategoryInfo];
            newMarker.iconUrl=@"event_2.png";
            
            [self addMarkerWithTitle:@"new Image"
                      withCoordinate:CLLocationCoordinate2DMake([newMarker.lat doubleValue], [newMarker.lng doubleValue])
                      withCustomData:newMarker];
            self.currentMarker=newMarker;
        }else{
            [CommonUtil alert:@"No location with image"];
        }
        
        /*
        NSDictionary *imageData = [[NSMutableDictionary alloc]initWithDictionary:asset.defaultRepresentation.metadata];
        NSDictionary *gpsData = [imageData objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
        NSString *lat=[gpsData objectForKey:@"Latitude"];
        NSString *lng=[gpsData objectForKey:@"Longitude"];
        [CommonUtil alert:[NSString stringWithFormat:@"%@ %@",lat,lng]];
        if(lat && lng){
            MMMarker *newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                          withLat:[lat doubleValue]
                                                          withLng:[lng doubleValue]];
            newMarker.category=[NSNumber numberWithUnsignedInteger:CategoryInfo];
            newMarker.iconUrl=@"event_2.png";
            
            [self addMarkerWithTitle:@"new Image"
                      withCoordinate:CLLocationCoordinate2DMake([newMarker.lat doubleValue], [newMarker.lng doubleValue])
                      withCustomData:newMarker];

        }
         */
    }failureBlock:^(NSError *error){
        NSLog(@"error:%@",error);
    }];
    
}


#pragma mark - RMMapViewDelegate

-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if(annotation.isUserLocationAnnotation)
        return nil;
    
    
    
    if ([annotation.userInfo isKindOfClass:[MMMarker class]]){
        MMMarker *modelMarker=annotation.userInfo;
        
        CGPoint anchorPoint;
        anchorPoint.x=0.5;
        anchorPoint.y=1;
        
        UIImage *iconImage=[UIImage imageNamed:modelMarker.iconUrl];
        
        if(!iconImage){
            iconImage=[UIImage imageNamed:@"default_default.png"];
        }
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:iconImage anchorPoint:anchorPoint];
        //RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"default_default"]anchorPoint:anchorPoint];
        
        
        
        marker.canShowCallout=YES;
        
        marker.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return marker;
    }else if ([annotation.userInfo isKindOfClass:[GooglePlaceDetail class]]){
        CGPoint anchorPoint;
        anchorPoint.x=0.5;
        anchorPoint.y=1;
        
        UIImage *iconImage=[UIImage imageNamed:@"search_default"];
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:iconImage anchorPoint:anchorPoint];
        
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

-(void) mapView:(RMMapView *)mapView annotation:(RMAnnotation *)annotation didChangeDragState:(RMMapLayerDragState)newState fromOldState:(RMMapLayerDragState)oldState{
    
    NSLog(@"change drag state %u",newState);
    
    if(newState==RMMapLayerDragStateNone){
        NSString *subTitle=[NSString stringWithFormat:@"lat: %f lng: %f",annotation.coordinate.latitude,annotation.coordinate.longitude];
        annotation.subtitle=subTitle;
        if ([annotation.userInfo isKindOfClass:[MMMarker class]]) {
            MMMarker *marker=(MMMarker *)annotation.userInfo;
            marker.lat=[NSNumber numberWithDouble:annotation.coordinate.latitude];
            marker.lng=[NSNumber numberWithDouble:annotation.coordinate.longitude];
            marker.updateTimestamp=[NSNumber numberWithLongLong:[CommonUtil currentUTCTimeStamp]];
            NSLog(@"Drage end update marker id:%@ location",marker.uuid);
            [self.routine updateLocation];
        }
    }
}


-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    if ([annotation.userInfo isKindOfClass:[GooglePlaceDetail class]]) {
        [self.searchRMMarkerActionSheet showInView:self.view];
    }else if ([annotation.userInfo isKindOfClass:[MMMarker class]]){
        self.currentMarker=annotation.userInfo;
        [self performSegueWithIdentifier:@"markerDetailSegue" sender:annotation];
    }
}

-(void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    NSLog(@"tap on label");
}


-(BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation{
    if ([annotation.userInfo isKindOfClass:[MKMapItem class]]) {
        return NO;
    }else{
        return YES;
    }
}
@end
