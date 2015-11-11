//
//  RLPlaybackQueueViewController.m
//  Relisten
//
//  Created by Manik Kalra on 11/9/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLPlaybackQueueViewController.h"

@interface RLPlaybackQueueViewController ()

@property (weak) IBOutlet RLTableView *tableView;
@property (nonatomic, weak) AGAudioPlayer *audioPlayer;
@property (nonatomic) NSInteger draggedRow;

@end

@implementation RLPlaybackQueueViewController

-(instancetype)initWithAudioPlayer:(AGAudioPlayer *)audioPlayer
{
    if(self = [self initWithNibName:@"RLPlaybackQueueViewController" bundle:nil])
    {
        self.audioPlayer = audioPlayer;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.deleteDelegate = self;
    self.tableView.doubleAction = @selector(doubleClickedTrack:);
    
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];
}

-(void)viewDidAppear
{
    [super viewDidAppear];
    
    [self.tableView reloadData];
    [self.tableView scrollRowToVisible:self.audioPlayer.currentIndex];
}

-(void)reloadData
{
    [self.tableView reloadData];
}

#pragma mark - Queue Manipulation Methods

-(void)doubleClickedTrack:(id)sender
{
    NSInteger row = [sender clickedRow];
    [self.audioPlayer playItemAtIndex:row];
    [self.tableView reloadData];
}

- (IBAction)clearQueue:(id)sender
{
//    [self.audioPlayer.queue clear];
//    [self.tableView reloadData];
}

-(void)deleteKeyPressedAtIndex:(NSInteger)index
{
    if(index == self.audioPlayer.currentIndex)
    {
        [self.audioPlayer forward];
    }
    [self.audioPlayer.queue removeItemAtIndex:index];
    [self.tableView reloadData];
}

#pragma mark - NSTableViewDataSource Methods

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.audioPlayer.queue.count;
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    self.draggedRow = [rowIndexes firstIndex]; // only one row allowed for drag and drop
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [pboard setData:data forType:NSStringPboardType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    if(operation == NSTableViewDropAbove)
        return NSDragOperationEvery;
    else
        return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    [self.audioPlayer.queue moveItemAtIndex:self.draggedRow toIndex:row];
    [self.tableView reloadData];
    
    return YES;
}

#pragma mark - NSTableViewDelegate Methods

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RLPlaybackQueueCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    IguanaMediaItem *item = self.audioPlayer.queue.queue[row];
    
    cellView.trackTitleTextField.stringValue = item.iguanaTrack.title;
    cellView.trackNumberTextField.stringValue = [NSString stringWithFormat:@"%ld", row + 1];
    
    // TODO CHANGE ARTIST FOR MULTI-ARTIST
    cellView.trackArtistTextField.stringValue = [[IGAPIClient sharedInstance] artist].name;
    
    NSString *subtitleText = [NSString stringWithFormat:@"%@ - %@ - %@", item.iguanaTrack.show.displayDate, item.iguanaShow.venue.name, item.iguanaShow.venue.city];
    cellView.trackShowDetailsTextField.stringValue = subtitleText;
    
    if(row == self.audioPlayer.currentIndex)
    {
        cellView.equilizerView.hidden = NO;
        cellView.trackNumberTextField.hidden = YES;
        
        if(self.audioPlayer.isPlaying)
        {
            [cellView.equilizerView startAnimated:YES];
        }
        else
        {
            [cellView.equilizerView pauseAnimated:YES];
        }
    }
    else
    {
        [cellView.equilizerView stopAnimated:NO];
        cellView.equilizerView.hidden = YES;
        cellView.trackNumberTextField.hidden = NO;
    }
    
    return cellView;
}

-(BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    NSTableRowView *myRowView = [aTableView rowViewAtRow:rowIndex makeIfNecessary:NO];
    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    
    return YES;
}


@end
