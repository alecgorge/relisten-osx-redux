//
//  RLShowsViewController.h
//  Relisten
//
//  Created by Manik Kalra on 9/26/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RLShowTableViewCell.h"
#import "RLTableView.h"
#import "RLTableRowView.h"
#import "IGAPIClient.h"

@protocol RLShowSelectedDelegate <NSObject>

- (void)showSelected:(IGShow *)show;

@end

@interface RLShowsViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSTabViewDelegate>

@property (nonatomic, weak) id<RLShowSelectedDelegate> delegate;

- (void)fetchShowsForYear:(IGYear *)year withProgressIndicator:(NSProgressIndicator *)indicator;
- (void)fetchShowsForVenue:(IGVenue *)venue withProgressIndicator:(NSProgressIndicator *)indicator;
- (void)fetchTopShowsWithProgressIndicator:(NSProgressIndicator *)indicator;
- (void)fetchRandomShowWithProgressIndicator:(NSProgressIndicator *)indicator andShow:(void (^)(IGShow *))success;
- (void)clearAllShows;
- (void)setCurrentlyPLayingShow:(IGShow *)show;
- (void)pauseCurrentlyPLayingShow:(IGShow *)show;

@end
