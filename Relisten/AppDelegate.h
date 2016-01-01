//
//  AppDelegate.h
//  Relisten
//
//  Created by Manik Kalra on 9/21/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CCNPreferencesWindowController/CCNPreferencesWindowController.h>
#import <LastFm/LastFm.h>
#import "RLLastFMPreferencesViewController.h"
#import "RLMainWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

-(void)enableDockButtons;
-(void)disableDockButtons;
-(void)setDockButtonPlayButton;
-(void)setDockPauseButton;

// Added these methods for easy access in NSApplication subclass
- (IBAction)playOrPauseDockButtonPressed:(id)sender;
- (IBAction)nextDockButtonpressed:(id)sender;
- (IBAction)previousDockButtonPressed:(id)sender;

- (void)showPreferencesWindow;

@end

