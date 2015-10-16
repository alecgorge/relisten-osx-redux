//
//  RLMainWindowController.h
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RLArtistsPopupButtonManager.h"
#import "RLYearsVenuesTopShowsViewController.h"
#import "RLShowsViewController.h"
#import "RLSourceAndTracksViewController.h"
#import "RLSplitView.h"

@interface RLMainWindowController : NSWindowController <NSSplitViewDelegate, RLYearsVenuesTopShowsSelectionDelegate, RLShowSelectedDelegate>

@end
