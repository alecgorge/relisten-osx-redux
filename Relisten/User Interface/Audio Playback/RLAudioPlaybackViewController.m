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
    
    self.view.wantsLayer = YES;
    self.view.layer.borderColor = [NSColor grayColor].CGColor;
    self.view.layer.borderWidth = 1.5;
    
    self.trackTitleTextField.stringValue = @"";
    self.trackSubtitleTextField.stringValue = @"";
    self.trackBeginningTimeTextField.stringValue = @"00:00:00";
    self.trackEndingTImeTextField.stringValue = @"00:00:00";
    self.bufferingTextField.stringValue = @"";
    
    self.durationFormatter = [[NSDateComponentsFormatter alloc] init];
    self.durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    self.durationFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
}

-(void)playTrack:(IGTrack *)track FromShow:(IGShow *)show
{
    NSInteger index = [show.tracks indexOfObject:track];
    
    NSArray *queue = [show.tracks map:^id(id object) {
        return [[IguanaMediaItem alloc] initWithTrack:object
                                             inShow:show];
    }];
    
    [self.queue clearAndReplaceWithItems:queue];
    [self.audioPlayer playItemAtIndex:index];
}

-(void)updateCurrentTrackInfo:(IguanaMediaItem *)mediaItem
{
    self.trackTitleTextField.stringValue = mediaItem.iguanaTrack.title;
    self.trackSubtitleTextField.stringValue = [NSString stringWithFormat:@"%@ | %@", IGAPIClient.sharedInstance.artist.name, mediaItem.iguanaTrack.show.displayDate];
    self.trackEndingTImeTextField.stringValue = [self.durationFormatter stringFromTimeInterval:mediaItem.iguanaTrack.length];
    self.trackSlider.maxValue = mediaItem.iguanaTrack.length;
    self.trackSlider.minValue = 0.0;
}

#pragma mark - UI Button Interaction Methods

-(void)updatePlayPauseButton
{
   
}

- (IBAction)playPauseButtonPressed:(id)sender
{
}

- (IBAction)nextButtonPressed:(id)sender
{
    [self.audioPlayer forward];
}

- (IBAction)previousButtonPressed:(id)sender
{
    [self.audioPlayer backward];
}

- (IBAction)trackSliderMoved:(id)sender
{
    NSSlider *slider = sender;
    double value = [slider doubleValue];
    [self.audioPlayer seekToPercent:value];
    slider.doubleValue = value;
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
    }
    else if(reason == AGAudioPlayerTrackPlaying)
    {
        IguanaMediaItem *currentMediaItem = (IguanaMediaItem *)self.audioPlayer.currentItem;
        [self updateCurrentTrackInfo:currentMediaItem];
    }
    else if(reason == AGAudioPlayerTrackStopped)
    {
        NSLog(@"Stopped");
    }
    else if(reason == AGAudioPlayerTrackPaused)
    {
        NSLog(@"Paused");
    }
    else if(reason == AGAudioPlayerError)
    {
        
    }
}

@end
