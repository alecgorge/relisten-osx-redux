//
//  RLAudioPlaybackViewController.m
//  Relisten
//
//  Created by Manik Kalra on 10/17/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLAudioPlaybackViewController.h"

@interface RLAudioPlaybackViewController ()

@property (weak) IBOutlet NSTextField *trackTitleTextField;
@property (weak) IBOutlet NSTextField *trackSubtitleTextField;
@property (weak) IBOutlet NSTextField *trackBeginningTimeTextField;
@property (weak) IBOutlet NSTextField *trackEndingTImeTextField;
@property (weak) IBOutlet NSTextField *bufferingTextField;

@property (weak) IBOutlet NSSlider *trackSlider;
@property (weak) IBOutlet NSSlider *volumeSlider;

@property (weak) IBOutlet NSButton *playButton;

@property (nonatomic, strong) AGAudioPlayer *audioPlayer;
@property (nonatomic, strong) AGAudioPlayerUpNextQueue *queue;
@property (nonatomic, strong) NSDateComponentsFormatter *durationFormatter;
@property (nonatomic, strong) RLPlaybackQueueViewController *queueViewController;

@end

@implementation RLAudioPlaybackViewController

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
    self.trackBeginningTimeTextField.stringValue = @"00:00:00";
    self.trackEndingTImeTextField.stringValue = @"00:00:00";
    self.bufferingTextField.stringValue = @"";
    self.volumeSlider.minValue = 0.0;
    self.volumeSlider.maxValue = 1.0;
    
    self.durationFormatter = [[NSDateComponentsFormatter alloc] init];
    self.durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    self.durationFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
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
}

-(void)addToEndOfQueueTrack:(IGTrack *)track FromShow:(IGShow *)show
{
    IguanaMediaItem *item = [[IguanaMediaItem alloc] initWithTrack:track inShow:show];
    [self.queue appendItem:item];
}

-(void)addToEndOfQueueTracks:(NSArray *)tracks FromShow:(IGShow *)show
{
    NSArray *queue = [tracks map:^id(id object) {
        return [[IguanaMediaItem alloc] initWithTrack:object inShow:show];
    }];
    
    [self.queue appendItems:queue];
}

-(void)updateCurrentTrackInfo:(IguanaMediaItem *)mediaItem
{
    self.trackTitleTextField.stringValue = mediaItem.iguanaTrack.title;
    NSString *subtitleText = [NSString stringWithFormat:@"%@ - %@ - %@ - %@", mediaItem.iguanaTrack.show.artist.name, mediaItem.iguanaTrack.show.displayDate, mediaItem.iguanaShow.venue.name, mediaItem.iguanaShow.venue.city];
    self.trackSubtitleTextField.stringValue = subtitleText;
    self.trackEndingTImeTextField.stringValue = [self.durationFormatter stringFromTimeInterval:mediaItem.iguanaTrack.length];
    self.trackSlider.maxValue = mediaItem.iguanaTrack.length;
    self.trackSlider.minValue = 0.0;
}

-(void)clearTrackInfo
{
    [self.audioPlayer stop];
    self.trackTitleTextField.stringValue = @"";
    self.trackSubtitleTextField.stringValue = @"";
    self.trackBeginningTimeTextField.stringValue = @"00:00:00";
    self.trackEndingTImeTextField.stringValue = @"00:00:00";
    self.trackSlider.doubleValue = 0.0;
    self.trackSlider.maxValue = 0.0;
    self.trackSlider.minValue = 0.0;
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
//    NSSlider *slider = sender;
//    double value = [slider doubleValue];
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
    if(reason == AGAudioPlayerTrackBuffering)
        self.bufferingTextField.stringValue = @"Buffering...";
    else
        self.bufferingTextField.stringValue = @"";
    
    if(reason == AGAudioPlayerTrackProgressUpdated)
    {
        self.trackSlider.doubleValue = self.audioPlayer.elapsed;
        self.trackBeginningTimeTextField.stringValue = [self.durationFormatter stringFromTimeInterval:self.audioPlayer.elapsed];
    }
    else if(reason == AGAudioPlayerTrackPlaying)
    {
        IguanaMediaItem *currentMediaItem = (IguanaMediaItem *)self.audioPlayer.currentItem;
        [self updateCurrentTrackInfo:currentMediaItem];
        [self.delegate trackPlayedAtIndex:self.audioPlayer.currentIndex forTrack:currentMediaItem.iguanaTrack andShow:currentMediaItem.iguanaShow];
        [self.queueViewController reloadData];
    }
    else if(reason == AGAudioPlayerTrackStopped)
    {
        [self clearTrackInfo];
    }
    else if(reason == AGAudioPlayerTrackPaused)
    {
         IguanaMediaItem *currentMediaItem = (IguanaMediaItem *)self.audioPlayer.currentItem;
        [self.delegate trackPausedAtIndex:self.audioPlayer.currentIndex forTrack:currentMediaItem.iguanaTrack andShow:currentMediaItem.iguanaShow];
        [self.queueViewController reloadData];
    }
    else if(reason == AGAudioPlayerError)
    {
        
    }
    
    [self updatePlayPauseButton];
}

@end
