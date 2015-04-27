//
//  OfflineRoutineVC.m
//  MyMapBox
//
//  Created by bizappman on 4/27/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import "OfflineRoutineVC.h"


@interface OfflineRoutineVC ()
@property (weak, nonatomic) IBOutlet UILabel *offlineTitleLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property(nonatomic,strong)NSTimer *timer;

@end

@implementation OfflineRoutineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"offlineVC view did load");
    self.timer=[NSTimer scheduledTimerWithTimeInterval:0.5
                                                target:self
                                              selector:@selector(checkRoutineProgress)
                                              userInfo:nil repeats:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"offlineVC view did appear");
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.timer invalidate];
    self.timer=nil;
}


-(void)updateProgress:(NSNumber *)progress{
    NSLog(@"progress:%f",[progress floatValue]);
    self.progressBar.progress=[progress floatValue];
    if([progress floatValue]==1){
        self.offlineTitleLabel.text=@"cach complete";
    }
}

-(void)checkRoutineProgress{
    NSLog(@"Check cach statue");
    MMRoutine *routine=[self.routineArray firstObject];
    
    if(routine.cachProgress==1){
        self.offlineTitleLabel.text=@"cach complete";
    }
    
    self.progressBar.progress=routine.cachProgress;
}


@end
