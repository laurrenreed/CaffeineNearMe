//
//  LERMapViewController.m
//  CaffineNearMe
//
//  Created by Lauren Reed on 1/2/16.
//  Copyright © 2016 Lauren Reed. All rights reserved.
//

#import "LERMapViewController.h"
#import "LERCustomAnnotation.h"
#import "LERCoffeeShop.h"
#import "LERCoffeeShopViewController.h"

#define METERS_MILE 1609.344
#define METERS_FEET 3.28084

@interface LERMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) NSArray *venues;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;

@property (nonatomic, strong) LERCoffeeShop *selectedCoffeeShop;
@property (nonatomic, strong) LERCustomAnnotation *coffeeShopAnnotation;

@end

@implementation LERMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedCoffeeShop = [LERCoffeeShop new];
    
    [[self mapView] setShowsUserLocation:YES];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    [[self locationManager] setDelegate:self];
    
    if ([[self locationManager] respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [[self locationManager] requestWhenInUseAuthorization];
    }
    
    [[self locationManager] setDesiredAccuracy:kCLLocationAccuracyBest];
    [[self locationManager] startUpdatingLocation];
    
    self.mapView.delegate = self;
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = locations.lastObject;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2*METERS_MILE, 2*METERS_MILE);
    [[self mapView] setRegion:viewRegion animated:YES];
    
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;
    
    [self.locationManager stopUpdatingLocation];
    [self reverseGeocodeforLocation:location];
    [self getVenuesFromFoursquare];
}

- (void)getVenuesFromFoursquare {
    
    [Foursquare2 venueSearchNearByLatitude:@(self.latitude)
                                 longitude:@(self.longitude)
                                     query:@"Coffee"
                                     limit:@150
                                    intent:intentBrowse
                                    radius:@(100000)
                                categoryId:nil
                                  callback:^(BOOL success, id result) {
                                      NSDictionary *venueDic = (NSDictionary *)result;
                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                          self.venues = venueDic[@"response"][@"venues"];
                                          [self setPointsForCoffeeShops:self.venues];
                                      }];
                                      
                                  }];
    [[self locationManager] stopUpdatingLocation];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{

    LERCustomAnnotation *annotationView = view.annotation;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LERCoffeeShopViewController *selectedCoffeeShopDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"coffeeShopDetail"];
    [self makeDictionaryToCoffeeShopObject:annotationView.venue];
    selectedCoffeeShopDetailVC.coffeeShopDetails = self.selectedCoffeeShop;
    
    NSLog(@" skjdfhskjdbfwkjdbfn %@", selectedCoffeeShopDetailVC.coffeeShopDetails.name);
    
    [[self navigationController] pushViewController:selectedCoffeeShopDetailVC animated:YES];

}

- (void)setPointsForCoffeeShops:(NSArray *)venues {
    
    for (NSDictionary *venue in venues) {
        
        CLLocationCoordinate2D coordinateOfCoffee;
        NSNumber *lat = venue[@"location"][@"lat"];
        NSNumber *lng = venue[@"location"][@"lng"];
        coordinateOfCoffee.latitude = [lat floatValue];
        coordinateOfCoffee.longitude = [lng floatValue];
        
        LERCustomAnnotation *coffeeShopAnnotation = [[LERCustomAnnotation alloc] initWithTitle:venue[@"name"]
                                                                                      subtitle:venue[@"location"][@"address"]
                                                                                         venue:venue
                                                                                      location:coordinateOfCoffee];
        [self.mapView addAnnotation:coffeeShopAnnotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[LERCustomAnnotation class]]) {
        
        LERCustomAnnotation *userLocation = (LERCustomAnnotation *)annotation;
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"customCoffeeAnnotation"];
        
        if (annotationView == nil) {
            annotationView = userLocation.annotationView;
        
        } else {
            annotationView.annotation = annotation;
        
        }
        
        return annotationView;
    }
    
    return nil;
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

- (LERCoffeeShop *)makeDictionaryToCoffeeShopObject:(NSDictionary *)venue {
    self.selectedCoffeeShop = [LERCoffeeShop new];
    
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

@end
