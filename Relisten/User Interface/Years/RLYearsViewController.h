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

@protocol RLYearSelectedDelegate <NSObject>

- (void)yearSelected:(IGYear *)year;
- (void)venueSelected:(IGVenue *)venue;
- (void)topShowsSelected;

@end

@interface RLYearsViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSTabViewDelegate>

@property (nonatomic, weak) id<RLYearSelectedDelegate> delegate;

- (void)fetchYears;

@end
