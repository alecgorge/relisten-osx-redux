//
//  RLTableRowView.m
//  Relisten
//
//  Created by Manik Kalra on 11/13/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLTableRowView.h"

@implementation RLTableRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)drawSelectionInRect:(NSRect)dirtyRect
{
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone)
    {
//        NSColor *themeColor = [NSColor colorWithRed:0.149 green:0.608 blue:0.737 alpha:1];
        NSColor *themeColor = [NSColor lightGrayColor];
        NSRect selectionRect = NSInsetRect(self.bounds, 0, 0);
        [themeColor setStroke];
        [themeColor setFill];
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRect:selectionRect];
        [selectionPath fill];
        [selectionPath stroke];
    }
}

@end
