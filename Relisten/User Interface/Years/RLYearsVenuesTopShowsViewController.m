//
//  RLYearsViewController.m
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLYearsVenuesTopShowsViewController.h"

@interface RLYearsVenuesTopShowsViewController ()

@property (weak) IBOutlet RLTableView *yearsTableView;
@property (weak) IBOutlet RLTableView *venuesTableView;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSTextField *topShowsTextField;

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
    
    self.view.wantsLayer = YES;
    self.view.layer.borderColor = [NSColor grayColor].CGColor;
    self.view.layer.borderWidth = 1.5;
}

- (void)fetchYears
{
    self.years = @[];
    [self.yearsTableView reloadData];
    [IGAPIClient.sharedInstance years:^(NSArray *years) {
        self.years = years;
        [self.yearsTableView reloadData];
    }];
    
    [self fetchVenues];
    
    self.topShowsTextField.stringValue = [NSString stringWithFormat:@"%@, top shows", IGAPIClient.sharedInstance.artist.name];
    [self.tabView selectFirstTabViewItem:nil];
}

-(void)fetchVenues
{
    self.venues = @[];
    [self.venuesTableView reloadData];
    [IGAPIClient.sharedInstance venues:^(NSArray * venues) {
        self.venues = venues;
        [self.venuesTableView reloadData];
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
    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    [myRowView setEmphasized:NO];
    
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

@end
