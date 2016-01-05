//
//  LERSearchViewController.m
//  CaffeineNearMe
//
//  Created by Lauren Reed on 1/4/16.
//  Copyright © 2016 Lauren Reed. All rights reserved.
//

#import "LERSearchViewController.h"
#import "LERCustomListCellTableViewCell.h"
#define METERS_TO_MILES 0.000621371192

@interface LERSearchViewController () <UISearchBarDelegate, UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *venues;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation LERSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.searchBarStyle = UISearchBarStyleProminent;
    self.searchBar.placeholder = @"Search by location";
    self.searchBar.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LERCustomListCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"customListCell"];
    self.tableView.rowHeight = 60;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    
//    peration *)venueSearchNearLocation:(NSString *)location
//query:(NSString *)query
//limit:(NSNumber *)limit
//intent:(FoursquareIntentType)intent
//radius:(NSNumber *)radius
//categoryId:(NSString *)categoryId
//callback:(Foursquare2Callback)callback;
//    
//    
    self.locationManager = [[CLLocationManager alloc] init];
    [[self locationManager] setDelegate:self];
    if ([[self locationManager] respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [[self locationManager] requestWhenInUseAuthorization];
    }
    [[self locationManager] setDesiredAccuracy:kCLLocationAccuracyBest];
    [[self locationManager] startUpdatingLocation];
    
    self.venues = [NSMutableArray new];
    
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = locations.lastObject;
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;

    // call search helper methods here
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *query = searchBar.text;
    if (self.venues.count > 1) {
        [self.venues removeAllObjects];
        [self.tableView reloadData];
    }
//    [self geoCodeLocationFromString:query];
    [self getVenuesFromFoursquareWithName:query];
}

- (void)getVenuesFromFoursquareWithName:(NSString *)query {
    
    //radius 10,000 bc there are exactly 2 coffee shops within 1000 of my home town on foursquare
    [Foursquare2 venueSearchNearByLatitude:@(self.latitude)
                                 longitude:@(self.longitude)
                                     query:query
                                     limit:@100
                                    intent:intentBrowse
                                    radius:@(10000)
                                categoryId:nil
                                  callback:^(BOOL success, id result) {
                                      NSDictionary *venueDic = (NSDictionary *)result;
                                      
                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                          self.venues = venueDic[@"response"][@"venues"];
                                      }];
                                      
                                  }];
    [self searchFoursquareForCoffeeShopsWithLocation:query];
}

//- (void)geoCodeLocationFromString:(NSString *)query {
//    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
//    [geoCoder geocodeAddressString:query
//                 completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//                     if(error){
//                         NSLog(@"error: %@", error.description);
//                         [self getVenuesFromFoursquareWithName:query];
//                     } else if(placemarks && placemarks.count > 0) {
//                         [self searchFoursquareForCoffeeShopsWithLocation:query];
//                     }
//                 }];
//}

- (void)searchFoursquareForCoffeeShopsWithLocation:(NSString *)query {
    
    [Foursquare2 venueSearchNearLocation:query
                                   query:@"Coffee"
                                   limit:@100
                                  intent:intentBrowse
                                  radius:@(1000)
                              categoryId:nil
                                callback:^(BOOL success, id result) {
                                    
                                    NSDictionary *venueDic = (NSDictionary *)result;
                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                        if (kFoursquare2ErrorDomain) {
                                            [self.tableView reloadData];
                                            return;
                                        } else {
                                        
                                        self.venues = venueDic[@"response"][@"venues"];
                                        [self.tableView reloadData];

                                        NSLog(@"venuedic %@", venueDic);
                                        }
                                    }];
                                    
                        }];
}


- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [[self locationManager] stopUpdatingLocation];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.venues.count;
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LERCustomListCellTableViewCell *cell = (LERCustomListCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"customListCell" forIndexPath:indexPath];
    
     NSDictionary *venue = self.venues[indexPath.row];
     
     cell.backgroundColor = [UIColor clearColor];
     cell.coffeeShopName.text = venue[@"name"];
     cell.coffeeShopAddress.text = venue[@"location"][@"address"];
     
     CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
     NSNumber *lat = venue[@"location"][@"lat"];
     NSNumber *lng = venue[@"location"][@"lng"];
     CLLocation *coffeeShopLocation = [[CLLocation alloc] initWithLatitude:[lat floatValue] longitude:[lng floatValue]];
     CLLocationDistance distance = [currentLocation distanceFromLocation:coffeeShopLocation];
     
     distance = distance * METERS_TO_MILES;
     NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
     formatter.numberStyle = NSNumberFormatterDecimalStyle;
     formatter.maximumFractionDigits = 2;
     formatter.roundingMode = NSNumberFormatterRoundUp;
     
     NSString *distanceString = [formatter stringFromNumber:@(distance)];
     cell.distanceFromMe.text = [NSString stringWithFormat:@"%@ mls", distanceString];
     
 
     return cell;
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
