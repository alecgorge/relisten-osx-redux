//
//  RLSourceAndTracksViewController.h
//  Relisten
//
//  Created by Manik Kalra on 9/29/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RLTrackTableCellView.h"
#import "RLTableView.h"
#import "IGAPIClient.h"

@protocol RLTrackSelectedDelegate <NSObject>

- (void)trackSelected:(IGTrack *)track FromShow:(IGShow *)show;

@end

@interface RLSourceAndTracksViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) id<RLTrackSelectedDelegate> delegate;

-(void)fetchTracksForShow:(IGShow *)show;
-(void)disableSourceSelection;

@end
