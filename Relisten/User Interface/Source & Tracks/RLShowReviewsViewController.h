//
//  RLShowReviewsViewController.h
//  Relisten
//
//  Created by Manik Kalra on 11/1/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <EDStarRating/EDStarRating.h>
#import "IGShow.h"

@interface RLShowReviewsViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

-(instancetype)initWithShow:(IGShow *)show;

@end
