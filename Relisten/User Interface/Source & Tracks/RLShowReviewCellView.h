//
//  RLShowReviewCellView.h
//  Relisten
//
//  Created by Manik Kalra on 01/11/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <EDStarRating/EDStarRating.h>

@interface RLShowReviewCellView : NSTableCellView

@property (assign) IBOutlet NSTextField *reviewTitleTextField;
@property (assign) IBOutlet NSTextField *reviewerTextField;
@property (assign) IBOutlet NSTextField *reviewBodytextField;
@property (assign) IBOutlet EDStarRating *starRating;

@end
