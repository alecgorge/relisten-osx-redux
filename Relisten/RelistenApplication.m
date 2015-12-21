//
//  RelistenApplication.m
//  Relisten
//
//  Created by Manik Kalra on 12/21/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RelistenApplication.h"

// Magic Keys definitions
#define SPSystemDefinedEventMediaKeys 8
#define NX_KEYTYPE_PLAY 16
#define NX_KEYTYPE_NEXT 17
#define NX_KEYTYPE_PREVIOUS 18
#define NX_KEYTYPE_FAST 19
#define NX_KEYTYPE_REWIND 20

@implementation RelistenApplication

-(void)sendEvent:(NSEvent *)event
{
    if ([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys)
    {
        int keyCode = (([event data1] & 0xFFFF0000) >> 16);
        int keyFlags = ([event data1] & 0x0000FFFF);
        BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
        int keyRepeat = (keyFlags & 0x1);
        
        if (keyIsPressed && keyRepeat == 0)
        {
            switch (keyCode)
            {
                case NX_KEYTYPE_PLAY:
                    [(AppDelegate *)[[NSApplication sharedApplication] delegate] playOrPauseDockButtonPressed:nil];
                    break;
                case NX_KEYTYPE_NEXT:
                case NX_KEYTYPE_FAST:
                    [(AppDelegate *)[[NSApplication sharedApplication] delegate] nextDockButtonpressed:nil];
                    break;
                case NX_KEYTYPE_PREVIOUS:
                case NX_KEYTYPE_REWIND:
                    [(AppDelegate *)[[NSApplication sharedApplication] delegate] previousDockButtonPressed:nil];
                    break;
                default:
                    break;
            }
        }
    }
    else
    {
        [super sendEvent:event];
    }
}

@end
