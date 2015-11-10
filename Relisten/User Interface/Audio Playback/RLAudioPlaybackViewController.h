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
#import "RLPlaybackQueueViewController.h"
#import "IguanaMediaItem.h"
#import "IGAPIClient.h"

@protocol RLAudioPlaybackDelegate <NSObject>

- (void)trackPlayedAtIndex:(NSInteger)index forTrack:(IGTrack *)track andShow:(IGShow *)show;
- (void)trackPausedAtIndex:(NSInteger)index forTrack:(IGTrack *)track andShow:(IGShow *)show;

@end

@interface RLAudioPlaybackViewController : NSViewController <AGAudioPlayerDelegate, AGAudioPlayerUpNextQueueDelegate>

@property (nonatomic, weak) id<RLAudioPlaybackDelegate> delegate;

-(void)playTrack:(IGTrack *)track FromShow:(IGShow *)show;

@end
