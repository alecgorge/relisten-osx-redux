//
//  RLAudioPlaybackViewController.m
//  Relisten
//
//  Created by Manik Kalra on 10/17/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLAudioPlaybackViewController.h"

NSString *RLAudioPlaybackTrackChanged = @"rl_audio_track_changed_notification";

IGShow *RLAudioPlaybackCurrentShow = nil;
IGTrack *RLAudioPlaybackCurrentTrack = nil;

@interface RLAudioPlaybackViewController ()

@property (weak) IBOutlet NSTextField *trackTitleTextField;
@property (weak) IBOutlet NSTextField *trackSubtitleTextField;
@property (weak) IBOutlet NSTextField *trackBeginningTimeTextField;
@property (weak) IBOutlet NSTextField *trackEndingTImeTextField;
@property (weak) IBOutlet NSTextField *bufferingTextField;

@property (weak) IBOutlet NSSlider *trackSlider;
@property (weak) IBOutlet NSSlider *volumeSlider;

@property (weak) IBOutlet NSButton *playButton;

@property (nonatomic, strong) NSDateComponentsFormatter *durationFormatter;
@property (nonatomic, strong) RLPlaybackQueueViewController *queueViewController;

//properties for scrobbing
@property (nonatomic, weak) IguanaMediaItem *currentMediaItem;
@property (nonatomic) BOOL currentTrackHasBeenScrobbed;

@end

@implementation RLAudioPlaybackViewController

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [self.alloc initWithNibName:NSStringFromClass(self.class)
                                              bundle:nil];
    });
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here
    
    // Set up AudioPlayer
    self.queue = [[AGAudioPlayerUpNextQueue alloc] init];
    self.audioPlayer = [[AGAudioPlayer alloc] initWithQueue:self.queue];
    self.audioPlayer.delegate = self;
    self.queueViewController = [[RLPlaybackQueueViewController alloc] initWithAudioPlayer:self.audioPlayer];
    
//    self.view.wantsLayer = YES;
//    self.view.layer.borderColor = [NSColor grayColor].CGColor;
//    self.view.layer.borderWidth = 1.0;
    
    self.trackTitleTextField.stringValue = @"";
    self.trackSubtitleTextField.stringValue = @"";
    self.trackBeginningTimeTextField.stringValue = @"00:00";
    self.trackEndingTImeTextField.stringValue = @"00:00";
    self.bufferingTextField.stringValue = @"Buffering…";
    self.bufferingTextField.hidden = YES;
    self.volumeSlider.minValue = 0.0;
    self.volumeSlider.maxValue = 1.0;
    self.volumeSlider.doubleValue = 1.0;
    
    self.durationFormatter = [[NSDateComponentsFormatter alloc] init];
    self.durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    self.durationFormatter.allowedUnits = (NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    self.currentTrackHasBeenScrobbed = NO;
}

#pragma mark - Track Manipulation

-(void)playTrack:(IGTrack *)track FromShow:(IGShow *)show
{
    NSInteger index = [show.tracks indexOfObject:track];
    
    NSArray *queue = [show.tracks map:^id(id object) {
        return [[IguanaMediaItem alloc] initWithTrack:object inShow:show];
    }];
    
    self.trackSlider.doubleValue = 0.0;
    [self.queue clearAndReplaceWithItems:queue];
    [self.audioPlayer playItemAtIndex:index];
}

-(void)playNextTrack:(IGTrack *)track FromShow:(IGShow *)show
{
    IguanaMediaItem *item = [[IguanaMediaItem alloc] initWithTrack:track inShow:show];
    [self.queue appendItem:item];
    [self.queue moveItem:item toIndex:self.audioPlayer.currentIndex + 1]; // POSSIBLY WRONG
    
    self.bufferingTextField.hidden = !self.audioPlayer.isBuffering;
}

-(void)addToEndOfQueueTrack:(IGTrack *)track FromShow:(IGShow *)show
{
    IguanaMediaItem *item = [[IguanaMediaItem alloc] initWithTrack:track inShow:show];
    [self.queue appendItem:item];
    self.bufferingTextField.hidden = !self.audioPlayer.isBuffering;
}

-(void)addToEndOfQueueTracks:(NSArray *)tracks FromShow:(IGShow *)show
{
    NSArray *queue = [tracks map:^id(id object) {
        return [[IguanaMediaItem alloc] initWithTrack:object inShow:show];
    }];
    
    [self.queue appendItems:queue];
    self.bufferingTextField.hidden = !self.audioPlayer.isBuffering;
}

-(void)updateCurrentTrackInfo:(IguanaMediaItem *)mediaItem
{
    self.trackTitleTextField.stringValue = mediaItem.iguanaTrack.title;
    NSString *subtitleText = [NSString stringWithFormat:@"%@ - %@ - %@ - %@", mediaItem.iguanaTrack.show.artist.name, mediaItem.iguanaTrack.show.displayDate, mediaItem.iguanaShow.venue.name, mediaItem.iguanaShow.venue.city];
    self.trackSubtitleTextField.stringValue = subtitleText;
    self.trackEndingTImeTextField.stringValue = [self.durationFormatter stringFromTimeInterval:mediaItem.iguanaTrack.length];
    self.trackSlider.maxValue = mediaItem.iguanaTrack.length;
    self.trackSlider.minValue = 0.0;
    
    self.bufferingTextField.hidden = self.audioPlayer.isBuffering;
}

-(void)clearTrackInfo
{
    self.trackTitleTextField.stringValue = @"";
    self.trackSubtitleTextField.stringValue = @"";
    self.trackBeginningTimeTextField.stringValue = @"00:00";
    self.trackEndingTImeTextField.stringValue = @"00:00";
    self.trackSlider.doubleValue = 0.0;
    self.trackSlider.maxValue = 0.0;
    self.trackSlider.minValue = 0.0;
    self.bufferingTextField.hidden = YES;
}

#pragma mark - UI Button Interaction Methods

-(void)updatePlayPauseButton
{
    if(self.audioPlayer.isPlaying)
        [self.playButton setImage:[NSImage imageNamed:@"Pause"]];
    else
        [self.playButton setImage:[NSImage imageNamed:@"Play"]];;
}

- (IBAction)playPauseButtonPressed:(id)sender
{
    if(self.audioPlayer.isPlaying)
        [self.audioPlayer pause];
    else
        [self.audioPlayer resume];
}

- (IBAction)nextButtonPressed:(id)sender
{
    if(self.audioPlayer.queue.count > 0)
        [self.audioPlayer forward];
}

- (IBAction)previousButtonPressed:(id)sender
{
    if(self.audioPlayer.queue.count > 0)
        [self.audioPlayer backward];
}

- (IBAction)trackSliderMoved:(id)sender
{
    NSSlider *slider = sender;
    double value = [slider doubleValue];
    self.trackBeginningTimeTextField.stringValue = [self.durationFormatter stringFromTimeInterval:value];
    [self.audioPlayer seekTo:value];
}

- (IBAction)volumeSliderMoved:(id)sender
{
    NSSlider *slider = sender;
    double value = [slider doubleValue];
    
    self.audioPlayer.volume = value;
}

#pragma mark - Queue Manipulation Methods

- (IBAction)showPlaybackQueue:(id)sender
{
    NSPopover *popover = [[NSPopover alloc] init];
    popover.behavior = NSPopoverBehaviorTransient;
    popover.animates = YES;
    popover.contentSize = NSMakeSize(400, 400);
    popover.contentViewController = self.queueViewController;
    
    [popover showRelativeToRect:NSZeroRect ofView:sender preferredEdge:NSMaxYEdge];
}

#pragma mark - AGAudioPlayerDelegate Methods

- (void)audioPlayer:(AGAudioPlayer *)audioPlayer uiNeedsRedrawForReason:(AGAudioPlayerRedrawReason)reason extraInfo:(NSDictionary *)dict
{
    self.bufferingTextField.hidden = !self.audioPlayer.isBuffering;
    
    IguanaMediaItem *item = (IguanaMediaItem *)self.audioPlayer.currentItem;
    RLAudioPlaybackCurrentShow = item.iguanaShow;
    RLAudioPlaybackCurrentTrack = item.iguanaTrack;
    
    if(reason == AGAudioPlayerTrackProgressUpdated)
    {
        self.trackSlider.doubleValue = self.audioPlayer.elapsed;
        self.trackBeginningTimeTextField.stringValue = [self.durationFormatter stringFromTimeInterval:self.audioPlayer.elapsed];
        
        [self updateLastFMScrobbleWithItem:item];
    }
    else if(reason == AGAudioPlayerTrackPlaying)
    {
        IguanaMediaItem *currentMediaItem = (IguanaMediaItem *)self.audioPlayer.currentItem;
        
        if(![self.currentMediaItem isEqual:currentMediaItem])
        {
            self.currentTrackHasBeenScrobbed = NO;
            self.currentMediaItem = (IguanaMediaItem *)self.audioPlayer.currentItem;
            
            NSString *album = [NSString stringWithFormat:@"%@ - %@ - %@", item.iguanaTrack.show.displayDate, item.iguanaShow.venue.name, item.iguanaShow.venue.city];
            
            [[LastFm sharedInstance] sendNowPlayingTrack:item.iguanaTrack.title
                                                 byArtist:item.iguanaShow.artist.name
                                                  onAlbum:album
                                             withDuration:item.iguanaTrack.length
                                           successHandler:nil
                                           failureHandler:nil];
        }
        
        [IGAPIClient.sharedInstance playTrack:currentMediaItem.iguanaTrack
                                       inShow:currentMediaItem.iguanaShow];
        
        [self updateCurrentTrackInfo:currentMediaItem];
        [self.delegate trackPlayedAtIndex:self.audioPlayer.currentIndex
                                 forTrack:currentMediaItem.iguanaTrack
                                  andShow:currentMediaItem.iguanaShow];
        
        [self.queueViewController reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RLAudioPlaybackTrackChanged
                                                          object:self
                                                        userInfo:nil];
    }
    else if(reason == AGAudioPlayerTrackStopped)
    {
        [self clearTrackInfo];
    }
    else if(reason == AGAudioPlayerTrackPaused)
    {
        IguanaMediaItem *currentMediaItem = (IguanaMediaItem *)self.audioPlayer.currentItem;
        
        if(currentMediaItem)
        {
            [self.delegate trackPausedAtIndex:self.audioPlayer.currentIndex
                                     forTrack:currentMediaItem.iguanaTrack
                                      andShow:currentMediaItem.iguanaShow];
        }
        else
        {
            [self clearTrackInfo];
        }
        
        [self.queueViewController reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RLAudioPlaybackTrackChanged
                                                          object:self
                                                        userInfo:nil];
    }
    else if(reason == AGAudioPlayerError)
    {
        
    }
    
    [self updatePlayPauseButton];
}

-(void)updateLastFMScrobbleWithItem:(IguanaMediaItem *)item
{
    if([LastFm sharedInstance].username && self.currentTrackHasBeenScrobbed == NO)
    {
        CGFloat progress = self.audioPlayer.elapsed/item.iguanaTrack.length;
        
        if(progress > 0.5)
        {
             NSString *album = [NSString stringWithFormat:@"%@ - %@ - %@", item.iguanaTrack.show.displayDate, item.iguanaShow.venue.name, item.iguanaShow.venue.city];
            
            [[LastFm sharedInstance] sendScrobbledTrack:item.iguanaTrack.title
                                               byArtist:item.iguanaShow.artist.name
                                                onAlbum:album
                                           withDuration:item.iguanaTrack.length
                                            atTimestamp:(int)[[NSDate date] timeIntervalSince1970]
                                         successHandler:nil
                                         failureHandler:nil];
            
            self.currentTrackHasBeenScrobbed = YES;
        }
    }
}

@end
