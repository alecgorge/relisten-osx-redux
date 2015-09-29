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
}

@end
