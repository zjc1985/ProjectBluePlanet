//
//  ExploreRoutineVC.m
//  MyMapBox
//
//  Created by bizappman on 6/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "ExploreRoutineVC.h"
#import <Mapbox-iOS-SDK/Mapbox.h>
#import "CommonUtil.h"
#import "MMSearchedRoutine.h"
#import "MMSearchedOvMarker.h"
#import "CloudManager.h"
#import "SearchRoutineInfoTVC.h"

#define SHOW_SEARCH_ROUTINE_INFO_SEGUE @"showSearchRoutineInfoSegue"

#define SEARCH_RESULTS_LIMIT 15
#define SEARCH_RESULTS_EACH_PAGE_NUM 5

@interface ExploreRoutineVC ()<RMMapViewDelegate,UIActionSheetDelegate>

@property(nonatomic,readonly) NSUInteger searchResultsTotalPage;

@property(nonatomic)NSUInteger currentPageNum;
@property(nonatomic,strong)NSNumber *currentSearchLat;
@property(nonatomic,strong)NSNumber *currentSearchLng;
@property(nonatomic,strong)NSMutableDictionary *searchCach;  //key:pageNum value: searchResults

@end

@implementation ExploreRoutineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentPageNum=0;
    
    self.mapView.minZoom=2;
    self.mapView.maxZoom=17;
    
    self.mapView.zoom=3;
    
    self.mapView.delegate=self;
    
    CLLocationCoordinate2D center=CLLocationCoordinate2DMake(31.239008, 121.470275);
    self.mapView.centerCoordinate=center;
    
    [self.view addSubview:self.mapView];
    
    [self.view sendSubviewToBack:self.mapView];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:NO];
}

#pragma mark - getter and setter
-(NSArray *)searchedRoutines{
    if(!_searchedRoutines){
        _searchedRoutines=[[NSArray alloc]init];
    }
    return _searchedRoutines;
}

-(NSUInteger)searchResultsTotalPage{
    return SEARCH_RESULTS_LIMIT/SEARCH_RESULTS_EACH_PAGE_NUM;
}

-(NSNumber *)currentSearchLat{
    if(!_currentSearchLat){
        _currentSearchLat=[NSNumber numberWithDouble:0];
    }
    return _currentSearchLat;
}

-(NSNumber *)currentSearchLng{
    if(!_currentSearchLng){
        _currentSearchLng=[NSNumber numberWithDouble:0];
    }
    return _currentSearchLng;
}

-(void)initNewCachResults{
    self.searchCach=[NSMutableDictionary new];
    NSUInteger count=SEARCH_RESULTS_LIMIT/SEARCH_RESULTS_EACH_PAGE_NUM;
    for (NSUInteger i=0; i<count; i++) {
        NSObject *nullObject=[[NSObject alloc]init];
        [self.searchCach setObject:nullObject forKey:[NSNumber numberWithUnsignedInteger:i+1]];
    }
}

#pragma mark - UI action

typedef enum : NSUInteger {
    searchRoutineinCenter = 0
} ActionSheetIndexForSearchRoutine;


- (IBAction)searchButtonClick:(id)sender {
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Search with center location", nil];
    [sheet showInView:self.view];
}

- (IBAction)prevSearchResultsBarButtonClick:(id)sender {
    if(self.currentPageNum>1){
        self.currentPageNum--;
        self.title=[NSString stringWithFormat:@"Page %u",self.currentPageNum];
        NSArray *cachResults=[self.searchCach objectForKey:[NSNumber numberWithUnsignedInteger:self.currentPageNum]];
        self.searchedRoutines=cachResults;
        [self updateMapUI];
    }
}

- (IBAction)nextSearchResultsBarButtonClick:(id)sender {
    
    if (self.currentPageNum<self.searchResultsTotalPage && self.currentPageNum>0) {
        self.title=@"Loading...";
        NSArray *cachResults=[self.searchCach objectForKey:[NSNumber numberWithUnsignedInteger:self.currentPageNum+1]];
        if([cachResults isKindOfClass:[NSArray class]]){
            self.currentPageNum++;
            self.title=[NSString stringWithFormat:@"Page %u",self.currentPageNum];
            self.searchedRoutines=cachResults;
            [self updateMapUI];
        }else{
            [CloudManager searchRoutinesByLat:self.currentSearchLat lng:self.currentSearchLng
                                    withLimit:[NSNumber numberWithUnsignedInteger:SEARCH_RESULTS_EACH_PAGE_NUM]
                                     withPage:[NSNumber numberWithUnsignedInteger:self.currentPageNum+1]
                            withBlockWhenDone:^(NSError *error, NSArray *routines) {
                                self.currentPageNum++;
                                self.title=[NSString stringWithFormat:@"Page %u",self.currentPageNum];
                                if(!error){
                                    self.title=[NSString stringWithFormat:@"Page %u",self.currentPageNum];
                                    [self.searchCach setObject:routines forKey:[NSNumber numberWithUnsignedInteger:self.currentPageNum]];
                                    self.searchedRoutines=routines;
                                    [self updateMapUI];
                                }else{
                                    self.title=@"Explore";
                                    [CommonUtil alert:[error localizedDescription]];
                                }
                            }];
        }
    }
}


#pragma mark - ui action delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case searchRoutineinCenter:{
            NSLog(@"search routine in center");
            
            self.title=@"Loading...";
            
            NSNumber *lat=[NSNumber numberWithDouble:self.mapView.centerCoordinate.latitude];
            NSNumber *lng=[NSNumber numberWithDouble:self.mapView.centerCoordinate.longitude];
            
            self.currentSearchLat=lat;
            self.currentSearchLng=lng;
            
            [CloudManager searchRoutinesByLat:lat lng:lng
                                    withLimit:[NSNumber numberWithUnsignedInteger:SEARCH_RESULTS_EACH_PAGE_NUM]
                                     withPage:[NSNumber numberWithUnsignedInteger:1]
                            withBlockWhenDone:^(NSError *error, NSArray *routines) {
                                [self initNewCachResults];
                                self.currentPageNum=1;
                                if(!error){
                                    self.title=[NSString stringWithFormat:@"Page %u",self.currentPageNum];
                                    [self.searchCach setObject:routines forKey:[NSNumber numberWithUnsignedInteger:1]];
                                    self.searchedRoutines=routines;
                                    [self updateMapUI];
                                }else{
                                    self.title=@"Explore";
                                    [CommonUtil alert:[error localizedDescription]];
                                }
            }];
            
            break;
        }
        default:
            break;
    }
}

//override
-(NSArray *)allRoutines{
    return [self searchedRoutines];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SHOW_SEARCH_ROUTINE_INFO_SEGUE]){
        SearchRoutineInfoTVC *desTVC=(SearchRoutineInfoTVC *)segue.destinationViewController;
        MMSearchedRoutine  *routine=(MMSearchedRoutine *)sender;
        desTVC.routine=routine;
    }
}


#pragma mark - RMMap delegate
-(void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point{
    //BOOL hidden=self.tabBarController.tabBar.hidden;
    [self.tabBarController.tabBar setHidden:NO];
}

-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if(annotation.isUserLocationAnnotation)
        return nil;
    
    if([annotation isKindOfClass:[RMPolylineAnnotation class]]){
        RMShapeAnnotation *lineAnnotation=(RMShapeAnnotation *)annotation;
        RMShape *lineShape=[[RMShape alloc]initWithView:self.mapView];
        for (CLLocation *eachLocation in lineAnnotation.points) {
            [lineShape addLineToCoordinate:eachLocation.coordinate];
        }
        return lineShape;
    }
    
    
    if ([annotation.userInfo isKindOfClass:[MMSearchedRoutine class]]) {
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"overview_point.png"]];
        
        return marker;
    }else if ([annotation.userInfo isKindOfClass:[MMSearchedOvMarker class]]){
        MMSearchedOvMarker *ovMarker=annotation.userInfo;
        
        CGPoint anchorPoint;
        anchorPoint.x=0.5;
        anchorPoint.y=1;
        
        UIImage *iconImage=[UIImage imageNamed:ovMarker.iconUrl];
        if(!iconImage){
            iconImage=[UIImage imageNamed:@"default_default.png"];
        }
        
        RMMarker *marker = [[RMMarker alloc] initWithUIImage: iconImage anchorPoint:anchorPoint];
        //RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"default_default"]anchorPoint:anchorPoint];
        
        
        marker.canShowCallout=YES;
        
        marker.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        //[marker setFrame:CGRectMake(0, 0, 32, 37)];
        
        return marker;
    }
    
    return nil;
}


-(void) mapView:(RMMapView *)mapView annotation:(RMAnnotation *)annotation didChangeDragState:(RMMapLayerDragState)newState fromOldState:(RMMapLayerDragState)oldState{
    if(newState==RMMapLayerDragStateNone){
        if ([annotation.userInfo isKindOfClass:[MMSearchedOvMarker class]]) {
            MMSearchedOvMarker *ovMarker=(MMSearchedOvMarker *)annotation.userInfo;
            ovMarker.lat=[NSNumber numberWithDouble: annotation.coordinate.latitude];
            ovMarker.lng=[NSNumber numberWithDouble: annotation.coordinate.longitude];

            MMSearchedRoutine *belongRoutine=ovMarker.belongRoutine;
            
            CGPoint offset= [self calculateOffsetFrom:belongRoutine to:ovMarker];
            
            ovMarker.offsetX=[NSNumber numberWithDouble: offset.x];
            ovMarker.offsetY=[NSNumber numberWithDouble: offset.y];

            [self updateMapUI];
        }
    }
}

-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    if([annotation.userInfo isKindOfClass:[MMSearchedOvMarker class]]){
        MMSearchedOvMarker *ovMarker=annotation.userInfo;
        [self performSegueWithIdentifier:SHOW_SEARCH_ROUTINE_INFO_SEGUE sender:ovMarker.belongRoutine];
    }
}

-(BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation{
    if([annotation.userInfo isKindOfClass:[MMSearchedRoutine class]]){
        return NO;
    }else{
        return YES;
    }
}

- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction{
    [self updateMapUI];
}

-(void)beforeMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction{
    if (wasUserAction) {
        [self.tabBarController.tabBar setHidden:YES];

    }
}


@end
