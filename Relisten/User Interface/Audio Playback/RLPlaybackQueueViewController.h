//
//  RLPlaybackQueueViewController.h
//  Relisten
//
//  Created by Manik Kalra on 11/9/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AGAudioPlayer/AGAudioPlayer.h>
#import "RLPlaybackQueueCellView.h"
#import "IguanaMediaItem.h"
#import "IGAPIClient.h"
#import "RLTableView.h"

@interface RLPlaybackQueueViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, RLTableViewDeleteDelegate>

-(instancetype)initWithAudioPlayer:(AGAudioPlayer *)audioPlayer;
-(void)reloadData;

@end
