//
//  MyRoutineMapVCViewController.m
//  MyMapBox
//
//  Created by yufu on 15/4/13.
//  Copyright (c) 2015年 yufu. All rights reserved.
//

#import "MyRoutineMapVCViewController.h"
#import "RoutineInfoViewController.h"

#define SHOW_ROUTINE_INFO_SEGUE @"showRoutineInfoSegue"

@interface MyRoutineMapVCViewController ()

@end

@implementation MyRoutineMapVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:SHOW_ROUTINE_INFO_SEGUE]){
        RoutineInfoViewController *routineInfoVC=segue.destinationViewController;
        
    }
}

- (IBAction)addMarker:(id)sender {
    
    RMAnnotation *annotation=[[RMAnnotation alloc] initWithMapView:self.mapView coordinate:self.mapView.centerCoordinate andTitle:@"One Location"];
    
    [self.mapView addAnnotation:annotation];
    
    //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(37.743584, -122.472331) animated:YES];
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
    [self performSegueWithIdentifier:SHOW_ROUTINE_INFO_SEGUE sender:annotation];
}

-(void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    NSLog(@"tap on label");
}


-(BOOL)mapView:(RMMapView *)mapView shouldDragAnnotation:(RMAnnotation *)annotation{
    return YES;
}

-(void) mapView:(RMMapView *)mapView annotation:(RMAnnotation *)annotation didChangeDragState:(RMMapLayerDragState)newState fromOldState:(RMMapLayerDragState)oldState{
    
    NSLog(@"change drag state %u",newState);
    
    if(newState==RMMapLayerDragStateNone){
        NSLog(@"Drage End");
        NSString *subTitle=[NSString stringWithFormat:@"lat: %f lng: %f",annotation.coordinate.latitude,annotation.coordinate.longitude];
        annotation.subtitle=subTitle;
        NSLog(@"current zoom: %f",mapView.zoom);
        NSLog(@"tileSources num %lu",(unsigned long)[mapView.tileSources count]);
        NSLog(@"tileSources isCacheable %u",[mapView.tileSource isCacheable]);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
