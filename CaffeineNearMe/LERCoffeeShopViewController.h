//
//  LERCoffeeShopViewController.h
//  CaffeineNearMe
//
//  Created by Lauren Reed on 1/2/16.
//  Copyright © 2016 Lauren Reed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LERCoffeeShop.h"
#import <MapKit/MapKit.h>

@interface LERCoffeeShopViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) LERCoffeeShop *coffeeShopDetails;

@end
