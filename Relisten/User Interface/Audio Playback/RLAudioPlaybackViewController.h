//
//  RLAudioPlaybackViewController.h
//  Relisten
//
//  Created by Manik Kalra on 10/17/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreImage/CoreImage.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
#import <AGAudioPlayer/AGAudioPlayer.h>
#import <CoreAudio/CoreAudio.h>
#import <AVFoundation/AVFoundation.h>
#import "RLPlaybackQueueViewController.h"
#import "IguanaMediaItem.h"
#import "IGAPIClient.h"

extern NSString *RLAudioPlaybackTrackChanged;

@protocol RLAudioPlaybackDelegate <NSObject>

- (void)trackPlayedAtIndex:(NSInteger)index forTrack:(IGTrack *)track andShow:(IGShow *)show;
- (void)trackPausedAtIndex:(NSInteger)index forTrack:(IGTrack *)track andShow:(IGShow *)show;

@end

@interface RLAudioPlaybackViewController : NSViewController <AGAudioPlayerDelegate, AGAudioPlayerUpNextQueueDelegate>

@property (nonatomic, weak) id<RLAudioPlaybackDelegate> delegate;

-(void)playTrack:(IGTrack *)track FromShow:(IGShow *)show;
-(void)playNextTrack:(IGTrack *)track FromShow:(IGShow *)show;
-(void)addToEndOfQueueTrack:(IGTrack *)track FromShow:(IGShow *)show;
-(void)addToEndOfQueueTracks:(NSArray *)tracks FromShow:(IGShow *)show;

// handle playback
- (IBAction)playPauseButtonPressed:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)previousButtonPressed:(id)sender;

@end
