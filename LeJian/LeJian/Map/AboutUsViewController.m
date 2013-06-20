//
//  AboutUsViewController.m
//  LeJian
//
//  Created by gongxuehan on 8/26/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "AboutUsViewController.h"
NSInteger const kAboutBaseTag = 21350;

@implementation AboutUsViewController

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
- (void)buttonClicked:(UIButton *)btn
{
    NSString *strUrl = nil;
    if (btn.tag == kAboutBaseTag)
    {
        strUrl = @"http://weibo.com/14752521";
    }
    else if (btn.tag == kAboutBaseTag + 1)
    {
        strUrl = @"http://weibo.cn/i/2421852350";
    }
    else if (btn.tag == kAboutBaseTag + 2)
    {
        strUrl = @"http://weibo.com/u/3038349317";
    }
    NSURL* url = [[NSURL alloc] initWithString:strUrl];  
    [[ UIApplication sharedApplication]openURL:url];  
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *imgAbout = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen ] bounds].size.height-64)];
    if (DEVICE_HEIGHT==480) {
        imgAbout.image = [UIImage imageNamed:@"about01.png"];
    }
    else{
        imgAbout.image = [UIImage imageNamed:@"about01-568h.png"];
    }
    [self.view addSubview:imgAbout];
    [imgAbout release];
    
    UIButton *btnDun = [[UIButton alloc] initWithFrame:CGRectMake(0, 134, 95, 48)];
    btnDun.backgroundColor = [UIColor clearColor];
    btnDun.tag = kAboutBaseTag;
    [btnDun addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDun];
    [btnDun release];
    
    UIButton *btnXHG = [[UIButton alloc] initWithFrame:CGRectMake(95, 134, 84, 48)];
    btnXHG.backgroundColor = [UIColor clearColor];
    btnXHG.tag = kAboutBaseTag + 1;
    [btnXHG addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnXHG];
    [btnXHG release];
    
    UIButton *btnSmiling = [[UIButton alloc] initWithFrame:CGRectMake(179, 134, 85, 48)];
    btnSmiling.backgroundColor = [UIColor clearColor];
    btnSmiling.tag = kAboutBaseTag + 2;
    [btnSmiling addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSmiling];
    [btnSmiling release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NavigationController *nav = (NavigationController *)self.navigationController;
    [nav setTitleLogoHiden:YES];
    [nav setTitle:@"关于我们"];
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
	return YES;
}

@end
