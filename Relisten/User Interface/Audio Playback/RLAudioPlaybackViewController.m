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

@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSSlider *volumeSlider;

@property (nonatomic, strong) NSDateComponentsFormatter *durationFormatter;
@property (nonatomic, strong) NSMutableArray <IGTrack *> *trackQueue;

@end

@implementation RLAudioPlaybackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here
    
    // Set up HyteriaPlayer
    HysteriaPlayer *hysteriaPlayer = [HysteriaPlayer sharedInstance];
    hysteriaPlayer.delegate = self;
    hysteriaPlayer.datasource = self;
    
    self.trackQueue = [[NSMutableArray alloc] init];
    
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
    [self.trackQueue removeAllObjects]; // TODO TEMP

    int index = (int)[show.tracks indexOfObject:track];
    
    for(int i = index; i < show.tracks.count; i++)
    {
        IGTrack *track = show.tracks[i];
        [self.trackQueue addObject:track];
    }
    
    HysteriaPlayer *hysteriaPlayer = [HysteriaPlayer sharedInstance];
    [hysteriaPlayer removeAllItems];
    [hysteriaPlayer fetchAndPlayPlayerItem:0];
}

-(void)updateTrackInfo:(IGTrack *)track
{
    self.trackTitleTextField.stringValue = track.title;
    self.trackSubtitleTextField.stringValue = [NSString stringWithFormat:@"%@ | %@", IGAPIClient.sharedInstance.artist.name, track.show.displayDate];
    self.trackEndingTImeTextField.stringValue = [self.durationFormatter stringFromTimeInterval:track.length];
}

#pragma mark - UI Button Interaction Methods

-(void)updatePlayPauseButton
{
    HysteriaPlayer *hysteriaPlayer = [HysteriaPlayer sharedInstance];
    
    if ([hysteriaPlayer isPlaying])
    {
        [self.playButton setImage:[NSImage imageNamed:@"Pause"]];
    }
    else
    {
        [self.playButton setImage:[NSImage imageNamed:@"Play"]];
    }

}

- (IBAction)playPauseButtonPressed:(id)sender
{
    HysteriaPlayer *hysteriaPlayer = [HysteriaPlayer sharedInstance];
    
    if ([hysteriaPlayer isPlaying])
    {
        [hysteriaPlayer pausePlayerForcibly:YES];
        [hysteriaPlayer pause];
    }
    else
    {
        [hysteriaPlayer pausePlayerForcibly:NO];
        [hysteriaPlayer play];
    }
}

- (IBAction)nextButtonPressed:(id)sender
{
    [[HysteriaPlayer sharedInstance] playNext];
}

- (IBAction)previousButtonPressed:(id)sender
{
    [[HysteriaPlayer sharedInstance] playPrevious];
}

#pragma mark - HysteriaPlayerDataSource

- (NSInteger)hysteriaPlayerNumberOfItems
{
     return [self.trackQueue count];
}

- (NSURL *)hysteriaPlayerURLForItemAtIndex:(NSInteger)index preBuffer:(BOOL)preBuffer
{
    NSString *stringUrl = self.trackQueue[index].file;
    NSURL *currentTrackURL = [NSURL URLWithString:stringUrl];
    
    return currentTrackURL;
}

#pragma mark - HysteriaPlayerDelegate

- (void)hysteriaPlayerDidFailed:(HysteriaPlayerFailed)identifier error:(NSError *)error
{
    switch (identifier)
    {
        case HysteriaPlayerFailedPlayer:
            break;
        case HysteriaPlayerFailedCurrentItem:
            [[HysteriaPlayer sharedInstance] playNext];
            break;
        default:
            break;
    }
    
    NSLog(@"%@", [error localizedDescription]);
}

- (void)hysteriaPlayerCurrentItemChanged:(AVPlayerItem *)item
{
    NSLog(@"current item changed");
}

- (void)hysteriaPlayerDidReachEnd
{
    NSLog(@"End reached!");
}

- (void)hysteriaPlayerRateChanged:(BOOL)isPlaying
{
    [self updatePlayPauseButton];
}

- (void)hysteriaPlayerWillChangedAtIndex:(NSInteger)index
{
    IGTrack *currentTrack = self.trackQueue[index];
    [self updateTrackInfo:currentTrack];
}



@end
