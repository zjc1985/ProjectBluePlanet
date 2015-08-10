//
//  BaseOvIconSelectTVC.h
//  MyMapBox
//
//  Created by bizappman on 7/27/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseOvIconSelectTVC : UITableViewController

@property(nonatomic,strong)NSString *selectedUrl;
@property(strong,nonatomic)NSArray *allOvIconUrls;

-(NSString *)reUseCellName; //abstract

@end
