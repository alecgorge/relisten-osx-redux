//
//  RLShowReviewsViewController.m
//  Relisten
//
//  Created by Manik Kalra on 11/1/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLShowReviewsViewController.h"

@interface RLShowReviewsViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet EDStarRating *showAverageRating;
@property (weak) IBOutlet NSTextField *reviewCountTextField;
@property (nonatomic, weak) IGShow *currentShow;

@end

@implementation RLShowReviewsViewController

-(instancetype)initWithShow:(IGShow *)show
{
    if(self = [super initWithNibName:@"RLShowReviewsViewController" bundle:nil])
    {
        self.currentShow = show;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Set up Avergae Rating
    self.showAverageRating.starImage = [NSImage imageNamed:@"star3.png"];
    self.showAverageRating.starHighlightedImage = [NSImage imageNamed:@"star2.png"];
    self.showAverageRating.maxRating = 5.0;
    self.showAverageRating.horizontalMargin = 12;
    self.showAverageRating.editable = NO;
    self.showAverageRating.displayMode = EDStarRatingDisplayAccurate;
    self.showAverageRating.rating = self.currentShow.averageRating;
    
    self.reviewCountTextField.stringValue = [NSString stringWithFormat:@"%lu Reviews", (unsigned long)[self.currentShow.reviews count]];

}

@end
