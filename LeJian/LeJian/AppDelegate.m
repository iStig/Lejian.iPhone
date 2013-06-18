//
//  AppDelegate.m
//  LeJian
//
//  Created by gongxuehan on 8/13/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigationController.h"
#import "ViewController.h"
#import "PublicMethod.h"
#import "GuideViewController.h"

@interface AppDelegate () 
{
    GuideViewController *_guideVC;
}
@end
@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_guideVC release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    ViewController *viewController = [[ViewController alloc] init];
    NavigationController *_navigationController = [[NavigationController alloc] initWithRootViewController:viewController];
    [viewController release];
    [self.window setRootViewController:_navigationController];
    [_navigationController release];
    

    
   if ([[PublicMethod sharedMethod] getValueForKey:kIsAppFirstKey] == nil)
    {
        _guideVC = [[GuideViewController alloc] init];
        self.window.rootViewController.navigationController.navigationBarHidden = YES;
        [self.window.rootViewController.view addSubview:_guideVC.view];
    }
    [self.window makeKeyAndVisible];
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification 
{
    NSDictionary *dict = [notification userInfo];
    NSDictionary *card_info = [dict objectForKey:kLocalNotificationUserInfoKey];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"MM月dd日 HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[card_info objectForKey:kDateKey] intValue]];

    NSString *body = [NSString stringWithFormat:@"您将在 %@ \n与 %@ 乐见",[fmt stringFromDate:date], [card_info objectForKey:kContactNameKey]];
    [fmt release];
    
    [[PublicMethod sharedMethod] showAlert:body];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidReceiveLocalNotificationKey object:nil];
}

@end
