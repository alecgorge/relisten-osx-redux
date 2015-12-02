//
//  RLYearTableCellView.m
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLYearTableCellView.h"

@implementation RLYearTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(void)populateWithYear:(IGYear *)year
{
    self.yearTextField.stringValue = [NSString stringWithFormat:@"%ld", (long)year.year];
    
    NSString *shows;
    if(year.showCount == 1)
        shows = [NSString stringWithFormat:@"%ld show", year.showCount];
    else
        shows = [NSString stringWithFormat:@"%ld shows", year.showCount];
    
    NSString *sources;
    if(year.recordingCount == 1)
        sources = [NSString stringWithFormat:@"%ld source", year.recordingCount];
    else
        sources = [NSString stringWithFormat:@"%ld sources", year.recordingCount];
    
    self.showsAndRecordingsTextField.stringValue = [NSString stringWithFormat:@"%@, %@", shows, sources];
    NSUInteger hours = year.duration/3600;
    self.durationTextField.stringValue = [NSString stringWithFormat:@"%lu hours", (unsigned long)hours];
    
    EDStarRating *starRating = self.yearStarRating;
    starRating.starImage = [NSImage imageNamed:@"star3.png"];
    starRating.starHighlightedImage = [NSImage imageNamed:@"star2.png"];
    starRating.maxRating = 5.0;
    starRating.horizontalMargin = 12;
    starRating.editable = NO;
    starRating.displayMode = EDStarRatingDisplayAccurate;
    starRating.rating = year.avgRating;
}

-(void)populateWithVenue:(IGVenue *)venue
{
    self.yearTextField.stringValue = venue.name;
    self.showsAndRecordingsTextField.stringValue = venue.city;
    
    NSString *shows;
    if([venue.showCount intValue] == 1)
        shows = [NSString stringWithFormat:@"%@ show", venue.showCount];
    else
        shows = [NSString stringWithFormat:@"%@ shows", venue.showCount];
    
    self.durationTextField.stringValue = shows;
}

@end
