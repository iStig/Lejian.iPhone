//
//  ThumbMapView.m
//  LeJian
//
//  Created by gongxuehan on 9/2/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "ThumbMapView.h"

NSInteger const kMapBaseTag = 234890;

@interface ThumbMapView()
{
}
@end

@implementation ThumbMapView

- (void)dealloc
{   
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame mapView:(NSString *)path topClickedMethod:(SEL)method bottomClickMethod:(SEL)method2 superView:(UIView *)superView  name:(NSString *)name tag:(SInt32)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.tag = tag;
        ///map
        UIImage *map = [[UIImage alloc] initWithContentsOfFile:path];
        UIImageView *vImageMap = [[UIImageView alloc] initWithFrame:self.bounds];
        vImageMap.image = map;
        [map release];
        [self addSubview:vImageMap];
        [vImageMap release];
        ///cover view
        UIImageView *vImageCover = [[UIImageView alloc] initWithFrame:self.bounds];
        vImageCover.image = [UIImage imageNamed:@"map_bg.png"];
        [self addSubview:vImageCover];
        
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
        [self addSubview:allBg];
        [allBg release];
        [labelName release];
        
        
        UIButton *topBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 20)];
        topBtn.backgroundColor = [UIColor clearColor];
        topBtn.tag = kMapBaseTag;
        [topBtn addTarget:superView action:method forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:topBtn];
        [topBtn release];
        
        UIButton *bottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20)];
        bottomBtn.tag = kMapBaseTag + 1;
        bottomBtn.backgroundColor = [UIColor clearColor];
        [bottomBtn addTarget:superView action:method2 forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bottomBtn];
        
        [vImageCover release];
    }
    return self;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [[self viewWithTag:kMapBaseTag] setUserInteractionEnabled:userInteractionEnabled];
    [[self viewWithTag:kMapBaseTag + 1] setUserInteractionEnabled:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
