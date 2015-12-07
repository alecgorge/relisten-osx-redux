//
//  RLArtistsViewController.m
//  Relisten
//
//  Created by Manik Kalra on 11/12/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLArtistsViewController.h"

@interface RLArtistsViewController ()

@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) NSArray *artists;
@property (nonatomic, strong) NSArray *unfilteredArtists;

@end

@implementation RLArtistsViewController {
    int selectedArtistRow;
}

-(instancetype)initWithProgressIndictor:(NSProgressIndicator *)indicator
{
    if(self = [self initWithNibName:@"RLArtistsViewController" bundle:nil])
    {
        [self fetchArtistsWithProgressIndictor:indicator];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void)viewWillAppear
{
    [super viewWillAppear];
    
    self.searchField.stringValue = @"";
    self.artists = self.unfilteredArtists;
    [self.tableView reloadData];
    
    selectedArtistRow = -1;
}

-(void)fetchArtistsWithProgressIndictor:(NSProgressIndicator *)indicator
{
    [indicator startAnimation:nil];
    [IGAPIClient.sharedInstance artists:^(NSArray *artists)
     {
         self.unfilteredArtists = [artists sortedArrayUsingComparator:^NSComparisonResult(IGArtist *obj1, IGArtist *obj2) {
             
             return [obj1.name localizedCaseInsensitiveCompare:obj2.name];
         }];
         
         NSString *slug = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_selected_artist_slug"];
         
         if(slug)
         {
             NSInteger index = [[self.unfilteredArtists valueForKeyPath:@"slug"] indexOfObject:slug];
             
             if(index >= 0 && index < self.unfilteredArtists.count)
             {
                 self.selectedArtist = self.unfilteredArtists[index];
                 [self.delegate artistSelected:self.unfilteredArtists[index]];
                 self.artists = self.unfilteredArtists;
             }
         }
         
         [indicator stopAnimation:nil];
     }];
}

#pragma mark - Filtering Methods

- (IBAction)searchFieldUpdated:(NSSearchField *)sender
{
    if (selectedArtistRow != -1) {
        [[self.tableView rowViewAtRow:selectedArtistRow makeIfNecessary:NO] setSelected:NO];
        selectedArtistRow = -1;
    }
    
    NSString *substring = [sender stringValue];
    
    if([substring isEqualToString:@""])
    {
        self.artists = self.unfilteredArtists;
        [self.tableView reloadData];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", substring];
        self.artists = [self.unfilteredArtists filteredArrayUsingPredicate:predicate];
        [self.tableView reloadData];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if([control isKindOfClass:[NSSearchField class]])
    {
        if(commandSelector == @selector(moveDown:))
        {
            if (selectedArtistRow != -1) {
                [[self.tableView rowViewAtRow:selectedArtistRow makeIfNecessary:NO] setSelected:NO];
            }
            if ((selectedArtistRow + 1) != self.artists.count) {
                selectedArtistRow++;
            }
            [[self.tableView rowViewAtRow:selectedArtistRow makeIfNecessary:NO] setSelected:YES];
            [self.tableView scrollRowToVisible:selectedArtistRow];
            return YES;
        }
        else if(commandSelector == @selector(moveUp:))
        {
            if (selectedArtistRow != -1) {
                [[self.tableView rowViewAtRow:selectedArtistRow makeIfNecessary:NO] setSelected:NO];
            }
            if ((selectedArtistRow - 1) != -1) {
                selectedArtistRow--;
            }
            [[self.tableView rowViewAtRow:selectedArtistRow makeIfNecessary:NO] setSelected:YES];
            [self.tableView scrollRowToVisible:selectedArtistRow];
            return YES;
        }
        else if(commandSelector == @selector(insertNewline:))
        {
            [self.delegate artistSelected:self.artists[selectedArtistRow]];
        }
    }

    return NO;
}

#pragma mark - NSTableViewdataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return self.artists.count;
}

#pragma mark - NSTableViewDelegate Methods

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[RLTableRowView alloc] init];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RLArtistTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    IGArtist *artist = self.artists[row];
    
    cellView.artistNameTextField.stringValue = artist.name;
    cellView.trackCountTextField.stringValue = [NSString stringWithFormat:@"%ld recordings", (long)artist.recordingCount];
    
    return cellView;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableview = notification.object;
    NSInteger row = [tableview selectedRow];
    
    [self.delegate artistSelected:self.artists[row]];
}

-(BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    NSTableRowView *myRowView = [aTableView rowViewAtRow:rowIndex makeIfNecessary:NO];
    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    //    [myRowView setEmphasized:NO];
    
    return YES;
}

@end
