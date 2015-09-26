//
//  RLSplitView.m
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLSplitView.h"

@implementation RLSplitView

-(NSColor *)dividerColor
{
    return [NSColor grayColor];
}

-(void)setFirstViewFromViewController:(NSViewController *)viewController
{
    viewController.view.frame = self.firstView.bounds;
    [self.firstView addSubview:viewController.view];
    viewController.view.autoresizingMask = NSViewHeightSizable;
}

-(void)setSecondViewFromViewController:(NSViewController *)viewController
{
    viewController.view.frame = self.secondView.bounds;
    [self.secondView addSubview:viewController.view];
    viewController.view.autoresizingMask = NSViewHeightSizable;
}

-(void)setThirdViewFromViewController:(NSViewController *)viewController
{
    [self.thirdView addSubview:viewController.view];
    viewController.view.autoresizingMask = NSViewHeightSizable;
}

@end
