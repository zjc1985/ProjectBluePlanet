//
//  OfflineRoutineVC.h
//  MyMapBox
//
//  Created by bizappman on 4/27/15.
//  Copyright (c) 2015 yufu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapbox-iOS-SDK/Mapbox.h>

@interface OfflineRoutineVC : UIViewController <RMTileCacheBackgroundDelegate>

@property(nonatomic,strong)RMTileCache *tileCach;
@property(nonatomic,strong)RMMapboxSource *tileSource;

@property(nonatomic)CLLocationCoordinate2D southWest;
@property(nonatomic)CLLocationCoordinate2D northEast;
@property(nonatomic)NSUInteger minZoom;
@property(nonatomic)NSUInteger maxZoom;

@end
