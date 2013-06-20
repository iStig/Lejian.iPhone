//
//  NewCardView.m
//  LeJian
//
//  Created by gongxuehan on 8/14/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "NewCardView.h"
#import "PublicMethod.h"
#import <AddressBook/AddressBook.h>
#import "ClockManager.h"
#import "ThumbMapView.h"


#define SHOW_C_PICKER_CENTER      CGPointMake(160,DEVICE_HEIGHT-88)
#define HIDE_C_PICKER_CENTER      CGPointMake(160,DEVICE_HEIGHT-88+252)

typedef enum{
    DateType = 0,
    RemindType,
}PickerType;

NSInteger const kBaseTag = 90000;
NSInteger const kMapViewTag = 98789;

@interface NewCardView()
{
    UILabel *_lblName;
    UILabel *_lblText;
    
    UILabel *_lblDate;
    UILabel *_lblTime;
    UILabel *_lblRemind;
    UILabel *_lblMinHour;
    
    UITextField         *_contentText;
    NSMutableDictionary *_mdictCard;
    
    UIButton       *_hidePickerBtn;
    BOOL            _isHideBtnClicked;
    UIDatePicker   *_datePicker;
    UIPickerView   *_remindPicker;
    NSArray        *_arrayRemindTime;
    NSArray        *_arrayRemindTSec;
    UIImageView     *_pickerBg;
    
    PickerType      _pickerType;
    
    UIImageView     *_vBackground;
    CLLocationManager *_locationManager;
    
    BOOL            _isDateSelected;
    BOOL            _isSystemMap;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableDictionary *mdictCard;

- (void)datePickerViewIsChanged;
- (void)pickerAnimation:(PickerType)type show:(BOOL)show;
- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients;
@end

@implementation NewCardView
@synthesize delegate = _delegate;
@synthesize mdictCard = _mdictCard;
@synthesize type  = _type;
@synthesize locationManager = _locationManager;

- (void)dealloc
{
    [_vBackground release];
    [_arrayRemindTSec release];
    [_locationManager release];
    [_contentText release];
    [_lblName release];
    [_lblText release];
    [_mdictCard release];
    [_lblDate release];
    [_lblTime release];
    [_lblRemind release];
    [_lblMinHour release];
    [_hidePickerBtn release];
    [_datePicker release];
    [_remindPicker release];
    [_arrayRemindTime release];
    if ([_pickerBg superview])
    {
        [_pickerBg removeFromSuperview];
    }
    [_pickerBg release];
    [super dealloc];
}

- (UIViewController *)getSuperViewController 
{
    for (UIView* next = [self superview]; next; next = next.superview) 
    {
        UIResponder *nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]]) 
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)addressBook
{
    ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
    ppnc.peoplePickerDelegate = self;
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:ppnc animated:YES];
    [ppnc release];
}

- (void)mapButtonClicked:(UIButton *)btn
{
    MapViewController *mapVctrl = [[MapViewController alloc]init];
    mapVctrl.dictMapLocation = _mdictCard;
    mapVctrl.delegate = self;
    [(NavigationController *)[self getSuperViewController].navigationController pushViewController:mapVctrl animated:YES];
    [mapVctrl release];
}

- (void)displayNewCardView
{
    if ([_delegate respondsToSelector:@selector(newCardIsFinishedEdit:)])
    {
        [_delegate newCardIsFinishedEdit:_mdictCard];
    }
}

- (void)jumpToSystemMap
{
    _isSystemMap = YES;
    CLLocationManager *lm= [[CLLocationManager alloc] init];//创建位置管理器
    lm.desiredAccuracy=kCLLocationAccuracyBest;//指定需要的精度级别
    [lm startUpdatingLocation];//启动位置管理器
    lm.delegate = self;
    self.locationManager = lm;
    [lm release];

}

- (NSString *)editMessage:(NSString *)time
{
    NSString *strMessage = [NSString stringWithFormat:@"%@ %@ %@", [[PublicMethod sharedMethod] getValueForKey:kTimeBeforeKey], time, [[PublicMethod sharedMethod] getValueForKey:kTimeAfterKey]];
    return strMessage;
}

- (void)buttonClicked:(UIButton *)btn
{
    [_contentText resignFirstResponder];
    switch (btn.tag - kBaseTag)
    {
        case 0: ///添加联系人
        case 7:
        {
            [self addressBook];
        }
            break;
        case 1: ///打电话
        {
            if (btn.userInteractionEnabled)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[_mdictCard objectForKey:kContactPhoneKey]]]];
            }
        }
            break;
        case 2: ///发短信
        {
            if (btn.userInteractionEnabled)
            {
                NSArray *array = [[NSArray alloc] initWithObjects:[_mdictCard objectForKey:kContactPhoneKey], nil];
                [self sendSMS:@"" recipientList:array];
                [array release];
            }
        }
            break;
        case 3: ///15分钟
        {
            NSArray *array = [[NSArray alloc] initWithObjects:[_mdictCard objectForKey:kContactPhoneKey], nil];
            [self sendSMS:[self editMessage:@"15分钟"] recipientList:array];
            [array release];
        }
            break;
        case 4: ///30分钟
        {
            NSArray *array = [[NSArray alloc] initWithObjects:[_mdictCard objectForKey:kContactPhoneKey], nil];
            [self sendSMS:[self editMessage:@"30分钟"] recipientList:array];
            [array release];
        }
            break;
        case 5: ///60分钟
        {
            NSArray *array = [[NSArray alloc] initWithObjects:[_mdictCard objectForKey:kContactPhoneKey], nil];
            [self sendSMS:[self editMessage:@"1小时"] recipientList:array];
            [array release];
        }
            break;
        case 6: ///定位
        {
            CLLocationManager *lm= [[CLLocationManager alloc] init];//创建位置管理器
            lm.desiredAccuracy=kCLLocationAccuracyBest;//指定需要的精度级别
            [lm startUpdatingLocation];//启动位置管理器
            lm.delegate = self;
            self.locationManager = lm;
            [lm release];
        }    
            break;
        case 8: ///map
        {
            MapViewController *mapVctrl = [[MapViewController alloc]init];
            mapVctrl.delegate = self;
            [(NavigationController *)[self getSuperViewController].navigationController pushViewController:mapVctrl animated:YES];
            [mapVctrl release];
        }
            break;
        case 9: ///设置时间
        {
            _isDateSelected = YES;
            _pickerType = DateType;
            if (!_lblDate.text || [_lblDate.text isEqualToString:@""]) {
                [self datePickerViewIsChanged];
            }
            [self pickerAnimation:DateType show:YES];
        }
            break;
        case 10: ///收起pickerView
        {
            _isHideBtnClicked = YES;
            [self pickerAnimation:_pickerType show:NO];
        }
            break;
        case 11: ///设置提醒
        {
            _pickerType = RemindType;
            if (_lblMinHour.hidden)
            {
                _lblRemind.text = @"1";
                _lblRemind.font = [UIFont boldSystemFontOfSize:18];
                
                _lblMinHour.text = @"小时";
                _lblMinHour.hidden = NO;
                [_remindPicker selectRow:2 inComponent:0 animated:NO];
                [_mdictCard setValue:@"3600" forKey:kRemindTimeKey];
            }
            [self pickerAnimation:RemindType show:YES];
        }
            break;
        default:
            break;
    }
}

- (void)saveNewCard
{
    if (![_contentText.text isEqualToString:DEFAULT_CONTENT_TEXT])
    {
        [_mdictCard setValue:_contentText.text forKey:kContactTextKey];
    }
    if (([_mdictCard objectForKey:kContactNameKey] == nil) ||
        ([_mdictCard objectForKey:kDateKey] == nil))
    {
        [[PublicMethod sharedMethod] showAlert:@"联系人、约会时间为必填项目!请务必填写!"];
    }
    else
    {
        if ([_mdictCard objectForKey:kCardIDKey] == nil)
        {
            SInt32 maxID = [[LeJianDatabase sharedDatabase] maxCardID];
            [_mdictCard setValue:[NSString stringWithFormat:@"%d", maxID + 1] forKey:kCardIDKey];
            [_mdictCard setValue:[NSString stringWithFormat:@"%d", LejianCreatType] forKey:kCardTypeKey];
        }
        [self displayNewCardView];
    }
}

- (void)showGuideView
{
    if ([_mdictCard objectForKey:kDateKey] && [_mdictCard objectForKey:kContactNameKey] && ([[PublicMethod sharedMethod] getValueForKey:kFirstStep3Key] == nil) && ([_mdictCard objectForKey:kMapNameKey] == nil))
    {
        if (DEVICE_HEIGHT==480) {
            
        [BDGuideView showGuideImageNamed:@"help03.png" withDelegate:self];
        }else{
        
        [BDGuideView showGuideImageNamed:@"3.png" withDelegate:self];
        }
        
       [[PublicMethod sharedMethod] saveValue:@"1" forKey:kFirstStep3Key];
    }
}

- (void)pickerAnimation:(PickerType)type show:(BOOL)show
{
    CGPoint center = CGPointZero;
    if (show)
    {
        _hidePickerBtn.hidden = NO;
        center = SHOW_C_PICKER_CENTER;
        if ([_delegate respondsToSelector:@selector(pickerViewIsShowed:)]) {
            [_delegate pickerViewIsShowed:YES];
        }
    }
    else
    {
        center = HIDE_C_PICKER_CENTER;
        if ([_delegate respondsToSelector:@selector(pickerViewIsShowed:)]) {
            [_delegate pickerViewIsShowed:NO];
        }
    }
    [UIView animateWithDuration:0.3 
                          delay:0
                        options:0 
                     animations:^(void){
                         if (type == DateType)
                         {
                             [_pickerBg bringSubviewToFront:_datePicker];
                         }
                         else if (type == RemindType)
                         {
                             [_pickerBg bringSubviewToFront:_remindPicker];
                         }
                         _pickerBg.center = center;
                     } 
                     completion:^(BOOL finished){
                         if (!show) 
                         {
                             _hidePickerBtn.hidden = YES;
                             if (_isHideBtnClicked)
                             {
                                 [self showGuideView];
                             }
                         }
                     }];
}

- (void)cancelNewCard
{
    [self pickerAnimation:_pickerType show:NO];
}

- (void)isCallButtonEnabled:(BOOL)enable
{
    [(UIButton *)[self viewWithTag:kBaseTag + 1] setUserInteractionEnabled:enable];
    [(UIButton *)[self viewWithTag:kBaseTag + 2] setUserInteractionEnabled:enable];

    if (enable)
    {
        [(UIButton *)[self viewWithTag:kBaseTag + 1] setImage:[UIImage imageNamed:@"callbtn_02.png"] forState:UIControlStateNormal];
        [(UIButton *)[self viewWithTag:kBaseTag + 1] setImage:[UIImage imageNamed:@"callbtn_03.png"] forState:UIControlStateHighlighted];
        [(UIButton *)[self viewWithTag:kBaseTag + 1] setAdjustsImageWhenHighlighted: YES];
        
        [(UIButton *)[self viewWithTag:kBaseTag + 2] setImage:[UIImage imageNamed:@"msgbtn_02.png"] forState:UIControlStateNormal];
        [(UIButton *)[self viewWithTag:kBaseTag + 2] setImage:[UIImage imageNamed:@"msgbtn_03.png"] forState:UIControlStateHighlighted];
        [(UIButton *)[self viewWithTag:kBaseTag + 2] setAdjustsImageWhenHighlighted: YES];
    }
    else 
    {
        [(UIButton *)[self viewWithTag:kBaseTag + 1] setImage:[UIImage imageNamed:@"callbtn_01.png"] forState:UIControlStateNormal];
        [(UIButton *)[self viewWithTag:kBaseTag + 1] setAdjustsImageWhenHighlighted: NO];

        [(UIButton *)[self viewWithTag:kBaseTag + 2] setImage:[UIImage imageNamed:@"msgbtn_01.png"] forState:UIControlStateNormal];
        [(UIButton *)[self viewWithTag:kBaseTag + 2] setAdjustsImageWhenHighlighted: NO];
    }
}

- (void)userImage:(UIImage *)img
{
//    NSLog(@"width %f height %f",img.size.width, img.size.height);
    UIButton *btn = (UIButton *)[self viewWithTag:kBaseTag];
    if (!btn)
    {
        return;
    }
    [btn setImage:img forState:UIControlStateNormal];
}

- (void)initNameAndTime
{
    _lblName = [[UILabel alloc] initWithFrame:CGRectMake(46, 29, 150, 22)];
    _lblName.textColor = TEXT_NAME_BLUE_COLOR;
    _lblName.font = [UIFont boldSystemFontOfSize:19];
    _lblName.text = @"添加联系人";
    _lblName.backgroundColor = [UIColor clearColor];
    _lblName.shadowColor = [UIColor whiteColor];
    _lblName.shadowOffset = CGSizeMake(0, 1.0);
    [self addSubview:_lblName];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(46, 29, 150, 20)];
    addButton.backgroundColor = [UIColor clearColor];
    addButton.tag = kBaseTag + 7;
    [addButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addButton];
    [addButton release];
    
    _contentText = [[UITextField alloc] initWithFrame:CGRectMake(46, 55, 150, 40)];
    _contentText.text = DEFAULT_CONTENT_TEXT;
    _contentText.delegate = self;
    _contentText.returnKeyType = UIReturnKeyDone;
    _contentText.backgroundColor = [UIColor clearColor];
    _contentText.font = [UIFont systemFontOfSize:14];
    _contentText.textColor = TEXT_PLACE_BLUE_COLOR;
    [self addSubview:_contentText];
    
    UIImageView *vImgTime = [[UIImageView alloc] initWithFrame:CGRectMake(46, 96, 218, 38)];
    vImgTime.image = [UIImage imageNamed:@"date.png"];
    vImgTime.userInteractionEnabled = YES;
    [self addSubview:vImgTime];
    
    _lblDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 70, 19)];
    _lblDate.backgroundColor = [UIColor clearColor];
    _lblDate.textColor = [UIColor blackColor];
    _lblDate.font = [UIFont boldSystemFontOfSize:18];
    _lblDate.text = @"";
    [vImgTime addSubview:_lblDate];
    
    _lblTime = [[UILabel alloc] initWithFrame:CGRectMake(88, 18, 70, 19)];
    _lblTime.backgroundColor = [UIColor clearColor];
    _lblTime.textColor = [UIColor blackColor];
    _lblTime.font = [UIFont boldSystemFontOfSize:18];
    _lblTime.text = @"";
    [vImgTime addSubview:_lblTime];
    
    UIButton *time = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 165, 37)];
    time.backgroundColor = [UIColor clearColor];
    time.tag = kBaseTag + 9;
    [time addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [vImgTime addSubview:time];
    [time release];
    
    _lblRemind = [[UILabel alloc] initWithFrame:CGRectMake(186, 18, 70, 19)];
    _lblRemind.backgroundColor = [UIColor clearColor];
    _lblRemind.textColor = [UIColor blackColor];
    _lblRemind.font = [UIFont systemFontOfSize:10];
    _lblRemind.text = @"设置提醒";
    [vImgTime addSubview:_lblRemind];
    
    _lblMinHour = [[UILabel alloc] initWithFrame:CGRectMake(21,3, 30, 13)];
    _lblMinHour.text = @"min";
    _lblMinHour.font = [UIFont boldSystemFontOfSize:12];
    _lblMinHour.backgroundColor = [UIColor clearColor];
    [_lblRemind addSubview:_lblMinHour];
    _lblMinHour.hidden = YES;
    [vImgTime release];
    
    UIButton *remindBtn = [[UIButton alloc] initWithFrame:CGRectMake(165, 0, 70, 37)];
    remindBtn.backgroundColor = [UIColor clearColor];
    remindBtn.tag = kBaseTag + 11;
    [remindBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [vImgTime addSubview:remindBtn];
    [remindBtn release];
}

- (void)initUserImage
{
    [[PublicMethod sharedMethod] addButtonWithRect:CGRectMake(208, 18, 76, 76) 
                                             img_n:@"user_01.png" 
                                             img_p:@""
                                               tag:kBaseTag
                                            target:self 
                                            method:@selector(buttonClicked:)
                                         superView:self 
                            userInteractionEnabled:YES];
}

- (void)initCallAndMessageBtn
{
    UIImageView *callImg = [[UIImageView alloc] initWithFrame:CGRectMake(22, 129, 275, 72)];
    callImg.image = [UIImage imageNamed:@"callbtn_bg.png"];
    [self addSubview:callImg];
    [callImg release];
    
    [[PublicMethod sharedMethod] addButtonWithRect:CGRectMake(38, 144, 124, 41) 
                                             img_n:@"callbtn_01.png"
                                             img_p:@"callbtn_03.png" 
                                               tag:kBaseTag + 1 
                                            target:self
                                            method:@selector(buttonClicked:) 
                                         superView:self userInteractionEnabled:NO];
    
    [[PublicMethod sharedMethod] addButtonWithRect:CGRectMake(158, 144, 123, 41) 
                                             img_n:@"msgbtn_01.png" 
                                             img_p:@"msgbtn_03.png"
                                               tag:kBaseTag+2
                                            target:self
                                            method:@selector(buttonClicked:) 
                                         superView:self userInteractionEnabled:NO];
}

- (void)initQuickMessageBtn
{
    UIImageView *qmBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 254, 61)];
    qmBg.image = [UIImage imageNamed:@"qmbtn_bg.png"];
    qmBg.center = CGPointMake(160, 313);
    [self addSubview:qmBg];
    [qmBg release];
    
    [[PublicMethod sharedMethod] addButtonWithRect:CGRectMake(44, 294, 39, 39) 
                                             img_n:@"qm15btn_01.png" 
                                             img_p:@"qm15btn_02.png"
                                               tag:kBaseTag+3
                                            target:self
                                            method:@selector(buttonClicked:) 
                                         superView:self userInteractionEnabled:YES];
    
    [[PublicMethod sharedMethod] addButtonWithRect:CGRectMake(108, 294, 39, 39) 
                                             img_n:@"qm30btn_01.png" 
                                             img_p:@"qm30btn_02.png"
                                               tag:kBaseTag+4
                                            target:self
                                            method:@selector(buttonClicked:) 
                                         superView:self userInteractionEnabled:YES];
    
    [[PublicMethod sharedMethod] addButtonWithRect:CGRectMake(173, 294, 39, 39) 
                                             img_n:@"qm60btn_01.png" 
                                             img_p:@"qm60btn_02.png"
                                               tag:kBaseTag+5
                                            target:self
                                            method:@selector(buttonClicked:) 
                                         superView:self userInteractionEnabled:YES];
    [[PublicMethod sharedMethod] addButtonWithRect:CGRectMake(237, 294, 39, 39) 
                                             img_n:@"qmdwbtn_01.png" 
                                             img_p:@"qmdwbtn_02.png"
                                               tag:kBaseTag+6
                                            target:self
                                            method:@selector(buttonClicked:) 
                                         superView:self userInteractionEnabled:YES];
}

- (void)initMapBtn
{
    [[PublicMethod sharedMethod] addButtonWithRect:CGRectMake(39, 208, 242, 49)
                                             img_n:@"addmap_01.png" 
                                             img_p:@""
                                               tag:kBaseTag + 8
                                            target:self 
                                            method:@selector(buttonClicked:)
                                         superView:self 
                            userInteractionEnabled:YES];
}

- (void)datePickerViewIsChanged
{
    NSDictionary *dict = [[PublicMethod sharedMethod] processDate:[_datePicker date] format:nil];
    [_mdictCard setValue:[dict objectForKey:kAbsoluteTimeKey] forKey:kDateKey];
    
    if ([[_mdictCard objectForKey:kDateKey] intValue] < [[NSDate date] timeIntervalSince1970])
    {
        _vBackground.image = [UIImage imageNamed:@"card_bg02.png"];
    }
    else
    {
        _vBackground.image = [UIImage imageNamed:@"card_bg.png"];
    }
    _lblDate.text = [dict objectForKey:kMonthKey];
    _lblTime.text = [dict objectForKey:kHourKey];
}

- (void)initPickerView
{
    _pickerBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 252)];
    _pickerBg.userInteractionEnabled = YES;
    _pickerBg.center = HIDE_C_PICKER_CENTER;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:_pickerBg];
    
    _hidePickerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 248)];
    _hidePickerBtn.backgroundColor = [UIColor clearColor];
    _hidePickerBtn.tag = kBaseTag + 10;
    [_hidePickerBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_hidePickerBtn];
    [_hidePickerBtn setHidden:YES];
    
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:7200];
    [_datePicker setDate:date];
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [_datePicker addTarget:self action:@selector(datePickerViewIsChanged) forControlEvents:UIControlEventValueChanged];
    [_pickerBg addSubview:_datePicker];
    
    _remindPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 252)];
    _arrayRemindTime = [[NSArray alloc]initWithObjects:@"即时提醒",@"15 分钟",@"30 分钟",@"1 小时",@"3 小时",@"6 小时",@"1 天",nil];
    _arrayRemindTSec = [[NSArray alloc] initWithObjects:@"0", @"900", @"1800",@"3600",@"10800",@"21600",@"86400", nil];
    _remindPicker.delegate = self;
    _remindPicker.dataSource = self;
    _remindPicker.showsSelectionIndicator = YES;
    [_pickerBg addSubview:_remindPicker];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mdictCard = [[NSMutableDictionary alloc] init];
        
        [self initUserImage];
        [_mdictCard setValue:@"编辑添加约会描述" forKey:kContactTextKey];
        [_mdictCard setValue:@"3600" forKey:kRemindTimeKey];
        self.backgroundColor = [UIColor clearColor];
        
        _vBackground = [[UIImageView alloc] initWithFrame:CGRectMake(24, 10, 272, 339)];
        _vBackground.image = [UIImage imageNamed:@"card_bg.png"];
        [self addSubview:_vBackground];
        
        [self initNameAndTime];
        [self initCallAndMessageBtn];
        [self initQuickMessageBtn];
        [self initMapBtn];
        [self initPickerView];
    }
    return self;
}

- (void)setType:(FuntionType)type
{
    _type = type;
    BOOL enabled = NO;
    if (type == NormalType)
    {
        [_contentText resignFirstResponder];
        [self cancelNewCard];
        enabled = NO;
    }
    else if (type == EditType)
    {
        enabled = YES;
        _contentText.userInteractionEnabled = YES;
        [_contentText becomeFirstResponder];
    }
    _contentText.userInteractionEnabled = enabled;
    [[self viewWithTag:kMapViewTag] setUserInteractionEnabled:enabled];
    [[self viewWithTag:kBaseTag] setUserInteractionEnabled:enabled];
    [[self viewWithTag:kBaseTag + 9] setUserInteractionEnabled:enabled];
    [[self viewWithTag:kBaseTag + 11] setUserInteractionEnabled:enabled];
    [[self viewWithTag:kBaseTag + 7] setUserInteractionEnabled:enabled];
    [[self viewWithTag:kBaseTag + 8] setUserInteractionEnabled:enabled];
}

- (void)setEditCardInfo:(NSDictionary *)card_info funtionType:(FuntionType)type
{
    if (card_info)
    {
        if ([[card_info objectForKey:kDateKey] intValue] < [[NSDate date] timeIntervalSince1970])
        {
            _vBackground.image = [UIImage imageNamed:@"card_bg02.png"];
        }
        else 
        {
            _vBackground.image = [UIImage imageNamed:@"card_bg.png"];
        }
        self.mdictCard = [NSMutableDictionary dictionaryWithDictionary:card_info];
        
        ///联系人，内容
        _lblName.text = [_mdictCard objectForKey:kContactNameKey];
        if ([_mdictCard objectForKey:kContactTextKey] && ![[_mdictCard objectForKey:kContactTextKey] isEqualToString:@""])
        {
            _contentText.text = [_mdictCard objectForKey:kContactTextKey];
        }
        if ([_mdictCard objectForKey:kContactPhoneKey] && ![[_mdictCard objectForKey:kContactPhoneKey] isEqualToString:@""])
        {
            [self isCallButtonEnabled:YES];
        }
        else
        {
            [self isCallButtonEnabled:NO];
        }
        ///日期
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[_mdictCard objectForKey:kDateKey] intValue]];
        NSDictionary *dictDate = [[PublicMethod sharedMethod] processDate:date format:nil];
        if (dictDate)
        {
            [_datePicker setDate:date];
            _lblDate.text = [dictDate objectForKey:kMonthKey];
            _lblTime.text = [dictDate objectForKey:kHourKey];
        }
        ///提醒时间
        NSDictionary *dict = [[PublicMethod sharedMethod] processRemindTime:[_mdictCard objectForKey:kRemindTimeKey]];
        if (dict)
        {
            _lblMinHour.text = [[dict allKeys] lastObject];
            _lblMinHour.hidden = NO;
            _lblRemind.font = [UIFont boldSystemFontOfSize:18];
            _lblRemind.text = [dict objectForKey:_lblMinHour.text]; 
            int index = 0;
            for (NSString *sec in _arrayRemindTSec)
            {
                if ([sec isEqualToString:[_mdictCard objectForKey:kRemindTimeKey]])
                {
                    break;
                }
                index ++;
            }
            [_remindPicker selectRow:index inComponent:0 animated:NO];
        }
        ///地图
        NSString  *mapName = [_mdictCard objectForKey:kMapNameKey];
        NSString  *mapPath = [_mdictCard objectForKey:kImagePathKey];
        
        if ([[self viewWithTag:kMapViewTag] superview])
        {
            [[self viewWithTag:kMapViewTag] removeFromSuperview];
        }

        if (mapPath && ![mapPath isEqualToString:@""])
        {
            ThumbMapView *map = [[ThumbMapView alloc] initWithFrame:CGRectMake(25, 188, 269, 90) mapView:mapPath topClickedMethod:@selector(mapButtonClicked:) bottomClickMethod:@selector(jumpToSystemMap) superView:self name:mapName tag:kMapViewTag];
            [self addSubview:map];
            [map release];
        }
        
        dict = [[PublicMethod sharedMethod] adressInfoWithRecordID:[[_mdictCard objectForKey:kABRecordIDKey] intValue]];
        [self userImage:[UIImage imageNamed:@"user_02.png"]];
        if ([dict objectForKey:kUserImageKey])
        {
            [self userImage:[dict objectForKey:kUserImageKey]];  
        }
        self.type = type;
    }
}

#pragma mark - AddressBook Delegate Method -
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{    
    NSMutableString *mStrName = [[NSMutableString alloc] initWithString:@""];
    //获取名字
    NSString *personName = (NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);  
    //读取lastname  
    NSString *lastname = (NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);  
    //读取middlename  
    NSString *middlename = (NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);  
    if (lastname)
    {
        [mStrName appendString:lastname];
    }
    if (middlename)
    {
        [mStrName appendFormat:@" %@",middlename];
    }
    if (personName)
    {
        [mStrName appendFormat:@" %@",personName];
    }
    _lblName.text = mStrName;
    [_mdictCard setValue:mStrName forKey:kContactNameKey];
    [mStrName release];
    //读取电话多值  
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);  
    //获取电话Label  
    if (ABMultiValueGetCount(phone))
    {
        NSString * personPhone = (NSString*)ABMultiValueCopyValueAtIndex(phone, identifier);  
        if (personPhone) 
        {
            [self isCallButtonEnabled:YES];
        } 
        else 
        {
            [self isCallButtonEnabled:NO];
        }
        [_mdictCard setValue:personPhone forKey:kContactPhoneKey];    
    }
//    NSString * personPhoneLabel = (NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, identifier));  
    //获取該Label下的电话值  
    
    [self userImage:[UIImage imageNamed:@"user_02.png"]];

    NSData *image = (NSData*) ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail); 
    UIImage *theImage = [UIImage imageWithData:image];
    
    if (theImage)
    {
        [self userImage:theImage];
    }
    ABRecordID personRecordID = ABRecordGetRecordID(person);
    [_mdictCard setValue:[NSString stringWithFormat:@"%d", personRecordID] forKey:kABRecordIDKey];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] dismissModalViewControllerAnimated:YES];
    
    if ([[[PublicMethod sharedMethod] getValueForKey:kCurrentFuntionKey] intValue] == NewType)
    {
        if (!_isDateSelected)
        {
            _pickerType = DateType;
            if (!_lblDate.text || [_lblDate.text isEqualToString:@""]) {
                [self datePickerViewIsChanged];
            }
            [self pickerAnimation:DateType show:YES];
        }
        else
        {
            [self showGuideView];
        }
    }
    
    return NO;
}

#pragma mark - MapViewController Delegate-
- (void)mapPlaceIsSelected:(NSDictionary *)dict
{
    if ([dict objectForKey:kImagePathKey])
    {
        if ([self viewWithTag:kMapViewTag]) 
        {
            [[self viewWithTag:kMapViewTag] removeFromSuperview];
        }
        ThumbMapView *map = [[ThumbMapView alloc] initWithFrame:CGRectMake(25, 188, 269, 90) mapView:[dict objectForKey:kImagePathKey] topClickedMethod:@selector(mapButtonClicked:) bottomClickMethod:@selector(jumpToSystemMap) superView:self name:[dict objectForKey:kMapNameKey] tag:kMapViewTag];
        [self addSubview:map];
        [map release];
    }
    //add map values to card dictionary
    for (NSString *strKey in [dict allKeys])
    {
        [_mdictCard setValue:[dict objectForKey:strKey] forKey:strKey];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - Remind picker delegate -
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_arrayRemindTime count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_arrayRemindTime objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *strTime = [_arrayRemindTSec objectAtIndex:row];
    NSDictionary *dict = [[PublicMethod sharedMethod] processRemindTime:strTime];
    _lblMinHour.text = [[dict allKeys] lastObject];
    _lblRemind.text = [dict objectForKey:_lblMinHour.text];
    [_mdictCard setValue:strTime forKey:kRemindTimeKey];
}

#pragma mark - UITextFieldDelegate -
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:DEFAULT_CONTENT_TEXT]) 
    {
        textField.text = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma  mark - message delegate -
- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
    
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = bodyOfMessage;   
        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:controller animated:YES];
    }   
}


// 处理发送完的响应结果
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] dismissModalViewControllerAnimated:YES];
    if (result == MessageComposeResultCancelled)
    {
        NSLog(@"Message cancelled");
    }
    else if (result == MessageComposeResultSent)
    { 
        NSLog(@"Message sent");  
    }   
    else
    {
        NSLog(@"Message failed");  
    }
}

#pragma mark - map -
///定位当前位置的方法
- (void)startedReverseGeoderWithLatitude:(double)latitude longitude:(double)longitude{
    CLLocationCoordinate2D coordinate2D;
    coordinate2D.longitude = longitude;
    coordinate2D.latitude = latitude;
    MKReverseGeocoder *geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate2D];
    geoCoder.delegate = self;
    [geoCoder start];
}

//用CLLoction获取到当前的经纬度
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocationDistance l = newLocation.coordinate.latitude;//得到经度
    CLLocationDistance v = newLocation.coordinate.longitude;//得到纬度
    if (_isSystemMap)
    {
        _isSystemMap = NO;
        NSString *x = [_mdictCard objectForKey:kMapXKey];
        NSString *y = [_mdictCard objectForKey:kMapYKey];
        NSString *theString = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%.15f,%.15f&daddr=%@,%@", l,v, x,y];
        theString =  [theString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        
        NSURL *url = [[NSURL alloc] initWithString:theString];
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        [self startedReverseGeoderWithLatitude: l longitude: v];
    }
    [_locationManager stopUpdatingLocation];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
//    NSLog(@"当前城市:%@",placemark.locality);
//    NSLog(@"name:%@",placemark.name);
//    NSLog(@"thoroughfare:%@",placemark.thoroughfare);
//    NSLog(@"subThoroughfare:%@",placemark.subThoroughfare);
//    NSLog(@"locality:%@",placemark.subLocality);
//    NSLog(@"administrativeArea:%@",placemark.administrativeArea);
//    NSLog(@"postalCode:%@",placemark.postalCode);
//    NSLog(@"ISOcountryCode:%@",placemark.ISOcountryCode);
//    NSLog(@"country:%@",placemark.country);
//    NSLog(@"ocean:%@",placemark.ocean);
//    NSLog(@"areasOfInterest:%@",placemark.areasOfInterest);
//    NSLog(@"the end <<<<<");
    if (placemark.thoroughfare)
    {
        NSArray *array = [[NSArray alloc] initWithObjects:[_mdictCard objectForKey:kContactPhoneKey], nil];
        [self sendSMS:[NSString stringWithFormat:@"%@ %@ %@", [[PublicMethod sharedMethod] getValueForKey:kPlaceBeforeKey],placemark.thoroughfare, [[PublicMethod sharedMethod] getValueForKey:kPlaceAfterKey]] recipientList:array];
        [array release];
    }
    else
    {
        [[PublicMethod sharedMethod] showAlert:@"对不起，定位失败!"];
    }
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    [[PublicMethod sharedMethod] showAlert:@"对不起，定位失败!"];
}
@end
