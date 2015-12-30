//
//  RLMainWindowController.h
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <LastFm/LastFm.h>
#import "RLArtistsViewController.h"
#import "RLYearsVenuesTopShowsViewController.h"
#import "RLShowsViewController.h"
#import "RLSourceAndTracksViewController.h"
#import "RLAudioPlaybackViewController.h"
#import "RLSplitView.h"
#import "AppDelegate.h"

@interface RLMainWindowController : NSWindowController <NSSplitViewDelegate, RLArtistSelectionDelegate, RLYearsVenuesTopShowsSelectionDelegate, RLShowSelectedDelegate, RLTrackSelectedDelegate, RLAudioPlaybackDelegate>

-(void)playPauseDockButtonPressed;
-(void)nextDockButtonPressed;
-(void)previousDockButtonPressed;

@end
