//
//  RLSplitView.h
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RLSplitView : NSSplitView

@property (weak) IBOutlet NSView *firstView;
@property (weak) IBOutlet NSView *secondView;
@property (weak) IBOutlet NSView *thirdView;

-(void)setFirstViewFromViewController:(NSViewController *)viewController;
-(void)setSecondViewFromViewController:(NSViewController *)viewController;
-(void)setThirdViewFromViewController:(NSViewController *)viewController;

@end
