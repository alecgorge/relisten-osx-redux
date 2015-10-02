//
//  RLSourceAndTracksViewController.m
//  Relisten
//
//  Created by Manik Kalra on 9/29/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLSourceAndTracksViewController.h"

@interface RLSourceAndTracksViewController ()

@property (weak) IBOutlet NSPopUpButton *sourcePopupButton;
@property (weak) IBOutlet NSButton *helpButton;
@property (weak) IBOutlet RLTableView *tableView;

@property (nonatomic, strong) NSArray *allShows;
@property (nonatomic, strong) IGShow *selectedShow;
@property (nonatomic, strong) NSDateComponentsFormatter *durationFormatter;

@end

@implementation RLSourceAndTracksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
    [self disableSourceSelection];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.durationFormatter = [[NSDateComponentsFormatter alloc] init];
    self.durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    self.durationFormatter.allowedUnits = (NSCalendarUnitMinute | NSCalendarUnitSecond);
}

-(void)disableSourceSelection
{
    [self.sourcePopupButton removeAllItems];
    self.sourcePopupButton.enabled = NO;
    self.helpButton.enabled = NO;
}

-(void)populatePopupButtonWithSources:(NSArray *)sources
{
    [self.sourcePopupButton removeAllItems];
    self.sourcePopupButton.enabled = YES;
    self.helpButton.enabled = YES;
    NSArray *sourceList = [sources valueForKey:@"source"];
    [self.sourcePopupButton addItemsWithTitles:sourceList];
}

-(void)fetchTracksForShow:(IGShow *)show
{
    [IGAPIClient.sharedInstance showsOn:show.displayDate
                                success:^(NSArray *shows) {
                                    
                                    self.allShows = shows;
                                    self.selectedShow = shows[0];
                                    [self populatePopupButtonWithSources:self.allShows];
                                    [self.tableView reloadData];
                                }];
}

- (IBAction)sourceSelectionChanged:(id)sender
{
    NSInteger index = [self.sourcePopupButton indexOfSelectedItem];
    self.selectedShow = self.allShows[index];
    [self.tableView reloadData];
}
#pragma mark - NSTableViewDelegate Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.selectedShow.tracks count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RLTrackTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    IGTrack *track = self.selectedShow.tracks[row];
    cellView.trackNumberTextField.stringValue = [NSString stringWithFormat:@"%ld.", (long)row];
    cellView.trackNameTextField.stringValue = track.title;
    
    cellView.trackDurationTextField.stringValue = [self.durationFormatter stringFromTimeInterval:track.length];

    return cellView;
}

-(BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    NSTableRowView *myRowView = [aTableView rowViewAtRow:rowIndex makeIfNecessary:NO];
    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    [myRowView setEmphasized:NO];
    
    return YES;
}


@end