//
//  RLArtistsViewController.h
//  Relisten
//
//  Created by Manik Kalra on 11/12/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IGAPIClient.h"
#import "RLArtistTableCellView.h"
#import "RLTableRowView.h"

@protocol RLArtistSelectionDelegate <NSObject>

- (void)artistSelected:(IGArtist *)artist;

@end

@interface RLArtistsViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) id<RLArtistSelectionDelegate>delegate;
@property (nonatomic, weak) IGArtist *selectedArtist;

-(instancetype)initWithProgressIndictor:(NSProgressIndicator *)indicator;
-(void)fetchArtistsWithProgressIndictor:(NSProgressIndicator *)indicator; // This is automatically called on init

@end
