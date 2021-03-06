//
//  RLYearsViewController.h
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IGAPIClient.h"
#import "RLTableView.h"
#import "RLYearTableCellView.h"
#import "RLTableRowView.h"

@protocol RLYearsVenuesTopShowsSelectionDelegate <NSObject>

- (void)yearSelected:(IGYear *)year;
- (void)venueSelected:(IGVenue *)venue;
- (void)topShowsSelected;

@end

@interface RLYearsVenuesTopShowsViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSTabViewDelegate>

@property (nonatomic, weak) id<RLYearsVenuesTopShowsSelectionDelegate> delegate;

- (void)selectAndScrollToRowWithYear: (NSInteger)year;
- (void)fetchYearsWithProgressIndicator:(NSProgressIndicator *)indicator;
- (void)fetchYearsWithProgressIndicator:(NSProgressIndicator *)indicator andSelectYear: (NSInteger)year;

@end
