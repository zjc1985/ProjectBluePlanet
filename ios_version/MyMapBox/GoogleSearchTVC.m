//
//  GoogleSearchTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/29/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "GoogleSearchTVC.h"
#import "CommonUtil.h"

#define  SEARCH_COMPLETE_UNWIND_SEGUE @"searchCompleteUnwindSegue"

@interface GoogleSearchTVC ()<UISearchBarDelegate>

@property(nonatomic,strong)NSArray *historyResults; //of GooglePlace+Dao
@property(nonatomic,strong)NSArray *searchResults; //GMSAutocompletePrediction

@end

@implementation GoogleSearchTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init search Bar
    self.searchDisplayController.searchBar.delegate=self;
    [self.searchDisplayController setSearchResultsDataSource:self];
    [self.searchDisplayController setSearchResultsDelegate:self];
    [self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"searchCell"];

}
#pragma mark - getter and setter
-(NSArray *)searchResults{
    if(!_searchResults){
        _searchResults=[[NSArray alloc]init];
    }
    return _searchResults;
}

-(NSArray *)historyResults{
    if(!_historyResults){
        _historyResults=[GooglePlace fetchAll];
    }
    return _historyResults;
}

#pragma mark - UI Action
- (IBAction)CancelButtonClick:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==self.searchDisplayController.searchResultsTableView) {
        return self.searchResults.count;
    }else{
        return self.historyResults.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if(tableView==self.searchDisplayController.searchResultsTableView){
        cell=[tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
        GMSAutocompletePrediction* result=[self.searchResults objectAtIndex:indexPath.row];
        cell.textLabel.text=result.attributedFullText.string;
    }else{
        cell= [tableView dequeueReusableCellWithIdentifier:@"searchHistoryCell" forIndexPath:indexPath];
        GooglePlace *place=[self.historyResults objectAtIndex:indexPath.row];
        cell.textLabel.text=place.title;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==self.searchDisplayController.searchResultsTableView) {
        GMSAutocompletePrediction *selectResult=[self.searchResults objectAtIndex:indexPath.row];
        [[GMSPlacesClient sharedClient] lookUpPlaceID:selectResult.placeID callback:^(GMSPlace *place, NSError *error) {
            if (error != nil) {
                NSLog(@"Place Details error %@", [error localizedDescription]);
                return;
            }
            
            if (place != nil) {
                NSLog(@"Place name %@", place.name);
                NSLog(@"Place address %@", place.formattedAddress);
                NSLog(@"Place placeID %@", place.placeID);
                NSLog(@"Place attributions %@", place.attributions);
                GooglePlace *newPlace=[GooglePlace createGooglePlaceWithPlaceId:place.placeID withTitle:place.name];
                newPlace.lat=[NSNumber numberWithDouble:place.coordinate.latitude];
                newPlace.lng=[NSNumber numberWithDouble:place.coordinate.longitude];
                self.selectedPlace=newPlace;
                [self performSegueWithIdentifier:SEARCH_COMPLETE_UNWIND_SEGUE sender:nil];
            } else {
                //NSLog(@"No place details for %@", placeID);
                [CommonUtil alert:@"no place detail found at google"];
            }
        }];
    }else{
        GooglePlace *selectResult=[self.historyResults objectAtIndex:indexPath.row];
        self.selectedPlace=selectResult;
        [self performSegueWithIdentifier:SEARCH_COMPLETE_UNWIND_SEGUE sender:nil];
    }
}


#pragma mark - search bar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self googlePlaceSearch:searchBar.text];
}

-(void)googlePlaceSearch:(NSString *)searchString{
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:self.minLocation
                                                                       coordinate:self.maxLocation];
    
    [[GMSPlacesClient sharedClient] autocompleteQuery:searchString
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
                                                 
                                                 self.searchResults=results;
                                                 [self.searchDisplayController.searchResultsTableView reloadData];
                                             }];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
