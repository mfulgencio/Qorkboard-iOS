//
//  QBDMyBoardViewController.h
//  Qorkboard
//
//  Created by Michael on 2/23/14.
//  Copyright (c) 2014 Qorkboard. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "QBDMyBoardFlyerDetailViewController.h"

@interface QBDMyBoardViewController : UIViewController <UINavigationControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
{
    IBOutlet UIScrollView *photoScrollView;
    NSMutableArray *allImages;
}

@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)refresh:(id)sender;
- (void)setUpImages:(NSArray *)images;
- (void)buttonTouched:(id)sender;

extern BOOL firstRun;

@end