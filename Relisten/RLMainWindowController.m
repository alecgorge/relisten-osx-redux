//
//  RLMainWindowController.m
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLMainWindowController.h"

@interface RLMainWindowController ()

// IB properties
@property (weak) IBOutlet RLSplitView *splitView;
@property (weak) IBOutlet NSPopUpButton *artistsPopupButton;

@property (nonatomic, strong) RLArtistsPopupButtonManager *artistPopupManager;
@property (nonatomic, strong) RLYearsViewController *yearsViewController;

@end

@implementation RLMainWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.window.titleVisibility = NSWindowTitleHidden;
    
    //Set up Years
    self.yearsViewController = [[RLYearsViewController alloc] initWithNibName:@"RLYearsViewController" bundle:nil];
    [self.splitView setFirstViewFromViewController:self.yearsViewController];
    self.splitView.delegate = self;
    
    // Set up the artist popup button
    self.artistPopupManager = [[RLArtistsPopupButtonManager alloc] initWithPopUpButton:_artistsPopupButton];
    [self.artistPopupManager.artistChanged.executionSignals subscribeNext:^(RACSignal *a) {
        [a subscribeNext:^(IGArtist *artist) {
            
            IGAPIClient.sharedInstance.artist = artist;
            [self.yearsViewController fetchYears];
            [NSUserDefaults.standardUserDefaults setObject:artist.slug
                                                    forKey:@"last_selected_artist_slug"];
            [NSUserDefaults.standardUserDefaults synchronize];
        }];
    }];
    [self.artistPopupManager refresh];
}

#pragma mark - NSSplitViewDelegate Methods

-(NSRect)splitView:(NSSplitView *)splitView effectiveRect:(NSRect)proposedEffectiveRect forDrawnRect:(NSRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex
{
    return NSZeroRect;
}

@end
