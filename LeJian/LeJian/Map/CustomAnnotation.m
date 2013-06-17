//
//  CustomAnnotationView.m
//  LeJian
//
//  Created by gongxuehan on 8/28/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "CustomAnnotationView.h"

@implementation CustomAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{  
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];  
    if (self) {  
        
        //大头针的图片   
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-3, 0, 20, 20)];  
        [imageView setImage:[UIImage imageNamed:@"ball.png"]];  
        [self addSubview:imageView];  
    }  
    return self;  
}  

- (void)dealloc  
{  
    [super dealloc];  
}  

@end
