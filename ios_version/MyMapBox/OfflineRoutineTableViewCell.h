//
//  OfflineRoutineTableViewCell.h
//  MyMapBox
//
//  Created by bizappman on 4/28/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfflineRoutineTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *routineTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *routineProgressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *routineProgressBar;

@end
