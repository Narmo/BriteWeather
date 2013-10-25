//
//  BWCityWindowController.m
//  BriteWeather
//
//  Created by Nik S Dyonin on 03.03.13.
//  Copyright (c) 2013 Brite Apps. All rights reserved.
//

#import "BWCityWindowController.h"

@implementation BWCityWindowController

- (id)init {
	self = [super initWithWindowNibName:@"BWCityWindow" owner:self];
	return self;
}

- (void)showWindow {
	self.window.title = NSLocalizedString(@"Select your city", @"");
	[self showWindow:NSApp];
	[self.window center];
	[NSApp activateIgnoringOtherApps:YES];
}

@end
