//
//  LERMapViewController.h
//  CaffineNearMe
//
//  Created by Lauren Reed on 1/2/16.
//  Copyright © 2016 Lauren Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <IonIcons/IonIcons.h>
#import <CoreLocation/CoreLocation.h>
#import <Foursquare-API-v2/Foursquare2.h>

@interface LERMapViewController : UIViewController

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *userCurrentLocationLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
