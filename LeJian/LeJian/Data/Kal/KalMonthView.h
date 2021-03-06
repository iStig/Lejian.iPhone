/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KalTileView, KalDate;

@interface KalMonthView : UIView
{
  NSUInteger numWeeks;
}

@property (nonatomic) NSUInteger numWeeks;

- (id)initWithFrame:(CGRect)rect; // designated initializer
- (void)showDates:(NSArray *)mainDates leadingAdjacentDates:(NSArray *)leadingAdjacentDates trailingAdjacentDates:(NSArray *)trailingAdjacentDates;
- (KalTileView *)todaysTileIfVisible;
- (KalTileView *)firstTileOfMonth;
- (KalTileView *)tileForDate:(KalDate *)date;
- (void)markTilesForDates:(NSDictionary *)dates;

@end
