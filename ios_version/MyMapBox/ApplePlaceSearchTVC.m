//
//  GoogleSearchTVC.m
//  MyMapBox
//
//  Created by bizappman on 6/29/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "ApplePlaceSearchTVC.h"
#import "CommonUtil.h"
#import "GooglePlaceManager.h"
#import "GooglePredictionResult.h"

#define  SEARCH_COMPLETE_UNWIND_SEGUE @"searchCompleteUnwindSegue"

@interface ApplePlaceSearchTVC ()<UISearchBarDelegate>

@property(nonatomic,strong)NSArray *historyResults; //will do later
@property(nonatomic,strong)NSArray *searchResults; //of GooglePredictionResult

@end

@implementation ApplePlaceSearchTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init search Bar
    self.searchDisplayController.searchBar.delegate=self;
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
        _historyResults=[[NSArray alloc]init];
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
    static NSString *kCellID = @"searchCell";
    
    // Dequeue a cell from self's table view.
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellID];
    
    if(tableView==self.searchDisplayController.searchResultsTableView){
        GooglePredictionResult *googlePredict=[self.searchResults objectAtIndex:indexPath.row];
        
        cell.textLabel.text=googlePredict.description;
        cell.detailTextLabel.text=googlePredict.description;
    }else{
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==self.searchDisplayController.searchResultsTableView) {
        GooglePredictionResult *predictResult=[self.searchResults objectAtIndex:indexPath.row];
        
        [GooglePlaceManager details:predictResult.placeId withBlock:^(NSError *error, GooglePlaceDetail *placeDetail) {
            if(error){
                NSLog(@"Search Request Error: %@", [error localizedDescription]);
                [CommonUtil alert:@"No Results Found"];
            }else{
                self.selectedPlace=placeDetail;
                [self performSegueWithIdentifier:SEARCH_COMPLETE_UNWIND_SEGUE sender:nil];
            }
        }];
    }else{
        
    }
}


#pragma mark - search bar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self googlePlaceSearch:searchBar.text];
    //[self appleLocationSearch:searchBar.text];
}

-(void)appleLocationSearch:(NSString *)searchString{
    // Create a search request with a string
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    [searchRequest setNaturalLanguageQuery:searchString];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.minLocation, 500000, 500000);
    [searchRequest setRegion:region];
    
    // Create the local search to perform the search
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (!error) {
            for (MKMapItem *mapItem in [response mapItems]) {
                NSLog(@"Name: %@, Placemark title: %@", [mapItem name], [[mapItem placemark] title]);
                self.searchResults=[response mapItems];
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
        } else {
            NSLog(@"Search Request Error: %@", [error localizedDescription]);
            [CommonUtil alert:@"No Results Found"];
        }
    }];
}

-(void)googlePlaceSearch:(NSString *)searchString{
    [GooglePlaceManager autoQueryComplete:searchString withBlock:^(NSError *error, NSArray *autoQueryResultArray) {
        if(error){
            NSLog(@"Search Request Error: %@", [error localizedDescription]);
            [CommonUtil alert:@"No Results Found"];
        }else{
            self.searchResults=autoQueryResultArray;
            
        }
        NSLog(@"reload data");
        [self performSelectorOnMainThread:@selector(reloadSearchTableData) withObject:nil waitUntilDone:NO];
    }];
}

-(void)reloadSearchTableData{
    [self.searchDisplayController.searchResultsTableView reloadData];
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
