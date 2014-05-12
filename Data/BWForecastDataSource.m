//
//  BWForecastDataSource.m
//  BriteWeather
//
//  Created by Nik S Dyonin on 25.02.13.
//  Copyright (c) 2013 Brite Apps. All rights reserved.
//

#import "BWForecastDataSource.h"

@implementation BWForecastDataSource

+ (instancetype)sharedInstance {
	static dispatch_once_t pred;
	static BWForecastDataSource *shared = nil;
	dispatch_once(&pred, ^{
		shared = [[self alloc] init];
	});
	return shared;
}

- (void)update {
	if (!updating) {
		updating = YES;
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			@autoreleasepool {
				NSString *lang = nil;
				NSArray *preferredLanguages = [NSLocale preferredLanguages];
				
				if ([preferredLanguages count]) {
					lang = preferredLanguages[0];
				}

				if (!lang) {
					lang = @"en";
				}
				
				NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

				NSDictionary *city = [settings objectForKey:SETTINGS_CITY];
				NSUInteger cityId = [city[@"id"] integerValue];

				if (cityId > 0) {
					NSString *units = [settings boolForKey:SETTINGS_METRIC_UNITS] ? @"metric" : @"imperial";
					NSString *url = [NSString stringWithFormat:@"%@/weather/?id=%lu&units=%@&lang=%@&APPID=%@", API_PREFIX, cityId, units, lang, APPID];
					
					TRACE(@"Url: %@", url);

					NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:0 error:nil];
					
					if (data) {
						_forecast = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
					}
					
					if ([_target respondsToSelector:@selector(forecastUpdateFinished)]) {
						dispatch_async(dispatch_get_main_queue(), ^{
							[_target performSelector:@selector(forecastUpdateFinished)];
						});
					}
				}
				
				updating = NO;
			}
		});
	}
}

- (void)loadWeatherIcon {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		@autoreleasepool {
			NSString *iconUrl = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", _forecast[@"weather"][0][@"icon"]];
			NSImage *icon = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:iconUrl]];
			
			if (icon) {
				NSSize iconSize = icon.size;
				CGFloat scale = 22.0f / iconSize.height;
				iconSize.height = 22.0f;
				iconSize.width *= scale;
				[icon setSize:iconSize];

				if ([_target respondsToSelector:@selector(forecastIconLoaded:)]) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[_target performSelector:@selector(forecastIconLoaded:) withObject:icon];
					});
				}
			}
		}
	});
}

- (NSString *)url {
	return _forecast[@"url"];
}

@end
