//
//  RLArtistsPopupButtonManager.h
//  Relisten
//
//  Created by Manik Kalra on 9/24/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "IGAPIClient.h"

@interface RLArtistsPopupButtonManager : NSObject

@property (nonatomic) NSPopUpButton *artistPopupButton;
@property (nonatomic) RACCommand *artistChanged;

- (instancetype)initWithPopUpButton:(NSPopUpButton *)popupButton;
- (void)refresh;
- (void)selectArtist:(IGArtist *)artist;

@end
