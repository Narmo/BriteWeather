//
//  BWAppDelegate.m
//  BriteWeather
//
//  Created by Nik S Dyonin on 25.02.13.
//  Copyright (c) 2013 Brite Apps. All rights reserved.
//

#import "BWAppDelegate.h"
#import "BWForecastDataSource.h"
#import "BWCityWindowController.h"

@interface BWAppDelegate()

@property (nonatomic, strong) BWCityWindowController *cityWindowController;

@end


@implementation BWAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.cityWindowController = [[BWCityWindowController alloc] init];

	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setTitle:@"--°C"];
	[statusItem setHighlightMode:YES];
	[statusItem setTarget:self];
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];

	NSMenu *menu = [[NSMenu alloc] init];
	[menu addItemWithTitle:NSLocalizedString(@"Settings", @"") action:@selector(showSettings) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedString(@"Update", @"") action:@selector(updateForecast) keyEquivalent:@""];
	[menu addItemWithTitle:NSLocalizedString(@"Quit", @"") action:@selector(quit) keyEquivalent:@""];
	[statusItem setMenu:menu];

	dataSource = [[BWForecastDataSource alloc] init];
	dataSource.target = self;

	updateTimer = [NSTimer timerWithTimeInterval:3600.0 target:self selector:@selector(updateForecast) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSDefaultRunLoopMode];

	[self updateForecast];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	TRACE(@"Error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	TRACE(@"New location: %@", newLocation);
}

- (void)showSettings {
	[_cityWindowController showWindow];
}

- (void)updateForecast {
	[dataSource update];
}

- (void)forecastUpdateFinished {
	@try {
		NSDictionary *forecast = dataSource.forecast;
		if (forecast) {
			double temp = [forecast[@"main"][@"temp"] doubleValue];
			[statusItem setTitle:[NSString stringWithFormat:@"%ld°C", (long)temp]];
			[dataSource loadWeatherIcon];

			NSString *location = [NSString stringWithFormat:NSLocalizedString(@"Location: %@", @""), forecast[@"name"]];
			NSString *weatherState = forecast[@"weather"][0][@"description"];
			NSString *temperature = [NSString stringWithFormat:NSLocalizedString(@"Min: %ld°C, max: %ld°C", @""), (long)[forecast[@"main"][@"temp_min"] doubleValue], (long)[forecast[@"main"][@"temp_max"] doubleValue]];
			NSString *humidity = [NSString stringWithFormat:NSLocalizedString(@"Humidity: %.1f%%", @""), [forecast[@"main"][@"humidity"] floatValue]];

			NSMenu *menu = [[NSMenu alloc] init];
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

			[statusItem setMenu:menu];
		}
	}
	@catch (NSException *e) {
		TRACE(@"-forecastUpdateFinished exception: %@", e);
		[statusItem setTitle:@"--°C"];

		NSMenu *menu = [[NSMenu alloc] init];
		[menu addItemWithTitle:NSLocalizedString(@"Settings", @"") action:@selector(showSettings) keyEquivalent:@""];
		[menu addItemWithTitle:NSLocalizedString(@"Update", @"") action:@selector(updateForecast) keyEquivalent:@""];
		[menu addItemWithTitle:NSLocalizedString(@"Quit", @"") action:@selector(quit) keyEquivalent:@""];
		[statusItem setMenu:menu];
	}
}

- (void)forecastIconLoaded {
	@try {
		if (dataSource.icon) {
			[statusItem setImage:dataSource.icon];
		}
	}
	@catch (NSException *e) {
	}
}

- (void)showWeatherNotification {
	NSDictionary *forecast = dataSource.forecast;
	if (forecast) {
		NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
		[notificationCenter removeAllDeliveredNotifications];

		NSUserNotification *notification = [[NSUserNotification alloc] init];
		notification.title = forecast[@"name"];
		notification.subtitle = [NSString stringWithFormat:@"%.0f°C", [forecast[@"main"][@"temp"] doubleValue]];
		notification.informativeText = forecast[@"weather"][0][@"description"];
		notification.deliveryDate = [NSDate date];

		[notificationCenter scheduleNotification: notification];
	}
}

- (void)openForecast {
	if ([dataSource.url length]) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:dataSource.url]];
	}
}

- (void)quit {
	[updateTimer invalidate];
	updateTimer = nil;
	dataSource.target = nil;
	dataSource = nil;
	[[NSApplication sharedApplication] terminate:self];
}

- (void)dealloc {
	[updateTimer invalidate];
	updateTimer = nil;
	dataSource.target = nil;
}

@end
