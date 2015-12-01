//
//  RLTrackTableCellView.m
//  Relisten
//
//  Created by Manik Kalra on 9/30/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLTrackTableCellView.h"

@implementation RLTrackTableCellView
{
    NSDateComponentsFormatter *durationFormatter;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)populateWithTrack:(IGTrack *)track forIndex:(NSInteger)index
{
    self.trackNumberTextField.stringValue = [NSString stringWithFormat:@"%ld", (long)index + 1];
    self.trackNameTextField.stringValue = track.title;
    
    if(!durationFormatter)
    {
        durationFormatter = [[NSDateComponentsFormatter alloc] init];
        durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropLeading;
        durationFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    }
    
    self.trackDurationTextField.stringValue = [durationFormatter stringFromTimeInterval:track.length];
    
    self.playNextMenuItem.tag = index;
    self.addToEndOfQueueMenuItem.tag = index;
    self.addRemainingConcertToQueueMenuItem.tag = index;
}

@end
