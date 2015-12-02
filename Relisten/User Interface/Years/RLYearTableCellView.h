//
//  RLYearTableCellView.h
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <EDStarRating/EDStarRating.h>
#import "IGYear.h"
#import "IGVenue.h"

@interface RLYearTableCellView : NSTableCellView

@property (assign) IBOutlet NSTextField *yearTextField;
@property (assign) IBOutlet NSTextField *showsAndRecordingsTextField;
@property (assign) IBOutlet NSTextField *durationTextField;
@property (assign) IBOutlet EDStarRating *yearStarRating;
@property (assign) IBOutlet NSTextField *yearsReviewCountTextField;

-(void)populateWithYear:(IGYear *)year;
-(void)populateWithVenue:(IGVenue *)venue;


@end
