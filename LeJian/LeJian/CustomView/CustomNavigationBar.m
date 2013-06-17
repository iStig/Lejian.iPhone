//
//  CustomNavigationBar.m
//  SystemExpert
//
//  Created by Ray Zhang  on 11-8-9.
//  Copyright 2011 QIHOO. All rights reserved.
//

#import "CustomNavigationBar.h"
#import <QuartzCore/QuartzCore.h>
#import "NavigationController.h"
//#import "SysUtils.h"

enum {
    NavigationLogoImageViewTag = 10000,
    NavigationTitleImageViewTag
};

@interface CustomNavigationBar ()

@property (nonatomic, retain)   UIButton                *backButton;
@property (nonatomic, retain)   UILabel                 *titleLabel;
@property (nonatomic, retain)   UIView                  *titleView;
@property (nonatomic, retain)   UIImageView             *titleLogo;
//UIView                  *_titleView;


@end

#define SPACE_BETWEEN_LOGO_AND_TITLE_WIDTH              6

//@implementation UINavigationBar (CustomStyle)
//
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code.
//	UIImage *image = [UIImage imageNamed:@"topbar"];
//	[image drawInRect:self.bounds];
//}
//
//- (void)willMoveToWindow:(UIWindow *)newWindow{
//	[super willMoveToWindow:newWindow];
//	[self applyDefaultStyle];
//}
//
//- (void)applyDefaultStyle {
//	// add the drop shadow
//	if (![[[UIDevice currentDevice] systemVersion] hasPrefix:@"3."]) {
//		self.layer.shadowColor = [[UIColor blackColor] CGColor];
//		self.layer.shadowOffset = CGSizeMake(0.0, 4.0);
//		self.layer.shadowOpacity = 0.25;
//		self.layer.masksToBounds = NO;
//		self.layer.shouldRasterize = YES;
//	}
//}
//
//@end


@implementation CustomNavigationBar

@synthesize navigationController    = _navigationController;
@synthesize backButton              = _backButton;
@synthesize titleLabel              = _titleLabel;
@synthesize showBackButtonItem      = _showBackButtonItem;
@synthesize titleView               = _titleView;
@synthesize titleLogo               = _titleLogo;

- (void)applyDefaultStyle 
{
	// add the drop shadow
	if ([[[UIDevice currentDevice] systemVersion] floatValue] > 3.1) {
		self.layer.shadowColor = [[UIColor blueColor] CGColor];
		self.layer.shadowOffset = CGSizeMake(0.0, 4.0);
		self.layer.shadowOpacity = 0.25;
		self.layer.masksToBounds = NO;
		self.layer.shouldRasterize = YES;
	}
}


- (void)dealloc 
{
    [_backButton release];
    [_titleView release];
    [_titleLabel release];
    [_titleLogo release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.userInteractionEnabled = NO;
		UIImage *bgImage = [UIImage imageNamed:@"nav_bg.png"];
		self.image = bgImage;
        
        //FIXEME: TOP BG 
        self.backgroundColor = [UIColor clearColor];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 62, 44)];
        
//        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"nav_back_normal"] forState:UIControlStateNormal];
        [backButton setImage:[UIImage imageNamed:@"nav_back_click"] forState:UIControlStateHighlighted];
        [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//        [backButton sizeToFit];
//        backButton.frame = CGRectOffset(backButton.frame, 23.0, 6.0);
        self.backButton = backButton;
        [self addSubview:backButton];
        [backButton release];
        
        // Title view
        _titleView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_titleView];
        
        _titleLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 99, 37)];
        _titleLogo.center = CGPointMake(160, 24);
        _titleLogo.image = [UIImage imageNamed:@"logo01.png"];
//        [_titleView addSubview:_titleLogo];
        [self addSubview:_titleLogo];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 1.0, 160.0, 42.0)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _titleLabel.shadowColor = [UIColor colorWithRed:0.24 green:0.40 blue:0.14 alpha:1.0];
        _titleLabel.shadowOffset = CGSizeMake(0, -1);
        [_titleView addSubview:_titleLabel];
        
        self.userInteractionEnabled = YES;
//        [self applyDefaultStyle];
    }
    return self;
}
- (void)setTitleLogoHiden:(BOOL)hide
{
    _titleLogo.hidden = hide;
}

- (void)back:(id)sender
{
    if ([_navigationController isKindOfClass:[NavigationController class]]) {
        NavigationController *navController = (NavigationController *)_navigationController;
        if (navController.presented) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
                if ([[navController viewControllers] count] > 1) {
                    [navController popViewControllerAnimated:YES];
                } else if (navController.parentViewController) {
                    [navController.parentViewController dismissModalViewControllerAnimated:YES];
                }
            }  else {
                if ([[navController viewControllers] count] > 1) {
                    [navController popViewControllerAnimated:YES];
                } else if (navController.presentingViewController) {
                    [navController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                }
            }
        } else {
            [_navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)setShowBackButtonItem:(BOOL)showBackButtonItem
{
    _showBackButtonItem = showBackButtonItem;
    _backButton.alpha = _showBackButtonItem ? 1.0 : 0.0;
}

- (void)setShowBackButtonItemAnimated:(BOOL)animated
{
    if(!animated) {
        self.showBackButtonItem = YES;
    } else {
        if(!_showBackButtonItem){
            [UIView beginAnimations:@"" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.3f];
            _backButton.alpha = 1.0;
            [UIView commitAnimations];
        }
        _showBackButtonItem = YES;
    }
}

- (void)setHideBackButtonItemAnimated:(BOOL)animated
{
    if (!animated) {
        self.showBackButtonItem = NO;
    } else {
        if (_showBackButtonItem) {
            [UIView beginAnimations:@"" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.3f];
            _backButton.alpha = 0.0;
            [UIView commitAnimations];
        }
        _showBackButtonItem = NO;
    }
}

- (void)setTitle:(NSString *)title
{
//    CGSize titleSize = [title sizeWithFont:_titleLabel.font];
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
//    _titleLogo.frame = CGRectMake(0, 0, 99, 37);
//    _titleLogo.frame = CGRectZero;
    CGFloat width =  _titleLabel.frame.size.width + 5;
    CGFloat height = _titleLabel.frame.size.height;
//    _titleLogo.frame = CGRectMake(0, (height - _titleLogo.frame.size.height) / 2, _titleLogo.frame.size.width, _titleLogo.frame.size.height);
    _titleLabel.frame = CGRectMake(5, (height - _titleLabel.frame.size.height) / 2, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    _titleView.frame = CGRectMake(0, 0, width, height);
    _titleView.center = CGPointMake(160, 22);
    [self setNeedsLayout];
}

//- (void)setTitleImageNamed:(NSString *)name {
////    _imgvTitle.image = imgTitle;
//    UIImageView *titleView = (UIImageView *)[_titleView viewWithTag:NavigationTitleImageViewTag];
//    titleView.hidden = NO;
//    titleView.image = [UIImage imageNamed:name];
//    [titleView sizeToFit];
//    CGFloat totalWidth = _titleView.frame.size.width;
//    CGFloat totalHeihgt = _titleView.frame.size.height;
//    CGFloat titleWidth = titleView.frame.size.width;
//    CGFloat titleHeigh = titleView.frame.size.height;
//    
//    UIImageView *logoView = (UIImageView *)[_titleView viewWithTag:NavigationLogoImageViewTag];
//    logoView.hidden = NO;
//    CGFloat logoWidth = logoView.frame.size.width;
//    CGFloat logoHeight = logoView.frame.size.height;
//    
//    CGFloat logoOriginX = (totalWidth - titleWidth - logoWidth - SPACE_BETWEEN_LOGO_AND_TITLE_WIDTH) / 2;
//    CGFloat titleOrigiX = 0;
//    if (titleWidth < totalWidth) {
//        titleOrigiX = logoOriginX + logoWidth + SPACE_BETWEEN_LOGO_AND_TITLE_WIDTH;
//    } else {
//        titleOrigiX = SPACE_BETWEEN_LOGO_AND_TITLE_WIDTH;
//    }
//    CGFloat logoOriginY = (totalHeihgt - logoHeight) / 2;
//    CGFloat titleOriginY = (totalHeihgt - titleHeigh) / 2;
//    
//    logoView.frame = CGRectMake(logoOriginX, logoOriginY, logoWidth, logoHeight);
//    titleView.frame = CGRectMake(titleOrigiX, titleOriginY, titleWidth, titleHeigh);
//}
@end
