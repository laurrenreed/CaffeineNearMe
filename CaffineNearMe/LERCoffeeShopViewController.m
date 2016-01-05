//
//  LERCoffeeShopViewController.m
//  CaffeineNearMe
//
//  Created by Lauren Reed on 1/2/16.
//  Copyright © 2016 Lauren Reed. All rights reserved.
//

#import "LERCoffeeShopViewController.h"
#import "LERCustomAnnotation.h"

#define METERS_PER_MILE 1609.344
@interface LERCoffeeShopViewController ()
@property (weak, nonatomic) IBOutlet UILabel *coffeeShopName;
@property (weak, nonatomic) IBOutlet UITextView *formattedAddress;
@property (weak, nonatomic) IBOutlet UILabel *city;
@property (weak, nonatomic) IBOutlet UILabel *activitySummary;
@property (weak, nonatomic) IBOutlet UIButton *phoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *webAddress;

@property (strong, nonatomic) NSArray *objectsToShare;

@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *share;
@property (weak, nonatomic) IBOutlet UIButton *directions;

@end

@implementation LERCoffeeShopViewController 

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.alpha = 0.75;
    
    self.mapView.delegate = self;
    
    self.coffeeShopName.text = self.coffeeShopDetails.name;
    
    NSArray *address = self.coffeeShopDetails.formattedAddress;
    NSString *formattedAddress = [address componentsJoinedByString:@"\n"];
    if (self.coffeeShopDetails.formattedAddress == nil) {
        self.formattedAddress.text = @"Address unavailable";
    } else {
        self.formattedAddress.text = formattedAddress;
        self.formattedAddress.scrollEnabled = NO;
    }
    self.formattedAddress.textAlignment = NSTextAlignmentCenter;
    
    self.city.text = self.coffeeShopDetails.city;
    if (self.coffeeShopDetails.activitySummary == nil){
        self.activitySummary.hidden = YES;
    } else {
        self.activitySummary.text = self.coffeeShopDetails.activitySummary;

    }
    
    if (self.coffeeShopDetails.phoneNumber == nil) {
        [[self phoneNumber] setTitle:@"Phone number univailable" forState:UIControlStateNormal];
    } else {
        NSString *phoneNumber = [NSString stringWithFormat:@"%@", self.coffeeShopDetails.phoneNumber];
        [[self phoneNumber] setTitle: phoneNumber forState:UIControlStateNormal];
    }
    
    if (self.coffeeShopDetails.webAddress == nil) {
        self.webAddress.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [self.coffeeShopDetails.latitude floatValue];
    zoomLocation.longitude = [self.coffeeShopDetails.longitude floatValue];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [_mapView setRegion:viewRegion animated:YES];
    
//    coffeeShopLocation.coordinate = annotationCoord;
//    coffeeShopLocation.title = self.coffeeShopDetails.name;
//    
//    [self.mapView addAnnotation:coffeeShopLocation];
    LERCustomAnnotation *coffeeShopPin = [[LERCustomAnnotation alloc] initWithTitle:nil subtitle:nil venue:nil location:zoomLocation];
    
    [self.mapView addAnnotation:coffeeShopPin];
    
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

- (IBAction)phoneNumber:(id)sender {
    
    NSString *phoneNumber = [NSString stringWithFormat:@"%@", self.coffeeShopDetails.phoneNumber];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phoneNumber]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
       
        UIAlertView *callFailed = [[UIAlertView alloc]initWithTitle:@"Uh oh!" message:@"Calling unavailable at this time." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [callFailed show];
 
    }
}


- (IBAction)webAddress:(id)sender {
    [[UIApplication sharedApplication] openURL:self.coffeeShopDetails.webAddress];
}

- (IBAction)directionsTapped:(id)sender {
    CLLocationCoordinate2D coffeeShopCoordinate;
    coffeeShopCoordinate.latitude = [self.coffeeShopDetails.latitude floatValue];
    coffeeShopCoordinate.longitude = [self.coffeeShopDetails.longitude floatValue];

    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coffeeShopCoordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:[NSString stringWithFormat:@"%@", self.coffeeShopDetails.name]];
 
    [mapItem openInMapsWithLaunchOptions:nil];
}


- (IBAction)shareButtonTapped:(id)sender {
    NSString *coffeeShopName = self.coffeeShopDetails.name;
    NSString *textToShare = @"Look at this cool coffee shop I found!";
    NSURL *webAddressToShare = self.coffeeShopDetails.webAddress;
    NSString *streetAddress = self.coffeeShopDetails.formattedAddress[0];
    
    if (webAddressToShare == nil) {
        self.objectsToShare = @[textToShare, coffeeShopName, streetAddress];
    } else {
        self.objectsToShare = @[textToShare, coffeeShopName, streetAddress, webAddressToShare];
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:self.objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToVimeo];
    activityVC.excludedActivityTypes = excludeActivities;
    [self presentViewController:activityVC animated:YES completion:nil];

}

@end
