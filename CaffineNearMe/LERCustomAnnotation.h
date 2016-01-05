//
//  LERCustomAnnotation.h
//  CaffeineNearMe
//
//  Created by Lauren Reed on 1/4/16.
//  Copyright © 2016 Lauren Reed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <ionicons/IonIcons.h>
#import "LERCoffeeShopViewController.h"

@interface LERCustomAnnotation : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSDictionary *venue;

- (id)initWithTitle:(NSString *)newTitle
           subtitle:(NSString *)address
              venue:(NSDictionary *)selectedVenue
           location:(CLLocationCoordinate2D)location;
- (MKAnnotationView *)annotationView;

@end
