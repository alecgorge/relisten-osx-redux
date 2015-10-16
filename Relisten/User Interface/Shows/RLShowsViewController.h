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
#import "IGAPIClient.h"

@protocol RLShowSelectedDelegate <NSObject>

- (void)showSelected:(IGShow *)show;

@end

@interface RLShowsViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) id<RLShowSelectedDelegate> delegate;

- (void)fetchShowsForYear:(IGYear *)year;
- (void)fetchShowsForVenue:(IGVenue *)venue;
- (void)clearAllShows;

@end
