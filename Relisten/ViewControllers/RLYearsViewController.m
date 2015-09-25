//
//  RLYearsViewController.m
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLYearsViewController.h"

@interface RLYearsViewController ()

@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) NSDateComponentsFormatter *durationFormatter;

@end

@implementation RLYearsViewController

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

- (void)fetchYears
{
    [IGAPIClient.sharedInstance years:^(NSArray *years) {
        self.years = years;
        [self.tableView reloadData];
    }];
}

#pragma mark - NSTableViewdataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.years count];
}

#pragma mark - NSTableViewDelegate Methods

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RLYearTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
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
    
    return cellView;
}

@end
