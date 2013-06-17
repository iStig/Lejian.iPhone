/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <CoreGraphics/CoreGraphics.h>
#import "KalMonthView.h"
#import "KalTileView.h"
#import "KalView.h"
#import "KalDate.h"
#import "KalPrivate.h"

#ifndef PathForImageNamed
#define PathForImageNamed(n)      [NSString stringWithFormat:@"%@/ChargeLogging/Resources/%@", [[NSBundle mainBundle] bundlePath], n]
#endif

extern const CGSize kTileSize;

@implementation KalMonthView

@synthesize numWeeks;

- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
//    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    for (int i=0; i<6; i++) {
      for (int j=0; j<7; j++) {
        CGRect r = CGRectMake(j*(kTileSize.width + 1), i*(kTileSize.height + 1) + 1, kTileSize.width, kTileSize.height);
        [self addSubview:[[[KalTileView alloc] initWithFrame:r row:i] autorelease]];
      }
    }
  }
  return self;
}

- (void)showDates:(NSArray *)mainDates leadingAdjacentDates:(NSArray *)leadingAdjacentDates trailingAdjacentDates:(NSArray *)trailingAdjacentDates
{
  int i = 0;
  
  for (KalDate *d in leadingAdjacentDates) {
    KalTileView *tile = [self.subviews objectAtIndex:i];
    [tile resetState];
    tile.type = KalTileTypeAdjacent;
    tile.date = d;
    [tile setNeedsDisplay];
    i++;
  }
  
  for (KalDate *d in mainDates) {
    KalTileView *tile = [self.subviews objectAtIndex:i];
    [tile resetState];
    tile.type = [d isToday] ? KalTileTypeToday : KalTileTypeRegular;
    tile.date = d;
    [tile setNeedsDisplay];
    i++;
  }
  
  for (KalDate *d in trailingAdjacentDates) 
  {
    KalTileView *tile = [self.subviews objectAtIndex:i];
    [tile resetState];
    tile.type = KalTileTypeAdjacent;
    tile.date = d;
    [tile setNeedsDisplay];
    i++;
  }

  numWeeks = 6;
  [self sizeToFit];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
//  CGContextRef ctx = UIGraphicsGetCurrentContext();
//  CGContextDrawTiledImage(ctx, (CGRect){CGPointZero,kTileSize}, [[UIImage imageNamed:@"kal_tile.png"] CGImage]);
//    CGRect line;
//    UIColor *color;
//        
//    //horizontal line
//    //gongxuehan mark:draw line
//    for(int i=0; i<numWeeks; i++) {
//        if (!i) 
//        {
//            line = CGRectMake(0, i*kTileSize.height , self.width, 1);
//            color = [UIColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
//            [color set];
//            CGContextFillRect(UIGraphicsGetCurrentContext(), line);
//        }
//        else 
//        {
//            line = CGRectMake(0, i*kTileSize.height, self.width, 1);
//            color = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
//            [color set];
//            CGContextFillRect(UIGraphicsGetCurrentContext(), line);
//        }
//        line = CGRectMake(5, (i+1)*kTileSize.height-1, self.width, 1);
//        color = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
//        [color set];
//        CGContextFillRect(UIGraphicsGetCurrentContext(), line);
    }
    
//    line = CGRectMake(0, numWeeks*kTileSize.height-2, self.width, 1);
//    color = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0];
//    [color set];
//    CGContextFillRect(UIGraphicsGetCurrentContext(), line);
//    line = CGRectMake(0, numWeeks*kTileSize.height - 2, self.width, 1);
//    color = [UIColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
//    [color set];
//    CGContextFillRect(UIGraphicsGetCurrentContext(), line);
    
//    //vertical line
//    for(int i=0; i<8; i++) {
//        line = CGRectMake(i*kTileSize.width, 0, 1, self.height);
//        if (i == 7)
//        {
//            line = CGRectMake(7 * kTileSize.width - 1, 0, 1, self.height);
//        }
//        color = [UIColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
//        [color set];
//        CGContextFillRect(UIGraphicsGetCurrentContext(), line);
//    }
//}

- (KalTileView *)todaysTileIfVisible
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if ([t isToday]) {
      tile = t;
      break;
    }
  }
  
  return tile;
}

- (KalTileView *)firstTileOfMonth
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if (!t.belongsToAdjacentMonth) {
      tile = t;
      break;
    }
  }
  
  return tile;
}

- (KalTileView *)tileForDate:(KalDate *)date
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if ([t.date isEqual:date]) {
      tile = t;
      break;
    }
  }
  
  return tile;
}

- (void)sizeToFit
{
  self.height = (kTileSize.height + 1) * numWeeks + 1;
}

//dates: date->array of type gongxuehan mark
- (void)markTilesForDates:(NSDictionary *)dates
{
    for (KalTileView *tile in self.subviews) {
        NSArray *types = [dates objectForKey:[tile.date NSDate]];
        [tile.markedTypes removeAllObjects];
        if (types && [types count]) {
            tile.marked = YES;
            [tile.markedTypes addObjectsFromArray:types];
        } else {
            tile.marked = NO;
        }
    }
}

@end
