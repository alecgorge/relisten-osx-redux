//
//  AppDelegate.h
//  Relisten
//
//  Created by Manik Kalra on 9/21/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Masonry/Masonry.h>
#import "RLMainWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

-(void)enableDockButtons;
-(void)disableDockButtons;
-(void)setDockButtonPlayButton;
-(void)setDockPauseButton;

@end

