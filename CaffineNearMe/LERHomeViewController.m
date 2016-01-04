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

@interface LERHomeViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *coffeeShopListTableView;
@property (nonatomic, strong) NSArray *venues;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic, strong) CLLocation *lastUpdatedLocation;
@property (nonatomic, strong) void (^locationCompletion)(CLLocation *location, BOOL success);
@property (nonatomic, strong) LERCoffeeShop *selectedCoffeeShop;


@end

@implementation LERHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.coffeeShopListTableView registerNib:[UINib nibWithNibName:@"LERCustomListCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"customListCell"];
    
    self.coffeeShopListTableView.rowHeight = 60;
    self.coffeeShopListTableView.delegate = self;
    self.coffeeShopListTableView.dataSource = self;
    self.coffeeShopListTableView.backgroundColor = [UIColor clearColor];
    
    [self getVenuesFromFoursquare];
}

- (void)getVenuesFromFoursquare {
    [Foursquare2 venueSearchNearByLatitude:@(40.73224021865526)
                                 longitude:@(-73.99370899999997)
                                     query:@"Coffee"
                                     limit:@100
                                    intent:intentBrowse
                                    radius:@(1000)
                                categoryId:nil
                                  callback:^(BOOL success, id result) {
        NSDictionary *venueDic = (NSDictionary *)result;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.venues = venueDic[@"response"][@"venues"];
                [self.coffeeShopListTableView reloadData];
        }];
                                      
    }];
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
    NSNumber *distance = venue[@"location"][@"distance"];
    NSString *distanceFromMe = [NSString stringWithFormat:@"%@ mls", distance];
    cell.distanceFromMe.text = distanceFromMe;
    NSLog(@"VENUE!!! %@", venue);
    
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
    self.selectedCoffeeShop.phoneNumber = venue[@"phone"];
    self.selectedCoffeeShop.city = venue[@"location"][@"city"];
    return self.selectedCoffeeShop;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"checkOutCoffeeShopDetail"]){
        //         PGBChatMessageVC *chatViewController = (PGBChatMessageVC *)segue.destinationViewController;

        LERCoffeeShopViewController *coffeeShopDetailViewController = (LERCoffeeShopViewController *)segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = self.coffeeShopListTableView.indexPathForSelectedRow;
        [self makeDictionaryToCoffeeShopObject:selectedIndexPath];
        coffeeShopDetailViewController.coffeeShopDetails = self.selectedCoffeeShop;
    }
}

@end
