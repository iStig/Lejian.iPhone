//
//  SettingViewController.m
//  LeJian
//
//  Created by gongxuehan on 8/13/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "SettingViewController.h"
#import "PublicMethod.h"
#import "ClockManager.h"
#import "AboutUsViewController.h"
#import "FastMessageViewController.h"
#import "LejianData.h"

#define APPLICATIONSCORE    @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=558382675"

NSInteger const kSwitchBaseTag = 86700;

typedef enum {
    RemindSwitchCell = 0,
    AutoCleanLogCell,
    SynchronizationSystemCell,
    ShowDeleteMessageCell,
    EidtFastMessageCell,
//    HelpCell,
}FirstSection;

typedef enum {
    PraiseCell = 0,
    AboutUsCell,
    FeedbackCell,
}SecondSection;

@interface SettingViewController()
{   
    UIButton    *_cancelButton;
    UITableView *_tableView;
    
    NSArray      *_arraySectionOne;
    NSArray      *_arraySectionTwo;
    
    UISwitch     *_switch;
    
    UIButton     *_hidePickerBtn;
    UIPickerView *_pickerView;
    NSArray      *_arrayClean;
    NSArray      *_arrayCleanText;
    NSDictionary *_dictSelectedDate; /// 用于自动清除
    SInt32        _selectedRow;
}

@property (nonatomic, retain) NSDictionary *dictSelectedDate;
- (void)showPickerViewAnimation:(BOOL)isShow;

@end

@implementation SettingViewController
@synthesize dictSelectedDate = _dictSelectedDate;

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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView
//{
//    self.view.backgroundColor = [UIColor redColor];
//}

- (void)dealloc
{
    [super dealloc];
    [_arrayCleanText release];
    [_dictSelectedDate release];
    [_hidePickerBtn release];
    [_arraySectionOne release];
    [_arraySectionTwo release];
    [_tableView release];
    [_cancelButton release];
    [_switch release];
    [_pickerView release];
    [_arrayClean release];
}

- (void)hidePickerView
{
    if (_selectedRow < 7)
    {        
        NSString *str = [NSString stringWithFormat:@"此操作将会清除您在 %@ 前的约会记录,　确定要执行此步操作吗?", [_arrayCleanText objectAtIndex:_selectedRow]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"乐见提示" message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
    }
    else 
    {
        NSString *strRow = [[self.dictSelectedDate allKeys] lastObject];
        [[PublicMethod sharedMethod] saveValue:[NSString stringWithFormat:@"%d", [strRow intValue]] forKey:kCleanIndexKey];
        [[PublicMethod sharedMethod] saveValue:[self.dictSelectedDate objectForKey:strRow] forKey:kCleanDayKey];
        
        UITableViewCell *cell  = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        if ([strRow intValue] <= [_arrayClean count] - 1)
        {
            cell.detailTextLabel.text = [_arrayClean objectAtIndex:[strRow intValue]];
        } 
        [[NSNotificationCenter defaultCenter] postNotificationName:kAutoCleanDateChangedNotificationKey object:nil userInfo:nil];
        [self showPickerViewAnimation:NO];
    }
}

- (void)onBackButton
{
    [(NavigationController *)self.navigationController popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _selectedRow = 1000;
    _arraySectionOne = [[NSArray alloc] initWithObjects:@"提醒开关",@"自动清理日程",@"同步日历",@"删除提示开关",@"编辑快捷短信内容", nil];
    _arraySectionTwo = [[NSArray alloc] initWithObjects:@"给乐见一个评价吧",@"关于我们",@"意见反馈", nil];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, DEVICE_HEIGHT-64) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.clipsToBounds = YES;
    _tableView.dataSource = self;
    [_tableView setShowsVerticalScrollIndicator:NO];
    [[self view] addSubview:_tableView];
    
    _arrayClean = [[NSArray alloc] initWithObjects:@"即时清除",@"保存1天",@"保存2天",@"保存3天",@"保存1周",@"保存2周",@"保存1个月",@"永久保存", nil];
    _arrayCleanText = [[NSArray alloc] initWithObjects:@"此刻",@"1天",@"2天",@"3天",@"1周",@"2周",@"1个月",nil];
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 252)];
    _pickerView.center = HIDE_PICKER_CENTER;
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.showsSelectionIndicator = YES;
    [self.view addSubview:_pickerView];
    [_pickerView selectRow:[[[PublicMethod sharedMethod] getValueForKey:kCleanIndexKey] intValue] inComponent:0 animated:NO];
    
    _hidePickerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 252)];
    _hidePickerBtn.backgroundColor = [UIColor clearColor];
    [_hidePickerBtn addTarget:self action:@selector(hidePickerView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_hidePickerBtn];
    _hidePickerBtn.hidden = YES;
    
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
    [_cancelButton setImage:[UIImage imageNamed:@"back_01.png"] forState:UIControlStateNormal];
    [_cancelButton setImage:[UIImage imageNamed:@"back_02.png"] forState:UIControlStateHighlighted];
    [_cancelButton addTarget:self action:@selector(onBackButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[PublicMethod sharedMethod] saveValue:[NSString stringWithFormat:@"%d", SettingPageTag] forKey:kCurrentPageKey];
    NavigationController *nav = (NavigationController *)self.navigationController;
    [nav setNavigationBarHidden:NO];
    [nav setLeftButton:_cancelButton animated:NO];
    [nav setTitleLogoHiden:YES];
    [nav setTitle:@"设置"];
    nav.leftButton.hidden = NO;
    nav.rightButton.hidden = YES;
}

- (void)showPickerViewAnimation:(BOOL)isShow
{
    CGPoint center = CGPointZero;
    if (isShow)
    {
        _hidePickerBtn.hidden = NO;
        center = SHOW_PICKER_CENTER;
    }
    else 
    {
        center = HIDE_PICKER_CENTER;
    }
    
    [UIView animateWithDuration:0.5 
                          delay:0 
                        options:0 
                     animations:^(void){
                         _pickerView.center = center;
                     } completion:^(BOOL finished){
                         if (!isShow)
                         {
                             _hidePickerBtn.hidden = YES;
                         }
                     }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!section)
    {
        return [_arraySectionOne count];
    }
    else 
    {
        return [_arraySectionTwo count];
    }
    
}

- (void)switchAction:(id)sender
{
    UISwitch *mySwitch = (UISwitch *)sender;
    if (mySwitch.tag == kSwitchBaseTag)
    {
        SInt32 isOn = 0;
        if (mySwitch.on)
        {
            isOn = 1;
        }
        [[ClockManager shardeScheduleData] remindFuntionIsOn:mySwitch.on];
        [[PublicMethod sharedMethod] saveValue:[NSString stringWithFormat:@"%d", isOn] forKey:kRemindKey];
    }
    else if (mySwitch.tag == kSwitchBaseTag + 1)
    {
        SInt32 isOn = 0;
        if (mySwitch.on)
        {
            isOn = 1;
            [[LejianData sharedData] synchronizationSystem:YES];
        }
        else 
        {
            isOn = 0;
            [[LejianData sharedData] synchronizationSystem:NO];
        }
        [[PublicMethod sharedMethod] saveValue:[NSString stringWithFormat:@"%d", isOn] forKey:kSynchronizationSystemKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
    }
    else if (mySwitch.tag == kSwitchBaseTag + 2)
    {
        SInt32 isOn = 0;
        if (mySwitch.on)
        {
            isOn = 1;
        }
        [[PublicMethod sharedMethod] saveValue:[NSString stringWithFormat:@"%d", isOn] forKey:kShowDeleteMessageKey];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CleanCellIdentifier = @"cleanIdentifier";
    static NSString *NormalCellIdentifier = @"normalIdentifier";
    static NSString *RemindCellIdentifier = @"remindCellIdentifier";
    
    UITableViewCell *cell = nil;
    if (indexPath.section)
    {
        cell = [_tableView dequeueReusableCellWithIdentifier:NormalCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NormalCellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = [_arraySectionTwo objectAtIndex:indexPath.row];
    }
    else if (!indexPath.section)
    {
        if (indexPath.row == RemindSwitchCell)
        {
            cell = [_tableView dequeueReusableCellWithIdentifier:RemindCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RemindCellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            CGRect switchRect = CGRectMake(222,7,0,0);
            UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:switchRect];
            mySwitch.tag = kSwitchBaseTag;
            [mySwitch setOn:[[[PublicMethod sharedMethod] getValueForKey:kRemindKey] boolValue]];
            [mySwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:mySwitch];    
            [mySwitch release];    
        }
        else if (indexPath.row == AutoCleanLogCell)
        {
            cell = [_tableView dequeueReusableCellWithIdentifier:CleanCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CleanCellIdentifier] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.textLabel.text = [_arraySectionOne objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [_arrayClean objectAtIndex:[[[PublicMethod sharedMethod] getValueForKey:kCleanIndexKey] intValue]];
        }
        else if (indexPath.row == SynchronizationSystemCell)
        {
            cell = [_tableView dequeueReusableCellWithIdentifier:RemindCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RemindCellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            CGRect switchRect = CGRectMake(222,7,0,0);
            UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:switchRect];
            mySwitch.tag = kSwitchBaseTag + 1;
            [mySwitch setOn:[[[PublicMethod sharedMethod] getValueForKey:kSynchronizationSystemKey] boolValue]];
            [mySwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:mySwitch];    
            [mySwitch release];    
        }
        else if (indexPath.row == ShowDeleteMessageCell)
        {
            cell = [_tableView dequeueReusableCellWithIdentifier:RemindCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RemindCellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            CGRect switchRect = CGRectMake(222,7,0,0);
            UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:switchRect];
            mySwitch.tag = kSwitchBaseTag + 2;
            [mySwitch setOn:[[[PublicMethod sharedMethod] getValueForKey:kShowDeleteMessageKey] boolValue]];
            [mySwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:mySwitch];    
            [mySwitch release];    
        }
        else 
        {
            cell = [_tableView dequeueReusableCellWithIdentifier:NormalCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NormalCellIdentifier] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.textLabel.text = [_arraySectionOne objectAtIndex:indexPath.row];
        }
        cell.textLabel.text = [_arraySectionOne objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section)
    {
        if (AutoCleanLogCell == indexPath.row)
        {
            [self showPickerViewAnimation:YES];
        }
        else if (EidtFastMessageCell == indexPath.row)
        {
            FastMessageViewController *fastMessage = [[FastMessageViewController alloc] init];
            [(NavigationController *)self.navigationController pushViewController:fastMessage animated:YES];
            [fastMessage release];
        }
    }
    else if (indexPath.section == 1)
    {
        if (AboutUsCell == indexPath.row)
        {
            AboutUsViewController *about = [[AboutUsViewController alloc] init];
            [(NavigationController *)self.navigationController pushViewController:about animated:YES];
            [about release];
        }
        else if (FeedbackCell == indexPath.row)
        {
            if([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController * controller = [[[MFMailComposeViewController alloc] init] autorelease];
                NSArray *array = [[NSArray alloc] initWithObjects:@"service@twiker.cn", nil];
                [controller setToRecipients:array];
                [array release];
                [controller setSubject:@"Lejian Feedback"];
                NSDictionary *dict = [[PublicMethod sharedMethod] systemInfo];
                NSString *body = [NSString stringWithFormat:@"\n\n\nDevice:%@ \nVersion:IOS %@ \nLejian version:1.0.1", [dict objectForKey:@"deviceName"], [dict objectForKey:@"version"]];
                [controller setMessageBody:body isHTML:NO];
                controller.mailComposeDelegate = self;
                [self presentModalViewController:controller animated:YES];
            }
            else 
            {
                [[PublicMethod sharedMethod] showAlert:@"您当前设备无法发送邮件,请确定是否正确设置邮箱!"];
            }
        }
        else if (PraiseCell == indexPath.row)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPLICATIONSCORE]];
        }
    }
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES]; 
}

#pragma mark - PickerView Delegate -
#pragma mark - Remind picker delegate -
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_arrayClean count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_arrayClean objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    SInt32 sec = 0;
    switch (row) {
        case 0:
            sec = 0;
            break;
        case 1:
            sec = 1;
            break;
        case 2:
            sec = 2;
            break;
        case 3:
            sec = 3;
            break;
        case 4:
            sec = 7;
            break;
        case 5:
            sec = 14;
            break;
        case 6:
            sec = 30;
            break;
        case 7:
            sec = 99;
            break;
        default:
            break;
    }
    
    NSString *strTime = nil;
    strTime = [NSString stringWithFormat:@"%d", sec];

    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:strTime, [NSString stringWithFormat:@"%d", row], nil];
    self.dictSelectedDate = dict;
    [dict release];
    
    _selectedRow = row;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *strRow = [[self.dictSelectedDate allKeys] lastObject];
        [[PublicMethod sharedMethod] saveValue:[NSString stringWithFormat:@"%d", [strRow intValue]] forKey:kCleanIndexKey];
        [[PublicMethod sharedMethod] saveValue:[self.dictSelectedDate objectForKey:strRow] forKey:kCleanDayKey];
        
        UITableViewCell *cell  = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        if ([strRow intValue] <= [_arrayClean count] - 1)
        {
            cell.detailTextLabel.text = [_arrayClean objectAtIndex:[strRow intValue]];
        } 
        [[NSNotificationCenter defaultCenter] postNotificationName:kAutoCleanDateChangedNotificationKey object:nil userInfo:nil];
        
        [self showPickerViewAnimation:NO];
    }
}

#pragma mark - Mail Delegate -
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}

@end
