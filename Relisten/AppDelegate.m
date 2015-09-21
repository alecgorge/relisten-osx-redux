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
@property (strong, nonatomic) RLMainViewController *mainViewController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainViewController = [[RLMainViewController alloc] initWithNibName:@"RLMainViewController" bundle:nil];
    [self.window.contentView addSubview:self.mainViewController.view];
    [self.mainViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.window.contentView);
    }];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *) theApplication
{
    return YES;
}

@end
