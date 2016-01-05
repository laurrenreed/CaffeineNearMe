//
//  LERCustomAnnotation.m
//  CaffeineNearMe
//
//  Created by Lauren Reed on 1/4/16.
//  Copyright © 2016 Lauren Reed. All rights reserved.
//

#import "LERCustomAnnotation.h"

@implementation LERCustomAnnotation

- (id)initWithTitle:(NSString *)newTitle
           subtitle:(NSString *)address
              venue:(NSDictionary *)selectedVenue
           location:(CLLocationCoordinate2D)location{
    
    self = [super init];
 
    if (self) {
        _title = newTitle;
        _subtitle = address;
        _venue = selectedVenue;
        _coordinate = location;
    }
    
    return self;
}

- (MKAnnotationView *)annotationView {
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self
                                                                    reuseIdentifier:@"customCoffeeAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];

    UIImage *coffeeIcon = [IonIcons imageWithIcon:ion_coffee
                                             size:35.0f
                                            color:[UIColor darkGrayColor]];
    
    annotationView.image = coffeeIcon;

    return annotationView;
}

@end
