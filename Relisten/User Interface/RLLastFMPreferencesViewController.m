//
//  RLLastFMPreferencesViewController.m
//  Relisten
//
//  Created by Manik Kalra on 12/30/15.
//  Copyright © 2015 Relisten. All rights reserved.
//

#import "RLLastFMPreferencesViewController.h"

@interface RLLastFMPreferencesViewController ()

@property (weak) IBOutlet NSTextField *scrobbleTextField;
@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@property (weak) IBOutlet NSButton *signinbutton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@end

@implementation RLLastFMPreferencesViewController

- (instancetype)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    
    return self;
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    // Do view setup here.
    
    if([LastFm sharedInstance].username)
    {
        [self setUserSignedInState];
    }
    else
    {
        [self setUserSignedOutState];
    }
}

-(void)setUserSignedInState
{
    NSString *username = [LastFm sharedInstance].username;
    self.scrobbleTextField.stringValue = [NSString stringWithFormat:@"Signed in as '%@'", username];
    
    self.usernameTextField.stringValue = username;
    self.usernameTextField.enabled = NO;
    
    self.passwordTextField.enabled = NO;
    self.passwordTextField.stringValue = @"12345678910";
    
    self.signinbutton.title = @"Sign Out";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"relisten_lastfm_state_changed"
                                                        object:self];
}

-(void)setUserSignedOutState
{
    self.scrobbleTextField.stringValue = @"Scrobble with Last.fm";
    
    self.usernameTextField.stringValue = @"";
    self.usernameTextField.placeholderString = @"Username...";
    self.usernameTextField.enabled = YES;
    
    self.passwordTextField.stringValue = @"";
    self.passwordTextField.placeholderString = @"Password...";
    self.passwordTextField.enabled = YES;
    
    self.signinbutton.title = @"Sign In";
    
    [[[NSApplication sharedApplication] mainWindow] performSelector: @selector(makeFirstResponder:)
                                                         withObject:self.usernameTextField
                                                         afterDelay:0.0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"relisten_lastfm_state_changed"
                                                        object:self];
}

#pragma mark - Lastfm Sign In/Sign Out handling

- (IBAction)signinbuttonpressed:(id)sender
{
    if([LastFm sharedInstance].username) // Sign Out
    {
        [[LastFm sharedInstance] logout];
        [self setUserSignedOutState];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"lastfm_session_key"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"lastfm_username_key"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else // Sign In
    {
        [self.progressIndicator startAnimation:nil];
        [[LastFm sharedInstance] getSessionForUser:self.usernameTextField.stringValue
                                         password:self.passwordTextField.stringValue
                                   successHandler:^(NSDictionary *result) {
                                       
                                       [self.progressIndicator stopAnimation:nil];
                                       
                                       [[NSUserDefaults standardUserDefaults] setObject:result[@"key"] forKey:@"lastfm_session_key"];
                                       [[NSUserDefaults standardUserDefaults] setObject:result[@"name"] forKey:@"lastfm_username_key"];
                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                       
                                       [LastFm sharedInstance].session = result[@"key"];
                                       [LastFm sharedInstance].username = result[@"name"];
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                           [self setUserSignedInState];
                                       });
                                   }
                                   failureHandler:^(NSError *error) {
                                       
                                       [self.progressIndicator stopAnimation:nil];
                                       
                                       // TODO handle error
                                       NSAlert *alert = [[NSAlert alloc] init];
                                       [alert addButtonWithTitle:@"OK"];
                                       [alert setMessageText:@"Could not sign into Last.fm"];
                                       [alert setInformativeText:error.localizedDescription];
                                       [alert setAlertStyle:NSInformationalAlertStyle];
                                       [alert runModal];
                                   }];
    }
}

#pragma mark - CCNPreferencesWindowControllerDelegate

- (NSString *)preferenceIdentifier
{
    return @"LastFMPreferencesIdentifier";
}

- (NSString *)preferenceTitle
{
    return @"Last.fm";
}

- (NSImage *)preferenceIcon
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

@end
