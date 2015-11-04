//
//  RLShowsViewController.m
//  Relisten
//
//  Created by Manik Kalra on 9/26/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLShowsViewController.h"

@interface RLShowsViewController ()

@property (weak) IBOutlet RLTableView *allShowsTableView;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet RLTableView *soundboardShowsTableView;

@property (nonatomic, strong) NSArray *allShows;
@property (nonatomic, strong) NSMutableArray *soundboardShows;
@property (nonatomic, strong) NSDateComponentsFormatter *durationFormatter;
@property (nonatomic, strong) IGShow *currentlyPlayingShow;
@property (nonatomic) BOOL playing;

@end

@implementation RLShowsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    self.soundboardShows = [[NSMutableArray alloc] init];
    
    self.allShowsTableView.dataSource = self;
    self.allShowsTableView.delegate = self;
    self.soundboardShowsTableView.delegate = self;
    self.soundboardShowsTableView.dataSource = self;
    
    self.durationFormatter = [[NSDateComponentsFormatter alloc] init];
    self.durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    self.durationFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    self.tabView.delegate = self;
    
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
}

- (void)fetchShowsForYear:(IGYear *)year
{
    [self clearAllShows];
    [IGAPIClient.sharedInstance year:year.year success:^(IGYear *yr) {
        
        NSArray *shows = yr.shows;
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"averageRating" ascending:NO];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        self.allShows = [shows sortedArrayUsingDescriptors:descriptors];
        [self reloadShows];
    }];
}

- (void)fetchShowsForVenue:(IGVenue *)venue
{
    [self clearAllShows];
    [IGAPIClient.sharedInstance venue:venue success:^(IGVenue *venue) {
        NSArray *shows = venue.shows;
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"averageRating" ascending:NO];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        self.allShows = [shows sortedArrayUsingDescriptors:descriptors];
        [self reloadShows];
    }];
}

- (void)fetchTopShows
{
    [self clearAllShows];
    [IGAPIClient.sharedInstance topShows:^(NSArray *topShows) {
        self.allShows = topShows;
        [self reloadShows];
    }];
}

-(void)clearAllShows
{
    self.allShows = @[];
    [self.soundboardShows removeAllObjects];
    [self.allShowsTableView reloadData];
    [self.soundboardShowsTableView reloadData];
}

-(void)reloadShows
{
    [self.allShowsTableView reloadData];
    
    for(IGShow *show in self.allShows)
    {
        if(show.isSoundboard)
            [self.soundboardShows addObject:show];
    }
    
    
    NSArray *sortedShows = self.soundboardShows;
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"averageRating" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
    self.soundboardShows = [[sortedShows sortedArrayUsingDescriptors:descriptors] mutableCopy];

    [self.soundboardShowsTableView reloadData];
}

-(void)setCurrentlyPLayingShow:(IGShow *)show
{
    self.playing = YES;
    self.currentlyPlayingShow = show;
    [self.allShowsTableView reloadData];
    [self.soundboardShowsTableView reloadData];
}

-(void)pauseCurrentlyPLayingShow:(IGShow *)show
{
    self.playing = NO;
    self.currentlyPlayingShow = show;
    [self.allShowsTableView reloadData];
    [self.soundboardShowsTableView reloadData];
}

#pragma mark - NSTableViewdataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(aTableView == self.allShowsTableView)
        return [self.allShows count];
    else
        return [self.soundboardShows count];
}

#pragma mark - NSTableViewDelegate Methods

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RLShowTableViewCell *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    IGShow *show;
    
    if(tableView == self.allShowsTableView)
        show = self.allShows[row];
    else
        show = self.soundboardShows[row];
    
    if(show.isSoundboard)
        cellView.showDateTextField.stringValue = [NSString stringWithFormat:@"%@ (SBD)", show.displayDate];
    else
        cellView.showDateTextField.stringValue = show.displayDate;
    
    if(show.id == self.currentlyPlayingShow.id)
    {
        if(self.playing)
        {
            cellView.equilizerView.hidden = NO;
            [cellView.equilizerView startAnimated:YES];
        }
        else // Paused
        {
            cellView.equilizerView.hidden = NO;
            [cellView.equilizerView pauseAnimated:YES];
        }
    }
    else // Don't show equalizer
    {
        cellView.equilizerView.hidden = YES;
        [cellView.equilizerView stopAnimated:NO];
    }
    
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
    
    IGShow *show;
    
    if(tableview == self.allShowsTableView)
        show = self.allShows[row];
    else
        show = self.soundboardShows[row];
    
    [self.delegate showSelected:show];
}

-(BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    NSTableRowView *myRowView = [aTableView rowViewAtRow:rowIndex makeIfNecessary:NO];
    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    //    [myRowView setEmphasized:NO];
    
    return YES;
}

#pragma mark - NSTabViewDelegate

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
//    [self.allShowsTableView reloadData];
//    [self.soundboardShowsTableView reloadData];
}

@end
