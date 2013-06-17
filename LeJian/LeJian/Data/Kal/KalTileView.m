/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalTileView.h"
#import "KalDate.h"
#import "KalPrivate.h"

#define GREEN_TEXT_COLOR [UIColor colorWithRed:109.0/255.0 green:172.0/255.0 blue:0/255.0 alpha:1.0f]
#define BLUE_TEXT_COLOR [UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:249.0/255.0 alpha:1.0f]
#define RED_TEXT_COLOR [UIColor colorWithRed:255.0/255.0 green:15.0/255.0 blue:4.0/255.0 alpha:1.0f]

#define MARK_IMAGE_FRAME CGRectMake(32, 0, 13, 13)
extern const CGSize kTileSize;
static NSString *typeImages[] = {@"blueMark.png", @"greenMark.png", @"RedMark.png"};

#ifndef PathForImageNamed
#define PathForImageNamed(n)      [NSString stringWithFormat:@"%@/ChargeLogging/Resources/%@", [[NSBundle mainBundle] bundlePath], n]
#endif


@implementation KalTileView

@synthesize date, markedTypes, row;

- (id)initWithFrame:(CGRect)frame row:(int)r
{
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    origin = frame.origin;
    self.row = r;
    markedTypes = [[NSMutableArray alloc] initWithCapacity:3];
    [self resetState];
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{
    NSUInteger n = [self.date day];
    CGFloat fontSize = 17.0f;
    UIFont *font = [UIFont fontWithName:@"STHeitiSC-Medium" size:fontSize];
//    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    NSString *text = nil;
    if (n)
    {
        text = [NSString stringWithFormat:@"%d", n]; 
    }
    CGSize size = [text sizeWithFont:font];
    
    CGRect textRect = CGRectMake(0, (kTileSize.height - size.height) / 2, kTileSize.width, kTileSize.height);

    UIImage *imgBg = [UIImage imageNamed:@"daybg01.png"];
    if (self.belongsToAdjacentMonth)
    {
        imgBg = [UIImage imageNamed:@"daybg02.png"];
    }
    [imgBg drawInRect:CGRectMake(0, 0, kTileSize.width, kTileSize.height)];
    
    UIColor *textColor = nil;
    
    if(self.belongsToAdjacentMonth)
    {
        textColor = [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1.0];
    } else 
    {
        textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
        if ([self isToday])
        {
            textColor = GREEN_TEXT_COLOR;
        }
        if (self.selected)
        {
            textColor = [UIColor whiteColor];
        }
        if ([markedTypes count]) 
        {
            UIImage *markImage = [UIImage imageNamed:@"side01.png"];
            [markImage drawInRect:MARK_IMAGE_FRAME];
        }
    }
    [textColor set];
    
    if (self.selected) {
        UIImage *selectedMark = [UIImage imageNamed:@"daybg03.png"];
        [selectedMark drawInRect:rect];
    }
    
    //gongxuehan mark: set date of day
    [text drawInRect:textRect withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
    [self setNeedsDisplay];
}

- (void)resetState
{
  // realign to the grid
  CGRect frame = self.frame;
  frame.origin = origin;
  frame.size = kTileSize;
  self.frame = frame;
  
  [date release];
  date = nil;
  flags.type = KalTileTypeRegular;
  flags.highlighted = NO;
  flags.selected = NO;
  flags.marked = NO;
  [markedTypes removeAllObjects];
}

- (void)setDate:(KalDate *)aDate
{
  if (date == aDate)
    return;

  [date release];
  date = [aDate retain];

  [self setNeedsDisplay];
}

- (BOOL)isSelected { return flags.selected; }

- (void)setSelected:(BOOL)selected
{
//  if (flags.selected == selected)
//    return;

  // workaround since I cannot draw outside of the frame in drawRect:
//  if (![self isToday]) {
//    CGRect rect = self.frame;
//    if (selected) {
//      rect.origin.x--;
//      rect.size.width++;
//      rect.size.height++;
//    } else {
//      rect.origin.x++;
//      rect.size.width--;
//      rect.size.height--;
//    }
//    self.frame = rect;
//  }
  
  flags.selected = selected;
  [self setNeedsDisplay];
}

- (BOOL)isHighlighted { return flags.highlighted; }

- (void)setHighlighted:(BOOL)highlighted
{
  if (flags.highlighted == highlighted)
    return;
  
  flags.highlighted = highlighted;
  [self setNeedsDisplay];
}

- (BOOL)isMarked { return flags.marked; }

- (void)setMarked:(BOOL)marked
{
//  if (flags.marked == marked)
//    return;
  
  flags.marked = marked;
  [self setNeedsDisplay];
}

- (KalTileType)type { return flags.type; }

- (void)setType:(KalTileType)tileType
{
  if (flags.type == tileType)
    return;
  
  // workaround since I cannot draw outside of the frame in drawRect:
//  CGRect rect = self.frame;
//  if (tileType == KalTileTypeToday) {
//    rect.origin.x--;
//    rect.size.width++;
//    rect.size.height++;
//  } else {
//    rect.origin.x++;
//    rect.size.width--;
//    rect.size.height--;
//  }
//  self.frame = rect;
  
  flags.type = tileType;
  [self setNeedsDisplay];
}

- (BOOL)isToday { return flags.type == KalTileTypeToday; }

- (BOOL)belongsToAdjacentMonth { return flags.type == KalTileTypeAdjacent; }

- (void)dealloc
{
  [markedTypes release];
  [date release];
  [super dealloc];
}

@end
