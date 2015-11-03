//
//  RLMainWindowController.m
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLMainWindowController.h"

@interface RLMainWindowController ()

@property (weak) IBOutlet RLSplitView *splitView;
@property (weak) IBOutlet NSPopUpButton *artistsPopupButton;
@property (weak) IBOutlet NSView *audioPlayBackView;

@property (nonatomic, strong) RLArtistsPopupButtonManager *artistPopupManager;
@property (nonatomic, strong) RLYearsVenuesTopShowsViewController *yearsViewController;
@property (nonatomic, strong) RLShowsViewController *showsViewController;
@property (nonatomic, strong) RLSourceAndTracksViewController *sourceAndTracksViewController;
@property (nonatomic, strong) RLAudioPlaybackViewController *audioPlayBackController;

@end

@implementation RLMainWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary;  
    self.splitView.delegate = self;
    
    //Set up Years
    self.yearsViewController = [[RLYearsVenuesTopShowsViewController alloc] initWithNibName:@"RLYearsVenuesTopShowsViewController" bundle:nil];
    self.yearsViewController.delegate = self;
    [self.splitView setFirstViewFromViewController:self.yearsViewController];
    
    //Set up Shows
    self.showsViewController = [[RLShowsViewController alloc] initWithNibName:@"RLShowsViewController" bundle:nil];
    self.showsViewController.delegate = self;
    [self.splitView setSecondViewFromViewController:self.showsViewController];
    
    // Set up Source and Tracks
    self.sourceAndTracksViewController = [[RLSourceAndTracksViewController alloc] initWithNibName:@"RLSourceAndTracksViewController" bundle:nil];
    self.sourceAndTracksViewController.delegate = self;
    [self.splitView setThirdViewFromViewController:self.sourceAndTracksViewController];
    
    // Set up the artist popup button
    self.artistPopupManager = [[RLArtistsPopupButtonManager alloc] initWithPopUpButton:_artistsPopupButton];
    [self.artistPopupManager.artistChanged.executionSignals subscribeNext:^(RACSignal *a) {
        [a subscribeNext:^(IGArtist *artist) {
            
            IGAPIClient.sharedInstance.artist = artist;
            [self.yearsViewController fetchYears];
            [self.showsViewController clearAllShows];
            [self.sourceAndTracksViewController disableSourceSelection];
            [NSUserDefaults.standardUserDefaults setObject:artist.slug
                                                    forKey:@"last_selected_artist_slug"];
            [NSUserDefaults.standardUserDefaults synchronize];
        }];
    }];
    
    [self.artistPopupManager refresh];
    
    // Set up playback controls
    self.audioPlayBackController = [[RLAudioPlaybackViewController alloc] initWithNibName:@"RLAudioPlaybackViewController" bundle:nil];
    self.audioPlayBackController.view.frame = self.audioPlayBackView.bounds;
    self.audioPlayBackController.view.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    self.audioPlayBackController.delegate = self;
    [self.audioPlayBackView addSubview:self.audioPlayBackController.view];
}

#pragma mark - Delegate Handling

-(void)yearSelected:(IGYear *)year
{
    [self.sourceAndTracksViewController disableSourceSelection];
    [self.showsViewController clearAllShows];
    [self.showsViewController fetchShowsForYear:year];
}

-(void)venueSelected:(IGVenue *)venue
{
    [self.sourceAndTracksViewController disableSourceSelection];
    [self.showsViewController clearAllShows];
    [self.showsViewController fetchShowsForVenue:venue];
}

-(void)topShowsSelected
{
    [self.sourceAndTracksViewController disableSourceSelection];
    [self.showsViewController clearAllShows];
    [self.showsViewController fetchTopShows];
}

-(void)showSelected:(IGShow *)show
{
    [self.sourceAndTracksViewController fetchTracksForShow:show];
}

-(void)trackSelected:(IGTrack *)track FromShow:(IGShow *)show
{
    [self.audioPlayBackController playTrack:track FromShow:show];
}

-(void)trackPlayedAtIndex:(NSInteger)index
{
    [self.sourceAndTracksViewController showTrackVisualizationForTrackIndex:index];
}
-(void)trackPausedAtIndex:(NSInteger)index
{
    [self.sourceAndTracksViewController pauseTrackVisualizationForTrackIndex:index];
}

@end
