//
//  ThumbNailCell.h
//  photoFrameWorkExercise
//
//  Created by bizappman on 9/15/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbImage;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *creationTimeLabel;

@end
