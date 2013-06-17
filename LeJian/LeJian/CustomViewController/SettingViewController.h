/////////////////////////////////////////////////////
/// COPYRIGHT NOTICE
/// Copyright (c) 2012, 上海掌讯信息有限公司（版权声明）
/// All rights reserved.
///
/// @file (PublicMethod.h)
/// @brief (公共方法对象)
///
/// (该对象为一个单例，内包含公共的消息，参数，键值的声明，和一些多处都会调用到的公共方法的实现)
///
/// version 1.1(版本声明)
/// @author (作者eg：龚雪寒)
/// @date (2012年8月2日)
///
///
/// 修订说明：最初版本
/////////////////////////////////////////////////////////
#import <UIKit/UIKit.h>
#import "NavigationController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingViewController : UIViewController <NavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@end
