//
//  AppRecommendViewController.m
//  LeJian
//
//  Created by iStig on 13-6-18.
//  Copyright (c) 2013年 smilingmobile. All rights reserved.
//

#import "AppRecommendViewController.h"

@interface AppRecommendViewController ()
@property(nonatomic, retain)UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, retain) UIWebView *webView;

@end

@implementation AppRecommendViewController
@synthesize activityIndicatorView,webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [webView release];
    [activityIndicatorView release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
   activityIndicatorView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((160-20)/2, (DEVICE_HEIGHT-20)/2, 20, 20)];

    
    webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, DEVICE_HEIGHT-44)];
    webView.delegate=self;
    NSString *urlString=@"http://211.152.32.52:8081/AppRecommend/AppList.jsp?c=4&token=7c7b9faf412741b1a8bc5faa54d72900";
    NSURL *url =[NSURL URLWithString:urlString];
    NSLog(@"%@",urlString);
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    [self.view addSubview:activityIndicatorView];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NavigationController *nav = (NavigationController *)self.navigationController;
    [nav setTitleLogoHiden:YES];
    [nav setTitle:@"应用推荐"];
    
    [self.activityIndicatorView startAnimating];
    self.activityIndicatorView.hidden=FALSE;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicatorView stopAnimating];
     self.activityIndicatorView.hidden=YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    [self.activityIndicatorView stopAnimating];
     self.activityIndicatorView.hidden=YES;
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"" message:@"数据加载失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

@end
