//
//  IconSelectTableViewCell.h
//  MyMapBox
//
//  Created by bizappman on 6/2/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMarker+Dao.h"

@interface IconSelectTableViewCell : UITableViewCell

@property(nonatomic,strong) NSString *iconName;
@property(nonatomic) MMMarkerCategory category;

@end
