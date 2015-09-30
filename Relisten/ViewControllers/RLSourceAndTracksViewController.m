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

@property (nonatomic, strong) NSArray *allShows;
@property (nonatomic, strong) IGShow *selectedShow;

@end

@implementation RLSourceAndTracksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
    [self disableSourceSelection];
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
                                }];
}

@end
