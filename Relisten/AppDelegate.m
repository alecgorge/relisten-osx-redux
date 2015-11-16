//
//  AppDelegate.m
//  Relisten
//
//  Created by Manik Kalra on 9/21/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) RLMainWindowController *mainWindowController;
@property (weak) IBOutlet NSMenuItem *playDockButtonMenuItem;
@property (weak) IBOutlet NSMenuItem *nextDockButtonMenuItem;
@property (weak) IBOutlet NSMenuItem *previousDockButtonMenuItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainWindowController = [[RLMainWindowController alloc] initWithWindowNibName:@"RLMainWindowController"];
    [self.mainWindowController.window center];
    [self.mainWindowController showWindow:nil];
    
    [self disableDockButtons];
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
