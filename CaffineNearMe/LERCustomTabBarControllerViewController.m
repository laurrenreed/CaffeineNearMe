//
//  LERCustomTabBarControllerViewController.m
//  CaffineNearMe
//
//  Created by Lauren Reed on 1/2/16.
//  Copyright © 2016 Lauren Reed. All rights reserved.
//

#import "LERCustomTabBarControllerViewController.h"

@interface LERCustomTabBarControllerViewController ()

@end

@implementation LERCustomTabBarControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UITabBar appearance] setBarTintColor:[UIColor lightGrayColor]];
    
    UIImage *listViewIcon = [IonIcons imageWithIcon:ion_coffee
                                          iconColor:[UIColor grayColor]
                                           iconSize:40.0f
                                          imageSize:CGSizeMake(90.0f, 90.0f)];
    [self.tabBar.items[0] setTitle:nil];
    [self.tabBar.items[0] setImage:listViewIcon];
    self.tabBar.items[0].imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    UIImage *selectedListView = [IonIcons imageWithIcon:ion_coffee
                                              iconColor:[UIColor darkGrayColor]
                                               iconSize:40.0f
                                              imageSize:CGSizeMake(90.0f, 90.0f)];
    self.tabBar.items[0].selectedImage = selectedListView;
    
    UIImage *mapViewIcon = [IonIcons imageWithIcon:ion_map
                                         iconColor:[UIColor grayColor]
                                          iconSize:40.0f
                                         imageSize:CGSizeMake(90.0f, 90.0f)];
    [self.tabBar.items[1] setTitle:nil];
    [self.tabBar.items[1] setImage:mapViewIcon];
    self.tabBar.items[1].imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    UIImage *selectedMapIcon = [IonIcons imageWithIcon:ion_map
                                             iconColor:[UIColor darkGrayColor]
                                              iconSize:40.0f
                                             imageSize:CGSizeMake(90.0f, 90.0f)];
    self.tabBar.items[1].selectedImage = selectedMapIcon;
    
    
//    UIImage *searchViewIcon = [IonIcons imageWithIcon:ion_ios_search_strong
//                                            iconColor:[UIColor grayColor]
//                                             iconSize:40.0f
//                                            imageSize:CGSizeMake(90.0f, 90.0f)];
//    [self.tabBar.items[2] setTitle:nil];
//    [self.tabBar.items[2] setImage:searchViewIcon];
//    self.tabBar.items[2].imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
//    UIImage *selectedSearchIcon = [IonIcons imageWithIcon:ion_ios_search_strong
//                                                iconColor:[UIColor darkGrayColor]
//                                                 iconSize:40.0f
//                                                imageSize:CGSizeMake(90.0f, 90.0f)];
//    self.tabBar.items[2].selectedImage = selectedSearchIcon;
}


@end
