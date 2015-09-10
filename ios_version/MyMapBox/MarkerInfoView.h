//
//  MarkerInfoView.h
//  MyMapBox
//
//  Created by bizappman on 8/12/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarkerInfoView : UIView

@property (weak, nonatomic) IBOutlet UILabel *markerInfoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *markerInfoSubLabel;
@property (weak, nonatomic) IBOutlet UILabel *markerInfoContentLabel;

@end
