//
//  IGTrack.h
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

//#import "PhishinTrack.h"

@class IGShow;

@protocol IGTrack
@end

@interface IGTrack : JSONModel<NSCoding>

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger track;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) NSTimeInterval length;
@property (nonatomic, strong) NSString *file;
@property (nonatomic, strong) NSString *slug;

@property (nonatomic, readonly) NSURL<Ignore> *mp3;

@property (nonatomic, strong) IGShow<Optional, Ignore> *show;

- (NSURL *)shareURLWithPlayedTime:(NSTimeInterval)elapsed;

@end
