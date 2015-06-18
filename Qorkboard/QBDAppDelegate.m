//
//  QBDAppDelegate.m
//  Qorkboard
//
//  Created by Michael on 2/22/14.
//  Copyright (c) 2014 Qorkboard. All rights reserved.
//

#import <Parse/Parse.h>
#import "QBDAppDelegate.h"
#import "QBDHomeBoardViewController.h"
#import "QBDMyBoardViewController.h"

@implementation QBDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set up Parse backend
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"]];
    NSString *applicationId = [dictionary objectForKey:@"parseApplicationId"];
    NSString *clientKey = [dictionary objectForKey:@"parseClientKey"];
    
    [Parse setApplicationId:applicationId
                  clientKey:clientKey];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Set NavigationBar tint color based on iOS version
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [[UINavigationBar appearance] setTintColor: [UIColor colorWithRed:30/255.0 green:134/255.0 blue:193/255.0 alpha:1.0]];
    } else {
        [[UINavigationBar appearance] setBarTintColor: [UIColor colorWithRed:30/255.0 green:134/255.0 blue:193/255.0 alpha:1.0]];
    }
    
    // White navigation text
    self.window.tintColor = [UIColor whiteColor];
    
    // White status bar content
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Qorkboard Blue tabs
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:30/255.0 green:134/255.0 blue:193/255.0 alpha:1.0]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
