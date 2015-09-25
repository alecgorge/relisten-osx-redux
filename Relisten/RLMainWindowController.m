//
//  RLMainWindowController.m
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLMainWindowController.h"

@interface RLMainWindowController ()

@property (weak) IBOutlet NSPopUpButton *artistsPopupButton;

@property (nonatomic, strong) RLArtistsPopupButtonManager *artistPopupManager;

@end

@implementation RLMainWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.window.titleVisibility = NSWindowTitleHidden;
    
    // Set up the artist popup button
    self.artistPopupManager = [[RLArtistsPopupButtonManager alloc] initWithPopUpButton:_artistsPopupButton];
    [self.artistPopupManager.artistChanged.executionSignals subscribeNext:^(RACSignal *a) {
        [a subscribeNext:^(IGArtist *artist) {
            
            // Add artist change handling code here
            [NSUserDefaults.standardUserDefaults setObject:artist.slug
                                                    forKey:@"last_selected_artist_slug"];
            [NSUserDefaults.standardUserDefaults synchronize];
        }];
    }];
    [self.artistPopupManager refresh];
}

@end
