//
//  LERCoffeeShop.h
//  CaffeineNearMe
//
//  Created by Lauren Reed on 1/3/16.
//  Copyright © 2016 Lauren Reed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LERCoffeeShop : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *phoneNumber;
@property (nonatomic, strong) NSString *activitySummary;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSArray *formattedAddress;
@property (nonatomic, assign) NSNumber *latitude;
@property (nonatomic, assign) NSNumber *longitude;
@property (nonatomic, strong) NSURL *webAddress;

@end
