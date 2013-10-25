//
//  BWForecastDataSource.m
//  BriteWeather
//
//  Created by Nik S Dyonin on 25.02.13.
//  Copyright (c) 2013 Brite Apps. All rights reserved.
//

#import "BWForecastDataSource.h"

#define FORECAST_URL @"http://api.openweathermap.org/data/2.1/weather/city/524901?units=metric&lang=ru"

@implementation BWForecastDataSource

@synthesize forecast = forecast;
@synthesize icon = icon;
@synthesize url = url;

- (void)update {
	if (!updating) {
		updating = YES;
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			@autoreleasepool {
				@try {
					NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:FORECAST_URL] options:0 error:nil];
					
					forecast = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
					url = forecast[@"url"];

					TRACE(@"Forecast: %@", forecast);

					if ([_target respondsToSelector:@selector(forecastUpdateFinished)]) {
						dispatch_async(dispatch_get_main_queue(), ^{
							[_target performSelector:@selector(forecastUpdateFinished)];
						});
					}
					
					updating = NO;
				}
				@catch (NSException *e) {
				}
			}
		});
	}
}

- (void)loadWeatherIcon {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		@autoreleasepool {
			@try {
				NSString *iconUrl = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", forecast[@"weather"][0][@"icon"]];
				icon = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:iconUrl]];
				
				NSSize iconSize = icon.size;
				CGFloat scale = 22.0f / iconSize.height;
				iconSize.height = 22.0f;
				iconSize.width *= scale;
				[icon setSize:iconSize];
				
				if ([_target respondsToSelector:@selector(forecastIconLoaded)]) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[_target performSelector:@selector(forecastIconLoaded)];
					});
				}
			}
			@catch (NSException *e) {
			}
		}
	});
}

@end
