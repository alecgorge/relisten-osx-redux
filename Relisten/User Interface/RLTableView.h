//
//  RLTableView.h
//  Relisten
//
//  Created by Manik Kalra on 9/25/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol RLTableViewDeleteDelegate <NSObject>

- (void)deleteKeyPressedAtIndex:(NSInteger)index;

@end

@interface RLTableView : NSTableView

@property (nonatomic, weak) id<RLTableViewDeleteDelegate> deleteDelegate;

@end
