//
//  RLPlaybackQueueCellView.h
//  Relisten
//
//  Created by Manik Kalra on 11/9/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CMEqualizerIndicatorView/CMEqualizerIndicatorView.h>

@interface RLPlaybackQueueCellView : NSTableCellView

@property (assign) IBOutlet NSTextField *trackTitleTextField;
@property (assign) IBOutlet CMEqualizerIndicatorView *equilizerView;
@property (assign) IBOutlet NSTextField *trackArtistTextField;
@property (assign) IBOutlet NSTextField *trackShowDetailsTextField;

@end
