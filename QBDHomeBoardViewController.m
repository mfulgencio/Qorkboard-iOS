//
//  QBDHomeBoardViewController.m
//  Qorkboard
//
//  Created by Michael Fulgencio on 2/27/14.
//  Copyright (c) 2014 Qorkboard. All rights reserved.
//

#import "QBDHomeBoardViewController.h"

@implementation QBDHomeBoardViewController

#define PADDING_TOP 0 // For placing the images nicely in the grid
#define PADDING 4
#define THUMBNAIL_COLS 2
#define THUMBNAIL_WIDTH 150
#define THUMBNAIL_HEIGHT 300

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    allImages = [[NSMutableArray alloc] init];
    
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    
    // Set up Location Manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate=self;
    self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    self.locationManager.distanceFilter=kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
    
    // Check to see if we are near San Luis Obispo
    CLLocationCoordinate2D targetPoint = CLLocationCoordinate2DMake(35.272468, -120.665909);
    CLRegion *targetRegion = [[CLCircularRegion alloc] initWithCenter:targetPoint
                                                     radius:self.locationManager.maximumRegionMonitoringDistance
                                                 identifier:@"San Luis Obispo"];
    
    
    BOOL monitoringAvailability = [CLLocationManager isMonitoringAvailableForClass:[targetRegion class]];
    
    if (monitoringAvailability) {
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            [self.locationManager startMonitoringForRegion:targetRegion];
        }
    }
    
    [self.locationManager requestStateForRegion:targetRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpImages:(NSArray *)images
{
    // Contains a list of all the BUTTONS
    allImages = [images mutableCopy];
    
    // This method sets up the downloaded images and places them nicely in a grid
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray *imageDataArray = [NSMutableArray array];
        
        // Iterate over all images and get the data from the PFFile
        for (int i = 0; i < images.count; i++) {
            PFObject *eachObject = [images objectAtIndex:i];
            PFFile *theImage = [eachObject objectForKey:@"image"];
            NSData *imageData = [theImage getData];
            UIImage *image = [UIImage imageWithData:imageData];
            [imageDataArray addObject:image];
        }
        
        // Dispatch to main thread to update the UI
        dispatch_async(dispatch_get_main_queue(), ^{
            // Remove old grid
            for (UIView *view in [photoScrollView subviews]) {
                if ([view isKindOfClass:[UIButton class]]) {
                    [view removeFromSuperview];
                }
            }
            
            // Create the buttons necessary for each image in the grid
            for (int i = 0; i < [imageDataArray count]; i++) {
                PFObject *eachObject = [images objectAtIndex:i];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *image = [imageDataArray objectAtIndex:i];
                [button setImage:image forState:UIControlStateNormal];
                button.showsTouchWhenHighlighted = YES;
                [button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = i;
                button.frame = CGRectMake(THUMBNAIL_WIDTH * (i % THUMBNAIL_COLS) + PADDING * (i % THUMBNAIL_COLS) + PADDING,
                                          THUMBNAIL_HEIGHT * (i / THUMBNAIL_COLS) + PADDING * (i / THUMBNAIL_COLS) + PADDING + PADDING_TOP,
                                          THUMBNAIL_WIDTH,
                                          THUMBNAIL_HEIGHT);
                button.imageView.contentMode = UIViewContentModeScaleAspectFill;
                [button setTitle:[eachObject objectId] forState:UIControlStateReserved];
                
                [button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
                
                [photoScrollView addSubview:button];
            }
            
            // Size the grid accordingly
            int rows = images.count / THUMBNAIL_COLS;
            if (((float)images.count / THUMBNAIL_COLS) - rows != 0) {
                rows++;
            }
            int height = THUMBNAIL_HEIGHT * rows + PADDING * rows + PADDING + PADDING_TOP;
            
            photoScrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
            photoScrollView.clipsToBounds = YES;
        });
    });
}

/********************
 ********************
 ********************
 ***** Button *******
 **** Handling ******
 ********************
 *******************/

- (IBAction)refresh:(id)sender
{
    // Set up to query for all Flyers sorted in order of when flyer was uploaded
    PFQuery *query = [PFQuery queryWithClassName:@"Flyer"];
    [query orderByAscending:@"createdAt"];
    
    // Query for matching flyers (in this case, all)
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Retrieve existing objectIDs
            NSMutableArray *oldCompareObjectIDArray = [NSMutableArray array];
            for (UIView *view in [photoScrollView subviews]) {
                if ([view isKindOfClass:[UIButton class]]) {
                    UIButton *eachButton = (UIButton *)view;
                    [oldCompareObjectIDArray addObject:[eachButton titleForState:UIControlStateReserved]];
                }
            }
            
            NSMutableArray *oldCompareObjectIDArray2 = [NSMutableArray arrayWithArray:oldCompareObjectIDArray];
            
            // If there are photos, we start extracting the data
            // Save a list of object IDs while extracting this data
            
            NSMutableArray *newObjectIDArray = [NSMutableArray array];
            if (objects.count > 0) {
                for (PFObject *eachObject in objects) {
                    [newObjectIDArray addObject:[eachObject objectId]];
                }
            }
            
            // Compare the old and new object IDs
            NSMutableArray *newCompareObjectIDArray = [NSMutableArray arrayWithArray:newObjectIDArray];
            NSMutableArray *newCompareObjectIDArray2 = [NSMutableArray arrayWithArray:newObjectIDArray];
            if (oldCompareObjectIDArray.count > 0) {
                // New objects
                [newCompareObjectIDArray removeObjectsInArray:oldCompareObjectIDArray];
                // Remove old objects if you delete them using the web browser
                [oldCompareObjectIDArray removeObjectsInArray:newCompareObjectIDArray2];
                if (oldCompareObjectIDArray.count > 0) {
                    // Check the position in the objectIDArray and remove
                    NSMutableArray *listOfToRemove = [[NSMutableArray alloc] init];
                    for (NSString *objectID in oldCompareObjectIDArray){
                        int i = 0;
                        for (NSString *oldObjectID in oldCompareObjectIDArray2){
                            if ([objectID isEqualToString:oldObjectID]) {
                                // Make list of all that you want to remove and remove at the end
                                [listOfToRemove addObject:[NSNumber numberWithInt:i]];
                            }
                            i++;
                        }
                    }
                    
                    // Remove from the back
                    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
                    [listOfToRemove sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
                    
                    for (NSNumber *index in listOfToRemove){
                        [allImages removeObjectAtIndex:[index intValue]];
                    }
                }
            }
            
            // Add new objects
            for (NSString *objectID in newCompareObjectIDArray){
                for (PFObject *eachObject in objects){
                    if ([[eachObject objectId] isEqualToString:objectID]) {
                        NSMutableArray *selectedPhotoArray = [[NSMutableArray alloc] init];
                        [selectedPhotoArray addObject:eachObject];
                        
                        
                        if (selectedPhotoArray.count > 0) {
                            [allImages addObjectsFromArray:selectedPhotoArray];
                        }
                    }
                }
            }
            
            // Remove and add from objects before this
            [self setUpImages:allImages];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)buttonTouched:(id)sender {
    // When picture is touched, open a viewcontroller with the image
    PFObject *theObject = (PFObject *)[allImages objectAtIndex:[sender tag]];
    PFFile *theImage = [theObject objectForKey:@"image"];
    NSData *imageData;
    imageData = [theImage getData];
    UIImage *selectedPhoto = [UIImage imageWithData:imageData];
    
    // Get all of the relevant information from the selected flyer
    NSString *ft = [theObject objectForKey:@"title"];
    NSString *desc = [theObject objectForKey:@"description"];
    NSDate *start = [theObject objectForKey:@"startDateAndTime"];
    NSString *location = [theObject objectForKey:@"location"];
    NSString *website = [theObject objectForKey:@"website"];
    
    // Initialize FlyerDetailView
    QBDFlyerDetailViewController *fdvc = [[QBDFlyerDetailViewController alloc] init];
    fdvc.flyerTitle = ft;
    fdvc.flyer = selectedPhoto;
    fdvc.info = [[NSMutableArray alloc] initWithObjects:
                 desc, start, location, website, nil];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:fdvc];
    
    //now present this navigation controller modally
    [self presentViewController:navigationController animated:YES completion:nil];
}

/********************
 ********************
 ********************
 ***** Location *****
 ********************
 ********************
 *******************/

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
//    NSString *currentLatitude = [[NSString alloc]
//                                 initWithFormat:@"%+.6f",
//                                 newLocation.coordinate.latitude];
//    _latitude.text = currentLatitude;
//    
//    NSString *currentLongitude = [[NSString alloc]
//                                  initWithFormat:@"%+.6f",
//                                  newLocation.coordinate.longitude];
//    _longitude.text = currentLongitude;
//    
//    NSString *currentHorizontalAccuracy =
//    [[NSString alloc]
//     initWithFormat:@"%+.6f",
//     newLocation.horizontalAccuracy];
//    _horizontalAccuracy.text = currentHorizontalAccuracy;
//    
//    NSString *currentAltitude = [[NSString alloc]
//                                 initWithFormat:@"%+.6f",
//                                 newLocation.altitude];
//    _altitude.text = currentAltitude;
//    
//    NSString *currentVerticalAccuracy =
//    [[NSString alloc]
//     initWithFormat:@"%+.6f",
//     newLocation.verticalAccuracy];
//    _verticalAccuracy.text = currentVerticalAccuracy;
//    
//    if (_startLocation == nil)
//        _startLocation = newLocation;
//    
//    CLLocationDistance distanceBetween = [newLocation
//                                          distanceFromLocation:_startLocation];
//    
//    NSString *tripString = [[NSString alloc]
//                            initWithFormat:@"%f",
//                            distanceBetween];
//    _distance.text = tripString;
}

//- (void)registerRegionWithCircularOverlay:(MKCircle*)overlay andIdentifier:(NSString*)identifier {
//    
//    // If the overlay's radius is too large, registration fails automatically,
//    // so clamp the radius to the max value.
//    CLLocationDegrees radius = overlay.radius;
//    if (radius > self.locationManager.maximumRegionMonitoringDistance) {
//        radius = self.locationManager.maximumRegionMonitoringDistance;
//    }
//    
//    // Create the geographic region to be monitored.
//    CLCircularRegion *geoRegion = [[CLCircularRegion alloc]
//                                   initWithCenter:overlay.coordinate
//                                   radius:radius
//                                   identifier:identifier];
//    [self.locationManager startMonitoringForRegion:geoRegion];
//}

// This method is used if the user is already inside the region we're monitoring for
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside){
        PFQuery *query = [PFQuery queryWithClassName:@"Flyer"];
        //  PFUser *user = [PFUser currentUser];
        [query whereKey:@"city" equalTo:region.identifier];
        [query orderByAscending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // Retrieve existing objectIDs
                
                NSMutableArray *oldCompareObjectIDArray = [NSMutableArray array];
                for (UIView *view in [photoScrollView subviews]) {
                    if ([view isKindOfClass:[UIButton class]]) {
                        UIButton *eachButton = (UIButton *)view;
                        [oldCompareObjectIDArray addObject:[eachButton titleForState:UIControlStateReserved]];
                    }
                }
                
                NSMutableArray *oldCompareObjectIDArray2 = [NSMutableArray arrayWithArray:oldCompareObjectIDArray];
                
                // If there are photos, we start extracting the data
                // Save a list of object IDs while extracting this data
                
                NSMutableArray *newObjectIDArray = [NSMutableArray array];
                if (objects.count > 0) {
                    for (PFObject *eachObject in objects) {
                        [newObjectIDArray addObject:[eachObject objectId]];
                    }
                }
                
                // Compare the old and new object IDs
                NSMutableArray *newCompareObjectIDArray = [NSMutableArray arrayWithArray:newObjectIDArray];
                NSMutableArray *newCompareObjectIDArray2 = [NSMutableArray arrayWithArray:newObjectIDArray];
                if (oldCompareObjectIDArray.count > 0) {
                    // New objects
                    [newCompareObjectIDArray removeObjectsInArray:oldCompareObjectIDArray];
                    // Remove old objects if you delete them using the web browser
                    [oldCompareObjectIDArray removeObjectsInArray:newCompareObjectIDArray2];
                    if (oldCompareObjectIDArray.count > 0) {
                        // Check the position in the objectIDArray and remove
                        NSMutableArray *listOfToRemove = [[NSMutableArray alloc] init];
                        for (NSString *objectID in oldCompareObjectIDArray){
                            int i = 0;
                            for (NSString *oldObjectID in oldCompareObjectIDArray2){
                                if ([objectID isEqualToString:oldObjectID]) {
                                    // Make list of all that you want to remove and remove at the end
                                    [listOfToRemove addObject:[NSNumber numberWithInt:i]];
                                }
                                i++;
                            }
                        }
                        
                        // Remove from the back
                        NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
                        [listOfToRemove sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
                        
                        for (NSNumber *index in listOfToRemove){
                            [allImages removeObjectAtIndex:[index intValue]];
                        }
                    }
                }
                
                // Add new objects
                for (NSString *objectID in newCompareObjectIDArray){
                    for (PFObject *eachObject in objects){
                        if ([[eachObject objectId] isEqualToString:objectID]) {
                            NSMutableArray *selectedPhotoArray = [[NSMutableArray alloc] init];
                            [selectedPhotoArray addObject:eachObject];
                            
                            
                            if (selectedPhotoArray.count > 0) {
                                [allImages addObjectsFromArray:selectedPhotoArray];
                            }
                        }
                    }
                }
                
                // Remove and add from objects before this
                [self setUpImages:allImages];
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        [self.locationManager stopMonitoringForRegion:region];
    }else{
        NSLog(@"is out of target region");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // Delegate of the location manager, when you have an error
    NSLog(@"locationManager didFailWithError: %@", error);
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Qorkboard"
                                                        message:@"Whoops! We can't seem to determine your location"
                                                        delegate:self
                                                        cancelButtonTitle:@"ok"
                                                        otherButtonTitles:nil];
    
    [errorAlert show];
}

/********************
 ********************
 ***** Login ********
 ******* & **********
 ***** Signup *******
 ********************
 *******************/

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

@end
