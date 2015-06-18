//
//  QBDTabBarController.m
//  Qorkboard
//
//  Created by Michael Fulgencio on 6/7/14.
//  Copyright (c) 2014 Qorkboard. All rights reserved.
//

#import "QBDTabBarController.h"

@interface QBDTabBarController ()
@end

@implementation QBDTabBarController
@synthesize menuDrawerWidth, menuDrawerX, recognizerOpen, recognizerClose;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    // side drawer
//    int statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//    menuDrawerWidth = self.view.frame.size.width * 0.75;
//    menuDrawerX = self.view.frame.origin.x - menuDrawerWidth;
//    menuDrawer = [[UIView alloc]initWithFrame:CGRectMake(menuDrawerX, self.view.frame.origin.y+statusBarHeight, menuDrawerWidth, self.view.frame.size.height-statusBarHeight)];
//    
//    menuDrawer.backgroundColor = [UIColor colorWithRed:30/255.0 green:134/255.0 blue:193/255.0 alpha:1.0];
//    
//    recognizerClose = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipes:)];
//    recognizerOpen = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipes:)];
//    recognizerClose.direction = UISwipeGestureRecognizerDirectionLeft;
//    recognizerOpen.direction = UISwipeGestureRecognizerDirectionRight;
//    
//    [self.view addGestureRecognizer:recognizerOpen];
//    [self.view addGestureRecognizer:recognizerClose];
//    
//    [self.view addSubview:menuDrawer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleSwipes:(UISwipeGestureRecognizer *) sender {
//    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
//        
//    } else if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
//        
//    }
//    [self drawerAnimation];
}

-(void)drawerAnimation {
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDuration:-5];
//    
//    CGFloat newX = 0;
//    CGFloat newTabControllerX = 0;
//    
//    menuDrawer.frame.origin.
//    
//    if (menuDrawer.frame.origin.x < self.view.frame.origin.x) {
//        newX = menuDrawer.frame.origin.x + menuDrawerWidth;
//        newTabControllerX = self.view.frame.origin.x + menuDrawerWidth;
//    } else {
//        newX = menuDrawer.frame.origin.x - menuDrawerWidth;
//        newTabControllerX = self.view.frame.origin.x - menuDrawerWidth;
//    }
//    
//    menuDrawer.frame = CGRectMake(newX, menuDrawer.frame.origin.y, menuDrawer.frame.size.width, menuDrawer.frame.size.height);
//    self.view.frame = CGRectMake(newTabControllerX, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
//    
//    [UIView commitAnimations];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
