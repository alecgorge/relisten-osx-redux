//
//  AppDelegate.m
//  Relisten
//
//  Created by Manik Kalra on 9/21/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "AppDelegate.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>

@interface AppDelegate ()

@property (strong, nonatomic) RLMainWindowController *mainWindowController;
@property (strong, nonatomic) CCNPreferencesWindowController *preferencesWindowController;

@property (weak) IBOutlet NSMenuItem *playDockButtonMenuItem;
@property (weak) IBOutlet NSMenuItem *nextDockButtonMenuItem;
@property (weak) IBOutlet NSMenuItem *previousDockButtonMenuItem;

@end

@implementation AppDelegate
{
    id localMonitorID;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [Parse setApplicationId:@"rURhGR7F6bUme9KzatDPPVUyQYtMFooooIwbdb6Q"
                  clientKey:@"6WDQvQeq9za3LklgmHJxTECtL4k0iKWIwvDc3yPX"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:nil];
    [Fabric with:@[[Crashlytics class]]];

    self.mainWindowController = [[RLMainWindowController alloc] initWithWindowNibName:@"RLMainWindowController"];
    [self.mainWindowController.window center];
    [self.mainWindowController showWindow:nil];
    
    [self disableDockButtons];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    // Handle global play pause by pressing Spacebar
    localMonitorID = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent * _Nullable(NSEvent * _Nonnull theEvent) {
        
        if (theEvent.keyCode == 49) // Spacebar 
        {
            [self playOrPauseDockButtonPressed:nil];
            theEvent = nil; // nil the event so the default behavior is overriden 
        }
        
        return theEvent;
    }];
    
    // Set up preferences
    self.preferencesWindowController = [CCNPreferencesWindowController new];
    self.preferencesWindowController.centerToolbarItems = YES;
    self.preferencesWindowController.allowsVibrancy = YES;
    self.preferencesWindowController.showToolbarItemsAsSegmentedControl = YES;
    
    RLLastFMPreferencesViewController *lastfm = [[RLLastFMPreferencesViewController alloc] init];
    [self.preferencesWindowController setPreferencesViewControllers:@[lastfm]];
    
    // Set up Lastfm
    LastFm.sharedInstance.apiKey = @"f2b89dbc431a938a385203bb218e5310";
    LastFm.sharedInstance.apiSecret = @"5c1ace2f9e7cdbb4c0b2fbbcc9ddb426";
    LastFm.sharedInstance.session = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastfm_session_key"];
    LastFm.sharedInstance.username = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastfm_username_key"];
}

-(void)dealloc
{
    [NSEvent removeMonitor:localMonitorID];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)visibleWindows
{
    if (visibleWindows)
    {
        [self.self.mainWindowController.window orderFront:self];
    }
    else
    {
        [self.self.mainWindowController.window makeKeyAndOrderFront:self];
    }
    
    return YES;
}

#pragma mark - Local Notifications

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    if(![self.mainWindowController.window isKeyWindow])
        return YES;
    
    return NO;
}

#pragma mark - Menu Button Handling

- (IBAction)sendFeedback:(id)sender
{
    NSString *toAddress = @"alecgorge@gmail.com";
    NSString *subject = @"Relisten Feedback";
    NSString *bodyText = @"";

    NSString *mailtoAddress = [[NSString stringWithFormat:@"mailto:%@?Subject=%@&body=%@", toAddress, subject, bodyText] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:mailtoAddress]];
}

- (IBAction)showPreferences:(id)sender
{
    [self.preferencesWindowController showPreferencesWindow];
}

#pragma mark - Dock Button Handling

-(void)enableDockButtons
{
    self.playDockButtonMenuItem.enabled = YES;
    self.nextDockButtonMenuItem.enabled = YES;
    self.previousDockButtonMenuItem.enabled = YES;
}

-(void)disableDockButtons
{
    self.playDockButtonMenuItem.enabled = NO;
    self.nextDockButtonMenuItem.enabled = NO;
    self.previousDockButtonMenuItem.enabled = NO;
}

-(void)setDockButtonPlayButton
{
    [self enableDockButtons];
    self.playDockButtonMenuItem.title = @"Play";
}

-(void)setDockPauseButton
{
    [self enableDockButtons];
    self.playDockButtonMenuItem.title = @"Pause";
}

- (IBAction)playOrPauseDockButtonPressed:(id)sender
{
    [self.mainWindowController playPauseDockButtonPressed];
}

- (IBAction)nextDockButtonpressed:(id)sender
{
    [self.mainWindowController nextDockButtonPressed];
}

- (IBAction)previousDockButtonPressed:(id)sender
{
    [self.mainWindowController previousDockButtonPressed];
}

@end
