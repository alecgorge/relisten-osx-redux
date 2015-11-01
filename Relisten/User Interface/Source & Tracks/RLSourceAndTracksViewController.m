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
@property (weak) IBOutlet NSButton *reviewsButton;
@property (weak) IBOutlet RLTableView *tableView;
@property (weak) IBOutlet NSTextField *lineageTextField;
@property (weak) IBOutlet NSTextField *taperTextField;

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
    self.tableView.doubleAction = @selector(doubleClickedTrack:);
    
    self.durationFormatter = [[NSDateComponentsFormatter alloc] init];
    self.durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    self.durationFormatter.allowedUnits = (NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
}

-(void)disableSourceSelection
{
    [self.sourcePopupButton removeAllItems];
    self.sourcePopupButton.enabled = NO;
    self.reviewsButton.enabled = NO;
    self.selectedShow = nil;
    [self.tableView reloadData];
    
    self.lineageTextField.stringValue = @"";
    self.taperTextField.stringValue = @"";
}

-(void)populatePopupButtonWithSources:(NSArray *)sources
{
    [self.sourcePopupButton removeAllItems];
    self.sourcePopupButton.enabled = YES;
    self.reviewsButton.enabled = YES;
    NSArray *sourceList = [sources valueForKey:@"source"];
    [self.sourcePopupButton addItemsWithTitles:sourceList];
}

-(void)setLineageAndTaperInfo
{
    self.lineageTextField.stringValue = self.selectedShow.lineage;
    self.taperTextField.stringValue = self.selectedShow.taper;
}

-(void)fetchTracksForShow:(IGShow *)show
{
    [IGAPIClient.sharedInstance showsOn:show.displayDate
                                success:^(NSArray *shows) {
                                    
                                    self.allShows = shows;
                                    self.selectedShow = shows[0];
                                    [self populatePopupButtonWithSources:self.allShows];
                                    [self setLineageAndTaperInfo];
                                    [self.tableView reloadData];
                                }];
}

- (IBAction)sourceSelectionChanged:(id)sender
{
    NSInteger index = [self.sourcePopupButton indexOfSelectedItem];
    self.selectedShow = self.allShows[index];
    [self setLineageAndTaperInfo];
    [self.tableView reloadData];
}

- (IBAction)showReviews:(id)sender // TODO
{
    NSPopover *popover = [[NSPopover alloc] init];
    RLShowReviewsViewController *reviews = [[RLShowReviewsViewController alloc] initWithShow:self.selectedShow];
    
    popover.behavior = NSPopoverBehaviorTransient;
    popover.animates = YES;
    popover.contentSize = NSMakeSize(500, 400);
    popover.contentViewController = reviews;
    
    [popover showRelativeToRect:NSZeroRect ofView:sender preferredEdge:NSMaxYEdge];
}

-(void)doubleClickedTrack:(id)sender
{
    NSInteger row = [sender clickedRow];
    IGTrack *selectedTrack = self.selectedShow.tracks[row];
    
    [self.delegate trackSelected:selectedTrack FromShow:self.selectedShow];
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
    cellView.trackNumberTextField.stringValue = [NSString stringWithFormat:@"%ld.", (long)row + 1];
    cellView.trackNameTextField.stringValue = track.title;
    
    cellView.trackDurationTextField.stringValue = [self.durationFormatter stringFromTimeInterval:track.length];

    return cellView;
}

-(BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    NSTableRowView *myRowView = [aTableView rowViewAtRow:rowIndex makeIfNecessary:NO];
    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
//    [myRowView setEmphasized:NO];
    
    return YES;
}


@end
