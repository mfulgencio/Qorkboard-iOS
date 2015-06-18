//
//  QBDMyBoardViewController.m
//  Qorkboard
//
//  Created by Michael on 2/23/14.
//  Copyright (c) 2014 Qorkboard. All rights reserved.
//

#import "QBDMyBoardViewController.h"

@implementation QBDMyBoardViewController

#define PADDING_TOP 0 // For placing the images nicely in the grid
#define PADDING 4
#define THUMBNAIL_COLS 2
#define THUMBNAIL_WIDTH 150
#define THUMBNAIL_HEIGHT 300

BOOL firstRun = YES;

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
    NSLog(@"in viewDidLoad");
	
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    __block NSMutableArray *sf;
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
    
    PFQuery *query = [PFQuery queryWithClassName:@"FavoritedFlyers"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 1) {
                sf = [NSMutableArray arrayWithArray:[[objects objectAtIndex:0] objectForKey:@"favorites"]];
                
                if (sf.count != 0) {
                    NSArray *chronSF = [[sf reverseObjectEnumerator] allObjects];
                    
                    PFQuery *query2 = [PFQuery queryWithClassName:@"Flyer"];
                    [query2 whereKey:@"title" containedIn:chronSF];
                    [query2 orderByAscending:@"createdAt"];
                    
                    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            //                        NSLog(@"Successfully retrieved %lu photos in My Board.", (unsigned long)objects.count);
                            
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
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"No Favorites"
                                                message:@"Head on over to the Home Board to start favoriting!"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
            } else {
                [[[UIAlertView alloc] initWithTitle:@"No Favorites"
                                            message:@"Head on over to the Home Board to start favoriting!"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    __block NSMutableArray *sf;
    
    NSLog(@"in viewWillAppear");
    
    if (firstRun == NO) {
        PFQuery *query = [PFQuery queryWithClassName:@"FavoritedFlyers"];
        [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count == 1) {
                    sf = [NSMutableArray arrayWithArray:[[objects objectAtIndex:0] objectForKey:@"favorites"]];
                    
                    NSArray *chronSF = [[sf reverseObjectEnumerator] allObjects];
                    
                    PFQuery *query2 = [PFQuery queryWithClassName:@"Flyer"];
                    [query2 whereKey:@"title" containedIn:chronSF];
                    [query2 orderByAscending:@"createdAt"];
                    
                    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
                } else {
                    
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    } else {
        firstRun = NO;
    }
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
    __block NSMutableArray *sf;
    
    PFQuery *query = [PFQuery queryWithClassName:@"FavoritedFlyers"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 1) {
                sf = [NSMutableArray arrayWithArray:[[objects objectAtIndex:0] objectForKey:@"favorites"]];
                
                NSArray *chronSF = [[sf reverseObjectEnumerator] allObjects];

                PFQuery *query2 = [PFQuery queryWithClassName:@"Flyer"];
                [query2 whereKey:@"title" containedIn:chronSF];
                [query2 orderByAscending:@"createdAt"];
                
                [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
            } else {
                
            }
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
    
    NSString *ft = [theObject objectForKey:@"title"];
    NSString *desc = [theObject objectForKey:@"description"];
    NSDate *start = [theObject objectForKey:@"startDateAndTime"];
    NSString *location = [theObject objectForKey:@"location"];
    NSString *website = [theObject objectForKey:@"website"];
    
    QBDMyBoardFlyerDetailViewController *mbfdvc = [[QBDMyBoardFlyerDetailViewController alloc] init];
    
    mbfdvc.flyerTitle = ft;
    mbfdvc.flyer = selectedPhoto;
    mbfdvc.info = [[NSMutableArray alloc] initWithObjects:
                 desc, start, location, website, nil];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mbfdvc];
    
    //now present this navigation controller as modally
    [self presentViewController:navigationController animated:YES completion:nil];
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
