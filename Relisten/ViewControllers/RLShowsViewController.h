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

@interface RLShowsViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

- (void)fetchShowsForYear:(IGYear *)year;
- (void)clearAllShows;

@end