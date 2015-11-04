//
//  RLTrackTableCellView.h
//  Relisten
//
//  Created by Manik Kalra on 9/30/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CMEqualizerIndicatorView/CMEqualizerIndicatorView.h>

@interface RLTrackTableCellView : NSTableCellView

@property (assign) IBOutlet NSTextField *trackNumberTextField;
@property (assign) IBOutlet NSTextField *trackNameTextField;
@property (assign) IBOutlet NSTextField *trackDurationTextField;
@property (assign) IBOutlet NSButton *trackPullDownButton;
@property (assign) IBOutlet CMEqualizerIndicatorView *equilizerView;

@end
