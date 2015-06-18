//
//  QBDTabBarController.h
//  Qorkboard
//
//  Created by Michael Fulgencio on 6/7/14.
//  Copyright (c) 2014 Qorkboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBDMenuDrawerController.h"

@interface QBDTabBarController : UITabBarController <UINavigationControllerDelegate>
{
    UIView *menuDrawer;
}

// Side Drawer
@property (readonly, nonatomic) UISwipeGestureRecognizer *recognizerOpen, *recognizerClose;
@property (readonly, nonatomic) int menuDrawerX, menuDrawerWidth;

-(void)handleSwipes:(UISwipeGestureRecognizer *) sender;
-(void)drawerAnimation;

extern CGFloat menuDrawerXOrigin;
extern CGFloat menuDrawerYOrigin;

@end
