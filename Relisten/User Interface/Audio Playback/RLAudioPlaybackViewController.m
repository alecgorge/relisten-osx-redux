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
@property (weak) IBOutlet NSSlider *trackSlider;

@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSSlider *volumeSlider;

@property (nonatomic, strong) NSDateComponentsFormatter *durationFormatter;

@end

@implementation RLAudioPlaybackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here
    
    self.view.wantsLayer = YES;
    self.view.layer.borderColor = [NSColor grayColor].CGColor;
    self.view.layer.borderWidth = 1.5;
    
    self.trackTitleTextField.stringValue = @"";
    self.trackSubtitleTextField.stringValue = @"";
    self.trackBeginningTimeTextField.stringValue = @"00:00:00";
    self.trackEndingTImeTextField.stringValue = @"00:00:00";
    
    self.durationFormatter = [[NSDateComponentsFormatter alloc] init];
    self.durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    self.durationFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
}

-(void)playTrack:(IGTrack *)track
{
    self.trackTitleTextField.stringValue = track.title;
    self.trackSubtitleTextField.stringValue = [NSString stringWithFormat:@"%@ | %@", IGAPIClient.sharedInstance.artist.name, track.show.displayDate];
    self.trackEndingTImeTextField.stringValue = [self.durationFormatter stringFromTimeInterval:track.length];
}

@end
