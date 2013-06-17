//
//  GuideViewController.m
//  LeJian
//
//  Created by gongxuehan on 8/31/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "GuideViewController.h"
#import "PublicMethod.h"

NSInteger const kGuideAlertTag = 94530;

@interface GuideViewController()
{
    NSArray         *_arrayGuides;
    NSMutableArray  *_marrayGuidePoint;
    SInt32          _lastPage;
    UISwitch        *_switch;
}
@end

@implementation GuideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)dealloc
{
    [super dealloc];
    [_marrayGuidePoint release];
    [_switch release];
    [_arrayGuides release];
}

- (void)switchAction
{
    SInt32 bSyn = 0;
    if (_switch.on)
    {
        bSyn = 1;
    }
    [[PublicMethod sharedMethod] saveValue:[NSString stringWithFormat:@"%d", bSyn] forKey:kSynchronizationSystemKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *vbg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    vbg.image = [UIImage imageNamed:@"Guide00.png"];
    [self.view addSubview:vbg];
    [vbg release];
    
    TTScrollView *scrollView = [[TTScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.delegate = self;
    scrollView.dataSource = self;
    scrollView.scrollEnabled = YES;
    scrollView.zoomEnabled = NO;
    [self.view addSubview:scrollView];
    
    _arrayGuides = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GuideImage" ofType:@"plist"]];
    
    _marrayGuidePoint = [[NSMutableArray alloc] initWithCapacity:[_arrayGuides count]];
    for (int i = 0; i < [_arrayGuides count]; i ++)
    {
        UIImageView *point = [[UIImageView alloc] initWithFrame:CGRectMake(136 + 20 * i, 420, 9, 9)];
        point.image = [UIImage imageNamed:@"point_02.png"];
        [self.view addSubview:point];
        [_marrayGuidePoint addObject:point];
        [point release];
    }
    
    _switch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 297, 0, 0)];
    [_switch setOn:[[[PublicMethod sharedMethod] getValueForKey:kSynchronizationSystemKey] boolValue]];
    [_switch addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_switch];   
    _switch.hidden = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)hideGuideViewAnimation
{
    [UIView animateWithDuration:0.5
                          delay:0 
                        options:0 
                     animations:^(void){
                         self.view.alpha = 0;
                     } completion:^(BOOL finished){
                         if ([self.view superview])
                         {
                             [self.view removeFromSuperview];
                         }
                        [[PublicMethod sharedMethod] saveValue:@"1" forKey:kIsAppFirstKey];
                     }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kGuideAlertTag) 
    {
        [self hideGuideViewAnimation];
        if (!buttonIndex)
        {
            [[PublicMethod sharedMethod] saveValue:@"0" forKey:kSynchronizationSystemKey];
        }
        else
        {
            [[PublicMethod sharedMethod] saveValue:@"1" forKey:kSynchronizationSystemKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
        }
//        [[PublicMethod sharedMethod] saveValue:@"1" forKey:kIsAppFirstKey];
    }
}

- (void)showSynchronizationAlert
{
    if ([[PublicMethod sharedMethod] getValueForKey:kIsAppFirstKey] == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"是否与系统日历同步,。" delegate:self cancelButtonTitle:@"不同步" otherButtonTitles:@"同步", nil];
        alert.tag = kGuideAlertTag;
        [alert show];
        [alert release]; 
    }
}

#pragma mark - ScrollView Delegate Method -
- (NSInteger)numberOfPagesInScrollView:(TTScrollView *)scrollView
{
    return [_arrayGuides count];
}

- (UIView *)scrollView:(TTScrollView *)scrollView pageAtIndex:(NSInteger)pageIndex
{
    UIImageView *view = (UIImageView *)[scrollView dequeueReusablePage];
    
    if (view == nil)
    {
        view = [[[UIImageView alloc] init] autorelease];
    }
    view.userInteractionEnabled = YES;
    view.image = [UIImage imageNamed:[NSString stringWithFormat:@"Guide0%d.png",pageIndex + 1]];
    if (pageIndex == [_arrayGuides count] - 1)
    {
        [view addSubview:_switch];
    }
    return view;
}

- (void)scrollViewWillBeginDragging:(TTScrollView *)scrollView
{
    
}

- (void)scrollView:(TTScrollView *)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex
{
//    if (pageIndex > [_arrayGuides count] - 1)
//    {
//        [self showSynchronizationAlert];
//    }
    UIImageView *last = [_marrayGuidePoint objectAtIndex:_lastPage];
    UIImageView *cur = [_marrayGuidePoint objectAtIndex:pageIndex];
    if (last)
    {
        [last setImage:[UIImage imageNamed:@"point_02.png"]];
    }
    if (cur)
    {
        [cur setImage:[UIImage imageNamed:@"point_01.png"]];
    }
    _lastPage = pageIndex;
    if (pageIndex == [_arrayGuides count] - 1)
    {
        _switch.hidden = NO;
    }
}

- (void)scrollViewDidEndDragging:(TTScrollView*)scrollView willDecelerate:(BOOL)willDecelerate
{
    UIView *view = [scrollView pageAtIndex:[_arrayGuides count] - 1];
    if (view)
    {
        if (view.frame.origin.x < 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kYinDaoWillDisplayNotification object:nil];
            [self hideGuideViewAnimation];
        }
    }
}

- (CGSize)scrollView:(TTScrollView *)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex
{
    return scrollView.frame.size;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
