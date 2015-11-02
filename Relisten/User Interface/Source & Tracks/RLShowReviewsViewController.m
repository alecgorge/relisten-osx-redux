//
//  RLShowReviewsViewController.m
//  Relisten
//
//  Created by Manik Kalra on 11/1/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLShowReviewsViewController.h"

@interface RLShowReviewsViewController ()

@property (weak) IBOutlet RLTableView *tableView;
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
    
    self.reviewCountTextField.stringValue = [NSString stringWithFormat:@"%ld Reviews", (long)self.currentShow.reviewsCount];
}

#pragma mark - NSTableViewDataSource Methods 

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.currentShow.reviewsCount;
}

#pragma mark - NSTableViewDelegate Methods

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    IGShowReview *review = self.currentShow.reviews[row];
    
    NSTextField *titleText = [[NSTextField alloc] init];
    titleText.stringValue = review.reviewtitle;
    CGFloat titleHeight = [((NSTextFieldCell *)[titleText cell]) cellSizeForBounds:NSMakeRect(0, 0, 360, FLT_MAX)].height;
    
    NSTextField *reviewerText = [[NSTextField alloc] init];
    reviewerText.stringValue = [NSString stringWithFormat:@"%@ | %@", review.reviewer, review.reviewdate];
    CGFloat reviewertextHeight = [((NSTextFieldCell *)[reviewerText cell]) cellSizeForBounds:NSMakeRect(0, 0, 360, FLT_MAX)].height;
    
    NSTextField *bodyText = [[NSTextField alloc] init];
    bodyText.stringValue = review.reviewbody;
    CGFloat bodyTextHeight = [((NSTextFieldCell *)[bodyText cell]) cellSizeForBounds:NSMakeRect(0, 0, 468, FLT_MAX)].height;
    
    CGFloat height = titleHeight + reviewertextHeight + bodyTextHeight;
    
    return height + 17;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RLShowReviewCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    IGShowReview *review = self.currentShow.reviews[row];
    
    cellView.reviewTitleTextField.stringValue = review.reviewtitle;
    cellView.reviewerTextField.stringValue = [NSString stringWithFormat:@"%@ | %@", review.reviewer, review.reviewdate];
    cellView.reviewBodytextField.stringValue = review.reviewbody;
    
    cellView.starRating.starImage = [NSImage imageNamed:@"star3.png"];
    cellView.starRating.starHighlightedImage = [NSImage imageNamed:@"star2.png"];
    cellView.starRating.maxRating = 5.0;
    cellView.starRating.horizontalMargin = 12;
    cellView.starRating.editable = NO;
    cellView.starRating.displayMode = EDStarRatingDisplayAccurate;
    cellView.starRating.rating = [review.stars floatValue];
    
    return cellView;
}


@end
