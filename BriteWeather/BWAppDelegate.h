//
//  BWAppDelegate.h
//  BriteWeather
//
//  Created by Nik S Dyonin on 25.02.13.
//  Copyright (c) 2013 Brite Apps. All rights reserved.
//

@class BWForecastDataSource;

@interface BWAppDelegate : NSObject <NSApplicationDelegate> {
	NSTimer *updateTimer;
	BWForecastDataSource *dataSource;
	NSStatusItem *statusItem;
}

@end
