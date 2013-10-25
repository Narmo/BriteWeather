//
//  BWCityWindow.h
//  BriteWeather
//
//  Created by Nik S Dyonin on 03.03.13.
//  Copyright (c) 2013 Brite Apps. All rights reserved.
//

@interface BWCityWindow : NSWindow

@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSBrowser *listView;

@end
