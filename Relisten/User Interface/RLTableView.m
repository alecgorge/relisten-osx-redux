//
//  RLTableView.m
//  Relisten
//
//  Created by Manik Kalra on 9/25/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLTableView.h"

@implementation RLTableView

- (void)drawGridInClipRect:(NSRect)clipRect
{
    NSRect lastRowRect = [self rectOfRow:[self numberOfRows]-1];
    NSRect myClipRect = NSMakeRect(0, 0, lastRowRect.size.width, NSMaxY(lastRowRect));
    NSRect finalClipRect = NSIntersectionRect(clipRect, myClipRect);
    [super drawGridInClipRect:finalClipRect];
}

- (void)keyDown:(NSEvent *)theEvent
{
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSDeleteCharacter)
    {
        
        [self.deleteDelegate deleteKeyPressedAtIndex:[self selectedRow]];
        return;
    }
    else
    {
        [super keyDown:theEvent];
    }
    
}

@end
