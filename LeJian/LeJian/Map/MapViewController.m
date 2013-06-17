//
//  MapViewController.m
//  QubaoMedicalCare
//
//  Created by  on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "LeJianDatabase.h"

@interface MapViewController()
{
    UISearchBar *_searchBar;
    UIButton    *_backButton;
    
    UIView      *_busyView;
    
    UIButton    *_luxianButton;
    UIButton    *_btnHideKeyBoard;
}
- (void)btnForwardClick;
- (void)btnBackwardClick;

@end
@implementation MapViewController
@synthesize arrayAddress;
@synthesize delegate = _delegate;
@synthesize dictMapLocation = _dictMapLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        arrayAddress = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)addMap
{
    _mapVC = [[GoogleMapViewController alloc] init];
    _mapVC.strLatitude = [_dictMapLocation objectForKey:kMapXKey];
    _mapVC.strLongitude = [_dictMapLocation objectForKey:kMapYKey];
    _mapVC.strAddress = [_dictMapLocation objectForKey:kMapNameKey];
    _mapVC.mapViewFrame = CGRectMake(0, 0,320,416);
    _mapVC.delegate = self;
    _mapVC.nav = self.navigationController;
    [self.view addSubview:_mapVC.view];
}

#pragma mark - View lifecycle

- (void)dealloc
{
    _searchBar.delegate = nil;
    _mapVC.delegate = nil;
    [[LejianData sharedData] setDelegate:nil];
    [[LeJianRequest sharedRequest] setDelegate:nil];
    [_btnHideKeyBoard release];
    [_luxianButton release];
    [_marrayNearLibrary release];
    [_marrayPlaceMark release];
    [_mapVC release];
    [_busyView release];
    [_searchBar release];
    [_backButton release];
    [arrayAddress release];
    [super dealloc];
}

- (void)buttonClicked:(UIButton *)btn
{
    NavigationController *nav = (NavigationController *)self.navigationController;
    [nav popViewControllerAnimated:YES];
}

- (void)luxianButtonClicked
{
    [_mapVC wakeupSystemMap];
}

- (void)hideKeyboard
{
    [_searchBar resignFirstResponder];
    _btnHideKeyBoard.hidden = YES;
}

- (void)viewDidLoad
{
    self.view.frame = CGRectMake(0, -20, 320, 416);
    [self addMap];
    [[LeJianRequest sharedRequest] setDelegate:self];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _searchBar.backgroundColor = [UIColor grayColor];
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.delegate = self;
    ///改变searchbar的默认颜色
    UIView *segment = [_searchBar.subviews objectAtIndex:0];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:segment.bounds];
    imgV.image = [UIImage imageNamed:@"mapsecbg01.png"];
    [segment addSubview:imgV];
    [imgV release];
    _searchBar.backgroundColor = [UIColor blueColor];
    ///当选中searchbar的时候键盘最下方键盘的类型
//    UITextField *searchFiled = [[_searchBar subviews] objectAtIndex:1];
//    [searchFiled setReturnKeyType:UIReturnKeyDone];
//    _searchBar.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:_searchBar]; 
    
    _busyView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 372)];
    _busyView.backgroundColor = [UIColor grayColor];
    _busyView.alpha = 0.8;
	UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    indicatorView.center = CGPointMake(160, _busyView.center.y - 44);
	indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[indicatorView startAnimating];
    [_busyView addSubview:indicatorView];
    [indicatorView release];

    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
    [_backButton setImage:[UIImage imageNamed:@"Cross_01.png"] forState:UIControlStateNormal];
    [_backButton setImage:[UIImage imageNamed:@"Cross_02.png"] forState:UIControlStateHighlighted];
    [_backButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _luxianButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
    [_luxianButton setImage:[UIImage imageNamed:@"maps_01.png"] forState:UIControlStateNormal];
    [_luxianButton setImage:[UIImage imageNamed:@"maps_02.png"] forState:UIControlStateHighlighted];
    [_luxianButton addTarget:self action:@selector(luxianButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _btnHideKeyBoard = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
    _btnHideKeyBoard.backgroundColor = [UIColor clearColor];
    [_btnHideKeyBoard addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    _btnHideKeyBoard.hidden = YES;
    [self.view addSubview:_btnHideKeyBoard];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[LejianData sharedData] setDelegate:self];
    
    NavigationController *nav = (NavigationController *)self.navigationController;
    [nav setNavigationBarHidden:NO];
    [nav setLeftBackButton];
    [nav setRightButton:_luxianButton animated:NO];
    [nav setTitle:@"地图"];
    [nav setTitleLogoHiden:YES];
    nav.leftButton.hidden = NO;
    nav.rightButton.hidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -searchBar delegate method -
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    _btnHideKeyBoard.hidden = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.view addSubview:_busyView];
    [[LeJianRequest sharedRequest] search:searchBar.text];
}

#pragma mark - LeJianDataDelegate Method -
- (void)searchInfoIsRecived:(NSArray *)array
{
    if ([_busyView superview]) 
    {
        [_busyView removeFromSuperview];
    }
    if ([array count])
    {
        _mapVC.marrayAnnotation = [NSMutableArray arrayWithArray:array];
    }
    else 
    {
        [[PublicMethod sharedMethod] showAlert:@"对不起，没有搜索到您输入的地址，请重新输入!"];
    }
}

- (void)dismissViewController 
{
    NavigationController *nav = (NavigationController *)self.navigationController;
    [nav popViewControllerAnimated:YES];
}

#pragma mark - GoogleMap Delegate Method -
- (void)selectedPlace:(NSDictionary *)dictInfo
{
    NSString *path = [NSString stringWithFormat:@"%@/%@-%@.png",[[LeJianDatabase sharedDatabase] filePath], [dictInfo objectForKey:kMapXKey], [dictInfo objectForKey:kMapYKey]];
    [[PublicMethod sharedMethod] saveImage:path view:_mapVC.view];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:dictInfo];
    [dict setValue:path forKey:kImagePathKey];
    
    if ([_delegate respondsToSelector:@selector(mapPlaceIsSelected:)])
    {
        [_delegate mapPlaceIsSelected:dict];
    }
    [dict release];
    [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:0.15];
}

#pragma mark - LejianRequest Delegate Method -
- (void)requestIsFailed
{
    [[PublicMethod sharedMethod] showAlert:@"您目前的网络状态不佳，搜索位置失败!"];
    if ([_busyView superview])
    {
        [_busyView removeFromSuperview];
    }
}
@end
