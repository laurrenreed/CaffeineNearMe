//
//  LERSearchViewController.m
//  CaffeineNearMe
//
//  Created by Lauren Reed on 1/4/16.
//  Copyright © 2016 Lauren Reed. All rights reserved.
//

#import "LERSearchViewController.h"
#import "LERCustomListCellTableViewCell.h"
#import "LERCoffeeShop.h"
#import "LERCoffeeShopViewController.h"

#define METERS_TO_MILES 0.000621371192

@interface LERSearchViewController () <UISearchBarDelegate, UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *venues;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) LERCoffeeShop *selectedCoffeeShop;

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"cOCoffeeShopDetail" sender:nil];
}

- (LERCoffeeShop *)makeDictionaryToCoffeeShopObject:(NSIndexPath *)selectedIndexPath {
    self.selectedCoffeeShop = [LERCoffeeShop new];
    
    NSDictionary *venue = self.venues[selectedIndexPath.row];
    
    self.selectedCoffeeShop.name = venue[@"name"];
    self.selectedCoffeeShop.formattedAddress = venue[@"location"][@"formattedAddress"];
    self.selectedCoffeeShop.latitude = venue[@"location"][@"lat"];
    self.selectedCoffeeShop.longitude = venue[@"location"][@"lng"];
    
    NSString *webAddress = venue[@"url"];
    self.selectedCoffeeShop.webAddress = [NSURL URLWithString:webAddress];
    
    self.selectedCoffeeShop.activitySummary = venue[@"summary"];
    self.selectedCoffeeShop.phoneNumber = venue[@"contact"][@"phone"];
    self.selectedCoffeeShop.city = venue[@"location"][@"city"];
    return self.selectedCoffeeShop;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"cOCoffeeShopDetail"]){
        LERCoffeeShopViewController *coffeeShopDetailViewController = (LERCoffeeShopViewController *)segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
        [self makeDictionaryToCoffeeShopObject:selectedIndexPath];
        coffeeShopDetailViewController.coffeeShopDetails = self.selectedCoffeeShop;
    }
}

@end
