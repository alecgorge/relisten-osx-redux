//
//  RLShowTableViewCell.h
//  Relisten
//
//  Created by Manik Kalra on 9/26/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <EDStarRating/EDStarRating.h>
#import <CMEqualizerIndicatorView/CMEqualizerIndicatorView.h>
#import "IGShow.h"

@interface RLShowTableViewCell : NSTableCellView

@property (assign) IBOutlet NSTextField *showDateTextField;
@property (assign) IBOutlet NSTextField *soundBoardtextField;
@property (assign) IBOutlet EDStarRating *starRating;
@property (assign) IBOutlet NSTextField *venueNameTextField;
@property (assign) IBOutlet NSTextField *venueCityTextField;
@property (assign) IBOutlet NSTextField *durationTextField;
@property (assign) IBOutlet NSTextField *recordingCountTextField;
@property (assign) IBOutlet CMEqualizerIndicatorView *equilizerView;

-(void)populateWithShow:(IGShow *)show;

@end
