/////////////////////////////////////////////////////
/// COPYRIGHT NOTICE
/// Copyright (c) 2012, 上海掌讯信息有限公司（版权声明）
/// All rights reserved.
///
/// @file (ViewController.h)
/// @brief (主界面)
///
/// (显示主界面，约会卡片列表)
///
/// version 1.1(版本声明)
/// @author (作者eg：龚雪寒)
/// @date (2012年8月13日)
///
///
/// 修订说明：最初版本
/////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import "NavigationController.h"
#import "TTScrollView.h"
#import "TTScrollViewDataSource.h"
#import "TTScrollViewDelegate.h"
#import "NewCardView.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "LogViewController.h"
#import "BDGuideView.h"


@interface ViewController : UIViewController <TTScrollViewDelegate, TTScrollViewDataSource, NewCardViewDelegate, EKEventViewDelegate, LogViewControllerDelegate ,UIAlertViewDelegate, BDGuideViewDelegate>

@end
