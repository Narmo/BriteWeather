//
//  BWAppDelegate.h
//  BriteWeather
//
//  Created by Nik S Dyonin on 25.02.13.
//  Copyright (c) 2013 Brite Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>

@class BWForecastDataSource;

@interface BWAppDelegate : NSObject <NSApplicationDelegate, NSPopoverDelegate, CLLocationManagerDelegate> {
	NSTimer *updateTimer;
	CLLocationManager *locationManager;
	BWForecastDataSource *dataSource;
	NSStatusItem *statusItem;
}

@end
