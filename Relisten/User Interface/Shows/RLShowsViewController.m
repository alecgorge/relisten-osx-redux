//
//  RLShowsViewController.m
//  Relisten
//
//  Created by Manik Kalra on 9/26/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLShowsViewController.h"

@interface RLShowsViewController ()

@property (weak) IBOutlet RLTableView *tableView;

@property (nonatomic, strong) NSArray *shows;
@property (nonatomic, strong) NSDateComponentsFormatter *durationFormatter;

@end

@implementation RLShowsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.durationFormatter = [[NSDateComponentsFormatter alloc] init];
    self.durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    self.durationFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
}

- (void)fetchShowsForYear:(IGYear *)year
{
    self.shows = @[];
    [self.tableView reloadData];
    [IGAPIClient.sharedInstance year:year.year success:^(IGYear *yr) {
        
        NSArray *shows = yr.shows;
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"averageRating" ascending:NO];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        self.shows = [shows sortedArrayUsingDescriptors:descriptors];
        [self.tableView reloadData];
    }];
}

- (void)fetchShowsForVenue:(IGVenue *)venue
{
    self.shows = @[];
    [self.tableView reloadData];
    [IGAPIClient.sharedInstance venue:venue success:^(IGVenue *venue) {
        NSArray *shows = venue.shows;
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"averageRating" ascending:NO];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        self.shows = [shows sortedArrayUsingDescriptors:descriptors];
        [self.tableView reloadData];
    }];
}

-(void)clearAllShows
{
    self.shows = nil;
    [self.tableView reloadData];
}

#pragma mark - NSTableViewdataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.shows count];
}

#pragma mark - NSTableViewDelegate Methods

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RLShowTableViewCell *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    IGShow *show = self.shows[row];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:show.date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    
    if(show.isSoundboard)
        cellView.showDateTextField.stringValue = [NSString stringWithFormat:@"%@(SBD)", dateString];
    else
        cellView.showDateTextField.stringValue = dateString;
    
    EDStarRating *starRating = cellView.starRating;
    starRating.starImage = [NSImage imageNamed:@"star3.png"];
    starRating.starHighlightedImage = [NSImage imageNamed:@"star2.png"];
    starRating.maxRating = 5.0;
    starRating.horizontalMargin = 12;
    starRating.editable = NO;
    starRating.displayMode = EDStarRatingDisplayAccurate;
    starRating.rating= show.averageRating;

    cellView.venueNameTextField.stringValue = show.venueName;
    cellView.venueCityTextField.stringValue = show.venueCity;
    cellView.durationTextField.stringValue = [self.durationFormatter stringFromTimeInterval:show.duration];
    
    NSString *recordings;
    if(show.recordingCount == 1)
        recordings = [NSString stringWithFormat:@"%ld recording", show.recordingCount];
    else
        recordings = [NSString stringWithFormat:@"%ld recordings", show.recordingCount];
    
    cellView.recordingCountTextField.stringValue = recordings;
    
    return cellView;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableview = notification.object;
    NSInteger row = [tableview selectedRow];
    
    IGShow *show = self.shows[row];
    [self.delegate showSelected:show];
}

-(BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    NSTableRowView *myRowView = [aTableView rowViewAtRow:rowIndex makeIfNecessary:NO];
    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    [myRowView setEmphasized:NO];
    
    return YES;
}

@end
