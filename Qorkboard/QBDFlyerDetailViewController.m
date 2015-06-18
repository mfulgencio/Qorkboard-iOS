//
//  QBDFlyerDetailViewController.m
//  Qorkboard
//
//  Created by Michael Fulgencio on 3/9/14.
//  Copyright (c) 2014 Qorkboard. All rights reserved.
//

#import "QBDFlyerDetailViewController.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation QBDFlyerDetailViewController
@synthesize flyerScrollView, flyerTitle, flyer, info;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //  [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    
    flyerScrollView = [[UIScrollView alloc] initWithFrame:fullScreenRect];
    
    UIImageView *flyerImage = [[UIImageView alloc] initWithImage:flyer];
    flyerImage.contentMode = UIViewContentModeScaleAspectFit;
    
    CGRect frame = flyerImage.frame;
    float imgFactor = frame.size.height / frame.size.width;
    frame.size.width = [[UIScreen mainScreen] bounds].size.width;
    frame.size.height = frame.size.width * imgFactor;
    
    flyerImage.frame = frame;
    
    UITableView *infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 300)];
    
    infoTable.dataSource = self;
    infoTable.delegate = self;
    
    [flyerScrollView addSubview:flyerImage];
    [flyerScrollView addSubview:infoTable];
    flyerScrollView.contentSize = CGSizeMake(320,758);
    flyerScrollView.clipsToBounds = YES;
    
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in flyerScrollView.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    
    [flyerScrollView setContentSize:(CGSizeMake(320, scrollViewHeight))];
    [flyerScrollView setBackgroundColor:[UIColor whiteColor]];
    
    self.view = flyerScrollView;
    
	// add navigationBar buttons
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStyleBordered target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIBarButtonItem *favoriteButton = [[UIBarButtonItem alloc] initWithTitle:@"Favorite" style: UIBarButtonItemStyleBordered target:self action:@selector(Favorite)];
    self.navigationItem.rightBarButtonItem = favoriteButton;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// Returning to the Home Board
- (IBAction)Back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Favoriting the current flyer
- (IBAction)Favorite {
    __block NSMutableArray *sf;
    
    PFQuery *query = [PFQuery queryWithClassName:@"FavoritedFlyers"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 1) {
                sf = [NSMutableArray arrayWithArray:[[objects objectAtIndex:0] objectForKey:@"favorites"]];

                if (![sf containsObject:flyerTitle]) {
                    [sf addObject:flyerTitle];
                    
                    [objects objectAtIndex:0][@"favorites"] = sf;
                    
                    [[objects objectAtIndex:0] saveInBackground];
                }
            } else {
                PFObject *usf = [PFObject objectWithClassName:@"FavoritedFlyers"];
                
                usf[@"username"] = [[PFUser currentUser] username];
                
                sf = [NSMutableArray array];
                [sf addObject:flyerTitle];
                
                usf[@"favorites"] = sf;
                
                [usf saveInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    // change the text of the button to "Remove"
    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style: UIBarButtonItemStyleBordered target:self action:@selector(Remove)];
    self.navigationItem.rightBarButtonItem = removeButton;
}

// Removing the current flyer from the user's favorites
- (IBAction)Remove {
    __block NSMutableArray *sf;
    
    PFQuery *query = [PFQuery queryWithClassName:@"FavoritedFlyers"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 1) {
                sf = [NSMutableArray arrayWithArray:[[objects objectAtIndex:0] objectForKey:@"favorites"]];
                
                [sf removeObject:flyerTitle];
                
                [objects objectAtIndex:0][@"favorites"] = sf;
                
                [[objects objectAtIndex:0] saveInBackground];
            } else {
                PFObject *usf = [PFObject objectWithClassName:@"FavoritedFlyers"];
                
                usf[@"username"] = [[PFUser currentUser] username];
                
                sf = [NSMutableArray array];
                [sf addObject:flyerTitle];
                
                usf[@"favorites"] = sf;
                
                [usf saveInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    // change the text of the button to "Favorite"
    UIBarButtonItem *favoriteButton = [[UIBarButtonItem alloc] initWithTitle:@"Favorite" style: UIBarButtonItemStyleBordered target:self action:@selector(Favorite)];
    self.navigationItem.rightBarButtonItem = favoriteButton;
}

- (NSInteger)tableView:(UITableView *)infoTable numberOfRowsInSection:(NSInteger)section {
    return [info count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 1) {
        //Create the Event Store
        EKEventStore *eventStore = [[EKEventStore alloc]init];
        
        //Check if iOS6 or later is installed on user's device *******************
        if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
            
            //Request the access to the Calendar
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted,NSError* error){
                
                //Access not granted-------------
                if(!granted){
                    NSString *message = @"In order to add this event to your calendar, you must grant Qorkboard access to your calendar";
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Warning"
                                                                       message:message
                                                                      delegate:self
                                                             cancelButtonTitle:@"Ok"
                                                             otherButtonTitles:nil,nil];
                    //Show an alert message!
                    //UIKit needs every change to be done in the main queue
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [alertView show];
                    }
                                   );
                    
                    //Access granted------------------
                } else{
                    
                    //Create the event and set the Label message
                    NSString *labelText;
                    
                    //Event created
                    if([self createEvent:eventStore]){
                        labelText = @"Event added!";
                        
                        //Error occured
                    }else{
                        labelText = @"Something went wrong";
                    }
                    
                    //Add the Label to the controller view
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/1.5, 320, 30)];
                        [label setText:labelText];
                        [label setTextAlignment:NSTextAlignmentCenter];
                        
                        [self.view addSubview:label];
                    });
                }
            }];
        }
        
        //Device prior to iOS 6.0  *********************************************
        else {
            [self createEvent:eventStore];
        }
    } else if (indexPath.row == 2) {
        // Check for iOS 6
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:[info objectAtIndex:indexPath.row]
             completionHandler:^(NSArray *placemarks, NSError *error) {
                 
                 // Convert the CLPlacemark to an MKPlacemark
                 // Note: There's no error checking for a failed geocode
                 CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                 MKPlacemark *placemark = [[MKPlacemark alloc]
                                           initWithCoordinate:geocodedPlacemark.location.coordinate
                                           addressDictionary:geocodedPlacemark.addressDictionary];
                 
                 // Create a map item for the geocoded address to pass to Maps app
                 MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                 [mapItem setName:geocodedPlacemark.name];
                 
                 // Set the directions mode to "Driving"
                 // Can use MKLaunchOptionsDirectionsModeWalking instead
                 NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                 
                 // Get the "Current User Location" MKMapItem
                 MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                 
                 // Pass the current location and destination map items to the Maps app
                 // Set the direction mode in the launchOptions dictionary
                 [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                 
             }];
        }
    } else if (indexPath.row == 3) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[info objectAtIndex:3]]];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"InfoCell";
    NSString *desc;
    NSDate *date;
    
    UITableViewCell *cell = nil; //[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //set your table view cell content here
    NSObject *obj = [self->info objectAtIndex:indexPath.row];
    
    if ([obj isKindOfClass:[NSString class]]){
        desc = [self->info objectAtIndex:indexPath.row];
        [cell.textLabel setText:desc];
    } else if ([obj isKindOfClass:[NSDate class]]) {
        date = [self->info objectAtIndex:indexPath.row];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterFullStyle];
        
        NSString *dateString = [df stringFromDate:date];
        
        [cell.textLabel setText:dateString];
    }
    
    [[cell textLabel] setNumberOfLines:0];
    [[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
    [[cell textLabel] setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    
    if (indexPath.row != 0)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the text so we can measure it
    NSString *text;
    
    NSObject *obj = [self->info objectAtIndex:indexPath.row];
    
    if ([obj isKindOfClass:[NSString class]]){
        text = [self->info objectAtIndex:indexPath.row];
    } else if ([obj isKindOfClass:[NSDate class]]) {
        NSDate *date = [self->info objectAtIndex:indexPath.row];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterFullStyle];
        
        text = [df stringFromDate:date];
    }
    // Get a CGSize for the width and, effectively, unlimited height
   // CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    // Get the size of the text given the CGSize we just made as a constraint
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         [UIFont systemFontOfSize:17.0f]}];    // Get the height of our measurement, with a minimum of 44 (standard cell size)
    CGFloat height = MAX(size.height, 44.0f);
    
    // return the height, with a bit of extra padding in
    return height + (CELL_CONTENT_MARGIN * 2);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self adjustHeightOfTableview];
}

- (void)adjustHeightOfTableview
{
    CGFloat height = self.tableView.contentSize.height;
    CGFloat maxHeight = self.tableView.superview.frame.size.height - self.tableView.frame.origin.y;
    
    // if the height of the content is greater than the maxHeight of
    // total space on the screen, limit the height to the size of the
    // superview.
    
    if (height > maxHeight)
        height = maxHeight;
    
    // now set the frame accordingly
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.tableView.frame;
        frame.size.height = height;
        self.tableView.frame = frame;
        
        // if you have other controls that should be resized/moved to accommodate
        // the resized tableview, do that here, too
    }];
}

//Event creation
-(BOOL)createEvent:(EKEventStore*)eventStore{
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = flyerTitle;
    event.startDate = [[self->info objectAtIndex:1] dateByAddingTimeInterval:25200];
    event.endDate = [event.startDate dateByAddingTimeInterval:3600];
    event.calendar = [eventStore defaultCalendarForNewEvents];
    
    NSError *error;
    [eventStore saveEvent:event span:EKSpanThisEvent error:&error];
    
    if (error) {
        NSLog(@"Event Store Error: %@",[error localizedDescription]);
        return NO;
    }else{
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
