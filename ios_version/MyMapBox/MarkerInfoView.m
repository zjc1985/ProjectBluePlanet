//
//  MarkerInfoView.m
//  MyMapBox
//
//  Created by bizappman on 8/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "MarkerInfoView.h"

@implementation MarkerInfoView

#pragma mark -init

-(void)setUp{
    self.layer.cornerRadius=6;
    self.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.layer.borderWidth=0.7;
    self.layer.masksToBounds=YES;
    
    self.layer.shadowColor=[UIColor blackColor].CGColor;
    self.layer.shadowOpacity=0.3;
    self.layer.shadowRadius=5.0;
    self.layer.shadowOffset=CGSizeMake(0, 1);
    self.clipsToBounds=NO;
}

-(void) awakeFromNib{
    [self setUp];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
