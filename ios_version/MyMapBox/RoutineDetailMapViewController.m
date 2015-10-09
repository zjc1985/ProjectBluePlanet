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
#import "SelectImageTVC.h"


#import "MMRoutine+Dao.h"
#import "LocalImageUrl+Dao.h"
#import "MarkerInfoView.h"

#import "MyMapBox-Swift.h"

#define SHOW_SEARCH_MODAL_SEGUE @"showSearchModalSegue"
#define SHOW_USER_ALBUMS_SEGUE @"showAlbumsSegue"

@interface RoutineDetailMapViewController ()<RMMapViewDelegate,UIActionSheetDelegate,RMTileCacheBackgroundDelegate,UIAlertViewDelegate>


@property (weak, nonatomic) IBOutlet MarkerInfoView *markerInfoView;

@property (weak, nonatomic) IBOutlet UIToolbar *playRoutineToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SlidePlayButton;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *activityBarButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property(strong,nonatomic)PHCachingImageManager *imageManager;

@property(nonatomic,strong) GooglePlaceDetail *searchResult;
@property(nonatomic,strong) NSMutableSet *lastSearchPredicts;

@property(nonatomic,strong) UIActionSheet *searchRMMarkerActionSheet;
@property(nonatomic,strong) UIActionSheet *navigationActionSheet;
@property(nonatomic,strong) UIAlertView *downloadProgressAlertView;

@end

@implementation RoutineDetailMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init ui
    self.slideIndicator=-1;
    
    UIBarButtonItem *searchButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonClick:)];
    UIBarButtonItem *addButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMarker:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addButton,searchButton, nil];
    
    [self.markerInfoView setHidden:YES];
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(markerInfoViewClick)];
    tapGesture.numberOfTapsRequired=1;
    [self.markerInfoView addGestureRecognizer:tapGesture];
    
    //init map
    self.mapView.maxZoom=16;
    
    self.mapView.zoom=15;
    
    self.mapView.bouncingEnabled=YES;
    
    self.mapView.delegate=self;
    
    self.mapView.showsUserLocation=YES;
    
    self.mapView.displayHeadingCalibration=YES;
    
    for (id cache in self.mapView.tileCache.tileCaches)
    {
        if ([cache isKindOfClass:[RMDatabaseCache class]])
        {
            RMDatabaseCache *dbCache = (RMDatabaseCache *)cache;
            NSLog(@"db cache capacity %ld",(unsigned long)dbCache.capacity);
        }
    }
    
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
        [self.mapView setZoom:14 atCoordinate:coord animated:YES];
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
-(UIAlertView *)downloadProgressAlertView{
    if(!_downloadProgressAlertView){
        _downloadProgressAlertView=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Download", @"")
                                                         message:@"progress:0%"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:nil];
    }
    return _downloadProgressAlertView;
}

-(NSMutableSet *)lastSearchPredicts{
    if(!_lastSearchPredicts){
        _lastSearchPredicts=[[NSMutableSet alloc]init];
    }
    return _lastSearchPredicts;
}

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
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:
                                    NSLocalizedString(@"Add to Routine",nil),
                                    NSLocalizedString(@"Clear Search Result",nil),
                                    nil];
    }
    return _searchRMMarkerActionSheet;
}

-(UIActionSheet *)navigationActionSheet{
    if(!_navigationActionSheet){
        if([[UIApplication sharedApplication] canOpenURL:
            [NSURL URLWithString:@"comgooglemaps://"]]){
            _navigationActionSheet=[[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:
                                    NSLocalizedString(@"Map",nil),
                                    NSLocalizedString(@"Google Map",nil),
                                    nil];
        }else{
            _navigationActionSheet=[[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:
                                    NSLocalizedString(@"Map",nil),
                                    nil];
        }
        
    }
    return _navigationActionSheet;
}

-(PHCachingImageManager *)imageManager{
    if(!_imageManager){
        _imageManager=[[PHCachingImageManager alloc]init];
    }
    return _imageManager;
}

#pragma mark - override
-(void)handleCurrentSlideMarkers:(NSArray *)currentSlideMarkers{
   
    [self.markerInfoView setHidden:YES];
    
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

- (IBAction)navigateButtonClick:(id)sender {
    [self.navigationActionSheet showInView:self.view];
}


- (IBAction)locateButtonClick:(id)sender {
    NSLog(@"Locate Button CLick");
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (IBAction)downloadMapButtonClick:(id)sender {
    if([self.mapView.tileCache isBackgroundCaching]){
        return;
    }
    
    CLLocationCoordinate2D southWest=self.mapView.latitudeLongitudeBoundingBox.southWest;
    CLLocationCoordinate2D northEast=self.mapView.latitudeLongitudeBoundingBox.northEast;
    
    NSUInteger tileNums=[self.mapView.tileCache tileCountForSouthWest:southWest northEast:northEast minZoom:self.mapView.zoom maxZoom:self.mapView.maxZoom];
    //[CommonUtil alert:[NSString stringWithFormat: @"zoom:%@ ,tileNum:%@",@(self.mapView.zoom),@(tileNums)]];
    if (tileNums>1200) {
        [CommonUtil alert:NSLocalizedString(@"Can not download. Too Large Size", @"")];
    }else{
        self.mapView.tileCache.backgroundCacheDelegate=self;
        
        NSLog(@"prepare download tile num:%@",@(tileNums));
        [self.downloadProgressAlertView show];
        [self.mapView.tileCache beginBackgroundCacheForTileSource:self.mapView.tileSource
                                                        southWest:southWest
                                                        northEast:northEast
                                                          minZoom:self.mapView.zoom
                                                          maxZoom:self.mapView.maxZoom];
    }
}


- (IBAction)addMarker:(id)sender {
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:NSLocalizedString(@"Add Marker in Center",nil),
                          NSLocalizedString(@"Add Marker with Image",nil),
                          NSLocalizedString(@"Add Marker in Current Location",nil),
                          nil];
    [sheet showInView:self.view];
}

-(IBAction)searchButtonClick:(id)sender{
    [self performSegueWithIdentifier:SHOW_SEARCH_MODAL_SEGUE sender:nil];
}

-(void)markerInfoViewClick{
    if(self.currentMarker){
        [self performSegueWithIdentifier:@"markerDetailSegue" sender:self.currentMarker];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"markerDetailSegue"]) {
        MarkerInfoTVC *markerInfoTVC=segue.destinationViewController;
        markerInfoTVC.marker=sender;
        markerInfoTVC.markerCount=[[self.routine allMarks] count];
        
        markerInfoTVC.belongRoutine=self.routine;
    }else if ([segue.identifier isEqualToString:SHOW_SEARCH_MODAL_SEGUE]){
        UINavigationController *navController=(UINavigationController *)segue.destinationViewController;
        ApplePlaceSearchTVC *desTVC=navController.viewControllers[0];
        desTVC.minLocation=CLLocationCoordinate2DMake([self.routine minLatInMarkers], [self.routine minLngInMarkers]);
        desTVC.maxLocation=CLLocationCoordinate2DMake([self.routine maxLatInMarkers], [self.routine maxLngInMarkers]);
        if(self.lastSearchPredicts){
            desTVC.historyResults=[self.lastSearchPredicts allObjects];
        }
    }
}

-(IBAction)searchDone:(UIStoryboardSegue *)segue{
    ApplePlaceSearchTVC *sourceTVC=segue.sourceViewController;
    if(sourceTVC.selectedPlace){
        self.searchResult=sourceTVC.selectedPlace;
    }
    if(sourceTVC.historyResults){
        [self.lastSearchPredicts addObjectsFromArray:sourceTVC.historyResults];
    }
}

-(IBAction)DeleteMarkerDone:(UIStoryboardSegue *)segue{
    self.currentMarker=nil;
    //stop slide mode
    self.slideIndicator=-1;
    
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

-(IBAction)SelectImageAssetDone:(UIStoryboardSegue *)segue{
    
    if([segue.sourceViewController isKindOfClass:[SelectImageTVC class]]){
        SelectImageTVC *selectImageTVC=segue.sourceViewController;
        NSArray *assets=selectImageTVC.selectedAssetsOut;
        for (PHAsset *imageAsset in assets) {
            //do things
            
            [self.imageManager requestImageDataForAsset:imageAsset options:nil
                                          resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                //do somthing
                                              CLLocation *location=imageAsset.location;
                                              if(location){
                                                  MMMarker *newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                                                                withLat:location.coordinate.latitude
                                                                                                withLng:location.coordinate.longitude];
                                                  newMarker.category=[NSNumber numberWithUnsignedInteger:CategoryInfo];
                                                  newMarker.iconUrl=@"event_2.png";
                                                  newMarker.slideNum=[NSNumber numberWithUnsignedInteger:[self.routine maxSlideNum]+1];
                                                  
                                                  [self addMarkerWithTitle:@"new Image"
                                                            withCoordinate:CLLocationCoordinate2DMake([newMarker.lat doubleValue], [newMarker.lng doubleValue])
                                                            withCustomData:newMarker];
                                                  //NSLog(@"orientation %@",@(result.imageOrientation));
                                                  NSString *imageUrl=[CommonUtil saveImageByData:imageData];
                                                  //attachImage
                                                  [LocalImageUrl createLocalImageUrl:imageUrl inMarker:newMarker];
                                              }
                
            }];
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
                newMarker.mycomment=self.searchResult.address;
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
    }else if (actionSheet==self.navigationActionSheet){
        
        [self openUrlForNavigationBy:buttonIndex];
    }else{
        MMMarker *newMarker=nil;
        switch (buttonIndex) {
            case addMarkerInCenter:{
                NSLog(@"add marker in center");
                newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                    withLat:self.mapView.centerCoordinate.latitude
                                                    withLng:self.mapView.centerCoordinate.longitude];
                newMarker.slideNum=[NSNumber numberWithUnsignedInteger:[self.routine maxSlideNum]+1];
                break;
            }
            case addMarkerWithImage :{
                NSLog(@"add marker with image");
                
                //[self showUIImagePicker];
                [self performSegueWithIdentifier:SHOW_USER_ALBUMS_SEGUE sender:self];
                self.currentMarker=nil;
                break;
            }
            case addMarkerInCurrentLocation:{
                NSLog(@"add marker in current location");
                newMarker=[MMMarker createMMMarkerInRoutine:self.routine
                                                    withLat:self.mapView.userLocation.coordinate.latitude
                                                    withLng:self.mapView.userLocation.coordinate.longitude];
                newMarker.slideNum=[NSNumber numberWithUnsignedInteger:[self.routine maxSlideNum]+1];
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

-(void)openUrlForNavigationBy:(ActionSheetIndexForNavigation)navType{
    if(!self.currentMarker){
        return;
    }
    
    MMMarker *currentMarker=self.currentMarker;
    NSString *urlString=nil;
    
    NSDictionary *saddrDic=[LocationTransform wgs2gcj:self.mapView.userLocation.coordinate.latitude
                                               wgsLon:self.mapView.userLocation.coordinate.longitude];
    NSNumber *sLat=[saddrDic objectForKey:@"lat"];
    NSNumber *sLng=[saddrDic objectForKey:@"lon"];
    
    NSDictionary *daddrDic=[LocationTransform wgs2gcj:[currentMarker.lat doubleValue]
                                               wgsLon:[currentMarker.lng doubleValue]];
    
    NSNumber *dLat=[daddrDic objectForKey:@"lat"];
    NSNumber *dLng=[daddrDic objectForKey:@"lon"];
    
    if (navType==navigation_google){
        
        urlString=[NSString stringWithFormat:@"comgooglemaps://?saddr=%@,%@&daddr=%@,%@",
                                   [sLat stringValue],
                                   [sLng stringValue],
                                   [dLat stringValue],
                                   [dLng stringValue]];
    }else{
        //else, use local map instead
        urlString=[NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@,%@&daddr=%@,%@",
                   [sLat stringValue],
                   [sLng stringValue],
                   [dLat stringValue],
                   [dLng stringValue]];
    }
    
    NSLog(@"forward url: %@",urlString);
    
    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:urlString]];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView==self.downloadProgressAlertView){
        if (buttonIndex==alertView.cancelButtonIndex) {
            NSLog(@"Cancel download maps");
            [self.mapView.tileCache cancelBackgroundCache];
        }
    }
}

#pragma mark - RMMapViewDelegate

-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if(annotation.isUserLocationAnnotation)
        return nil;
    
    
    
    if ([annotation.userInfo isKindOfClass:[MMMarker class]]){
        MMMarker *modelMarker=annotation.userInfo;
        
        CGPoint anchorPoint;
        anchorPoint.x=0.32;
        anchorPoint.y=0.8;
        
        UIImage *iconImage=[UIImage imageNamed:modelMarker.iconUrl];
        
        if(!iconImage){
            iconImage=[UIImage imageNamed:@"default_default.png"];
        }
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:iconImage anchorPoint:anchorPoint];
        //RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"default_default"]anchorPoint:anchorPoint];
        
        
        
        marker.canShowCallout=YES;
        
        //marker.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return marker;
    }else if ([annotation.userInfo isKindOfClass:[GooglePlaceDetail class]]){
        CGPoint anchorPoint;
        anchorPoint.x=0.32;
        anchorPoint.y=0.8;
        
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
        [self performSegueWithIdentifier:@"markerDetailSegue" sender:annotation.userInfo];
    }
}

-(void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    NSLog(@"tap on label");
}

-(void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    if(annotation.isUserLocationAnnotation)
        return;
    
    if ([annotation.userInfo isKindOfClass:[MMMarker class]]){
        MMMarker *modelMarker=annotation.userInfo;
        [self showMarkInfoViewByMMMarker:modelMarker];
        self.currentMarker=modelMarker;
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([modelMarker.lat doubleValue], [modelMarker.lng doubleValue]) animated:YES];
    }
    
}

-(void)showMarkInfoViewByMMMarker:(MMMarker *)marker{
    self.markerInfoView.markerInfoTitleLabel.text=marker.title;
    self.markerInfoView.markerInfoSubLabel.text=[NSString stringWithFormat:@"%@ %@",marker.categoryName,marker.slideNum];
    self.markerInfoView.markerInfoContentLabel.text=marker.mycomment;
    [self.markerInfoView setHidden:NO];
}

-(void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point{
    [self.markerInfoView setHidden:YES];
}


-(BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation{
    if ([annotation.userInfo isKindOfClass:[MKMapItem class]]) {
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - RMTileCacheBackgroundDelegate
-(void)tileCache:(RMTileCache *)tileCache didBackgroundCacheTile:(RMTile)tile withIndex:(NSUInteger)tileIndex ofTotalTileCount:(NSUInteger)totalTileCount{
    NSLog(@"MMRoutineCachHelper caching currrent num: %lu with total count %lu",(unsigned long)tileIndex,(unsigned long)totalTileCount);
    float progress=(float)tileIndex/(float)totalTileCount;
    
    NSUInteger p=progress*100;
    
    NSLog(@"%@",@(p));
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadProgressAlertView.message=[NSString stringWithFormat:@"progress:%@ %%",@(p)];
    });
}

-(void)tileCache:(RMTileCache *)tileCache didReceiveError:(NSError *)error whenCachingTile:(RMTile)tile{
    NSLog(@"Cach error:%@",error.localizedDescription);
}

-(void)tileCacheDidCancelBackgroundCache:(RMTileCache *)tileCache{
    NSLog(@"Cach cancel");
}

-(void)tileCacheDidFinishBackgroundCache:(RMTileCache *)tileCache{
    NSLog(@"Cach did finish");
    [self.downloadProgressAlertView dismissWithClickedButtonIndex:self.downloadProgressAlertView.cancelButtonIndex animated:YES];
}


@end
