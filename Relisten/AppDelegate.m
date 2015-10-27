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

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainWindowController = [[RLMainWindowController alloc] initWithWindowNibName:@"RLMainWindowController"];
    [self.mainWindowController.window center];
    [self.mainWindowController showWindow:nil];
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

@end
