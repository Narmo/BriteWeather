//
//  BWAppDelegate.m
//  BriteWeather
//
//  Created by Nik S Dyonin on 25.02.13.
//  Copyright (c) 2013 Brite Apps. All rights reserved.
//

#import "BWAppDelegate.h"
#import "BWForecastDataSource.h"
#import "BWSettingsWindowController.h"

@interface BWAppDelegate()

@property (nonatomic, strong) BWSettingsWindowController *cityWindowController;

@end


@implementation BWAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

	if (![settings objectForKey:SETTINGS_METRIC_UNITS]) {
		[settings setBool:YES forKey:SETTINGS_METRIC_UNITS];
	}
	
	NSString *units = [[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_METRIC_UNITS] ? @"°C" : @"°F";
	
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setTitle:[NSString stringWithFormat:@"--%@", units]];
	[statusItem setHighlightMode:YES];
	[statusItem setTarget:self];

	NSMenu *menu = [[NSMenu alloc] init];
	[menu addItemWithTitle:NSLocalizedString(@"Settings", @"") action:@selector(showSettings) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedString(@"Update", @"") action:@selector(updateForecast) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedString(@"Quit", @"") action:@selector(quit) keyEquivalent:@""];
	[statusItem setMenu:menu];

	dataSource = [BWForecastDataSource sharedInstance];
	dataSource.target = self;

	updateTimer = [NSTimer timerWithTimeInterval:3600.0 target:self selector:@selector(updateForecast) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSDefaultRunLoopMode];
	
	[dataSource update];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsWindowWillClose) name:kBWSettingsWindowWillCloseNotification object:nil];
}

- (void)showSettings {
	if (!_cityWindowController) {
		self.cityWindowController = [[BWSettingsWindowController alloc] initWithWindowNibName:@"BWSettingsWindowController"];
	}

	[_cityWindowController showWindow];
}

- (void)settingsWindowWillClose {
	self.cityWindowController = nil;
}

- (void)forecastUpdateFinished {
	NSDictionary *forecast = dataSource.forecast;
	NSMenu *menu = [[NSMenu alloc] init];
	
	NSString *units = [[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_METRIC_UNITS] ? @"°C" : @"°F";

	if (forecast) {
		double temp = [forecast[@"main"][@"temp"] doubleValue];
		[statusItem setTitle:[NSString stringWithFormat:@"%ld%@", (long)temp, units]];
		[dataSource loadWeatherIcon];

		NSString *location = [NSString stringWithFormat:@"%@ (%@)", forecast[@"name"], forecast[@"sys"][@"country"]];
		NSString *weatherState = forecast[@"weather"][0][@"description"];
		
		NSString *temperature = [NSString stringWithFormat:@"%@: %ld%@, %@: %ld%@",
								 NSLocalizedString(@"Min", @""),
								 (long)[forecast[@"main"][@"temp_min"] doubleValue],
								 units,
								 NSLocalizedString(@"max", @""),
								 (long)[forecast[@"main"][@"temp_max"] doubleValue],
								 units];

		NSString *humidity = [NSString stringWithFormat:NSLocalizedString(@"Humidity: %.1f%%", @""), [forecast[@"main"][@"humidity"] floatValue]];
		
		[menu addItemWithTitle:location action:NULL keyEquivalent:@""];
		[menu addItemWithTitle:weatherState action:NULL keyEquivalent:@""];
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItemWithTitle:temperature action:NULL keyEquivalent:@""];
		[menu addItemWithTitle:humidity action:NULL keyEquivalent:@""];

		[menu addItem:[NSMenuItem separatorItem]];

		if ([dataSource.url length]) {
			[menu addItemWithTitle:NSLocalizedString(@"Show in browser", @"") action:@selector(openForecast) keyEquivalent:@""];
		}

		[menu addItemWithTitle:NSLocalizedString(@"Settings", @"") action:@selector(showSettings) keyEquivalent:@""];
		[menu addItemWithTitle:NSLocalizedString(@"Update", @"") action:@selector(updateForecast) keyEquivalent:@""];

		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItemWithTitle:NSLocalizedString(@"Quit", @"") action:@selector(quit) keyEquivalent:@""];
	}
	else {
		[statusItem setTitle:[NSString stringWithFormat:@"--%@", units]];

		[menu addItemWithTitle:NSLocalizedString(@"Settings", @"") action:@selector(showSettings) keyEquivalent:@""];
		[menu addItemWithTitle:NSLocalizedString(@"Update", @"") action:@selector(updateForecast) keyEquivalent:@""];
		[menu addItemWithTitle:NSLocalizedString(@"Quit", @"") action:@selector(quit) keyEquivalent:@""];
	}
	
	[statusItem setMenu:menu];
}

- (void)updateForecast {
	[dataSource update];
}

- (void)forecastIconLoaded:(NSImage *)icon {
	[statusItem setImage:icon];
}

- (void)openForecast {
	if ([dataSource.url length]) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:dataSource.url]];
	}
}

- (void)quit {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[updateTimer invalidate];
	updateTimer = nil;
	dataSource.target = nil;
	[[NSApplication sharedApplication] terminate:self];
}

@end
