//
//  SvSaveToUtils.h
//  SvSaveToCameraRoll
//
//  Created by mapleCao on 13-4-16.
//  Copyright (c) 2013年 smileEvday. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SvSaveToDelegate <NSObject>

- (void)saveToUtilStartCopy:(NSInteger)itemCount;

/*
 * @brief invoke each media item copied
 */
- (void)mediaItemCopiedIsSuccess:(BOOL)success;


- (void)savetoUtilCopyFinished;

@end


@interface SvSaveToUtils : NSObject

@property (nonatomic, assign) id<SvSaveToDelegate> delegate;

/*
 * @brief method to save all media item to camera roll
 */
- (void)saveMediaToCameraRoll;

@end
