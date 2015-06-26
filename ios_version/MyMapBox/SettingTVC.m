//
//  SettingTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/24/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "SettingTVC.h"
#import <AVOSCloud/AVOSCloud.h>
#import "CommonUtil.h"
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "CloudManager.h"


@interface SettingTVC ()

@property (weak, nonatomic) IBOutlet UITableViewCell *testFeatureCell;

@end

@implementation SettingTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.testFeatureCell.hidden=YES;
    [self.tabBarController.tabBar setHidden:NO];
}


- (IBAction)logOutClick:(id)sender {
    [AVUser logOut];
    
    //todo clean core data data
    [CommonUtil resetCoreData];
    
    [CommonUtil alert:@"logout success"];
}

- (IBAction)testFeature:(id)sender {
    //[self localSearchTester];
    [self placeAutocomplete];
}

- (void)placeAutocomplete {
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(31.274, 121.5320) coordinate:CLLocationCoordinate2DMake(31.180, 121.4393)];
    
    [[GMSPlacesClient sharedClient] autocompleteQuery:@"云南 泸沽湖"
                              bounds:bounds
                              filter:nil
                            callback:^(NSArray *results, NSError *error) {
                                if (error != nil) {
                                    NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                    return;
                                }
                                
                                for (GMSAutocompletePrediction* result in results) {
                                    NSLog(@"Result '%@' with placeID %@", result.attributedFullText.string, result.placeID);
                                }
                            }];
}

-(void)localSearchTester{
    MKLocalSearchRequest *request=[[MKLocalSearchRequest alloc]init];
    [request setNaturalLanguageQuery:@"上海 世纪大道"];
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (!error) {
            for (MKMapItem *mapItem in [response mapItems]) {
                NSLog(@"Name: %@, Placemark title: %@", [mapItem name], [[mapItem placemark] title]);
            }
        } else {
            NSLog(@"Search Request Error: %@", [error localizedDescription]);
        }
    }];
}

@end
