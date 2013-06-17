//
//  ViewController.m
//  LeJian
//
//  Created by gongxuehan on 8/13/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "ViewController.h"
#import "PublicMethod.h"
#import "LeJianDatabase.h"
#import "LeJianRequest.h"
#import <QuartzCore/QuartzCore.h>
#import "ClockManager.h"

#define SHOW_SCROLLVIEW_FRAME CGRectMake(0, 0, 320, 416)
#define HIDE_SCROLLVIEW_FRAME CGRectMake(320, 0, 320, 416)

typedef enum {
    AddType = 0,
    SureType = 1,
}AddButtonType;

NSInteger const kBaseButtonTag = 88000;
NSInteger const kBaseViewTag = 87000;
NSInteger const kAlertBaseTag = 86700;

@interface ViewController ()
{
    TTScrollView        *_ttScrollView;
    NSMutableArray      *_arrayCardList;
    SInt32              _effectiveDate;
    
    UIButton            *_btnCancelNew;
    UIButton            *_btnEdit;
    
    AddButtonType       _addButtonType;
    UIImageView         *_bottomBg;
    
    LejianData          *_LJData;
    BOOL                _bFirst;

    UIImageView         *_vUnexpired;
    UIImageView         *_vExpired;
}

@property (nonatomic, retain) NSMutableArray *arrayCardList;

- (void)appicationDidBecomActive;
@end

@implementation ViewController
@synthesize arrayCardList = _arrayCardList;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kYinDaoWillDisplayNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAutoCleanDateChangedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidReceiveLocalNotificationKey object:nil];

    [_vExpired  release];
    [_vUnexpired release];
    [_bottomBg release];
    [_arrayCardList release];
    [_ttScrollView release];
    [_btnCancelNew release];
    [super dealloc];
}

- (void)editCardAnimation:(BOOL)isEdit
{///bAdd为YES　则是编辑，　NO　为取消 
    NewCardView *editView = (NewCardView *)[_ttScrollView centerPage];
    if (isEdit)
    {
        editView.type = EditType;
    }
    else 
    {
        editView.type = NormalType;
    }
}

- (void)addNewCardAnimation:(BOOL)bAdd
{///bAdd为YES　则是新增，　NO　为取消 
    NewCardView *newCard = (NewCardView *)[self.view viewWithTag:kBaseViewTag];
    CGRect rect = CGRectZero;
    if (bAdd)
    {
        if (newCard)
        {
            return;
        }
        newCard = [[NewCardView alloc] initWithFrame:CGRectMake(0, 480, 320, 367)];
        newCard.delegate = self;
        newCard.tag = kBaseViewTag;
        [self.view addSubview:newCard];
        [self.view bringSubviewToFront:_bottomBg];
        rect = CGRectMake(0, 0, 320, 367);
        _ttScrollView.frame = SHOW_SCROLLVIEW_FRAME;
        [newCard release];
    }
    else
    {
        _ttScrollView.frame = HIDE_SCROLLVIEW_FRAME;
        rect = CGRectMake(0, 480, 320, 367);
    }
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^(void){
                         newCard.frame = rect;
                         if (bAdd)
                         {
                             _ttScrollView.frame = HIDE_SCROLLVIEW_FRAME;
                         }
                         else 
                         {
                             _ttScrollView.frame = SHOW_SCROLLVIEW_FRAME;
                         }
                     }
                     completion:^(BOOL finished){
                         if (!bAdd)
                         {
                             [newCard removeFromSuperview];
                         }
                     }];
}

- (void)reloadTableView
{
    SInt32 index = [_ttScrollView centerPageIndex];
    [_arrayCardList removeObjectAtIndex:index];
    [_ttScrollView reloadData];
    if (index > ([_arrayCardList count] - 1))
    {
        [_ttScrollView setCenterPageIndex:[_arrayCardList count] - 1 animated:YES];
    }
}

- (NSDictionary *)cardListIsFirst:(BOOL)first card_id:(SInt32)card_id
{
    NSDictionary *dict = [[LeJianDatabase sharedDatabase] cardList:first card_id:card_id];
    NavigationController *nav = (NavigationController *)self.navigationController;
    
    if ([[[PublicMethod sharedMethod] getValueForKey:kCurrentPageKey] intValue] == HomePageTag)
    {
        if ([[[PublicMethod sharedMethod] getValueForKey:kCurrentFuntionKey] intValue] == NormalType)
        {
            if (![[dict objectForKey:[[dict allKeys] lastObject]] count]) 
            {
                [[nav leftButton] setHidden:YES];
                _vExpired.hidden = YES;
                _vUnexpired.hidden = YES;
            }
            else
            {
                [nav setLeftButton:_btnEdit animated:NO];
                [[nav leftButton] setHidden:NO];
                _vExpired.hidden = NO;
                _vUnexpired.hidden = NO;
            } 
        } 
    }
    return dict;
}

- (void)deleteCard
{
    if ([_arrayCardList count])
    {
        [[LejianData sharedData] deleteCard:[_arrayCardList objectAtIndex:[_ttScrollView centerPageIndex]]];
    }
    
    NewCardView *view = (NewCardView *)[_ttScrollView pageAtIndex:[_ttScrollView centerPageIndex]];
    NewCardView *nextView = (NewCardView *)[_ttScrollView pageAtIndex:[_ttScrollView centerPageIndex] + 1];
    NewCardView *fontview = (NewCardView *)[_ttScrollView pageAtIndex:[_ttScrollView centerPageIndex] - 1];
    if (view)
    {
        [UIView animateWithDuration:0.3 
                              delay:0
                            options:0 
                         animations:^(void){
                             view.frame = CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height);
                             if (nextView)
                             {  
                                 nextView.frame = CGRectMake(nextView.frame.origin.x - 320, 0, nextView.frame.size.width, nextView.frame.size.height);
                             }
                             else if (fontview)
                             {
                                 fontview.frame = CGRectMake(fontview.frame.origin.x + 320, 0, fontview.frame.size.width, fontview.frame.size.height);
                             }
                         } 
                         completion:^(BOOL finished)
         {
             NSDictionary *cardList = [self cardListIsFirst:YES card_id:0];
             SInt32 index = [_ttScrollView centerPageIndex];
             if ([_ttScrollView centerPageIndex] == [_arrayCardList count] - 1)
             {
                 index -= 1;
             }
             self.arrayCardList = [cardList objectForKey:[[cardList allKeys] lastObject]];
             [_ttScrollView reloadData];
             [_ttScrollView setCenterPageIndex:index];
         }];
    }
}

- (void)buttonClicked:(UIButton *)btn
{
    FuntionType type = [[PublicMethod sharedMethod] currentFuntionType];
    
    NavigationController *nav = (NavigationController *)self.navigationController;
    if (btn.tag == kBaseButtonTag)
    {
        if (type == NormalType)
        {
            if ([[PublicMethod sharedMethod] getValueForKey:kFirstStep2Key] == nil)
            {
                [BDGuideView showGuideImageNamed:@"help02.png" withDelegate:self];
                [[PublicMethod sharedMethod] saveValue:@"1" forKey:kFirstStep2Key];
            }
            [btn setImage:[UIImage imageNamed:@"footbtn_01_2.png"] forState:UIControlStateNormal];
            [[PublicMethod sharedMethod] setFuntionType:NewType];
            [nav setLeftButton:_btnCancelNew animated:NO];
            nav.leftButton.hidden = NO;
            [self addNewCardAnimation:YES];
        }
        else
        {///编辑和新增状态下的确认
            FuntionType type = [[[PublicMethod sharedMethod] getValueForKey:kCurrentFuntionKey] intValue];
            if (type == NewType)
            {
                NewCardView *newCard = (NewCardView *)[self.view viewWithTag:kBaseViewTag];
                if (newCard)
                {
                    [newCard saveNewCard];
                } 
            }
            else if (type == EditType)
            {
                NewCardView *editCard = (NewCardView *)[_ttScrollView centerPage];
                if (editCard)
                {
                    [editCard saveNewCard];
                }
            }
            _ttScrollView.scrollEnabled = YES;
        }
    }
    else if (btn.tag == kBaseButtonTag + 1)
    {///日历
        if (type != NormalType) 
        {
            return;
        }
        LogViewController *log = [[LogViewController alloc] initWithDataSource:[LeJianDatabase sharedDatabase]];
        log.delegate = self;
        [(NavigationController *)self.navigationController pushViewController:log animated:YES];
        [log release];
    }
    else if (btn.tag == kBaseButtonTag + 2)
    {///删除
        if ((type != NormalType) || (![_arrayCardList count])) 
        {
            return;
        }
        NSString *message = nil;
        if ([[[PublicMethod sharedMethod] getValueForKey:kShowDeleteMessageKey] intValue])
        {
            if ([[[PublicMethod sharedMethod] getValueForKey:kSynchronizationSystemKey] intValue])
            {
                message = @"由于您选择将乐见与系统日历同步，该操作将会同步删除您系统日历上的事件提醒，是否确定删除?";
            }
            else
            {
                message = @"是否确定删除该约会卡片?";
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"乐见提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = kAlertBaseTag + 1;
            [alert show];
            [alert release];
        }
        else 
        {
            [self deleteCard];
        }
    }
    else if (btn.tag == kBaseButtonTag + 3)
    {///取消编辑状态或者新建状态
        FuntionType type = [[[PublicMethod sharedMethod] getValueForKey:kCurrentFuntionKey] intValue];
        if (type == NewType) 
        {
            UIView *view = [self.view viewWithTag:kBaseViewTag];
            if ([view superview])
            {
                [self addNewCardAnimation:NO];
                [(NewCardView *)view cancelNewCard];
            }
        }
        else if (type == EditType)
        {
            _ttScrollView.scrollEnabled = YES;
            [self editCardAnimation:NO];
        }
        [nav setLeftButton:_btnEdit animated:NO];
        [[PublicMethod sharedMethod] setFuntionType:NormalType];
        UIButton *btn = (UIButton *)[self.view viewWithTag:kBaseButtonTag];
        if (btn)
        {
            [btn setImage:[UIImage imageNamed:@"footbtn_01.png"] forState:UIControlStateNormal];
        }
    }
    else if (btn.tag == kBaseButtonTag + 4)
    {//edit
        if (![_arrayCardList count])
        {
            return;
        }
        UIButton *btn = (UIButton *)[self.view viewWithTag:kBaseButtonTag];
        if (btn)
        {
            [btn setImage:[UIImage imageNamed:@"footbtn_01_2.png"] forState:UIControlStateNormal];
        }
        [[PublicMethod sharedMethod] setFuntionType:EditType];
        _ttScrollView.scrollEnabled = NO;
        [nav setLeftButton:_btnCancelNew animated:NO];
        nav.leftButton.hidden = NO;
        [self editCardAnimation:YES];
    }
}   

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    _LJData = [LejianData sharedData];
    [[PublicMethod sharedMethod] startLocationManager];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showGuideView) name:kYinDaoWillDisplayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appicationDidBecomActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLocalNotification) name:kDidReceiveLocalNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoCleanDateIsChanged) name:kAutoCleanDateChangedNotificationKey object:nil];
    
    self.view.backgroundColor = [UIColor blueColor];
    
    [[PublicMethod sharedMethod] setFuntionType:NormalType];
    
    UIImageView *vImageBG = [[UIImageView alloc] initWithFrame:self.view.bounds];
    vImageBG.image = [UIImage imageNamed:@"bg.png"];
    [self.view addSubview:vImageBG];
    [vImageBG release];
    
    UIImageView *bottomVImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 367, 320, 49)];
    bottomVImg.image = [UIImage imageNamed:@"bottom_bg.png"];
    [self.view addSubview:bottomVImg];
    [bottomVImg release];
    
    _bFirst = YES;
    
    _ttScrollView = [[TTScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 367)];
    _ttScrollView.backgroundColor = [UIColor clearColor];
    _ttScrollView.delegate = self;
    _ttScrollView.dataSource = self;
    _ttScrollView.scrollEnabled = YES;
    _ttScrollView.zoomEnabled = NO;
    [self.view addSubview:_ttScrollView];
    
    [_ttScrollView setCenterPageIndex:_effectiveDate];
        
    _btnCancelNew = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
    [_btnCancelNew setImage:[UIImage imageNamed:@"back_01.png"] forState:UIControlStateNormal];
    [_btnCancelNew setImage:[UIImage imageNamed:@"back_02.png"] forState:UIControlStateHighlighted];
    _btnCancelNew.tag = kBaseButtonTag + 3;
    [_btnCancelNew addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
    [_btnEdit setImage:[UIImage imageNamed:@"edit_01.png"] forState:UIControlStateNormal];
    [_btnEdit setImage:[UIImage imageNamed:@"edit_02.png"] forState:UIControlStateHighlighted];
    _btnEdit.tag = kBaseButtonTag + 4;
    [_btnEdit addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];

    
    _bottomBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 367, 320, 49)];
    _bottomBg.backgroundColor = [UIColor clearColor];
    _bottomBg.userInteractionEnabled = YES;
    [self.view addSubview:_bottomBg];

    [[PublicMethod sharedMethod] addButtonWithRect:CGRectMake(0, 5, 110, 44) img_n:@"footbtn_02.png" img_p:nil tag:kBaseButtonTag + 1 target:self method:@selector(buttonClicked:) superView:_bottomBg userInteractionEnabled:YES];
    [[PublicMethod sharedMethod] addButtonWithRect:CGRectMake(110, 0, 100, 49) img_n:@"footbtn_01.png" img_p:nil tag:kBaseButtonTag target:self method:@selector(buttonClicked:) superView:_bottomBg userInteractionEnabled:YES];
    [[PublicMethod sharedMethod] addButtonWithRect:CGRectMake(210, 5, 110, 44) img_n:@"footbtn_03.png" img_p:nil tag:kBaseButtonTag + 2 target:self method:@selector(buttonClicked:) superView:_bottomBg userInteractionEnabled:YES];
    
    _vExpired = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 9, 9)];
    _vExpired.center = CGPointMake(148, 357);
    _vExpired.image = [UIImage imageNamed:@"point_02.png"];
    [self.view addSubview:_vExpired];

    _vUnexpired = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 9, 9 )];
    _vUnexpired.center = CGPointMake(170, 357);
    _vUnexpired.image = [UIImage imageNamed:@"point_01.png"];
    [self.view addSubview:_vUnexpired];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex  
{
    if (alertView.tag == kAlertBaseTag + 1)
    {
        if (buttonIndex)
        {
            [self deleteCard];
        }
    }
}   

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[PublicMethod sharedMethod] saveValue:[NSString stringWithFormat:@"%d", HomePageTag] forKey:kCurrentPageKey];

    NavigationController *nav = (NavigationController *)self.navigationController;
    
    if ([[PublicMethod sharedMethod] currentFuntionType] == NormalType)
    {
        [nav setLeftButton:_btnEdit animated:NO];
        if (![_arrayCardList count]) 
        {
            [[nav leftButton] setHidden:YES];
            
        }
        else
        {
            [nav setLeftButton:_btnEdit animated:NO];
            [[nav leftButton] setHidden:NO];
        } 
    } 
    else 
    {
        [nav setLeftButton:_btnCancelNew animated:NO]; 
    }
    
    [nav setDefaultRightSettingButton];
    [nav setTitle:nil];
    [nav setTitleLogoHiden:NO];
    if ([[[PublicMethod sharedMethod] getValueForKey:kIsAppFirstKey] intValue])
    {
        [nav setNavigationBarHidden:NO];
    }
    [nav.rightButton setHidden:NO];
    
}

- (void)showGuideView
{
    if ([[PublicMethod sharedMethod] getValueForKey:kFirstStep1Key] == nil)
    {
        [BDGuideView showGuideImageNamed:@"help01.png" withDelegate:self];
        [[PublicMethod sharedMethod] saveValue:@"1" forKey:kFirstStep1Key];
    }
}

- (void)guideViewWillDisappear:(BDGuideView *)guideView
{
}

- (SInt32)setScrollViewContentOffSet:(NSDictionary *)new_card
{
    SInt32 index = _ttScrollView.centerPageIndex;
    if (![_arrayCardList count]) {
        return 0;
    }
    NSDictionary *now = [_arrayCardList objectAtIndex:index];
    CGFloat currentCard = [[now objectForKey:kDateKey] floatValue];
    CGFloat newCard = [[new_card objectForKey:kDateKey] floatValue];
    
    if (newCard < currentCard)
    {
        index ++;
    }
    return index;
}

- (void)removeNewCardView
{
    UIView *view = [self.view viewWithTag:kBaseViewTag];
    if ([view superview])
    {
        [view removeFromSuperview];
    }
}

#pragma mark - NewCard Delegate -
- (void)newCardIsFinishedEdit:(NSDictionary *)card_info
{
    if (card_info)
    {
        SInt32 card_id = [[card_info objectForKey:kCardIDKey] intValue];
        UIView *view = [self.view viewWithTag:kBaseViewTag];
        FuntionType type = [[PublicMethod sharedMethod] currentFuntionType];
        if (type == EditType) 
        {
            [_LJData updateCardInfo:card_info];
            [[ClockManager shardeScheduleData] modifyLocalNotification:card_info];
            if ([view superview]) {
                [self editCardAnimation:NO];
            }
        }
        else if (type == NewType)
        {            
            [_LJData appendNewCard:card_info];   
            [[ClockManager shardeScheduleData] addNewLocalNotification:card_info];
            _ttScrollView.frame = SHOW_SCROLLVIEW_FRAME;
        }
        [[PublicMethod sharedMethod] setFuntionType:NormalType];
        NSDictionary *cardList = [self cardListIsFirst:NO card_id:card_id];
        SInt32 index = [[[cardList allKeys] lastObject] intValue];
        
        self.arrayCardList = [cardList objectForKey:[[cardList allKeys] lastObject]];
        [_ttScrollView reloadData];
        if (index <= [_arrayCardList count] - 1)
        {
            [_ttScrollView setCenterPageIndex:index];
        }
        if (type == NewType)
        {
            [self performSelector:@selector(removeNewCardView) withObject:nil afterDelay:0.1];
        }
        
        UIButton *btn = (UIButton *)[self.view viewWithTag:kBaseButtonTag];
        NavigationController *nav = (NavigationController *)self.navigationController;
        [nav setLeftButton:_btnEdit animated:NO];
        if (btn)
        {
            [btn setImage:[UIImage imageNamed:@"footbtn_01.png"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - SingleCard Delegate -
- (void)finishedAppendMapInfo:(NSDictionary *)new_cardInfo
{
    if (new_cardInfo)
    {
        [_LJData updateCardInfo:new_cardInfo];
        NSDictionary *cardList = [self cardListIsFirst:YES card_id:0];
        self.arrayCardList = [cardList objectForKey:[[cardList allKeys] lastObject]];
        [_ttScrollView reloadData];
    }
}

- (void)pickerViewIsShowed:(BOOL)isShow
{
    if (isShow)
    {
        _bottomBg.userInteractionEnabled = NO;
    }
    else 
    {
        _bottomBg.userInteractionEnabled = YES;
    }
}

#pragma mark - TTScrollViewDelegate Method -
- (NSInteger)numberOfPagesInScrollView:(TTScrollView *)scrollView
{
    return [_arrayCardList count];
}

- (UIView *)scrollView:(TTScrollView *)scrollView pageAtIndex:(NSInteger)pageIndex
{
    NewCardView *view = (NewCardView *)[scrollView dequeueReusablePage];
    
    if (view == nil)
    {
        view = [[NewCardView alloc] init];
        view.delegate = self;
    }
    [view setEditCardInfo:[_arrayCardList objectAtIndex:pageIndex] funtionType:NormalType];
    view.frame = CGRectMake(320 * pageIndex, 0, 320, 367);
    return view;
}

- (void)scrollView:(TTScrollView *)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex
{
    if (pageIndex <= [_arrayCardList count] - 1)
    {
        if ([[[_arrayCardList objectAtIndex:pageIndex] objectForKey:kDateKey] intValue] <= [[NSDate date] timeIntervalSince1970])
        {
            _vExpired.image = [UIImage imageNamed:@"point_01.png"];
            _vUnexpired.image = [UIImage imageNamed:@"point_02.png"];
        }
        else
        {
            _vExpired.image = [UIImage imageNamed:@"point_02.png"];
            _vUnexpired.image = [UIImage imageNamed:@"point_01.png"];
        }
    }
}

- (CGSize)scrollView:(TTScrollView *)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex
{
    return scrollView.frame.size;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma  mark - EK -
- (void)appicationDidBecomActive
{
    [_LJData appicationDidBecomActive];
    NSDictionary *cardList = nil;
    if (_bFirst)
    {
        _bFirst = NO;
        cardList = [self cardListIsFirst:YES card_id:0];
    }
    else
    {   
        if ([_arrayCardList count])
        {
            cardList = [self cardListIsFirst:NO card_id:[[[_arrayCardList objectAtIndex:[_ttScrollView centerPageIndex]] objectForKey:kCardIDKey] intValue]];
        }
        else
        {
            cardList = [self cardListIsFirst:YES card_id:0];
        }
    }
    _effectiveDate = [[[cardList allKeys] lastObject] intValue];
    self.arrayCardList = [cardList objectForKey:[[cardList allKeys] lastObject]];
    [_ttScrollView reloadData];
    if (_effectiveDate <= [_arrayCardList count] - 1)
    {///如果该页还存在
        [_ttScrollView setCenterPageIndex:_effectiveDate];
    }
    else
    {///该页已经不存在
        if ([_ttScrollView centerPageIndex] >= [_arrayCardList count] - 1)
        {
            [_ttScrollView setCenterPageIndex:[_arrayCardList count] - 1];
        }
    }
}

- (void)didReceiveLocalNotification
{
//    NSDictionary *cardList = [[LeJianDatabase sharedDatabase] cardList:YES card_id:0];
    NSDictionary *cardList = [self cardListIsFirst:YES card_id:0];
    _effectiveDate = [[[cardList allKeys] lastObject] intValue];
    self.arrayCardList = [cardList objectForKey:[[cardList allKeys] lastObject]];
    [_ttScrollView reloadData];
}

#pragma mark - Log Delegate Method -
- (void)oneCardIsBeenSelected:(NSDictionary *)card_info
{
//    NSDictionary *cardList = [[LeJianDatabase sharedDatabase] cardList:NO card_id:[[card_info objectForKey:kCardIDKey] intValue]];
    NSDictionary *cardList = [self cardListIsFirst:NO card_id:[[card_info objectForKey:kCardIDKey] intValue]];
    _effectiveDate = [[[cardList allKeys] lastObject] intValue];
    [_ttScrollView setCenterPageIndex:_effectiveDate];
}

#pragma mark - SettingViewController notification method-
- (void)autoCleanDateIsChanged
{
//    NSDictionary *cardList = [[LeJianDatabase sharedDatabase] cardList:YES card_id:0];
    NSDictionary *cardList = [self cardListIsFirst:YES card_id:0];
    _effectiveDate = [[[cardList allKeys] lastObject] intValue];
    self.arrayCardList = [cardList objectForKey:[[cardList allKeys] lastObject]];
    [_ttScrollView reloadData];
    [_ttScrollView setCenterPageIndex:_effectiveDate];
}

@end
