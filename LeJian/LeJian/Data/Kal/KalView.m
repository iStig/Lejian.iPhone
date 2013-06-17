/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalView.h"
#import "KalGridView.h"
#import "KalLogic.h"
#import "KalPrivate.h"
#import "KalTileView.h"

#define LED_DIG_FONT        [UIFont fontWithName:@"DigifaceWide" size:15.0f]
#define HEAD_DATE_GREEN_COLOR  [UIColor colorWithRed:109.0/255.0 green:170.0/255.0 blue:5.0/255.0 alpha:1.0]

#define CONTENT_VIEW_FRAME CGRectMake(0.f, kHeaderHeight, 320, self.frame.size.height - kHeaderHeight)
#define ANIMATION_SPLIT_COUNT 2
#define ANIMATION_HEIGHT 87

#ifndef PathForImageNamed
#define PathForImageNamed(n)      [NSString stringWithFormat:@"%@/ChargeLogging/Resources/%@", [[NSBundle mainBundle] bundlePath], n]
#endif

@interface KalView ()
{
    UIView *_contentView;
}
- (void)addSubviewsToHeaderView:(UIView *)headerView;
- (void)addSubviewsToContentView:(UIView *)contentView;
- (void)setHeaderTitleText:(NSString *)text;
@end

static const CGFloat kHeaderHeight = 56.f;

@implementation KalView

@synthesize delegate, tableView;

- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)theDelegate logic:(KalLogic *)theLogic
{
  if ((self = [super initWithFrame:frame])) 
  {
    delegate = theDelegate;
    logic = [theLogic retain];
    [logic addObserver:self forKeyPath:@"selectedMonthNameAndYear" options:NSKeyValueObservingOptionNew context:NULL];
    // Content
    _contentView = [[UIView alloc] initWithFrame:CONTENT_VIEW_FRAME];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _contentView.clipsToBounds = YES; 
    [self addSubviewsToContentView:_contentView];
    [self addSubview:_contentView];
      
    // Header
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, kHeaderHeight)] autorelease];
    headerView.backgroundColor = [UIColor clearColor];
    headerView.clipsToBounds = YES;
    [self addSubviewsToHeaderView:headerView];
    [self addSubview:headerView];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  [NSException raise:@"Incomplete initializer" format:@"KalView must be initialized with a delegate and a KalLogic. Use the initWithFrame:delegate:logic: method."];
  return nil;
}

- (void)slideDown { [gridView slideDown]; }
- (void)slideUp { [gridView slideUp]; }
- (void)refreshDate 
{
    [logic moveToTodaysMonth];
    [gridView refreshDate];
}

- (void)showPreviousMonth
{
  if (!gridView.transitioning)
    [delegate showPreviousMonth];
}

- (void)showFollowingMonth
{
  if (!gridView.transitioning)
    [delegate showFollowingMonth];
}

- (void)addSubviewsToHeaderView:(UIView *)headerView
{
  const CGFloat kChangeMonthButtonWidth = 23;
  const CGFloat kChangeMonthButtonHeight = 23;
  const CGFloat kMonthLabelWidth = 200.0f;
  
  // Header background gradient
    UIImageView *backgroundView = nil;
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    UIImage *backgroundImage = nil;
    if (systemVersion < 5.0)
    {
        backgroundImage = [[UIImage imageNamed:@"yearbg01.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];
    } 
    else
    {
        backgroundImage = [[UIImage imageNamed:@"yearbg01.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2.0, 0, 0)];
    }

    backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    CGRect imageFrame = headerView.frame;
    imageFrame.size.height = 38.0f;
    imageFrame.origin = CGPointZero;
    backgroundView.frame = imageFrame;
    [headerView addSubview:backgroundView];
    [backgroundView release];
  
  // Create the previous month button on the left side of the view
    CGRect previousMonthButtonFrame = CGRectMake(14,
                                                 9,
                                                 kChangeMonthButtonWidth,
                                                 kChangeMonthButtonHeight);
    UIButton *previousMonthButton = [[UIButton alloc] initWithFrame:previousMonthButtonFrame];
    [previousMonthButton setImage:[UIImage imageNamed:@"leftbtn01.png"] forState:UIControlStateNormal];
//    [previousMonthButton setImage:[UIImage imageWithContentsOfFile:PathForImageNamed(@"calendar_head_left_click.png")] forState:UIControlStateHighlighted];  
    previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [previousMonthButton addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:previousMonthButton];
    [previousMonthButton release];
    previousMonthButton.showsTouchWhenHighlighted = NO;
  
  // Draw the selected month name centered and at the top of the view
  CGRect monthLabelFrame = CGRectMake((self.width/2.0f) - (kMonthLabelWidth/2.0f),
                                      9,
                                      kMonthLabelWidth,
                                      20);
  headerTitleLabel = [[UILabel alloc] initWithFrame:monthLabelFrame];
  headerTitleLabel.backgroundColor = [UIColor clearColor];
  headerTitleLabel.font = [UIFont systemFontOfSize:20.f];
  headerTitleLabel.textAlignment = UITextAlignmentCenter;
  headerTitleLabel.textColor = [UIColor blackColor];//HEAD_DATE_GREEN_COLOR;
  [self setHeaderTitleText:[logic selectedMonthNameAndYear]];
  [headerView addSubview:headerTitleLabel];
  
  // Create the next month button on the right side of the view
  CGRect nextMonthButtonFrame = CGRectMake(self.width - kChangeMonthButtonWidth - 14,
                                           9,
                                           kChangeMonthButtonWidth,
                                           kChangeMonthButtonHeight);
  UIButton *nextMonthButton = [[UIButton alloc] initWithFrame:nextMonthButtonFrame];
  [nextMonthButton setImage:[UIImage imageNamed:@"rightbtn01.png"] forState:UIControlStateNormal];  
//  [nextMonthButton setImage:[UIImage imageWithContentsOfFile:PathForImageNamed(@"calendar_head_right_click.png")] forState:UIControlStateHighlighted]; 
  nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
  nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  [nextMonthButton addTarget:self action:@selector(showFollowingMonth) forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:nextMonthButton];
  [nextMonthButton release];
  nextMonthButton.showsTouchWhenHighlighted = NO;

  // Add column labels for each weekday (adjusting based on the current locale's first weekday)
  //gongxuehan:title of week day , month
    UIImageView *weekBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 38, 320, 18)];
    weekBG.image = [UIImage imageNamed:@"weekbg01.png"];
    [headerView addSubview:weekBG];
    
  NSArray *weekdayNames = [[[[NSDateFormatter alloc] init] autorelease] shortWeekdaySymbols];
  NSUInteger firstWeekday = [[NSCalendar currentCalendar] firstWeekday];
  NSUInteger i = firstWeekday - 1;
  for (CGFloat xOffset = 0.f; xOffset < headerView.width; xOffset += 45.f, i = (i+1)%7) {
    CGRect weekdayFrame = CGRectMake(xOffset, 0.f, 45.f, 18);
    UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
    weekdayLabel.backgroundColor = [UIColor clearColor];
    weekdayLabel.font = [UIFont boldSystemFontOfSize:10.f];
    weekdayLabel.textAlignment = UITextAlignmentCenter;
    weekdayLabel.textColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.f];
    weekdayLabel.text = [weekdayNames objectAtIndex:i];
    [weekBG addSubview:weekdayLabel];
    [weekdayLabel release];
  }
    [weekBG release];

}

- (void)addSubviewsToContentView:(UIView *)contentView
{
  // Both the tile grid and the list of events will automatically lay themselves
  // out to fit the # of weeks in the currently displayed month.
  // So the only part of the frame that we need to specify is the width.
  CGRect fullWidthAutomaticLayoutFrame = CGRectMake(0.f, 0.f, 320, 216.0f);

    UIImage *image = nil;
    CGRect frame = contentView.frame;
    frame.origin = CGPointZero;
    UIImageView *vImage = [[UIImageView alloc] initWithFrame:frame];
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion < 5.0)
    {
        image = [[UIImage imageNamed:@"bg01.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];   
    } 
    else
    {
        image = [[UIImage imageNamed:@"bg01.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)] ;
    }
    vImage.image = image;
    [contentView addSubview:vImage];
    [vImage release];

  // The tile grid (the calendar body)
  gridView = [[KalGridView alloc] initWithFrame:fullWidthAutomaticLayoutFrame logic:logic delegate:delegate];
  [gridView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
  [contentView addSubview:gridView]; 
  
  // The list of events for the selected day
//  tableView = [[UITableView alloc] initWithFrame:fullWidthAutomaticLayoutFrame style:UITableViewStylePlain];
//  tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//  tableView.allowsSelection = NO;
//  [contentView addSubview:tableView];
  
  // Drop shadow below tile grid and over the list of events for the selected day
//  shadowView = [[UIImageView alloc] initWithFrame:fullWidthAutomaticLayoutFrame];
  
//  UIImage *image = nil;
//  CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
//  if (systemVersion < 5.0)
//  {
//      image = [[UIImage imageNamed:@"2_bg_3shadow.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];   
//  } 
//  else
//  {
//      image = [[UIImage imageNamed:@"2_bg_3shadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2.0, 0, 0)] ;
//  }
//
//  shadowView.image = image;
//  shadowView.height = shadowView.image.size.height;
//  [contentView addSubview:shadowView];
// Trigger the initial KVO update to finish the contentView layout
  [gridView sizeToFit];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (object == gridView && [keyPath isEqualToString:@"frame"]) {
    
    /* Animate tableView filling the remaining space after the
     * gridView expanded or contracted to fit the # of weeks
     * for the month that is being displayed.
     *
     * This observer method will be called when gridView's height
     * changes, which we know to occur inside a Core Animation
     * transaction. Hence, when I set the "frame" property on
     * tableView here, I do not need to wrap it in a
     * [UIView beginAnimations:context:].
     */
    CGFloat gridBottom = gridView.top + gridView.height;
    CGRect frame = tableView.frame;
    frame.origin.y = gridBottom;
    frame.size.height = tableView.superview.height - gridBottom;
    tableView.frame = frame;
    shadowView.top = gridBottom;
    
  } else if ([keyPath isEqualToString:@"selectedMonthNameAndYear"]) {
    [self setHeaderTitleText:[change objectForKey:NSKeyValueChangeNewKey]];
    
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (void)setHeaderTitleText:(NSString *)text
{
  [headerTitleLabel setText:text];
  [headerTitleLabel sizeToFit];
  headerTitleLabel.left = floorf(self.width/2.f - headerTitleLabel.width/2.f);
}

- (void)selectDate:(KalDate *)date
{
    [gridView selectDate:date];
}

- (BOOL)isTodayChanged
{
    return [gridView isTodayChanged];
}

- (void)jumpToSelectedMonth { [gridView jumpToSelectedMonth]; }

- (void)selectTodayIfVisible { [gridView selectTodayIfVisible]; }

- (BOOL)isSliding { return gridView.transitioning; }

- (void)markTilesForDates:(NSDictionary *)dates { [gridView markTilesForDates:dates]; }

- (void)contentViewAnimation:(CGRect)newRect
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options:0 
                     animations:^(void){
                         _contentView.frame = newRect;
                     } 
                     completion:^(BOOL finished){
                     }]; 
}

- (void)showDetailChargeLogView
{
    int row = gridView.selectedTile.row;
    CGRect newRect = CONTENT_VIEW_FRAME;
    if (row > ANIMATION_SPLIT_COUNT)
    {
        newRect.origin.y = kHeaderHeight - ANIMATION_HEIGHT;
    }
    else 
    {
        newRect.size.height = newRect.size.height - ANIMATION_HEIGHT;
    }
    [self contentViewAnimation:newRect];
}

- (void)hideDetailChargeLogView
{
    [self contentViewAnimation:CONTENT_VIEW_FRAME];
}

- (KalDate *)selectedDate { return gridView.selectedDate; }

- (void)dealloc
{
  [logic removeObserver:self forKeyPath:@"selectedMonthNameAndYear"];
  [logic release];
  
  [_contentView release];
  [headerTitleLabel release];
  [gridView removeObserver:self forKeyPath:@"frame"];
  [gridView release];
  [tableView release];
  [shadowView release];
  [super dealloc];
}

@end
