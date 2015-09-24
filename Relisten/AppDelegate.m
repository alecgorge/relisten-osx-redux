//
//  AppDelegate.m
//  Relisten
//
//  Created by Manik Kalra on 9/21/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) RLMainWindowController *mainWindowController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainWindowController = [[RLMainWindowController alloc] initWithWindowNibName:@"RLMainWindowController"];
    [self.mainWindowController showWindow:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *) theApplication
{
    return YES;
}

@end
