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

#define SHOW_SEARCH_MARKER_DETAIL_SEGUE @"showSearchMarkerDetailSegue"

@interface SearchRoutineDetailMapVC ()<RMMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *slidePlayButton;

@end

@implementation SearchRoutineDetailMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
}

- (IBAction)PrevButtonClick:(id)sender {
    [self slidePrevClick];
}

- (IBAction)NextButtonClick:(id)sender {
    [self slideNextClick];
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
        
        UIImage *iconImage=[UIImage imageNamed:modelMarker.iconUrl];
        
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SHOW_SEARCH_MARKER_DETAIL_SEGUE]) {
        SearchMarkerInfoTVC *desTVC=segue.destinationViewController;
        desTVC.marker=sender;
    }
}

@end
