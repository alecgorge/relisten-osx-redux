//
//  RLMainWindowController.h
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#ifndef FOR_APPSTORE
#define FOR_APPSTORE 1
#endif

#import <Cocoa/Cocoa.h>
#import "RLArtistsViewController.h"
#import "RLYearsVenuesTopShowsViewController.h"
#import "RLShowsViewController.h"
#import "RLSourceAndTracksViewController.h"
#import "RLAudioPlaybackViewController.h"
#import "RLSplitView.h"
#import "AppDelegate.h"

#if !FOR_APPSTORE
#import <SPMediaKeyTap/SPMediaKeyTap.h>
#endif

@interface RLMainWindowController : NSWindowController <NSSplitViewDelegate, RLArtistSelectionDelegate, RLYearsVenuesTopShowsSelectionDelegate, RLShowSelectedDelegate, RLTrackSelectedDelegate, RLAudioPlaybackDelegate>

-(void)playPauseDockButtonPressed;
-(void)nextDockButtonPressed;
-(void)previousDockButtonPressed;

@end
