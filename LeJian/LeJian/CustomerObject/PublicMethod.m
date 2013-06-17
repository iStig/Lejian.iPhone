//
//  PublicMethod.m
//  LeJian
//
//  Created by gongxuehan on 8/13/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "PublicMethod.h"
#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>
#import <sys/sysctl.h>

NSString *const kYinDaoWillDisplayNotification = @"yinDaoWillDisplayNotification";

NSString *const kFirstStep1Key = @"firstStep1";
NSString *const kFirstStep2Key = @"firstStep2";
NSString *const kFirstStep3Key = @"firstStep3";

NSString *const kIsAppFirstKey = @"isAppFirst";
NSString *const kLocalNotificationUserInfoKey = @"localNotificationUserInfo";
NSString *const kDidReceiveLocalNotificationKey = @"didReceiveLocalNotification";
NSString *const kAutoCleanDateChangedNotificationKey = @"autoCleanDateChangedNotification";

NSString *const kSynchronizationSystemKey = @"synchronizationSystem";

NSString *const kRemindKey = @"b_remind";
NSString *const kCleanDayKey = @"clean_day";
NSString *const kCleanIndexKey = @"clean_index";

NSInteger const kAlertTag = 880919;
NSString *const kCardIDKey = @"card_id";
NSString *const kContactNameKey = @"contact_name";
NSString *const kContactTextKey = @"contact_text";
NSString *const kContactPhoneKey = @"contact_phone";
NSString *const kRemindTimeKey = @"remind_time";
NSString *const kMapXKey = @"map_x";
NSString *const kMapYKey = @"map_y";
NSString *const kDateKey = @"date";
NSString *const kImagePathKey = @"map_path";
NSString *const kMapNameKey = @"map_name";
NSString *const kABRecordIDKey = @"ABRecordID";
NSString *const kCardTypeKey = @"cardType";
NSString *const kCardIdentifierKey = @"card_identifier";

//NSString *const kProviedeNameKey = @"provider_name";
//NSString *const kLatitudeKey = @"lat";
//NSString *const kLongitudeKey = @"lng";
NSString *const kUserImageKey  = @"userImage";
NSString *const kCurrentFuntionKey = @"currentFuntion";

NSString *const kNewFuntionKey = @"newFuntion";
NSString *const kNormalFuntionKey = @"normalFuntion";
NSString *const kEditFuntionKey = @"editFuntion";

NSString *const kAbsoluteTimeKey = @"absoluteTime";
NSString *const kMonthKey = @"month";
NSString *const kHourKey = @"hour";

NSString *const kSaveNewCardNotification = @"saveNewCardNotification";
NSString *const kShowDeleteMessageKey = @"showDeleteMessage";

NSString *const kTimeBeforeKey = @"timeBefore";
NSString *const kTimeAfterKey = @"timeAfter";
NSString *const kPlaceBeforeKey = @"placeBefore";
NSString *const kPlaceAfterKey = @"placeAfter";

NSString *const kCurrentPageKey = @"currentPage";

CGImageRef UIGetScreenImage();
void SaveScreenImage(NSString *path)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CGImageRef cgImage = UIGetScreenImage();
    void *imageBytes = NULL;
    if (cgImage == NULL) {
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        imageBytes = malloc(320 * 480 * 4);
        CGContextRef context = CGBitmapContextCreate(imageBytes, 320, 480, 8, 320 * 4, colorspace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorspace);
        for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
            CGRect bounds = [window bounds];
            CALayer *layer = [window layer];
            CGContextSaveGState(context);
            if ([layer contentsAreFlipped]) {
                CGContextTranslateCTM(context, 0.0f, bounds.size.height);
                CGContextScaleCTM(context, 1.0f, -1.0f);
            }
            [layer renderInContext:(CGContextRef)context];
            CGContextRestoreGState(context);
        }
        cgImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
    }
    NSData *pngData = UIImagePNGRepresentation([UIImage imageWithCGImage:cgImage]);
    CGImageRelease(cgImage);
    if (imageBytes)
        free(imageBytes);
    [pngData writeToFile:path atomically:YES];
    [pool release];
}

@implementation PublicMethod

static PublicMethod *sharedMethod = nil;

- (NSString *)platform {
	size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname("hw.machine", answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
	free(answer);
	return results;
}

- (NSDictionary *)systemInfo
{
    UIDevice *current = [UIDevice currentDevice];
    NSString *strVersion = [current systemVersion];
    NSString *strSystem = [self platform];
    NSString *deviceName = nil;
    NSDictionary *infoPlist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DeviceVersion" ofType:@"plist"]];
    NSArray *version = [infoPlist allKeys];
    for (NSString *str in version)
    {
        if ([str isEqualToString:strSystem])
        {
            deviceName = [infoPlist objectForKey:str];
            break;
        }
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:deviceName,@"deviceName",
                          strVersion,@"version", nil];
    return [dict autorelease];
}

- (void)saveImage:(NSString *)path view:(UIView *)theView
{ 
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    UIView *aView = [[[UIApplication sharedApplication] delegate] window];
    UIGraphicsBeginImageContext(theView.frame.size); 
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGContextSaveGState(context); 
    UIRectClip(CGRectMake(25, 258, 270, 90)); 
    [aView.layer renderInContext:context]; 
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext(); 
    UIGraphicsEndImageContext(); 
    UIImage *image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(theImage.CGImage, CGRectMake(25, 258, 270, 90))];
    NSData *pngData = UIImagePNGRepresentation(image);
    [pngData writeToFile:path atomically:YES];
    [pool release];
} 

- (void)mapView:(NSString *)path clickedMethod:(SEL)method rect:(CGRect)rect superView:(UIView *)view name:(NSString *)name tag:(SInt32)tag userInteractionEnabled:(BOOL)enabled
{
    UIView *subView = [[UIView alloc] initWithFrame:rect];
    subView.backgroundColor = [UIColor clearColor];
    subView.tag = tag;
    subView.userInteractionEnabled = enabled;
//    subView.clipsToBounds = YES;
    ///map
    UIImage *map = [[UIImage alloc] initWithContentsOfFile:path];
    UIImageView *vImageMap = [[UIImageView alloc] initWithFrame:subView.bounds];
    vImageMap.image = map;
    [map release];
    [subView addSubview:vImageMap];
    [vImageMap release];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70, 63, 130, 15)];
//    label.backgroundColor = [UIColor whiteColor];
//    label.font = [UIFont systemFontOfSize:13];
//    label.textAlignment = UITextAlignmentCenter;
//    label.text = name;
//    label.textColor = [UIColor blackColor];
//    [subView addSubview:label];
//    [label release];
    ///cover view
    UIImageView *vImageCover = [[UIImageView alloc] initWithFrame:subView.bounds];
    vImageCover.image = [UIImage imageNamed:@"map_bg.png"];
    [subView addSubview:vImageCover];
    ///click button
//    if (enabled) {
//        vImageMap.userInteractionEnabled = YES;
//        vImageCover.userInteractionEnabled = YES;
//    }
    
    ///place name
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectZero];
    labelName.font = [UIFont systemFontOfSize:11];
    labelName.backgroundColor = [UIColor clearColor];
    labelName.textAlignment = UITextAlignmentCenter;
    labelName.text = name;
    [labelName sizeToFit];
    
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    UIImage *content = nil;
    if (version < 5.0)
    {
        content = [[UIImage imageNamed:@"maptextbg01.png"] stretchableImageWithLeftCapWidth:3.0 topCapHeight:0];
    } 
    else
    {
        content = [[UIImage imageNamed:@"maptextbg01.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3.0, 0, 3.0)];
    }
    UIImageView *allBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, labelName.frame.size.width + 20, labelName.frame.size.height)];
    labelName.center = CGPointMake(allBg.frame.size.width / 2, allBg.frame.size.height / 2);
    allBg.image = content;
    [allBg addSubview:labelName];
    allBg.center = CGPointMake(135, 72);
    [subView addSubview:allBg];
    [allBg release];
    [labelName release];
    
    UIButton *btn  = [[UIButton alloc] initWithFrame:subView.bounds];
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:view action:method forControlEvents:UIControlEventTouchUpInside];
    [subView addSubview:btn];
    [btn release];
        
    [view addSubview:subView];

    UIButton *btns = [[UIButton alloc] initWithFrame:CGRectMake(25, rect.origin.y + 70, subView.bounds.size.width, 20)];
    btns.backgroundColor = [UIColor redColor];
    [btns addTarget:view action:@selector(jumpToSystemMap) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btns];
    [btns release];
    
    [vImageCover release];
    [subView release];
}

- (NSDictionary *)processDate:(NSDate *)date format:(NSString *)format
{
    if (date == nil)
    {
        date = [NSDate date];
    }
    SInt32 sec = [date timeIntervalSince1970];
    NSString *strSec = [NSString stringWithFormat:@"%d",DELETE_SEC(sec)];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    if (format == nil)
    {
        [fmt setDateFormat:@"MM.dd HH:mm"];
    }
    else 
    {
        [fmt setDateFormat:format];
    }
    
    NSString *strDate = [fmt stringFromDate:date];
    [fmt release];
    NSArray *array = [strDate componentsSeparatedByString:@" "];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:strSec,kAbsoluteTimeKey, [array objectAtIndex:0], kMonthKey, [array objectAtIndex:1], kHourKey, nil];
    return [dict autorelease];
}

- (void)showAlert:(NSString *)message
{
    UIView *window = [[[UIApplication sharedApplication] delegate] window];
    if (![window viewWithTag:kAlertTag])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}
    
- (NSDictionary *)processRemindTime:(NSString *)strSec
{
    NSDictionary *dict = nil;
    SInt32 sec = [strSec intValue];
    
    SInt32 day = sec / (3600 * 24);
    SInt32 hour = (sec - day * 3600 * 24) / 3600;
    SInt32 min = (sec - hour * 3600) / 60;
    
    NSString *value = nil;
    NSString *key = nil;
    
    if (!day)
    {
        if (!hour)
        {
//            if (min > 1)
//            {
                key = @"分钟";
//            }
//            else
//            {
//                key = @"M";
//            }
            value = [NSString stringWithFormat:@"%d", min];
        }
        else
        {
//            if (hour > 1)
//            {
                key = @"小时";
//            }
//            else
//            {
//                key = @"H";
//            }
            value = [NSString stringWithFormat:@"%d", hour];
        }
    }
    else
    {
//        if (day > 1)
//        {
//            key = @"D";
//        }
//        else
//        {
            key = @"天";
//        }
        value = [NSString stringWithFormat:@"%d", day];
    }
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:value, key, nil];

    return [dict autorelease];
}

- (NSDictionary *)adressInfoWithRecordID:(SInt32)RecordID
{
    ABAddressBookRef addressBook = ABAddressBookCreate();  
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, RecordID);
    if (person == nil)
    {
        if (addressBook)
        {
            CFRelease(addressBook);
        }
        return nil;
    }
    NSMutableDictionary *mdictPerson = [[NSMutableDictionary alloc] init];
    NSMutableString *mStrName = [[NSMutableString alloc] initWithString:@""];
    //获取名字
    NSString *personName = (NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);  
    //读取lastname  
    NSString *lastname = (NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);  
    //读取middlename  
    NSString *middlename = (NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);  
    if (personName)
    {
        [mStrName appendString:personName];
    }
    if (middlename)
    {
        [mStrName appendFormat:@" %@",middlename];
    }
    if (lastname)
    {
        [mStrName appendFormat:@" %@",lastname];
    }
    [mdictPerson setValue:mStrName forKey:kContactNameKey];
    [mStrName release];
    
    NSData *image = (NSData*) ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail); 
    UIImage *theImage = [UIImage imageWithData:image];
    if (theImage)
    {
        [mdictPerson setValue:theImage forKey:kUserImageKey];
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:mdictPerson];
    [mdictPerson release];
    CFRelease(addressBook);
    return  [dict autorelease];
}

+ (PublicMethod *) sharedMethod
{
    @synchronized(self) {
        if (sharedMethod == nil) {
            [[self alloc] init];
        }
    }
    return sharedMethod;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if(sharedMethod == nil) { 
            sharedMethod = [super allocWithZone:zone];
            return sharedMethod;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (void)saveValue:(NSString *)object forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
    [defaults synchronize];
}
- (NSString *)getValueForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}


- (id)init
{
    self = [super init];
    if (self) 
    {
        if ([self getValueForKey:kRemindKey] == nil)
        {
            [self saveValue:@"1" forKey:kRemindKey];
        }
        if ([self getValueForKey:kCleanIndexKey] == nil)
        {
            [self saveValue:@"7" forKey:kCleanIndexKey];
        }
        if ([self getValueForKey:kCleanDayKey] == nil)
        {
            [self saveValue:@"99" forKey:kCleanDayKey];
        }
        
        if ([self getValueForKey:kTimeBeforeKey] == nil)
        {
            [self saveValue:@"我还有" forKey:kTimeBeforeKey];
        }
        if ([self getValueForKey:kTimeAfterKey] == nil)
        {
            [self saveValue:@"左右到达" forKey:kTimeAfterKey];
        }
        if ([self getValueForKey:kPlaceBeforeKey] == nil)
        {
            [self saveValue:@"我已经到达" forKey:kPlaceBeforeKey];
        }
        if ([self getValueForKey:kPlaceAfterKey] == nil)
        {
            [self saveValue:@"附近" forKey:kPlaceAfterKey];
        }
        if ([self getValueForKey:kCurrentPageKey] == nil)
        {
            [self saveValue:@"0" forKey:kCurrentPageKey];
        }
        if ([self getValueForKey:kShowDeleteMessageKey] == nil)
        {
            [self saveValue:@"1" forKey:kShowDeleteMessageKey];
        }
        if  ([self getValueForKey:kSynchronizationSystemKey] == nil)
        {
            [self saveValue:@"0" forKey:kSynchronizationSystemKey];
        }
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [_locationManager release];
}

- (CLLocationManager *)startLocationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];//创建位置管理器
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;//指定需要的精度级别
        _locationManager.distanceFilter=1000.0f;//设置距离筛选器
        [_locationManager startUpdatingLocation];
    }
    return _locationManager;
}


- (void)setFuntionType:(FuntionType)type
{
    [self saveValue:[NSString stringWithFormat:@"%d",type] forKey:kCurrentFuntionKey];
}   

- (FuntionType)currentFuntionType
{
    return [[self getValueForKey:kCurrentFuntionKey] intValue];
}

- (void)addButtonWithRect:(CGRect)frame img_n:(NSString *)img_n img_p:(NSString *)img_p tag:(SInt32)tag target:(id)target method:(SEL)method superView:(UIView *)superView userInteractionEnabled:(BOOL)enabled
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setImage:[UIImage imageNamed:img_n] forState:UIControlStateNormal];
    if (img_p == nil)
    {
        btn.adjustsImageWhenHighlighted = NO;
    }
    [btn setImage:[UIImage imageNamed:img_p] forState:UIControlStateHighlighted];
    [btn setTag:tag];
    btn.userInteractionEnabled = enabled;
    [btn addTarget:target action:method forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:btn];
    [btn release];
}

@end
