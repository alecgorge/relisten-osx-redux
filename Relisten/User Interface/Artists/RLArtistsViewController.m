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

@end

@implementation RLArtistsViewController

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
}

-(void)fetchArtistsWithProgressIndictor:(NSProgressIndicator *)indicator
{
    [indicator startAnimation:nil];
    [IGAPIClient.sharedInstance artists:^(NSArray *artists)
     {
         self.artists = [artists sortedArrayUsingComparator:^NSComparisonResult(IGArtist *obj1, IGArtist *obj2) {
             
             return [obj1.name localizedCaseInsensitiveCompare:obj2.name];
         }];
         
         NSString *slug = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_selected_artist_slug"];
         
         if(slug)
         {
             NSInteger index = [[self.artists valueForKeyPath:@"slug"] indexOfObject:slug];
             
             if(index >= 0 && index < self.artists.count)
             {
                 self.selectedArtist = self.artists[index];
                 [self.delegate artistSelected:self.artists[index]];
             }
         }
         
         [indicator stopAnimation:nil];
     }];
}

#pragma mark - NSTableViewdataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return self.artists.count;
}

#pragma mark - NSTableViewDelegate Methods

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
