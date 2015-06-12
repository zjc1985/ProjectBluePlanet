//
//  IconSelectTableViewCell.m
//  MyMapBox
//
//  Created by bizappman on 6/2/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "IconSelectTableViewCell.h"

@interface IconSelectTableViewCell()

@end

@implementation IconSelectTableViewCell

-(void)setIconName:(NSString *)iconName{
    UIImage *iconImage=[UIImage imageNamed:iconName];
    if (iconName) {
        _iconName=iconName;
        self.imageView.image=iconImage;
    }
}

-(void)setCategory:(MMMarkerCategory)category{
    _category=category;
    self.textLabel.text=[MMMarker CategoryNameWithMMMarkerCategory:_category];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
