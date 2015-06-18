//
//  QBDHomeBoardViewController.h
//  Qorkboard
//
//  Created by Michael Fulgencio on 2/27/14.
//  Copyright (c) 2014 Qorkboard. All rights reserved.
//

#import <Parse/Parse.h>
#include <stdlib.h>
#import <UIKit/UIKit.h>
#import "QBDFlyerDetailViewController.h"

@interface QBDHomeBoardViewController : UIViewController
    <UINavigationControllerDelegate, CLLocationManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
{
    IBOutlet UIScrollView *photoScrollView;
    NSMutableArray *allImages;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)refresh:(id)sender;
- (void)setUpImages:(NSArray *)images;
- (void)buttonTouched:(id)sender;

@end