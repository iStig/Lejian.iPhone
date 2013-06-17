//
//  GuideViewController.h
//  LeJian
//
//  Created by gongxuehan on 8/31/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTScrollView.h"
#import "TTScrollViewDataSource.h"
#import "TTScrollViewDelegate.h"

@interface GuideViewController : UIViewController <TTScrollViewDelegate, TTScrollViewDataSource, UIAlertViewDelegate>

@end
