//
//  BWForecastDataSource.h
//  BriteWeather
//
//  Created by Nik S Dyonin on 25.02.13.
//  Copyright (c) 2013 Brite Apps. All rights reserved.
//

@interface BWForecastDataSource : NSObject {
	BOOL updating;
}

@property (nonatomic, assign) id target;
@property (nonatomic, readonly) NSDictionary *forecast;
@property (nonatomic, readonly) NSString *url;

+ (instancetype)sharedInstance;
- (void)update;
- (void)loadWeatherIcon;

@end
