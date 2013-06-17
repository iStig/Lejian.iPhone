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

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#pragma mark - Text Color  -
#define TEXT_NAME_BLUE_COLOR [UIColor colorWithRed:30.0/255.0 green:77.0/255.0 blue:107.0/255.0 alpha:1.0]
#define TEXT_PLACE_BLUE_COLOR [UIColor colorWithRed:18.0/255.0 green:47.0/255.0 blue:65.0/255.0 alpha:1.0]
#define DEFAULT_CONTENT_TEXT @"添加约会描述 "
#define DELETE_SEC(d) ((d) - ((d) % 60))

#define SHOW_PICKER_CENTER      CGPointMake(160, 328)
#define HIDE_PICKER_CENTER      CGPointMake(160, 566)

typedef enum 
{
    NormalType = 0,
    NewType,
    EditType,
}FuntionType;

typedef enum 
{
    HomePageTag = 0,
    SettingPageTag,
    LogPageTag,
}CurrentPageTag;

typedef enum
{
    SystemCalendarType = 0,
    LejianCreatType,
}CardType;

NSString *const kYinDaoWillDisplayNotification;
NSString *const kFirstStep1Key;
NSString *const kFirstStep2Key;
NSString *const kFirstStep3Key;

NSString *const kIsAppFirstKey;
#pragma mark - UILocalNotification key -
NSString *const kLocalNotificationUserInfoKey;
NSString *const kDidReceiveLocalNotificationKey;
NSString *const kAutoCleanDateChangedNotificationKey;

#pragma mark - Setting key -
NSString *const kRemindKey;
NSString *const kCleanDayKey;
NSString *const kCleanIndexKey;
#pragma mark - sql key -
NSString *const kCardIDKey;
NSString *const kContactNameKey;
NSString *const kContactTextKey;
NSString *const kContactPhoneKey;
NSString *const kRemindTimeKey;
NSString *const kMapXKey;
NSString *const kMapYKey;
NSString *const kDateKey;
NSString *const kImagePathKey;
NSString *const kMapNameKey;
NSString *const kABRecordIDKey;
NSString *const kCardTypeKey;
NSString *const kCardIdentifierKey;

#pragma mark - Map -
//NSString *const kProviedeNameKey;
//NSString *const kLatitudeKey;
//NSString *const kLongitudeKey;
NSString *const kUserImageKey;

#pragma mark
NSString *const kCurrentFuntionKey;

NSString *const kNewFuntionKey;
NSString *const kNormalFuntionKey;
NSString *const kEditFuntionKey;

#pragma mark - Date -
NSString *const kAbsoluteTimeKey;
NSString *const kMonthKey;
NSString *const kHourKey;

#pragma mark - set Message -
NSString *const kTimeBeforeKey;
NSString *const kTimeAfterKey;
NSString *const kPlaceBeforeKey;
NSString *const kPlaceAfterKey;

#pragma mark - Page Key -  
NSString *const kCurrentPageKey;
NSString *const kShowDeleteMessageKey;

NSString *const kSynchronizationSystemKey;
#pragma mark - Notification -
NSString *const kSaveNewCardNotification;

@interface PublicMethod : NSObject
{
    CLLocationManager *_locationManager;
}


- (CLLocationManager *)startLocationManager;

+ (PublicMethod *) sharedMethod;
- (NSString *)platform;

void SaveScreenImage(NSString *path);

- (void)saveImage:(NSString *)path view:(UIView *)theView;

- (void)addButtonWithRect:(CGRect)frame img_n:(NSString *)img_n img_p:(NSString *)img_p tag:(SInt32)tag target:(id)target method:(SEL)method superView:(UIView *)superView userInteractionEnabled:(BOOL)enabled;

- (void)mapView:(NSString *)path clickedMethod:(SEL)method rect:(CGRect)rect superView:(UIView *)view name:(NSString *)name tag:(SInt32)tag userInteractionEnabled:(BOOL)enabled;

- (NSDictionary *)processDate:(NSDate *)date format:(NSString *)format;
- (NSDictionary *)processRemindTime:(NSString *)strSec;

- (NSDictionary *)adressInfoWithRecordID:(SInt32)RecordID;

- (void)showAlert:(NSString *)message;

- (void)saveValue:(NSString *)object forKey:(NSString *)key;
- (NSString *)getValueForKey:(NSString *)key;

- (FuntionType)currentFuntionType;
- (void)setFuntionType:(FuntionType)type;

- (NSDictionary *)systemInfo;

@end
