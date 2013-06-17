//
//  LogViewController.m
//  LeJian
//
//  Created by gongxuehan on 8/20/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "LogViewController.h"
#import "PublicMethod.h"
#import "NewCardView.h"

NSInteger const kLogBaseTag = 12340;

@interface LogViewController()
{
    UITableView     *_tableView;
    NSArray         *_arrayDayCard;
    UIButton        *_btnCancelNew;
    UIImageView     *_vCardBG;
}

@property (nonatomic, retain) NSArray *arrayDayCard;

@end

@implementation LogViewController
@synthesize arrayDayCard = _arrayDayCard;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDataSource:(id<KalDataSource>)source
{
    if ((self = [super init])) {
        dataSource = [source retain];
    }
    return self;
}  

- (id)init
{
    return [self initWithDataSource:[SimpleKalDataSource dataSource]];
}

- (KalView*)calendarView { return _kalView; };

- (void)fetchDataForCurrentMonth
{
    if ([dataSource respondsToSelector:@selector(presentingDatesFrom:to:delegate:)]) {
        [dataSource presentingDatesFrom:logic.fromDate to:logic.toDate delegate:self];
    }
}

- (void)refreshDetailView:(KalDate *)date
{
    if (selectedDate != date)
    {
        [selectedDate release];
        selectedDate = [date retain];
    }
    
    NSDate *from = [[date NSDate] cc_dateByMovingToBeginningOfDay];
    NSDate *to = [[date NSDate] cc_dateByMovingToEndOfDay];
    
    LeJianDatabase *database = [LeJianDatabase sharedDatabase];
    [database loadItemsFromDate:from toDate:to];
    
    NSDictionary *dict = [database loadItemsFromDate:from toDate:to];
    if (dict)
    {
        NSString *key = [[dict allKeys] lastObject];
        self.arrayDayCard = [dict objectForKey:key];
        [_tableView reloadData];
    }
}
- (void)didSelectDate:(KalDate *)date
{    
    if (!date)
    {
        return;
    }
    [self refreshDetailView:date];
}

- (void)layoutLogStatistics
{
    
}

- (void)showPreviousMonth
{
    [logic retreatToPreviousMonth];
    [[self calendarView] slideDown];
    [self fetchDataForCurrentMonth];
    [self layoutLogStatistics];
}

- (void)showFollowingMonth
{
    [logic advanceToFollowingMonth];
    [[self calendarView] slideUp];
    [self fetchDataForCurrentMonth];
    [self layoutLogStatistics];
}

- (void)loadDataSource:(id<KalDataSource>)theDataSource;
{
    NSDictionary *markedDates = [theDataSource markedDatesFrom:logic.fromDate to:logic.toDate];
    
    [[self calendarView] markTilesForDates:markedDates];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)dealloc
{
    [super dealloc];
    [_vCardBG release];
    [logic release];
    [_kalView release];
    [_btnCancelNew release];
    [_tableView release];
}

- (void)buttonClicked:(UIButton *)btn
{
    if ([self.view viewWithTag:kLogBaseTag])
    {
        [[self.view viewWithTag:kLogBaseTag] removeFromSuperview];
        NavigationController *nav = (NavigationController *)self.navigationController;
        [[nav rightButton] setHidden:YES];
        _vCardBG.alpha = 0;
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (logic == nil) {
        logic = [[KalLogic alloc] init];
    }
    
    _kalView = [[KalView alloc] initWithFrame:CGRectMake(0, 0, 320, 272) delegate:self logic:logic];
    [self.view addSubview:_kalView];
    [self fetchDataForCurrentMonth];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 272, 320, 144) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
    
    UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 272, 320, 16)];
    coverView.image = [UIImage imageNamed:@"bg02.png"];
    [self.view addSubview:coverView];
    [coverView release];
    
    _vCardBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    _vCardBG.backgroundColor = [UIColor grayColor];
    _vCardBG.alpha = 0;
    [self.view addSubview:_vCardBG];

    _btnCancelNew = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
    [_btnCancelNew setImage:[UIImage imageNamed:@"Cross_01.png"] forState:UIControlStateNormal];
    [_btnCancelNew setImage:[UIImage imageNamed:@"Cross_02.png"] forState:UIControlStateHighlighted];
    [_btnCancelNew addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[PublicMethod sharedMethod] saveValue:[NSString stringWithFormat:@"%d", LogPageTag] forKey:kCurrentPageKey];
    NavigationController *nav = (NavigationController *)self.navigationController;
    [nav setLeftBackButton];
    nav.rightButton.hidden = YES;
    [nav setTitleLogoHiden:YES];
    [nav setTitle:@"日历"];
    [[self calendarView] selectTodayIfVisible];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)showCardAnimation:(SInt32)index
{
    NavigationController *nav = (NavigationController *)self.navigationController;

    NewCardView *newCard = [[NewCardView alloc] initWithFrame:CGRectMake(0, 0, 320, 367)];
    [newCard setEditCardInfo:[self.arrayDayCard objectAtIndex:index] funtionType:NormalType];
    newCard.alpha = 0;
    newCard.tag = kLogBaseTag;
    [self.view addSubview:newCard];
    [newCard release];
    
    [UIView animateWithDuration:0.3 
                          delay:0 
                        options:0 
                     animations:^(void){
                         newCard.alpha = 1.0;
                         _vCardBG.alpha = 0.5;
                     } completion:^(BOOL finished){
                         [nav setRightButton:_btnCancelNew animated:NO];
                         [[nav rightButton] setHidden:NO];
                     }];
}

- (NSString *)processDate:(NSString *)strSec
{
    SInt32 sec = [strSec intValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:sec];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"HH:mm"];
    NSString *strDate = [fmt stringFromDate:date];
    [fmt release];
    return strDate;
}

#pragma mark - ScrollView Delegate -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayDayCard count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier] autorelease];
    }
    NSDictionary *dict = [self.arrayDayCard objectAtIndex:indexPath.row];
    cell.textLabel.text = [self processDate:[dict objectForKey:kDateKey]];
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    
    NSString *name = [dict objectForKey:kContactNameKey];
    if (name == nil || [name isEqualToString:@""])
    {
        name = @"未添加联系人";
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"与 %@ 乐见", name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([_delegate respondsToSelector:@selector(oneCardIsBeenSelected:)])
    {
        [_delegate oneCardIsBeenSelected:[self.arrayDayCard objectAtIndex:indexPath.row]];
    }
    [(NavigationController *)self.navigationController popViewControllerAnimated:NO];
//    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES]; 
}

@end
