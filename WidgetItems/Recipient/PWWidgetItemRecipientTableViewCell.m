//
//  ProWidgets
//  Google Authenticator
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemRecipientTableViewCell.h"
#import "../../PWController.h"
#import "../../PWTheme.h"

char PWWidgetItemRecipientTableViewCellRecipientKey;

@implementation PWWidgetItemRecipientTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		self.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
		
		_showingRemoveButton = NO;
		[self _configureAddButton];
		/*
		// separator
		_separator = [UIView new];
		[self.contentView addSubview:_separator];
		
		// title label
		_titleLabel = [UILabel new];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
		[self.contentView addSubview:_titleLabel];
		
		// location label
		_locationLabel = [UILabel new];
		_locationLabel.backgroundColor = [UIColor clearColor];
		_locationLabel.font = [UIFont systemFontOfSize:14.0];
		[self.contentView addSubview:_locationLabel];
		
		// start time label
		_startTimeLabel = [UILabel new];
		_startTimeLabel.textAlignment = NSTextAlignmentRight;
		_startTimeLabel.backgroundColor = [UIColor clearColor];
		_startTimeLabel.font = [UIFont systemFontOfSize:13.0];
		[self.contentView addSubview:_startTimeLabel];
		
		// end time label
		_endTimeLabel = [UILabel new];
		_endTimeLabel.textAlignment = NSTextAlignmentRight;
		_endTimeLabel.backgroundColor = [UIColor clearColor];
		_endTimeLabel.font = [UIFont systemFontOfSize:13.0];
		[self.contentView addSubview:_endTimeLabel];*/
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	/*
	CGSize size = self.bounds.size;
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat horizontalPadding = 8.0;
	
	CGFloat separatorWidth = 2.0;
	CGFloat timeWidth = 60.0;
	
	CGFloat labelHeight = 22.0;
	CGFloat contentHeight = labelHeight * 2;
	CGFloat top = (height - contentHeight) / 2;
	
	CGRect separatorRect = CGRectMake(horizontalPadding * 2 + timeWidth, 0, separatorWidth, height);
	
	CGRect startTimeRect = CGRectMake(horizontalPadding, top, timeWidth, labelHeight);
	CGRect endTimeRect = startTimeRect;
	endTimeRect.origin.y += labelHeight;
	
	CGRect titleRect = CGRectMake(horizontalPadding * 3 + timeWidth + separatorWidth, top, 0.0, labelHeight);
	titleRect.size.width = width - titleRect.origin.x - horizontalPadding;
	
	CGRect locationRect = CGRectMake(horizontalPadding * 3 + timeWidth + separatorWidth, top + labelHeight, 0.0, labelHeight);
	locationRect.size.width = width - locationRect.origin.x - horizontalPadding;
	
	_separator.frame = separatorRect;
	_titleLabel.frame = titleRect;
	_locationLabel.frame = locationRect;
	_startTimeLabel.frame = startTimeRect;
	_endTimeLabel.frame = endTimeRect;*/
}

/*- (MFComposeRecipient *)buttonRecipient {
	UIButton *button = (UIButton *)self.accessoryView;
	if (button != nil) {
		return objc_getAssociatedObject(button, &PWWidgetItemRecipientTableViewCellRecipientKey);
	}
	return nil;
}*/

- (void)setButtonRecipient:(MFComposeRecipient *)recipient {
	UIButton *button = (UIButton *)self.accessoryView;
	if (button != nil) {
		objc_setAssociatedObject(button, &PWWidgetItemRecipientTableViewCellRecipientKey, recipient, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
}

- (void)setButtonTarget:(id)target action:(SEL)action {
	UIButton *button = (UIButton *)self.accessoryView;
	LOG(@"setButtonTarget:%@ <button: %@>", target, button);
	if (button != nil) {
		[button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
		[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)setTitleTextColor:(UIColor *)color {
	
	UIColor *detailTextColor = [PWTheme lightenColor:color];
	
	self.textLabel.textColor = color;
	self.detailTextLabel.textColor = detailTextColor;
}

- (void)setSelectedTitleTextColor:(UIColor *)color {
	
	UIColor *detailTextColor = [PWTheme lightenColor:color];
	
	self.textLabel.highlightedTextColor = color;
	self.detailTextLabel.highlightedTextColor = detailTextColor;
}

- (void)setValueTextColor:(UIColor *)color {}

- (void)setName:(NSString *)title {
	self.textLabel.text = title;
}

- (void)setType:(NSString *)type address:(NSString *)address {
	
	CGFloat fontSize = 14.0;
	UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
	UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
	UIColor *detailTextColor = self.detailTextLabel.textColor;
	if (detailTextColor == nil) detailTextColor = [UIColor blackColor];
	
	NSDictionary *attrs = @{ NSFontAttributeName: regularFont };
	NSDictionary *boldAttrs = @{ NSFontAttributeName: boldFont };
	
	NSString *text = [NSString stringWithFormat:@"%@%@%@", type, ([type length] == 0 ? @"" : @" "), address];
	NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:attrs];
	
	if ([type length] > 0) {
		[attributedText setAttributes:boldAttrs range:NSMakeRange(0, [type length])];
	}
	
	[self.detailTextLabel setAttributedText:attributedText];
	[attributedText release];
}

- (void)setShowingRemoveButton:(BOOL)showing {
	if (_showingRemoveButton != showing) {
		
		if (showing) {
			[self _configureRemoveButton];
		} else {
			[self _configureAddButton];
		}
		
		_showingRemoveButton = showing;
	}
}

- (void)_configureAddButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
	button.userInteractionEnabled = NO;
	self.accessoryView = button;
}

- (void)_configureRemoveButton {
	UIImage *image = [[PWController sharedInstance] imageResourceNamed:@"recipientRemoveButton"];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, 44.0, 44.0); // fixed size
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
	button.userInteractionEnabled = YES;
	[button setImage:image forState:UIControlStateNormal];
	self.accessoryView = button;
}

- (void)dealloc {
	
	UIButton *button = (UIButton *)self.accessoryView;
	if (button != nil) {
		[button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
	}
	
	[super dealloc];
}

@end