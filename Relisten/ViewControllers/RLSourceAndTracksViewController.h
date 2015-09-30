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

@interface RLSourceAndTracksViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

-(void)fetchTracksForShow:(IGShow *)show;
-(void)disableSourceSelection;

@end
