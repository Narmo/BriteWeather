//
//  BWForecastDataSource.h
//  BriteWeather
//
//  Created by Nik S Dyonin on 25.02.13.
//  Copyright (c) 2013 Brite Apps. All rights reserved.
//

@interface BWForecastDataSource : NSObject {
	NSDictionary *forecast;
	NSImage *icon;
	NSString *url;

	BOOL updating;
}

@property (nonatomic, assign) id target;
@property (nonatomic, readonly) NSDictionary *forecast;
@property (nonatomic, readonly) NSImage *icon;
@property (nonatomic, readonly) NSString *url;

- (void)update;
- (void)loadWeatherIcon;

@end
