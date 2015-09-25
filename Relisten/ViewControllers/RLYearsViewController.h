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

@interface RLYearsViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

- (void)fetchYears;

@end
