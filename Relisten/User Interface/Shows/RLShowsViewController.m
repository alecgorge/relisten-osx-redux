//
//  RLShowsViewController.m
//  Relisten
//
//  Created by Manik Kalra on 9/26/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLShowsViewController.h"

#import "RLAudioPlaybackViewController.h"

#define ALL_SHOWS       0
#define SOUNDBOARD      1

@interface RLShowsViewController ()

@property (weak) IBOutlet RLTableView *allShowsTableView;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet RLTableView *soundboardShowsTableView;
@property (weak) IBOutlet NSSegmentedControl *segmentedControl;

@property (nonatomic, strong) NSArray *allShows;
@property (nonatomic, strong) NSMutableArray *soundboardShows;
@property (nonatomic, strong) NSDateComponentsFormatter *durationFormatter;

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
    [self.segmentedControl setSelected:YES forSegment:ALL_SHOWS];
    
    //self.view.wantsLayer = YES;
    //self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTableViews)
                                                 name:RLAudioPlaybackTrackChanged
                                               object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:RLAudioPlaybackTrackChanged
                                                  object:nil];
}

-(void)refreshTableViews
{
    [self.allShowsTableView reloadData];
    [self.soundboardShowsTableView reloadData];
}

- (void)fetchShowsForYear:(IGYear *)year withProgressIndicator:(NSProgressIndicator *)indicator
{
    [self fetchShowsForYear:year withProgressIndicator:indicator andHighlightShowWithDate:nil];
}

- (void)fetchShowsForYear:(IGYear *)year withProgressIndicator:(NSProgressIndicator *)indicator andHighlightShowWithDate: (NSDate *)date
{
    [self clearAllShows];
    [indicator startAnimation:nil];
    [IGAPIClient.sharedInstance year:year.year success:^(IGYear *yr) {
        
        NSArray *shows = yr.shows;
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"averageRating" ascending:NO];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        self.allShows = [shows sortedArrayUsingDescriptors:descriptors];
        [self reloadShows];
        [indicator stopAnimation:nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", date];
        NSArray *matchedShows = [self.allShows filteredArrayUsingPredicate:predicate];
        
        if (matchedShows.count > 0)
        {
            IGShow *matchedShow = matchedShows[0];
            NSInteger index = [self.allShows indexOfObject:matchedShow];
            [self.tabView selectTabViewItemAtIndex:ALL_SHOWS];
            [self.segmentedControl setSelectedSegment:ALL_SHOWS];
            [[self.allShowsTableView rowViewAtRow:index makeIfNecessary:YES] setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
            [[self.allShowsTableView rowViewAtRow:index makeIfNecessary:YES] setSelected:YES];
            [self.allShowsTableView scrollRowToVisible:index];
        }
    }];
}



- (void)fetchShowsForVenue:(IGVenue *)venue withProgressIndicator:(NSProgressIndicator *)indicator
{
    [self clearAllShows];
    [indicator startAnimation:nil];
    [IGAPIClient.sharedInstance venue:venue success:^(IGVenue *venue) {
        NSArray *shows = venue.shows;
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"averageRating" ascending:NO];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        self.allShows = [shows sortedArrayUsingDescriptors:descriptors];
        [self reloadShows];
        [indicator stopAnimation:nil];
    }];
}

- (void)fetchTopShowsWithProgressIndicator:(NSProgressIndicator *)indicator
{
    [self clearAllShows];
    [indicator startAnimation:nil];
    [IGAPIClient.sharedInstance topShows:^(NSArray *topShows) {
        self.allShows = topShows;
        [self reloadShows];
        [indicator stopAnimation:nil];
    }];
}

-(void)fetchRandomShowWithProgressIndicator:(NSProgressIndicator *)indicator andShow:(void (^)(IGShow *))success
{
    [self clearAllShows];
    [indicator startAnimation:nil];
    [IGAPIClient.sharedInstance randomShow:^(NSArray *randomShow) {
        self.allShows = [NSArray arrayWithObject:randomShow[0]];
        [self reloadShows];
        [[self.allShowsTableView rowViewAtRow:0 makeIfNecessary:YES] setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
        [[self.allShowsTableView rowViewAtRow:0 makeIfNecessary:YES] setSelected:YES];
        [self.allShowsTableView scrollRowToVisible:0];
        [self.tabView selectTabViewItemAtIndex:ALL_SHOWS];
        
        success(randomShow[0]);
        
        [indicator stopAnimation:nil];
    }];
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

-(void)clearAllShows
{
    self.allShows = @[];
    [self.soundboardShows removeAllObjects];
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

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[RLTableRowView alloc] init];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RLShowTableViewCell *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    IGShow *show;
    
    if(tableView == self.allShowsTableView)
        show = self.allShows[row];
    else
        show = self.soundboardShows[row];
    
    [cellView populateWithShow:show];
    
    if(show.ArtistId == RLAudioPlaybackCurrentShow.ArtistId
    && [show.displayDate isEqualToString:RLAudioPlaybackCurrentShow.displayDate]) {
        if(RLAudioPlaybackViewController.sharedInstance.audioPlayer.isPlaying) {
            cellView.equilizerView.hidden = NO;
            [cellView.equilizerView startAnimated:YES];
        }
        else {
            cellView.equilizerView.hidden = NO;
            [cellView.equilizerView pauseAnimated:YES];
        }
    }
    // Don't show equalizer
    else  {
        cellView.equilizerView.hidden = YES;
        [cellView.equilizerView stopAnimated:NO];
    }
    
    return cellView;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableview = notification.object;
    NSInteger row = [tableview selectedRow];
    
    if(row > -1 && row < [tableview numberOfRows])
    {
        IGShow *show;
    
        if(tableview == self.allShowsTableView)
            show = self.allShows[row];
        else
            show = self.soundboardShows[row];
    
        [self.delegate showSelected:show];
    }
}

-(BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    NSTableRowView *myRowView = [aTableView rowViewAtRow:rowIndex makeIfNecessary:NO];
    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    //    [myRowView setEmphasized:NO];
    
    return YES;
}

#pragma mark - Segmented Control Handling

- (IBAction)segmentedControlIndexChanged:(id)sender
{
    NSSegmentedControl *control = (NSSegmentedControl *)sender;
    
    NSInteger selectedSeg = [control selectedSegment];
    
    switch (selectedSeg)
    {
        case ALL_SHOWS:
            [self.tabView selectTabViewItemAtIndex:ALL_SHOWS];
            break;
        case SOUNDBOARD:
            [self.tabView selectTabViewItemAtIndex:SOUNDBOARD];
            break;
        default:
            break;
    }
}

@end
