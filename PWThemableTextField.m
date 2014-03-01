//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWThemableTextField.h"
#import "PWController.h"
#import "PWTheme.h"

@implementation PWThemableTextField

- (instancetype)init {
	if ((self = [super init])) {
		[self _configureAppearance];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self _configureAppearance];
	}
	return self;
}

- (void)_configureAppearance {
	
	PWTheme *theme = [PWController activeTheme];
	UIColor *backgroundColor = [theme cellBackgroundColor];
	UIColor *inputTextColor = [theme cellInputTextColor];
	UIColor *inputPlaceholderTextColor = [theme cellInputPlaceholderTextColor];
	
	self.backgroundColor = backgroundColor;
	
	self.textColor = inputTextColor;
	self.tintColor = [PWTheme adjustColorBrightness:inputTextColor colorAdjustment:0.0 alphaMultiplier:.3];
	
	[self setValue:inputPlaceholderTextColor forKeyPath:@"_placeholderLabel.textColor"];
	
	self.keyboardAppearance = theme.wantsDarkKeyboard ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;
}

@end