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
@property (weak) IBOutlet NSButton *nowPlayingButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic, strong) RLArtistsPopupButtonManager *artistPopupManager;
@property (nonatomic, strong) RLYearsVenuesTopShowsViewController *yearsViewController;
@property (nonatomic, strong) RLShowsViewController *showsViewController;
@property (nonatomic, strong) RLSourceAndTracksViewController *sourceAndTracksViewController;
@property (nonatomic, strong) RLAudioPlaybackViewController *audioPlayBackController;
@property (nonatomic, strong) IGShow *currentlyPlayingShow;
@property (nonatomic, strong) IGArtist *currentlyPlayingArtist;

@end

@implementation RLMainWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    self.window.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary;  
    self.splitView.delegate = self;
    
    self.nowPlayingButton.enabled = NO;
    
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
            
            [IGAPIClient sharedInstance].artist = artist;
            [self.yearsViewController fetchYearsWithProgressIndicator:self.progressIndicator];
            [self.showsViewController clearAllShows];
            [self.sourceAndTracksViewController disableSourceSelection];
            [NSUserDefaults.standardUserDefaults setObject:artist.slug
                                                    forKey:@"last_selected_artist_slug"];
            [NSUserDefaults.standardUserDefaults synchronize];
        }];
    }];
    
    [self.artistPopupManager refreshWithProgressIndictor:self.progressIndicator];
    
    // Set up playback controls
    self.audioPlayBackController = [[RLAudioPlaybackViewController alloc] initWithNibName:@"RLAudioPlaybackViewController" bundle:nil];
    self.audioPlayBackController.view.frame = self.audioPlayBackView.bounds;
    self.audioPlayBackController.view.autoresizingMask = NSViewWidthSizable;
    self.audioPlayBackController.delegate = self;
    [self.audioPlayBackView addSubview:self.audioPlayBackController.view];
}

#pragma mark - 'Now Playing' Button Handling

- (IBAction)showNowPlayingShow:(id)sender
{
    [self.artistPopupManager selectArtist:self.currentlyPlayingArtist];
    IGAPIClient.sharedInstance.artist = self.currentlyPlayingArtist;
    [self.sourceAndTracksViewController fetchTracksForShow:self.currentlyPlayingShow withProgressIndicator:self.progressIndicator];
    [self.yearsViewController fetchYearsWithProgressIndicator:self.progressIndicator];
    IGYear *year = [[IGYear alloc] init];
    year.year = self.currentlyPlayingShow.year;
    [self.showsViewController fetchShowsForYear:year withProgressIndicator:self.progressIndicator];
}

- (IBAction)refreshArtists:(id)sender
{
    [self.artistPopupManager refreshWithProgressIndictor:self.progressIndicator];
}

#pragma mark - RLYearsVenuesTopShowsSelectionDelegate Handling

-(void)yearSelected:(IGYear *)year
{
    [self.sourceAndTracksViewController disableSourceSelection];
    [self.showsViewController clearAllShows];
    [self.showsViewController fetchShowsForYear:year withProgressIndicator:self.progressIndicator];
}

-(void)venueSelected:(IGVenue *)venue
{
    [self.sourceAndTracksViewController disableSourceSelection];
    [self.showsViewController clearAllShows];
    [self.showsViewController fetchShowsForVenue:venue withProgressIndicator:self.progressIndicator];
}

-(void)topShowsSelected
{
    [self.sourceAndTracksViewController disableSourceSelection];
    [self.showsViewController clearAllShows];
    [self.showsViewController fetchTopShowsWithProgressIndicator:self.progressIndicator];
}

#pragma mark - RLShowSelectedDelegate Handling

-(void)showSelected:(IGShow *)show
{
    [self.sourceAndTracksViewController fetchTracksForShow:show withProgressIndicator:self.progressIndicator];
}

#pragma mark - RLTrackSelectedDelegate Handling

-(void)trackSelected:(IGTrack *)track FromShow:(IGShow *)show
{
    [self.audioPlayBackController playTrack:track FromShow:show];
}

#pragma mark - RLAudioPlaybackDelegate Handling

-(void)trackPlayedAtIndex:(NSInteger)index forTrack:(IGTrack *)track andShow:(IGShow *)show
{
    self.nowPlayingButton.enabled = YES;
    self.currentlyPlayingShow = show;
    self.currentlyPlayingArtist = [IGAPIClient sharedInstance].artist; // TODO. won't work with multi-artist queue
    
    [self.sourceAndTracksViewController showTrackVisualizationForTrackIndex:index andTrack:track];
    [self.showsViewController setCurrentlyPLayingShow:show];
}
-(void)trackPausedAtIndex:(NSInteger)index forTrack:(IGTrack *)track andShow:(IGShow *)show
{
    [self.sourceAndTracksViewController pauseTrackVisualizationForTrackIndex:index andTrack:track];
    [self.showsViewController pauseCurrentlyPLayingShow:show];
}

@end
