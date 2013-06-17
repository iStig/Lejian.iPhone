//
//  NavigationController.m
//  ChatClient
//
//  Created by Zhang Liang on 6/15/11.
//  Copyright 2011 QiHoo. All rights reserved.
//

#import "NavigationController.h"
#import "SettingViewController.h"

#define NAV_BAR_HEIGHT  44.0
#define NAV_BAR_FRAME   CGRectMake(0.0, 20.0, 320.0, NAV_BAR_HEIGHT)

@interface NavigationController ()

- (void)presentSettingPage:(UIButton *)aButton;

@end

@implementation NavigationController

@synthesize navDelegate     = _navDelegate;
@synthesize presented       = _presented;

#pragma mark - View lifecycle

- (id)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if(self){
//        self.delegate = self;
    }
    return self;
}

//liubin modify, camera take photo cause memory warning, cause viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    CustomNavigationBar *navBar = [[CustomNavigationBar alloc] initWithFrame:NAV_BAR_FRAME];
    navBar.navigationController = self;
    self.navigationBar.userInteractionEnabled = NO;
    self.navigationBar.alpha = 0.0001;
    [self.view addSubview:navBar];
    navBar.showBackButtonItem = NO;
    _navBar = navBar;
    [navBar release];  
    _leftButton = nil;
    _rightButton = nil;
    [self setDefaultLeftSettingButton];
}

- (void)setTitleLogoHiden:(BOOL)hide
{
    [[self realNavigationBar] setTitleLogoHiden:hide];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma -
#pragma Overrides

- (CustomNavigationBar *)realNavigationBar
{
    return _navBar;
}


- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated 
{
    [super setNavigationBarHidden:hidden animated:animated];
    if(animated){
        CGRect frame = _navBar.frame;
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationDuration:UINavigationControllerHideShowBarDuration];
        if(hidden){
            frame.origin.y = -frame.size.height;
        }else{
            frame.origin.y = 20.0;
        }
        _navBar.frame = frame;
        [UIView commitAnimations];
    } else {
        CGRect frame = _navBar.frame;
        if(hidden){
            frame.origin.y = -frame.size.height;
        }else{
            frame.origin.y = 20.0;
        }
        _navBar.frame = frame;
    }
    [self.view bringSubviewToFront:_navBar];
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    [viewController setHidesBottomBarWhenPushed:YES];
    [super pushViewController:viewController animated:animated];
//    [self setTitle:viewController.title];
    if ([[self viewControllers] count] > 1) {
        [_navBar setShowBackButtonItem:YES];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    // Fix bug 26157, 26180 - supeng
    [self.view setExclusiveTouch:YES];
    
    NSArray *vcs = [self viewControllers];
    UIViewController *prevVc = nil;
    if ( [vcs count] > 1 ) {
        prevVc = [vcs objectAtIndex:([vcs count] - 2)];
        if ([vcs count] == 2 && NO == _presented) {
            [_navBar setHideBackButtonItemAnimated:YES];
        }
    }
    
    UIViewController *controller = [super popViewControllerAnimated:animated];
    if (prevVc) {
//        [_navBar setTitle:prevVc.title];
    }
    return controller;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    UIViewController *rootVc = [[self viewControllers] objectAtIndex:0];
    if (NO == _presented) {
        [_navBar setHideBackButtonItemAnimated:YES];
    }
    NSArray *controllers = [super popToRootViewControllerAnimated:animated];
    if (rootVc) {
        [_navBar setTitle:rootVc.title];
    }
    return controllers;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSInteger vcIndex = [[self viewControllers] indexOfObject:viewController];
    if (vcIndex == 0 && NO == _presented) {
        [_navBar setHideBackButtonItemAnimated:YES];
    }
    NSArray *controllers = [super popToViewController:viewController animated:animated];
    [_navBar setTitle:viewController.title];
    return controllers;
}

- (UIButton *)leftButton
{
    return _leftButton;
}

- (void)setLeftButton:(id)_button animated:(BOOL)animated
{
    if (_leftButton && !_button && animated) {
        [UIView beginAnimations:@"1" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:0.3f];
        _leftButton.alpha = 0.0;
        [UIView commitAnimations];
        return;
    }
    if (_leftButton) {
        if(_leftButton == _button) {
            return;
        }
        [_leftButton removeFromSuperview];
        _leftButton = nil;
    }
    if (_button){
        _leftButton = _button;
        CGRect frame = _leftButton.frame;
        CGPoint center = CGPointMake(16.0+frame.size.width/2, NAV_BAR_HEIGHT/2);
        _leftButton.center = center;
        [_navBar addSubview:_leftButton];
        if (animated) {
            _leftButton.alpha = 0.0;
            [UIView beginAnimations:@"" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];            
            [UIView setAnimationDuration:0.3f];
            _leftButton.alpha = 1.0;
            [UIView commitAnimations];
        }
    }
}

- (UIButton *)rightButton
{
    return _rightButton;
}
//a button with any origin
- (void)setRightButton:(id)_button animated:(BOOL)animated
{
    if (_rightButton && !_button) {
        if (animated) {
            [UIView beginAnimations:@"0" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
            [UIView setAnimationDuration:0.3f];
            _rightButton.alpha = 0.0;
            [UIView commitAnimations];
        } else {
            [_rightButton removeFromSuperview];
            _rightButton = nil;
        }
         return;
    }
    if (_rightButton) {
        if (_rightButton == _button) {
            return;
        }
        [_rightButton removeFromSuperview];
        _rightButton = nil;
    }
    if (_button) {
        _rightButton = _button;
        CGRect frame = _rightButton.frame;
        // Fix bug 26206
        CGPoint center = CGPointMake(_navBar.frame.size.width - frame.size.width/2 - 15.0, NAV_BAR_HEIGHT/2.0);
        _rightButton.center = center;
        [_navBar addSubview:_rightButton];
        if (animated) {
            _rightButton.alpha = 0.0;
            [UIView beginAnimations:@"" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];            
            [UIView setAnimationDuration:0.3f];
            _rightButton.alpha = 1.0;
            [UIView commitAnimations];
        }
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID compare:@"1"] == NSOrderedSame) {
        [_leftButton removeFromSuperview];
        _leftButton = nil;
    } else if([animationID compare:@"0"] == NSOrderedSame) {
        [_rightButton removeFromSuperview];
        _rightButton = nil;
    }
}

#pragma -
- (void)setTitle:(NSString *)title
{
    [[self realNavigationBar] setTitle:title];
}

//- (void)setTitleImageNamed:(NSString *)name {
//    [[self realNavigationBar] setTitleImageNamed:name];
//}

- (void)setLeftButtonTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIFont *font = [UIFont systemFontOfSize:13];
    CGSize size = [title sizeWithFont:font];
    CGFloat margin = 8.0;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, size.width + margin*2, 31.0);
    UIImage *back = [[UIImage imageNamed:@"setting_back_normal.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
    [button setImage:back forState:UIControlStateNormal];
    back = [[UIImage imageNamed:@"setting_back_click.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
    [button setImage:back forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button setTitleShadowColor:[UIColor colorWithRed:0.24 green:0.40 blue:0.14 alpha:1.0] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [self setLeftButton:button animated:YES];
}

- (void)onBackButton:(UIButton *)btn 
{
    [self popViewControllerAnimated:YES];
}

-(void)setDefaultLeftSettingButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 1.0, 41.0, 41.0)];
    UIImage *settingImageNormal = [UIImage imageNamed:@"Settings_01.png"];
    [button setImage:settingImageNormal forState:UIControlStateNormal];
    UIImage *settingImageHighlight = [UIImage imageNamed:@"Settings_02.png"];
    [button setImage:settingImageHighlight forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(presentSettingPage:) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftButton:button animated:NO];
}

- (void)setDefaultRightSettingButton 
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 1.0, 41.0, 41.0)];
    UIImage *settingImageNormal = [UIImage imageNamed:@"Settings_01.png"];
    [button setImage:settingImageNormal forState:UIControlStateNormal];
    UIImage *settingImageHighlight = [UIImage imageNamed:@"Settings_02.png"];
    [button setImage:settingImageHighlight forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(presentSettingPage:) forControlEvents:UIControlEventTouchUpInside];
    [self setRightButton:button animated:NO];
}

- (void)setLeftBackButton
{
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
    [back setImage:[UIImage imageNamed:@"back_01.png"] forState:UIControlStateNormal];
    [back setImage:[UIImage imageNamed:@"back_02.png"] forState:UIControlStateHighlighted];
    [back addTarget:self action:@selector(onBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftButton:back animated:NO];
    [back release];
}

- (void)setRightButtonTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIFont *font = [UIFont boldSystemFontOfSize:13];
    CGSize size = [title sizeWithFont:font];
    CGFloat margin = 8.0;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, size.width + margin*2, 31.0);
    UIImage *back = [[UIImage imageNamed:@"topbar_button_r.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
    [button setImage:back forState:UIControlStateNormal];
    back = [[UIImage imageNamed:@"topbar_button_r_click.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
    [button setImage:back forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button setTitleShadowColor:[UIColor colorWithRed:0.24 green:0.40 blue:0.14 alpha:1.0] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [self setRightButton:button animated:NO];
}

- (void)setShowBackButtonItemAnimated:(BOOL)animated
{
    [_navBar setShowBackButtonItemAnimated:animated];
}
- (void)setHideBackButtonItemAnimated:(BOOL)animated
{
    [_navBar setHideBackButtonItemAnimated:animated];
}

- (void)presentSettingPage:(UIButton *)aButton
{
    SettingViewController *settingController = [[SettingViewController alloc] init];
    [self pushViewController:settingController animated:YES];
    [settingController release];
}

- (void)dealloc
{
    [super dealloc];
}

@end


#undef NAV_BAR_FRAME