//
//  RoutineDetailMapViewController.m
//  MyMapBox
//
//  Created by yufu on 15/4/13.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "RoutineDetailMapViewController.h"
#import "CommonUtil.h"

@interface RoutineDetailMapViewController ()<RMMapViewDelegate,UIActionSheetDelegate>


@property (weak, nonatomic) IBOutlet UIButton *locateButton;
@property (weak, nonatomic) IBOutlet UIToolbar *playRoutineToolBar;
@property(nonatomic,strong) RMMapView *mapView;

@end

@implementation RoutineDetailMapViewController

#define tourMapId  @"lionhart586.gkihab1d"
#define streetMapId @"lionhart586.lnmjhd7b"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locateButton.layer.borderWidth=0.5f;
    self.locateButton.layer.cornerRadius = 4.5;
    
    RMMapboxSource *tileSource=nil;
    NSString *filePath=[CommonUtil dataFilePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSMutableDictionary *dictionary= [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        NSString *tileJSON=[dictionary objectForKey:@"tileJSONTourMap"];
        NSLog(@"found tileJSON in file");
        tileSource= [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
    }else{
        tileSource =[[RMMapboxSource alloc] initWithMapID:streetMapId];
    }
    
    self.mapView=[[RMMapView alloc] initWithFrame:self.view.bounds
                                    andTilesource:tileSource];
    self.mapView.minZoom=3;
    self.mapView.maxZoom=17;
    
    self.mapView.zoom=15;
    
    self.mapView.bouncingEnabled=YES;
    
    self.mapView.delegate=self;
    
    self.mapView.showsUserLocation=YES;
    
    self.mapView.displayHeadingCalibration=YES;
    
    CLLocationCoordinate2D center=CLLocationCoordinate2DMake(31.216571, 121.391336);
    self.mapView.centerCoordinate=center;
    
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
}


- (IBAction)locateButtonClick:(id)sender {
    NSLog(@"Locate Button CLick");
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)addMarker:(id)sender {
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Add Marker in Center",@"Add Marker with Image",@"Add Marker in Current Location", nil];
    [sheet showInView:self.view];
}


-(void)addMarkerWithTitle:(NSString *)title withCoordinate:(CLLocationCoordinate2D)coordinate{
    RMAnnotation *annotation=[[RMAnnotation alloc] initWithMapView:self.mapView
                                                        coordinate:coordinate
                                                          andTitle:title];
    
    [self.mapView addAnnotation:annotation];
    
}

#pragma UIActionSheetDelegate

#define addMarkerInCenter 0;
#define addMarkerWithImage 1;
#define addMarkerInCurrentLocation 2;

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case addMarkerInCenter:
            NSLog(@"add marker in center");
            break;
            
        default:
            break;
    }
}

#pragma RMMapViewDelegate

-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if(annotation.isUserLocationAnnotation)
        return nil;
    RMMarker *marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"rocket" tintColor:
                        [UIColor colorWithRed:0.224 green:0.671 blue:0.780 alpha:1.000]];
    
    marker.canShowCallout = YES;
    
    marker.rightCalloutAccessoryView = [UIButton
                                        buttonWithType:UIButtonTypeDetailDisclosure];
    
    
    return marker;
}



-(void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    [self performSegueWithIdentifier:@"markerDetailSegue" sender:annotation];
}

-(void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    NSLog(@"tap on label");
}


-(BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation{
    return YES;
}

@end
