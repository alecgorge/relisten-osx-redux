//
//  RLTrackTableCellView.h
//  Relisten
//
//  Created by Manik Kalra on 9/30/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CMEqualizerIndicatorView/CMEqualizerIndicatorView.h>
#import "IGTrack.h"

@interface RLTrackTableCellView : NSTableCellView

@property (assign) IBOutlet NSTextField *trackNumberTextField;
@property (assign) IBOutlet NSTextField *trackNameTextField;
@property (assign) IBOutlet NSTextField *trackDurationTextField;
@property (assign) IBOutlet NSMenuItem *playNextMenuItem;
@property (assign) IBOutlet NSMenuItem *addToEndOfQueueMenuItem;
@property (assign) IBOutlet NSMenuItem *addRemainingConcertToQueueMenuItem;
@property (assign) IBOutlet CMEqualizerIndicatorView *equilizerView;

-(void)populateWithTrack:(IGTrack *)track forIndex:(NSInteger)index;

@end
