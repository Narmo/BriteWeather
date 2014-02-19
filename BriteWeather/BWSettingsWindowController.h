//
//  BWSettingsWindowController.h
//  BriteWeather
//
//  Created by Nik Dyonin on 19.02.14.
//  Copyright (c) 2014 Brite Apps. All rights reserved.
//

static NSString *kBWSettingsWindowWillCloseNotification = @"BWSettingsWindowWillClose";

@interface BWSettingsWindowController : NSWindowController <NSWindowDelegate, NSComboBoxDelegate, NSComboBoxDataSource, NSTextFieldDelegate>

@property (weak) IBOutlet NSComboBox *cityCombobox;
@property (weak) IBOutlet NSMatrix *unitsMatrix;

- (void)showWindow;

@end

@interface NSComboBox (MYExpansionAPI)

@property (getter=isExpanded) BOOL expanded;

@end
