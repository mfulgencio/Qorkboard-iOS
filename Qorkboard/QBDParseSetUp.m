//
//  QBDParseSetUp.m
//  Qorkboard
//
//  Created by Michael Fulgencio on 6/17/15.
//  Copyright (c) 2015 Qorkboard. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@implementation QBDParseSetUp : NSObject 

- (void)setUpParse
{
    // Set up Parse backend
    [Parse setApplicationId:@"tsm7PSg6DqHNYDzphOVrCrdmcYmnlABnAn1PavDh"
                  clientKey:@"6dPvpOljgRtVcdvYEBumeEvXwGy8IVFYhAWk20Hk"];
}

@end