//
//  RLYearTableCellView.h
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RLYearTableCellView : NSTableCellView

@property (assign) IBOutlet NSTextField *yearTextField;
@property (assign) IBOutlet NSTextField *showsAndRecordingsTextField;
@property (assign) IBOutlet NSTextField *durationTextField;

@end
