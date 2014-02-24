//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWTheme : NSObject {
	
	NSString *_name;
	NSBundle *_bundle;
	
	UIColor *_preferredTintColor;
	UIColor *_preferredBarTextColor;
}

@property(nonatomic, copy) NSString *name;
@property(nonatomic, retain) NSBundle *bundle;

@property(nonatomic, readonly) UIColor *preferredTintColor;
@property(nonatomic, readonly) UIColor *preferredBarTextColor;

@property(nonatomic, readonly) PWBackgroundView *backgroundView;
@property(nonatomic, readonly) PWContainerView *containerView;
@property(nonatomic, readonly) UINavigationController *navigationController;
@property(nonatomic, readonly) UINavigationBar *navigationBar;

//////////////////////////////////////////////////////////////////////

/**
 * Initialization
 **/

- (instancetype)initWithName:(NSString *)name bundle:(NSBundle *)bundle;

//////////////////////////////////////////////////////////////////////

/**
 * Public API
 **/

- (UIImage *)imageNamed:(NSString *)name;
- (UIImage *)imageNamed:(NSString *)name withCapInsets:(UIEdgeInsets)insets;

+ (UIColor *)parseColorString:(NSString *)string;
+ (UIImage *)imageFromColor:(UIColor *)color;
+ (UIColor *)adjustColorBrightness:(UIColor *)color adjustment:(CGFloat)adjustment;
+ (UIColor *)darkenColor:(UIColor *)color;
+ (UIColor *)lightenColor:(UIColor *)color;

//////////////////////////////////////////////////////////////////////

/**
 * Private methods
 **/

// assign the UI elements to this instance for further theming
- (void)_setPreferredTintColor:(UIColor *)tintColor;
- (void)_setPreferredBarTextColor:(UIColor *)tintColor;
- (void)_configureAppearance;

//////////////////////////////////////////////////////////////////////

/**
 * Override these methods to configure the theme
 **/

// Setup Theme
// for themers to setup the theme (e.g. add sub views)
// NOT necessary to adjust sizes yet. DO it in adjustLayout
- (void)setupTheme;

// Remove Theme
// for themers to remove all subviews added in setupTheme
- (void)removeTheme;

// Adjust Layout
// for themers to adjust the size and position of different
// UI elements
- (void)adjustLayout;

//////////////////////////////////////////////////////////////////////

/**
 * Override these methods to customize the theme
 **/

///////////////////////////
////////// Style //////////
///////////////////////////

- (BOOL)wantsDarkKeyboard;

////////////////////////////
////////// Images //////////
////////////////////////////

// Determines the background image of the sheet
// If nil, then background color will be used instead
- (UIImage *)sheetBackgroundImageForOrientation:(PWWidgetOrientation)orientation;

// Determines the background image of the navigation bar
// If nil, then background color will be used instead
- (UIImage *)navigationBarBackgroundImageForOrientation:(PWWidgetOrientation)orientation;

// Determine the background image of the cells
//
// Not including the cells in custom table views that do not follow
// values from theme
//
// If nil, then background color will be used instead
- (UIImage *)cellBackgroundImageForOrientation:(PWWidgetOrientation)orientation;
- (UIImage *)cellSelectedBackgroundImageForOrientation:(PWWidgetOrientation)orientation;

////////////////////////////
////////// Colors //////////
////////////////////////////

// Determines the background color of the sheet
// If nil, then default background color will be used instead
- (UIColor *)sheetBackgroundColor;

// Determines different colors in the navigation bar
// If nil, then default colors will be used instead
- (UIColor *)navigationBarBackgroundColor;
- (UIColor *)navigationTitleTextColor;
- (UIColor *)navigationButtonTextColor;

// Determine different colors in the cells
//
// Not including the cells in custom table views that do not follow
// values from theme
//
// If nil, then default colors will be used instead
- (UIColor *)cellTintColor;
- (UIColor *)cellSeparatorColor;
- (UIColor *)cellBackgroundColor;
- (UIColor *)cellTitleTextColor;
- (UIColor *)cellValueTextColor;
- (UIColor *)cellButtonTextColor;
- (UIColor *)cellInputTextColor;
- (UIColor *)cellInputPlaceholderTextColor;
- (UIColor *)cellPlainTextColor;

- (UIColor *)cellSelectedBackgroundColor;
- (UIColor *)cellSelectedTitleTextColor;
- (UIColor *)cellSelectedValueTextColor;
- (UIColor *)cellSelectedButtonTextColor;

- (UIColor *)cellHeaderFooterViewBackgroundColor;
- (UIColor *)cellHeaderFooterViewTitleTextColor;

- (UIColor *)cellSwitchOnColor;
- (UIColor *)cellSwitchOffColor;

//////////////////////////////////////////
////////// Sizes and Dimensions //////////
//////////////////////////////////////////

// Determines the corner radius of the sheet
- (CGFloat)cornerRadius;

// Determines the height of an item cell in item table view
- (CGFloat)heightOfCellOfType:(PWWidgetCellType)type forOrientation:(PWWidgetOrientation)orientation;

//////////////////////////////////////////////////////////////////////

/**
 * Default theme values
 **/

+ (UIColor *)defaultSheetBackgroundColor;

+ (UIColor *)defaultNavigationBarBackgroundColor;
+ (UIColor *)defaultNavigationTitleTextColor;
+ (UIColor *)defaultNavigationButtonTextColor;

+ (UIColor *)defaultCellTintColor;
+ (UIColor *)defaultCellSeparatorColor;
+ (UIColor *)defaultCellBackgroundColor;
+ (UIColor *)defaultCellTitleTextColor;
+ (UIColor *)defaultCellValueTextColor;
+ (UIColor *)defaultCellButtonTextColor;
+ (UIColor *)defaultCellInputTextColor;
+ (UIColor *)defaultCellInputPlaceholderTextColor;
+ (UIColor *)defaultCellPlainTextColor;

+ (UIColor *)defaultCellSelectedBackgroundColor;
+ (UIColor *)defaultCellSelectedTitleTextColor;
+ (UIColor *)defaultCellSelectedValueTextColor;
+ (UIColor *)defaultCellSelectedButtonTextColor;

+ (UIColor *)defaultCellHeaderFooterViewBackgroundColor;
+ (UIColor *)defaultCellHeaderFooterViewTitleTextColor;

+ (UIColor *)defaultCellSwitchOnColor;
+ (UIColor *)defaultCellSwitchOffColor;

+ (CGFloat)defaultCornerRadius;
+ (CGFloat)defaultHeightOfCellOfType:(PWWidgetCellType)type forOrientation:(PWWidgetOrientation)orientation;

//////////////////////////////////////////////////////////////////////

/**
 * System colors
 **/

+ (UIColor *)systemBlueColor;

@end