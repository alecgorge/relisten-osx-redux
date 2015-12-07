//
//  RLSourceAndTracksViewController.h
//  Relisten
//
//  Created by Manik Kalra on 9/29/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CMEqualizerIndicatorView/CMEqualizerIndicatorView.h>
#import "RLTrackTableCellView.h"
#import "RLTableView.h"
#import "RLTableRowView.h"
#import "IGAPIClient.h"
#import "RLShowReviewsViewController.h"

@protocol RLTrackSelectedDelegate <NSObject>

- (void)trackSelected:(IGTrack *)track FromShow:(IGShow *)show;
- (void)playTrackNext:(IGTrack *)track FromShow:(IGShow *)show;
- (void)addTrackToEndOfQueue:(IGTrack *)track FromShow:(IGShow *)show;
- (void)addTracksToQueue:(NSArray *)tracks FromShow:(IGShow *)show;

@end

@interface RLSourceAndTracksViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) id<RLTrackSelectedDelegate> delegate;

-(void)fetchTracksForShow:(IGShow *)show withProgressIndicator:(NSProgressIndicator *)indicator;
-(void)fetchTracksForShow:(IGShow *)show withProgressIndicator:(NSProgressIndicator *)indicator andSelectSource: (NSString *)source;
-(void)disableSourceSelection;

@end
