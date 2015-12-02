//
//  RLSourceAndTracksViewController.m
//  Relisten
//
//  Created by Manik Kalra on 9/29/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLSourceAndTracksViewController.h"

#import "RLAudioPlaybackViewController.h"

#import <FXNotifications/FXNotifications.h>

@interface RLSourceAndTracksViewController ()

@property (weak) IBOutlet NSPopUpButton *sourcePopupButton;
@property (weak) IBOutlet NSButton *reviewsButton;
@property (weak) IBOutlet RLTableView *tableView;
@property (weak) IBOutlet NSTextField *lineageTextField;
@property (weak) IBOutlet NSTextField *taperTextField;
@property (weak) IBOutlet NSButton *addToQueueButton;
@property (weak) IBOutlet NSButton *listenOnArchiveButton;

@property (nonatomic, strong) NSArray *allShows;
@property (nonatomic, strong) IGShow *selectedShow;

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
    
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                              forName:RLAudioPlaybackTrackChanged
                                               object:nil
                                                queue:NSOperationQueue.mainQueue
                                           usingBlock:^(NSNotification *note, id observer) {
                                               [self.tableView reloadData];
                                           }];
}

-(void)disableSourceSelection
{
    [self.sourcePopupButton removeAllItems];
    self.sourcePopupButton.enabled = NO;
    self.reviewsButton.enabled = NO;
    self.addToQueueButton.enabled = NO;
    self.listenOnArchiveButton.enabled = NO;
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
    self.addToQueueButton.enabled = YES;
    self.listenOnArchiveButton.enabled = YES;
    
    NSArray *sourceList = [sources valueForKey:@"source"];
    [self.sourcePopupButton addItemsWithTitles:sourceList];
}

-(void)setLineageAndTaperInfo
{
    self.lineageTextField.stringValue = self.selectedShow.lineage;
    self.taperTextField.stringValue = self.selectedShow.taper;
}

-(void)fetchTracksForShow:(IGShow *)show withProgressIndicator:(NSProgressIndicator *)indicator
{
    [indicator startAnimation:nil];
    [IGAPIClient.sharedInstance showsOn:show.displayDate
                                success:^(NSArray *shows) {
                                    
                                    self.allShows = shows;
                                    self.selectedShow = shows[0];
                                    [self populatePopupButtonWithSources:self.allShows];
                                    [self setLineageAndTaperInfo];
                                    [self.tableView reloadData];
                                    [indicator stopAnimation:nil];
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

#pragma mark - Queue Manipulation from Popup

- (IBAction)playNextButtonPressed:(id)sender
{
    NSMenuItem *currentItem = (NSMenuItem *)sender;
    IGTrack *track = self.selectedShow.tracks[currentItem.tag];
    [self.delegate playTrackNext:track FromShow:self.selectedShow];
}

- (IBAction)addToEndOfQueueButtonPressed:(id)sender
{
    NSMenuItem *currentItem = (NSMenuItem *)sender;
    IGTrack *track = self.selectedShow.tracks[currentItem.tag];
    [self.delegate addTrackToEndOfQueue:track FromShow:self.selectedShow];
}

- (IBAction)addRemainingConcertToEndOfQueueButtonPressed:(id)sender
{
    NSMenuItem *currentItem = (NSMenuItem *)sender;
    NSInteger index = currentItem.tag;
    NSInteger size = self.selectedShow.tracks.count;
    NSArray *items = [self.selectedShow.tracks subarrayWithRange:NSMakeRange(index, size - index - 1)];
    [self.delegate addTracksToQueue:items FromShow:self.selectedShow];
}

- (IBAction)addConcertToQueue:(id)sender
{
    [self.delegate addTracksToQueue:self.selectedShow.tracks FromShow:self.selectedShow];
}

#pragma mark - NSTableViewDelegate Methods

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[RLTableRowView alloc] init];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.selectedShow.tracks count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RLTrackTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    IGTrack *track = self.selectedShow.tracks[row];
    
    [cellView populateWithTrack:track forIndex:row];
    
    // Show equalizer
    if(track.id == RLAudioPlaybackCurrentTrack.id) {
        if(RLAudioPlaybackViewController.sharedInstance.audioPlayer.isPlaying) {
            cellView.trackNumberTextField.hidden = YES;
            cellView.equilizerView.hidden = NO;
            [cellView.equilizerView startAnimated:YES];
        }
        else // Paused
        {
            cellView.trackNumberTextField.hidden = YES;
            cellView.equilizerView.hidden = NO;
            [cellView.equilizerView pauseAnimated:YES];
        }
    }
    else // Don't show equalizer
    {
        cellView.equilizerView.hidden = YES;
        [cellView.equilizerView stopAnimated:NO];
        cellView.trackNumberTextField.hidden = NO;
    }

    return cellView;
}

-(BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    NSTableRowView *myRowView = [aTableView rowViewAtRow:rowIndex makeIfNecessary:NO];
    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
//    [myRowView setEmphasized:NO];
    
    return YES;
}

#pragma mark - Archive.org routing

- (IBAction)listenOnArchiveButtonPressed:(id)sender
{
    NSString *urlString = [NSString stringWithFormat:@"https://archive.org/details/%@", self.selectedShow.archiveIdentifier];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

@end
