//
//  RLArtistTableCellView.h
//  Relisten
//
//  Created by Manik Kalra on 11/12/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RLArtistTableCellView : NSTableCellView

@property (assign) IBOutlet NSTextField *artistNameTextField;
@property (assign) IBOutlet NSTextField *trackCountTextField;

@end
