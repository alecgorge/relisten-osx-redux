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
@property (weak) IBOutlet NSView *audioPlayBackView;
@property (weak) IBOutlet NSButton *nowPlayingButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSButton *artistButton;

@property (nonatomic, strong) RLArtistsViewController *artistViewController;
@property (nonatomic, strong) RLYearsVenuesTopShowsViewController *yearsViewController;
@property (nonatomic, strong) RLShowsViewController *showsViewController;
@property (nonatomic, strong) RLSourceAndTracksViewController *sourceAndTracksViewController;
@property (nonatomic, strong) RLAudioPlaybackViewController *audioPlayBackController;
@property (nonatomic, strong) IGShow *currentlyPlayingShow;
@property (nonatomic, strong) NSPopover *artistPopover;

#if !FOR_APPSTORE
@property (nonatomic, strong) SPMediaKeyTap *keyTap;
#endif

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
    
    // Set up the artists
    self.artistViewController = [[RLArtistsViewController alloc] initWithProgressIndictor:self.progressIndicator];
    self.artistViewController.delegate = self;
    self.artistPopover = [[NSPopover alloc] init];
    self.artistPopover.behavior = NSPopoverBehaviorTransient;
    self.artistPopover.animates = YES;
    self.artistPopover.contentSize = NSMakeSize(300, 500);
    self.artistPopover.contentViewController = self.artistViewController;
    
    // Set up playback controls
    self.audioPlayBackController = RLAudioPlaybackViewController.sharedInstance;
    self.audioPlayBackController.view.frame = self.audioPlayBackView.bounds;
    self.audioPlayBackController.view.autoresizingMask = NSViewWidthSizable;
    self.audioPlayBackController.delegate = self;
    [self.audioPlayBackView addSubview:self.audioPlayBackController.view];
    
    // Handle global media keys
#if !FOR_APPSTORE
    self.keyTap = [[SPMediaKeyTap alloc] init];
    [self.keyTap setDelegate:self];
    if([SPMediaKeyTap usesGlobalMediaKeyTap])
    {
        [self.keyTap startWatchingMediaKeys];
    }
#endif
}

- (IBAction)showArtistPopover:(id)sender
{
    [self.artistPopover showRelativeToRect:NSZeroRect ofView:sender preferredEdge:NSMaxYEdge];
}

#pragma mark - 'Now Playing' Button Handling

- (IBAction)showNowPlayingShow:(id)sender
{
    [self.artistButton setTitle:self.currentlyPlayingShow.artist.name];
    [self.artistViewController setSelectedArtist:self.currentlyPlayingShow.artist];
    IGAPIClient.sharedInstance.artist = self.currentlyPlayingShow.artist;
    [self.sourceAndTracksViewController fetchTracksForShow:self.currentlyPlayingShow withProgressIndicator:self.progressIndicator andSelectShowWithId: self.currentlyPlayingShow.id];
    [self.yearsViewController fetchYearsWithProgressIndicator:self.progressIndicator andSelectYear:self.currentlyPlayingShow.year];
    IGYear *year = [[IGYear alloc] init];
    year.year = self.currentlyPlayingShow.year;
    [self.showsViewController fetchShowsForYear:year withProgressIndicator:self.progressIndicator andHighlightShowWithDate: self.currentlyPlayingShow.date];
}

- (IBAction)refreshArtists:(id)sender
{
    [self.artistViewController fetchArtistsWithProgressIndictor:self.progressIndicator];
}

- (IBAction)randomShow:(id)sender
{
    if(![IGAPIClient.sharedInstance artist])
    {
        IGArtist *randomArtist = [self.artistViewController randomArtist];
        
        if(!randomArtist)
            return;
        
        IGAPIClient.sharedInstance.artist = randomArtist;
        [self.artistViewController setSelectedArtist:randomArtist];
        [self.artistButton setTitle:randomArtist.name];
    }
    
    [IGAPIClient.sharedInstance randomShow:^(NSArray *randomShow) {
        
        IGShow *show = randomShow[0];
        [self.sourceAndTracksViewController fetchTracksForShow:show withProgressIndicator:self.progressIndicator];
        IGYear *year = [[IGYear alloc] init];
        year.year = show.year;
        [self.showsViewController fetchShowsForYear:year withProgressIndicator:self.progressIndicator andHighlightShowWithDate:show.date];
        [self.yearsViewController fetchYearsWithProgressIndicator:self.progressIndicator andSelectYear:show.year];
    }];
}

#pragma mark - RLArtistSelectionDelegate Handling

-(void)artistSelected:(IGArtist *)artist
{
    [self.artistButton setTitle:artist.name];
    [self.artistPopover close];
    [IGAPIClient sharedInstance].artist = artist;
    [self.yearsViewController fetchYearsWithProgressIndicator:self.progressIndicator];
    [self.showsViewController clearAllShows];
    [self.sourceAndTracksViewController disableSourceSelection];
    [NSUserDefaults.standardUserDefaults setObject:artist.slug
                                            forKey:@"last_selected_artist_slug"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

#pragma mark - RLYearsVenuesTopShowsSelectionDelegate Handling

-(void)yearSelected:(IGYear *)year
{
    [self.sourceAndTracksViewController disableSourceSelection];
    [self.showsViewController fetchShowsForYear:year withProgressIndicator:self.progressIndicator];
}

-(void)venueSelected:(IGVenue *)venue
{
    [self.sourceAndTracksViewController disableSourceSelection];
    [self.showsViewController fetchShowsForVenue:venue withProgressIndicator:self.progressIndicator];
}

-(void)topShowsSelected
{
    [self.sourceAndTracksViewController disableSourceSelection];
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

- (void)playTrackNext:(IGTrack *)track FromShow:(IGShow *)show
{
    [self.audioPlayBackController playNextTrack:track FromShow:show];
}

- (void)addTrackToEndOfQueue:(IGTrack *)track FromShow:(IGShow *)show
{
    [self.audioPlayBackController addToEndOfQueueTrack:track FromShow:show];
}

- (void)addTracksToQueue:(NSArray *)tracks FromShow:(IGShow *)show
{
    [self.audioPlayBackController addToEndOfQueueTracks:tracks FromShow:show];
}

#pragma mark - RLAudioPlaybackDelegate Handling

-(void)trackPlayedAtIndex:(NSInteger)index forTrack:(IGTrack *)track andShow:(IGShow *)show
{
    [(AppDelegate *)[[NSApplication sharedApplication] delegate] setDockPauseButton];
    
    self.nowPlayingButton.enabled = YES;
    self.currentlyPlayingShow = show;
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = track.title;
    notification.subtitle = show.artist.name;
    notification.informativeText = [NSString stringWithFormat:@"%@ - %@ - %@", show.displayDate, show.venue.name, show.venue.city];
    notification.soundName = nil;
        
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

-(void)trackPausedAtIndex:(NSInteger)index forTrack:(IGTrack *)track andShow:(IGShow *)show
{
    [(AppDelegate *)[[NSApplication sharedApplication] delegate] setDockButtonPlayButton];
}

#pragma mark - Handle global media keys 

#if !FOR_APPSTORE
-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
    NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
    
    // Weird hex stuff needed, too lazy to figure it out...
    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([event data1] & 0x0000FFFF);
    BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    
    if (keyIsPressed)
    {
        switch (keyCode)
        {
            case NX_KEYTYPE_PLAY:
                [self.audioPlayBackController playPauseButtonPressed:nil];
                break;
                
            case NX_KEYTYPE_FAST:
                [self.audioPlayBackController nextButtonPressed:nil];
                break;
                
            case NX_KEYTYPE_REWIND:
                [self.audioPlayBackController previousButtonPressed:nil];
                break;
            default:
                break;
        }
    }
}
#endif

#pragma mark Handle Dock Menu Button

-(void)playPauseDockButtonPressed
{
    [self.audioPlayBackController playPauseButtonPressed:nil];
}

-(void)nextDockButtonPressed
{
     [self.audioPlayBackController nextButtonPressed:nil];
}

-(void)previousDockButtonPressed
{
    [self.audioPlayBackController previousButtonPressed:nil];
}

@end
