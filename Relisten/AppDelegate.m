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

@interface AppDelegate ()

@property (strong, nonatomic) RLMainWindowController *mainWindowController;
@property (weak) IBOutlet NSMenuItem *playDockButtonMenuItem;
@property (weak) IBOutlet NSMenuItem *nextDockButtonMenuItem;
@property (weak) IBOutlet NSMenuItem *previousDockButtonMenuItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [Fabric with:@[[Crashlytics class]]];

    self.mainWindowController = [[RLMainWindowController alloc] initWithWindowNibName:@"RLMainWindowController"];
    [self.mainWindowController.window center];
    [self.mainWindowController showWindow:nil];
    
    [self disableDockButtons];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
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

#pragma maek - Dock Button Handling

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
