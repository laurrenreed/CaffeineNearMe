//
//  LERHomeViewController.m
//  CaffineNearMe
//
//  Created by Lauren Reed on 12/22/15.
//  Copyright © 2015 Lauren Reed. All rights reserved.
//

#import "LERCoffeeShop.h"
#import "LERHomeViewController.h"
#import "LERCustomListCellTableViewCell.h"
#import "LERCoffeeShopViewController.h"
#import "Reachability.h"

#define METERS_TO_MILES 0.000621371192

@interface LERHomeViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *coffeeShopListTableView;
@property (nonatomic, strong) NSArray *venues;
@property (nonatomic, strong) LERCoffeeShop *selectedCoffeeShop;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (weak, nonatomic) IBOutlet UILabel *userCurrentLocationLabel;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation LERHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Caffeine Near Me";
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    [[self locationManager] setDelegate:self];
    
    if ([[self locationManager] respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [[self locationManager] requestWhenInUseAuthorization];
    }
    
    [[self locationManager] setDesiredAccuracy:kCLLocationAccuracyBest];
    [[self locationManager] startUpdatingLocation];
    
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    reach.reachableBlock = ^(Reachability*reach)
    {
        NSLog(@"REACHABLE!");
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"UNREACHABLE!");
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"The Internet connection appears to be offline"
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        });
    };
    
    [reach startNotifier];
    
    [self.coffeeShopListTableView registerNib:[UINib nibWithNibName:@"LERCustomListCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"customListCell"];
    
    self.coffeeShopListTableView.rowHeight = 60;
    self.coffeeShopListTableView.delegate = self;
    self.coffeeShopListTableView.dataSource = self;
    self.coffeeShopListTableView.backgroundColor = [UIColor clearColor];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.coffeeShopListTableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor darkGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [self.coffeeShopListTableView addSubview:self.refreshControl];
    
}

- (void)handleRefresh {
    [[self locationManager] startUpdatingLocation];
    [self.coffeeShopListTableView reloadData];
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
    
    
}



- (void)reverseGeocodeforLocation:(CLLocation *)location {
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            NSString *userLocation =[NSString stringWithFormat:@"➢ %@, %@", [placemark locality], [placemark administrativeArea]];
            self.userCurrentLocationLabel.text = userLocation;
        }

    }];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = locations.lastObject;
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;
    [self reverseGeocodeforLocation:location];
    [self getVenuesFromFoursquare];
}

- (void)getVenuesFromFoursquare {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Coffee Shops";
    hud.labelColor = [UIColor darkGrayColor];
    //radius 10,000 bc there are exactly 2 coffee shops within 1000 of my home town on foursquare
    [Foursquare2 venueSearchNearByLatitude:@(self.latitude)
                                 longitude:@(self.longitude)
                                     query:@"Coffee"
                                     limit:@100
                                    intent:intentBrowse
                                    radius:@(10000)
                                categoryId:nil
                                  callback:^(BOOL success, id result) {
                                      if (success == NO){
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"Unable to connect to the internet, please try again later" delegate:nil cancelButtonTitle:@"okay" otherButtonTitles:nil, nil];
                                      } else {
                                      
                                      NSDictionary *venueDic = (NSDictionary *)result;
                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                          self.venues = venueDic[@"response"][@"venues"];
                                          [self.coffeeShopListTableView reloadData];
                                      }];
                                      }
                                      
    }];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    [[self locationManager] stopUpdatingLocation];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.venues.count;
}

- (void)sortArrayByDistance {
    NSSortDescriptor *orderByDistance = [[NSSortDescriptor alloc] initWithKey:@"location.distance" ascending:YES];
    self.venues = [self.venues sortedArrayUsingDescriptors:[NSArray arrayWithObjects:orderByDistance, nil]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self sortArrayByDistance];
    
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
    [self performSegueWithIdentifier:@"checkOutCoffeeShopDetail" sender:nil];
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
    if([[segue identifier] isEqualToString:@"checkOutCoffeeShopDetail"]){
        LERCoffeeShopViewController *coffeeShopDetailViewController = (LERCoffeeShopViewController *)segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = self.coffeeShopListTableView.indexPathForSelectedRow;
        [self makeDictionaryToCoffeeShopObject:selectedIndexPath];
        coffeeShopDetailViewController.coffeeShopDetails = self.selectedCoffeeShop;
    }
}

@end
