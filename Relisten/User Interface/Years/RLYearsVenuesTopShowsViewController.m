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
@property (nonatomic, strong) NSDateComponentsFormatter *durationFormatter;

@end

@implementation RLYearsVenuesTopShowsViewController

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
    
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
}

- (void)fetchYearsWithProgressIndicator:(NSProgressIndicator *)indicator
{
    [indicator startAnimation:nil];
    self.years = @[];
    [self.yearsTableView reloadData];
    [IGAPIClient.sharedInstance years:^(NSArray *years) {
        self.years = years;
        [self.yearsTableView reloadData];
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
        self.venues = venues;
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
        
        cellView.yearTextField.stringValue = [NSString stringWithFormat:@"%ld", (long)year.year];
        
        NSString *shows;
        if(year.showCount == 1)
            shows = [NSString stringWithFormat:@"%ld show", year.showCount];
        else
            shows = [NSString stringWithFormat:@"%ld shows", year.showCount];
        
        NSString *sources;
        if(year.recordingCount == 1)
            sources = [NSString stringWithFormat:@"%ld source", year.recordingCount];
        else
            sources = [NSString stringWithFormat:@"%ld sources", year.recordingCount];
        
        cellView.showsAndRecordingsTextField.stringValue = [NSString stringWithFormat:@"%@, %@", shows, sources];
        cellView.durationTextField.stringValue = [self.durationFormatter stringFromTimeInterval:year.duration];
    }
    else if(tableView == self.venuesTableView)
    {
        IGVenue *venue = self.venues[row];
        
        cellView.yearTextField.stringValue = venue.name;
        cellView.showsAndRecordingsTextField.stringValue = venue.city;
        
        NSString *shows;
        if([venue.showCount intValue] == 1)
            shows = [NSString stringWithFormat:@"%@ show", venue.showCount];
        else
            shows = [NSString stringWithFormat:@"%@ shows", venue.showCount];
        
        cellView.durationTextField.stringValue = shows;
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

@end
