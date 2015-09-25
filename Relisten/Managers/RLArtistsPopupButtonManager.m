//
//  RLArtistsPopupButtonManager.m
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLArtistsPopupButtonManager.h"

@interface RLArtistsPopupButtonManager()

@property (nonatomic) NSArray *artists;

@end

@implementation RLArtistsPopupButtonManager

- (instancetype)initWithPopUpButton:(NSPopUpButton *)popupButton
{
    if (self = [super init])
    {
        [self setPopUpButton:popupButton];
    }
    
    return self;
}

- (void)setPopUpButton:(NSPopUpButton *)popUpButton
{
    self.artistPopupButton = popUpButton;
    
    self.artistPopupButton.rac_command = [RACCommand.alloc initWithSignalBlock:^RACSignal *(id input) {
        
        IGArtist *artist = self.artists[self.artistPopupButton.indexOfSelectedItem];
        
        return [RACSignal return:artist];
    }];
    
    self.artistChanged = self.artistPopupButton.rac_command;
}

- (void)refresh
{
    [IGAPIClient.sharedInstance artists:^(NSArray *artists)
    {
        self.artists = [artists sortedArrayUsingComparator:^NSComparisonResult(IGArtist *obj1, IGArtist *obj2) {
            
            return [obj1.name localizedCaseInsensitiveCompare:obj2.name];
        }];
        
        [self.artistPopupButton removeAllItems];
        [self.artistPopupButton addItemsWithTitles:[self.artists map:^id(IGArtist *object) {
            
            return object.name;
        }]];
        
        ((NSPopUpButtonCell*)self.artistPopupButton.cell).enabled = YES;
        
        NSString *slug = [NSUserDefaults.standardUserDefaults objectForKey:@"last_selected_artist_slug"];
        if(slug)
        {
            NSInteger index = [[self.artists valueForKeyPath:@"slug"] indexOfObject:slug];
            
            if(index >= 0 && index < self.artists.count)
            {
                [self.artistPopupButton selectItemAtIndex: index];
                [self.artistPopupButton.rac_command execute:self];
            }
        }
    }];
}

@end
