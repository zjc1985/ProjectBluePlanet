//
//  NSMutableArray+StackExtension.h
//  MyMapBox
//
//  Created by bizappman on 15/10/27.
//  Copyright © 2015年 yufu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (StackExtension)

-(void)push:(id)object;
-(id)pop;

@end
