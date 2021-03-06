//
//  ProWidgets
//  Substrate (mainly to inject the library into SpringBoard)
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

#import "PWWidgetPickerCell.h"
#import "PWTheme.h"
#import "PWThemableTableViewCell.h"

#import "PWController.h"
#import "PWWidgetController.h"
#import "PWWindow.h"
#import "PWWebRequest.h"

#import "preference/PWPrefURLInstallation.h"

#define IS_PROWIDGETS(x) [[x scheme] isEqualToString:@"prowidgets"]

extern CFNotificationCenterRef CFNotificationCenterGetDistributedCenter();

static void handleException(NSException *exception) {
	NSArray *symbols = [exception callStackSymbols];
	NSLog(@"***** Uncaught Exception: %@ *****", [exception description]);
	unsigned i = 0;
	for (i = 0; i < [symbols count]; i++) {
		NSLog(@"***** %@", (NSString *)[symbols objectAtIndex:i]);
	}
}

@interface UITextEffectsWindow : UIWindow
@end

%group SpringBoard

%hook UITextEffectsWindow

// this is to fix the too low window level (10.0) for web views
- (void)setWindowLevel:(CGFloat)windowLevel {
	if ([PWWidgetController isPresentingMaximizedWidget]) {
		%orig(2100.0);
	} else {
		%orig;
	}
}

%end

%hook SBBacklightController

- (void)_lockScreenDimTimerFired {
	if ([PWController sharedInstance]._showingWelcomeScreen || [PWWidgetController isLocked]) {
		[self resetLockScreenIdleTimer];
	} else {
		%orig;
	}
}

%end
/*
%hook SBPanGestureRecognizer

- (id)init {
	self = %orig;
	LOG(@"===== SBPanGestureRecognizer: %@ <%p>", self, self);
	return self;
}

- (void)updateForBeganOrMovedTouches:(void *)context {
	%log;
	LOG(@"===== updateForBeganOrMovedTouches: %@ <%p>", self, self);
	%orig;
}

%end
*/
%hook SBNotificationCenterController

- (void)beginPresentationWithTouchLocation:(CGPoint)touchLocation {
	
	LOG(@"beginPresentationWithTouchLocation: %f, %f", touchLocation.x, touchLocation.y);
	
	if ([PWWidgetController isDragging] || [PWWidgetController shouldDisableNotificationCenterPresentation])
		return;
	
	if ([PWController shouldMinimizeAllControllersAutomatically] && [PWWidgetController isPresentingMaximizedWidget])
		[PWWidgetController minimizeAllControllers];
	
	%orig;
}

%end

%hook SBControlCenterController

- (void)beginTransitionWithTouchLocation:(CGPoint)touchLocation {
	
	if ([PWWidgetController isDragging])
		return;
	
	if ([PWController shouldMinimizeAllControllersAutomatically] && [PWWidgetController isPresentingMaximizedWidget])
		[PWWidgetController minimizeAllControllers];
	
	%orig;
}

%end

%hook SBUIController

- (void)finishLaunching {
	%orig;
	[[PWController sharedInstance] _firstTimeShowWelcomeScreen];
}

%end

%hook SpringBoard

// this is to correct the interface orientation in my own window
- (UIInterfaceOrientation)_statusBarOrientationForWindow:(UIWindow *)window {
	if ([window isKindOfClass:[PWWindow class]]) {
		return [PWController currentInterfaceOrientation];
	} else {
		return %orig;
	}
}

- (void)_handleMenuButtonEvent {
	LOG(@"PWSubstrate: _handleMenuButtonEvent");
	NSTimer *menuButtonTimer = *(NSTimer **)instanceVar(self, "_menuButtonTimer");
	if (menuButtonTimer == nil) {
		PWWidgetController *activeController = [PWWidgetController activeController];
		if (activeController != nil && [activeController dismiss]) {
			// reset menuButtonClickCount
			Ivar ivar = class_getInstanceVariable([self class], "_menuButtonClickCount");
			uintptr_t *_menuButtonClickCount = (uintptr_t *)((char *)self + ivar_getOffset(ivar));
			*_menuButtonClickCount = 0;
			return;
		}
	}
	
	%orig;
}

- (void)handleMenuDoubleTap {
	if ([PWWidgetController isPresentingMaximizedWidget]) {
		[PWWidgetController minimizeAllControllers];
	} else {
		%orig;
	}
}

- (void)applicationDidFinishLaunching:(id)application {
	
	LOG(@"PWSubstrate: Initializing PWController");
	
	PWController *instance = [PWController sharedInstance];
	
	// configure PWController
	[instance configure];
	
	// add observer
	[self addActiveOrientationObserver:instance];

	return %orig;
}

static inline BOOL handleSBOpenURL(NSURL *url) {
    
    if (IS_PROWIDGETS(url)) {
		
		NSString *callURL = [url absoluteString];
		
		LOG(@"PWSubstrate: Received open URL notification (%@).", callURL);
		
		if (callURL != nil && [callURL length] > 0) {
			
			if ([callURL hasPrefix:@"prowidgets://present?name="]) {
				
				NSString *widgetName = [callURL substringFromIndex:[@"prowidgets://present?name=" length]];
				widgetName = [PWWebRequest decodeURIComponent:widgetName];
				
				if (widgetName != nil && [widgetName length] > 0) {
					NSDictionary *userInfo = @{ @"from": @"url" };
					[PWWidgetController presentWidgetNamed:widgetName userInfo:userInfo];
				}
				
			} else if ([callURL hasPrefix:@"prowidgets://install/"]) {
				
				NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^prowidgets://install/(widget|theme)\\?url=(.+)$"
																					   options:0
																						 error:nil];
				
				NSTextCheckingResult *match = [regex firstMatchInString:callURL
																options:0
																  range:NSMakeRange(0, [callURL length])];
				
				if (match == nil) return YES;
				
				NSString *installType = nil;
				NSString *installURL = nil;
				for (unsigned int i = 0; i < [match numberOfRanges] - 1; i++) {
					
					NSRange range = [match rangeAtIndex:i + 1];
					if (range.location == NSNotFound) continue;
					
					NSString *part = [callURL substringWithRange:range];
					
					if (i == 0) {
						installType = part;
					} else if (i == 1) {
						installURL = [PWWebRequest decodeURIComponent:part];
					}
				}
				
				if (installType != nil && installURL != nil && [installURL length] > 0) {
					NSString *constructedURL = [NSString stringWithFormat:@"prefs:root=cc.tweak.prowidgets&install=%@&url=%@", installType, installURL];
					LOG(@"PWSubstrate: Opening '%@'", constructedURL);
					[PWWidgetController minimizeAllControllers];
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:constructedURL]];
				}
			}
		}
        
        return YES;
        
	} else {
        
		// minimize all controllers when a URL is being opened
		[PWWidgetController minimizeAllControllers];
        
        return NO;
    }
}

// 7.0
//- (void)_applicationOpenURL:(NSURL *)url withApplication:(id)application sender:(id)sender publicURLsOnly:(BOOL)only animating:(BOOL)animating additionalActivationFlags:(id)flags activationHandler:(id)handler {
- (void)_openURLCore:(NSURL *)url display:(id)display animating:(BOOL)animating sender:(id)sender additionalActivationFlags:(id)flags activationHandler:(id)handler {
    if (!handleSBOpenURL(url)) {
        %orig;
    }
}

// 7.1
//- (void)_applicationOpenURL:(NSURL *)url withApplication:(id)application sender:(id)sender publicURLsOnly:(BOOL)only animating:(BOOL)animating activationContext:(id)context activationHandler:(id)handler {
- (void)_openURLCore:(NSURL *)url display:(id)display animating:(BOOL)animating sender:(id)sender activationContext:(id)context activationHandler:(id)handler {
    if (!handleSBOpenURL(url)) {
        %orig;
    }
}

%end

extern char PWWidgetItemTonePickerControllerThemeKey;

@interface UITableViewCell ()

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)style;

@end

%hook TKToneTableController

- (void)_configureTextColorOfLabelInCell:(UITableViewCell *)cell checked:(BOOL)checked {
	%orig;
	if (cell != nil && [cell isKindOfClass:[PWThemableTableViewCell class]]) {
		PWTheme *theme = (PWTheme *)objc_getAssociatedObject(self, &PWWidgetItemTonePickerControllerThemeKey);
		if (theme != NULL) {
			[(PWThemableTableViewCell *)cell setTheme:theme];
		}
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	%orig;
	if (cell != nil) {
		
		PWTheme *theme = (PWTheme *)objc_getAssociatedObject(self, &PWWidgetItemTonePickerControllerThemeKey);
		
		if ([cell isKindOfClass:[PWThemableTableViewCell class]]) {
			cell.separatorStyle = UITableViewCellSeparatorStyleNone;
		} else if ([cell isKindOfClass:objc_getClass("TLDividerTableViewCell")]) {
			UIColor *dividerColor = [theme cellHeaderFooterViewBackgroundColor];
			TLDividerTableViewCell *divider = (TLDividerTableViewCell *)cell;
			[divider setContentBackgroundColor:dividerColor];
			[divider setContentFillColor:dividerColor];
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = %orig;
	if (cell != nil) {
		if ([cell isKindOfClass:[PWThemableTableViewCell class]]) {
			PWTheme *theme = (PWTheme *)objc_getAssociatedObject(self, &PWWidgetItemTonePickerControllerThemeKey);
			if (theme != NULL) {
				[(PWThemableTableViewCell *)cell setTheme:theme];
			}
		}
	}
	return cell;
}

%end

%end

%group Preferences

/*
%hook TKTonePicker

- (id)initWithFrame:(CGRect)arg1 avController:(id)arg2 filter:(unsigned int)arg3 tonePicker:(BOOL)arg4 {
	LOG(@"### TKTonePicker ### filter: %d, tonePicker: %@", (int)arg3, arg4 ? @"YES" : @"NO");
	return %orig;
}

%end
*/

%hook PreferencesAppController

- (void)applicationOpenURL:(NSURL *)url {
	
	%orig;
	
	NSString *string = [url absoluteString];
	if ([string hasPrefix:@"prefs:root=cc.tweak.prowidgets"]) {
		
		BOOL installWidget = [string rangeOfString:@"&install=widget&"].location != NSNotFound;
		BOOL installTheme = !installWidget && [string rangeOfString:@"&install=theme&"].location != NSNotFound;
		
		if (installWidget || installTheme) {
			
			// locate the position of url parameter
			NSUInteger urlIndex = [string rangeOfString:@"&url="].location;
			if (urlIndex == NSNotFound) return;
			
			// extract the installation URL
			NSString *urlString = [string substringFromIndex:urlIndex + 5];
			
			if ([urlString length] > 0) {
				
				// create installation URL
				NSURL *installURL = [NSURL URLWithString:urlString];
				
				// retrieve root view controller
				UIViewController *rootViewController = [[UIApplication sharedApplication].keyWindow rootViewController];
				
				// create installation view controller
				PWPrefURLInstallation *controller = [[[objc_getClass("PWPrefURLInstallation") alloc] initWithURL:installURL type:(installWidget ? PWPrefURLInstallationTypeWidget : PWPrefURLInstallationTypeTheme) fromPreference:NO] autorelease];
				
				// present it
				[rootViewController presentViewController:controller animated:NO completion:nil];
			}
		}
	}
}

%end

#define CellClass PWWidgetPickerCell
#define CellTypeString @"PWWidgetPickerCell"
#define DetailString @"PWWidgetPicker"

%hook PSTableCell

+ (Class)cellClassForSpecifier:(PSSpecifier *)specifier {
	NSString *cell = [specifier propertyForKey:@"cell"];
	if ([cell isEqualToString:CellTypeString]) {
		return [PWWidgetPickerCell class];
	} else {
		return %orig;
	}
}

+ (NSString *)reuseIdentifierForSpecifier:(PSSpecifier *)specifier {
	NSString *cell = [specifier propertyForKey:@"cell"];
	if ([cell isEqualToString:CellTypeString]) {
		return CellTypeString;
	} else {
		return %orig;
	}
}

+ (int)cellTypeFromString:(NSString *)string {
	if ([string isEqualToString:CellTypeString]) {
		return 2;
	} else {
		return %orig;
	}
}

%end

@interface PSSpecifier ()

- (void)_pw_prepareWidgetInfo;

@end

static char PWPreparedWidgetInfoKey;

#define PREPARE NSNumber *o = objc_getAssociatedObject(self, &PWPreparedWidgetInfoKey); if (o == NULL || o == nil || ![o boolValue]) [self _pw_prepareWidgetInfo];
#define SET_PREPARED objc_setAssociatedObject(self, &PWPreparedWidgetInfoKey, @(1), OBJC_ASSOCIATION_COPY_NONATOMIC);

%hook PSSpecifier

- (NSArray *)titleDictionary {
	PREPARE;
	return %orig;
}

- (NSArray *)values {
	PREPARE;
	return %orig;
}

%new
- (void)_pw_prepareWidgetInfo {
	NSString *cell = [self propertyForKey:@"cell"];
	if ([cell isEqualToString:CellTypeString]) {
		
		NSMutableArray *titles = [NSMutableArray array];
		NSMutableArray *values = [NSMutableArray array];
		
		// PWShowNone
		NSNumber *_showNone = [self propertyForKey:@"PWShowNone"];
		BOOL showNone = _showNone == nil || ![_showNone isKindOfClass:[NSNumber class]] ? YES : [_showNone boolValue];
		
		if (showNone) {
			[titles addObject:@"None"];
			[values addObject:@""];
		}
		
		// retrieve widget list
		NSArray *list = [[PWController sharedInstance] enabledWidgets];
		for (NSDictionary *widget in list) {
			NSString *name = widget[@"name"];
			NSString *displayName = widget[@"displayName"];
			[titles addObject:displayName];
			[values addObject:name];
		}
		
		[self setValues:values titles:titles shortTitles:nil usingLocalizedTitleSorting:NO];
	}
	SET_PREPARED;
}

%end

%end
/*
CFTypeRef SecTaskCopyValueForEntitlement(void *task, CFStringRef entitlement, CFErrorRef *error);

static CFTypeRef (*orig_SecTaskCopyValueForEntitlement)(void *task, CFStringRef entitlement, CFErrorRef *error);

static CFTypeRef replaced_SecTaskCopyValueForEntitlement(void *task, CFStringRef entitlement, CFErrorRef *error) {
    NSLog(@"SecTaskCopyValueForEntitlement: %@", (NSString *)entitlement);
    return orig_SecTaskCopyValueForEntitlement(task, entitlement, error);
}
*/
static inline __attribute__((constructor)) void init() {
	@autoreleasepool {
        
        //MSHookFunction((void **)SecTaskCopyValueForEntitlement, replaced_SecTaskCopyValueForEntitlement, (void **)*orig_SecTaskCopyValueForEntitlement);
        
		NSSetUncaughtExceptionHandler(&handleException);
		if (objc_getClass("SpringBoard") != nil) {
			%init(SpringBoard);
		} else if (objc_getClass("PreferencesAppController") != nil) {
			%init(Preferences);
		}
	}
}