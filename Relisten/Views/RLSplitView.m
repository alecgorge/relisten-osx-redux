//
//  RLSplitView.m
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLSplitView.h"

@implementation RLSplitView

-(void)setFirstViewFromViewController:(NSViewController *)viewController
{
    [self.firstView addSubview:viewController.view];
    viewController.view.autoresizingMask = NSViewHeightSizable;
}

-(void)setSecondViewFromViewController:(NSViewController *)viewController
{
    self.secondView = viewController.view;
}

-(void)setThirdViewFromViewController:(NSViewController *)viewController
{
    self.thirdView = viewController.view;
}

@end
