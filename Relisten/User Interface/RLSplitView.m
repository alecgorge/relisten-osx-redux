//
//  RLSplitView.m
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLSplitView.h"

@implementation RLSplitView

//-(NSColor *)dividerColor
//{
//    return [NSColor grayColor];
//}

-(void)setFirstViewFromViewController:(NSViewController *)viewController
{
    viewController.view.frame = self.firstView.bounds;
    
//    for (NSView *subview in self.firstView.subviews) // May need this in case we have to swap views
//    {
//        [subview removeFromSuperview];
//    }
    
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
    viewController.view.frame = self.thirdView.bounds;
    [self.thirdView addSubview:viewController.view];
    viewController.view.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
}

@end
