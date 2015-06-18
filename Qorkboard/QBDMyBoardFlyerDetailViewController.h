//
//  QBDMyBoardFlyerDetailViewController.h
//  Qorkboard
//
//  Created by Michael Fulgencio on 6/1/14.
//  Copyright (c) 2014 Qorkboard. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <MapKit/MapKit.h>

@interface QBDMyBoardFlyerDetailViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    IBOutlet UIScrollView *flyerScrollView;
    IBOutlet UINavigationItem *navBar;
    NSString *flyerTitle;
    UIImage *flyer;
    NSMutableArray *info;
    NSMutableArray *savedFlyers;
}

@property (strong, nonatomic) IBOutlet UIScrollView *flyerScrollView;
@property (strong, nonatomic) IBOutlet NSString *flyerTitle;
@property (strong, nonatomic) IBOutlet UIImage *flyer;
@property (strong, nonatomic) IBOutlet NSMutableArray *info;
@property (nonatomic, copy) UIColor *backgroundColor;

- (BOOL)createEvent:(EKEventStore*)eventStore;

@end
