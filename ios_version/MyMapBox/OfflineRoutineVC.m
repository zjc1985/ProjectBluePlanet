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

@end

@implementation OfflineRoutineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.tileCach){
        self.tileCach.backgroundCacheDelegate=self;
    }
    
    NSLog(@"offlineVC view did load");
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"offlineVC view did appear");
    
    if([self validBounds]){
        [self startDownLoadTileCach];
    }
}

-(BOOL)validBounds{
    if(self.southWest.latitude!=0 &&
       self.southWest.longitude!=0 &&
       self.northEast.latitude!=0 &&
       self.northEast.longitude!=0 &&
       self.tileSource && self.tileCach && self.minZoom!=0 && self.maxZoom !=0){
        NSLog(@"valid args will do cach");
        return YES;
    }else{
        NSLog(@"not valid args cancel do cach");
        return NO;
    }
}

-(void)updateProgress:(NSNumber *)progress{
    NSLog(@"progress:%f",[progress floatValue]);
    self.progressBar.progress=[progress floatValue];
    if([progress floatValue]==1){
        self.offlineTitleLabel.text=@"cach complete";
    }
}

#pragma mark - cach related


-(void)startDownLoadTileCach{
    if(self.tileSource && self.tileCach && self.minZoom>0 && self.maxZoom>0){
        [self.tileCach beginBackgroundCacheForTileSource:self.tileSource
                                               southWest:self.southWest
                                               northEast:self.northEast
                                                 minZoom:self.minZoom
                                                 maxZoom:self.maxZoom];
    }
}

- (void)tileCache:(RMTileCache *)tileCache didBackgroundCacheTile:(RMTile)tile withIndex:(NSUInteger)tileIndex ofTotalTileCount:(NSUInteger)totalTileCount{
    NSLog(@"OfflineVC caching currrent num: %u with total count %u",tileIndex,totalTileCount);
    float progress=(float)tileIndex/(float)totalTileCount;
    
    [self performSelectorOnMainThread:@selector(updateProgress:)
                           withObject:[NSNumber numberWithFloat:progress]
                        waitUntilDone:NO];
    
    
    if(tileIndex==totalTileCount){
        NSLog(@"Cach Complete");
    }
}


@end
