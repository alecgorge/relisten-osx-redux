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
#import "IguanaMediaItem.h"
#import "IGAPIClient.h"

@interface RLAudioPlaybackViewController : NSViewController <AGAudioPlayerDelegate>

-(void)playTrack:(IGTrack *)track FromShow:(IGShow *)show;

@end
