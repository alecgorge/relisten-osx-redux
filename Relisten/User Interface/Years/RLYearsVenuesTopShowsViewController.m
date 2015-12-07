//
//  RLYearsViewController.m
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLYearsVenuesTopShowsViewController.h"

#define ALL_YEARS    0
#define VENUES       1
#define TOP_SHOWS    2

@interface RLYearsVenuesTopShowsViewController ()

@property (weak) IBOutlet RLTableView *yearsTableView;
@property (weak) IBOutlet RLTableView *venuesTableView;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSTextField *topShowsTextField;
@property (weak) IBOutlet NSSegmentedControl *segmentedControl;

@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) NSArray *venues;
@property (nonatomic, strong) NSArray *unfilteredVenues;
@property (nonatomic, strong) NSDateComponentsFormatter *durationFormatter;

@end

@implementation RLYearsVenuesTopShowsViewController {
    NSInteger lastSelectedRowIndex;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
    self.yearsTableView.dataSource = self;
    self.yearsTableView.delegate = self;
    self.venuesTableView.dataSource = self;
    self.venuesTableView.delegate = self;
    
    self.durationFormatter = [[NSDateComponentsFormatter alloc] init];
    self.durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    self.durationFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    self.tabView.delegate = self;
    [self.segmentedControl setSelected:YES forSegment:ALL_YEARS];
    
   // self.view.wantsLayer = YES;
    //self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
}

- (void)selectAndScrollToRowWithYear: (NSInteger)year {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %i", year];
    NSArray *matchedYears = [self.years filteredArrayUsingPredicate:predicate];
    if (matchedYears.count > 0) {
        IGShow *matchedYear = matchedYears[0];
        NSInteger index = [self.years indexOfObject:matchedYear];
        [[self.yearsTableView rowViewAtRow:lastSelectedRowIndex makeIfNecessary:YES] setSelected:NO];
        [[self.yearsTableView rowViewAtRow:index makeIfNecessary:YES] setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
        [[self.yearsTableView rowViewAtRow:index makeIfNecessary:YES] setSelected:YES];
        [self.yearsTableView scrollRowToVisible:index];
        lastSelectedRowIndex = index;
    }
}

- (void)fetchYearsWithProgressIndicator:(NSProgressIndicator *)indicator
{
    [self fetchYearsWithProgressIndicator:indicator andSelectYear:-1];
}

- (void)fetchYearsWithProgressIndicator:(NSProgressIndicator *)indicator andSelectYear: (NSInteger)year
{
    [indicator startAnimation:nil];
    self.years = @[];
    [self.yearsTableView reloadData];
    [IGAPIClient.sharedInstance years:^(NSArray *years) {
        self.years = years;
        [self.yearsTableView reloadData];
        
        if (year != -1) {
            [self selectAndScrollToRowWithYear:year];
        }
    }];
    
    [self fetchVenuesWithProgressIndicator:indicator];
    
    self.topShowsTextField.stringValue = [NSString stringWithFormat:@"%@, top shows", IGAPIClient.sharedInstance.artist.name];
    
    [self.segmentedControl setSelected:YES forSegment:ALL_YEARS];
    [self.tabView selectTabViewItemAtIndex:ALL_YEARS];
}

-(void)fetchVenuesWithProgressIndicator:(NSProgressIndicator *)indicator
{
    self.venues = @[];
    [self.venuesTableView reloadData];
    [IGAPIClient.sharedInstance venues:^(NSArray * venues) {
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        self.unfilteredVenues = [venues sortedArrayUsingDescriptors:descriptors];
        self.venues = self.unfilteredVenues;
        [self.venuesTableView reloadData];
        [indicator stopAnimation:nil];
    }];
}

#pragma mark - NSTableViewdataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(aTableView == self.yearsTableView)
        return [self.years count];
    else if(aTableView == self.venuesTableView)
        return [self.venues count];
    else
        return 0;
}

#pragma mark - NSTableViewDelegate Methods

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RLYearTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

    if(tableView == self.yearsTableView)
    {
        IGYear *year = self.years[row];
        [cellView populateWithYear:year];
    }
    else if(tableView == self.venuesTableView)
    {
        IGVenue *venue = self.venues[row];
        [cellView populateWithVenue:venue];
    }
    
    return cellView;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableview = notification.object;
    NSInteger row = [tableview selectedRow];
    
    if(tableview == self.yearsTableView)
    {
        IGYear *year = self.years[row];
        [self.delegate yearSelected:year];
    }
    else if(tableview == self.venuesTableView)
    {
        IGVenue *venue = self.venues[row];
        [self.delegate venueSelected:venue];
    }
}

-(BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    NSTableRowView *myRowView = [aTableView rowViewAtRow:rowIndex makeIfNecessary:NO];
    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    //    [myRowView setEmphasized:NO];
    
    return YES;
}

#pragma mark - NSTabViewDelegate

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[RLTableRowView alloc] init];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if([tabViewItem.label isEqualToString:@"Top Shows"])
    {
       [self.delegate topShowsSelected];
    }
}

- (IBAction)segmentedControlSelectionChanged:(id)sender
{
    NSSegmentedControl *control = (NSSegmentedControl *)sender;
    
    NSInteger selectedSeg = [control selectedSegment];
    
    switch (selectedSeg)
    {
        case ALL_YEARS:
            [self.tabView selectTabViewItemAtIndex:ALL_YEARS];
            break;
        case VENUES:
            [self.tabView selectTabViewItemAtIndex:VENUES];
            break;
        case TOP_SHOWS:
            [self.tabView selectTabViewItemAtIndex:TOP_SHOWS];
            break;
        default:
            break;
    }
}

#pragma mark - Venue Filtering

- (IBAction)filterVenues:(NSSearchField *)sender
{
    NSString *substring = [sender stringValue];
    
    if([substring isEqualToString:@""])
    {
        self.venues = self.unfilteredVenues;
        [self.venuesTableView reloadData];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", substring];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"city contains[c] %@", substring];
        NSCompoundPredicate *compound = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate, predicate2]];
        self.venues = [self.unfilteredVenues filteredArrayUsingPredicate:compound];
        [self.venuesTableView reloadData];
    }
}

@end
