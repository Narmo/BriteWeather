//
//  BWSettingsWindowController.m
//  BriteWeather
//
//  Created by Nik Dyonin on 19.02.14.
//  Copyright (c) 2014 Brite Apps. All rights reserved.
//

#import "BWSettingsWindowController.h"
#import "BWForecastDataSource.h"

@implementation BWSettingsWindowController {
	NSMutableArray *cities;
	NSTimer *searchDelayTimer;
}

- (void)showWindow {
	self.window.title = NSLocalizedString(@"Settings", @"");
	self.window.delegate = self;
	[self showWindow:NSApp];
	[NSApp activateIgnoringOtherApps:YES];
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	cities = [[NSMutableArray alloc] init];
	
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	BOOL metric = [settings boolForKey:SETTINGS_METRIC_UNITS];

	if (metric) {
		[self.unitsMatrix selectCellAtRow:0 column:0];
	}
	else {
		[self.unitsMatrix selectCellAtRow:1 column:0];
	}
	
	NSDictionary *city = [settings objectForKey:SETTINGS_CITY];

	if (city) {
		NSString *name = [NSString stringWithFormat:@"%@ (%@)", city[@"name"], city[@"sys"][@"country"]];
		[self.cityCombobox setStringValue:name];
	}

	self.cityCombobox.delegate = self;
	self.cityCombobox.dataSource = self;
}

- (void)windowWillClose:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:kBWSettingsWindowWillCloseNotification object:nil];
	[[BWForecastDataSource sharedInstance] update];
}

- (IBAction)unitsChanged:(NSMatrix *)sender {
	NSInteger tag = sender.selectedTag;
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	if (tag == 1) {
		[settings setBool:YES forKey:SETTINGS_METRIC_UNITS];
	}
	else {
		[settings setBool:NO forKey:SETTINGS_METRIC_UNITS];
	}
	
	[settings synchronize];
	
	[[BWForecastDataSource sharedInstance] update];
}

- (IBAction)doneAction:(NSButton *)sender {
	[self.window close];
}

- (void)controlTextDidChange:(NSNotification *)obj {
	NSTextView *textView = [obj userInfo][@"NSFieldEditor"];
	NSString *string = [textView string];
	
	[searchDelayTimer invalidate];
	
	if ([string length]) {
		searchDelayTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(searchCity:) userInfo:@{@"string": string} repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer:searchDelayTimer forMode:NSRunLoopCommonModes];
		
		if (![_cityCombobox isExpanded]) {
			[_cityCombobox setExpanded:YES];
		}
	}
	else {
		[cities removeAllObjects];
		[_cityCombobox reloadData];
		
		if ([_cityCombobox isExpanded]) {
			[_cityCombobox setExpanded:NO];
		}
	}
}

- (void)searchCity:(NSTimer *)sender {
	NSString *string = [sender userInfo][@"string"];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		@autoreleasepool {
			NSString *lang = [[NSLocale preferredLanguages] firstObject];
			
			if (!lang) {
				lang = @"en";
			}
			
			NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
			NSString *units = [settings boolForKey:SETTINGS_METRIC_UNITS] ? @"metric" : @"imperial";
			NSString *url = [NSString stringWithFormat:@"%@/find/?q=%@&units=%@&lang=%@&type=like&APPID=%@", API_PREFIX, [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], units, lang, APPID];

			@try {
				NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:0 error:nil];
				
				if (data) {
					NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
					[cities removeAllObjects];
					
					if (response) {
						[cities addObjectsFromArray:response[@"list"]];
					}
				}
			}
			@catch (NSException *e) {
				TRACE(@"BWSettingsWindowController (-searchCity:) exception: %@", e);
			}

			dispatch_async(dispatch_get_main_queue(), ^{
				[_cityCombobox reloadData];
			});
		}
	});
}

- (void)dealloc {
	[searchDelayTimer invalidate];
}

#pragma mark - Combobox callbacks

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
	return [cities count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
	NSDictionary *city = cities[index];
	return [NSString stringWithFormat:@"%@ (%@)", city[@"name"], city[@"sys"][@"country"]];
}

- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)string {
	for (NSDictionary *city in cities) {
		NSString *name = city[@"name"];

		if ([string commonPrefixWithString:name options:NSCaseInsensitiveSearch]) {
			NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
			[settings setObject:city forKey:SETTINGS_CITY];
			[settings synchronize];
			return [NSString stringWithFormat:@"%@ (%@)", city[@"name"], city[@"sys"][@"country"]];
		}
	}
	
	return nil;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
	NSInteger selectedItem = [self.cityCombobox indexOfSelectedItem];
	NSDictionary *city = cities[selectedItem];

	if (city) {
		NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
		[settings setObject:city forKey:SETTINGS_CITY];
		[settings synchronize];
	}
}

@end

// http://stackoverflow.com/a/17346857/318460
@implementation NSComboBox (Expansion)

- (BOOL)isExpanded {
	id ax = NSAccessibilityUnignoredDescendant(self);
	return [[ax accessibilityAttributeValue:NSAccessibilityExpandedAttribute] boolValue];
}

- (void)setExpanded:(BOOL)expanded {
	id ax = NSAccessibilityUnignoredDescendant(self);
	[ax accessibilitySetValue:@(expanded) forAttribute:NSAccessibilityExpandedAttribute];
}

@end
