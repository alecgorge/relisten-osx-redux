//
//  RLShowTableViewCell.m
//  Relisten
//
//  Created by Manik Kalra on 9/26/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLShowTableViewCell.h"

@implementation RLShowTableViewCell
{
    NSDateComponentsFormatter *durationFormatter;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)populateWithShow:(IGShow *)show
{
    if(show.isSoundboard)
        self.soundBoardtextField.hidden = NO;
    else
        self.soundBoardtextField.hidden = YES;
    
    EDStarRating *starRating = self.starRating;
    starRating.starImage = [NSImage imageNamed:@"star3.png"];
    starRating.starHighlightedImage = [NSImage imageNamed:@"star2.png"];
    starRating.maxRating = 5.0;
    starRating.horizontalMargin = 12;
    starRating.editable = NO;
    starRating.displayMode = EDStarRatingDisplayAccurate;
    starRating.rating= show.averageRating;
    
    self.reviewCountTextField.stringValue = [NSString stringWithFormat:@"%ld", (long)show.reviewsCount];
    
    self.venueNameTextField.stringValue = show.venueName ? show.venueName : (show.venue ? show.venue.name : @"Unknown");
    self.venueCityTextField.stringValue = show.venueCity ? show.venueCity : (show.venue ? show.venue.city : @"Unknown");
    
    if(!durationFormatter)
    {
        durationFormatter = [[NSDateComponentsFormatter alloc] init];
        durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        durationFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    }
    
    self.durationTextField.stringValue = [durationFormatter stringFromTimeInterval:show.duration];
    
    NSString *recordings;
    if(show.recordingCount == 1)
        recordings = [NSString stringWithFormat:@"%ld recording", show.recordingCount];
    else
        recordings = [NSString stringWithFormat:@"%ld recordings", show.recordingCount];
    
    self.recordingCountTextField.stringValue = recordings;
}

@end
