//
//  SvSaveToUtils.m
//  SvSaveToCameraRoll
//
//  Created by mapleCao on 13-4-16.
//  Copyright (c) 2013年 smileEvday. All rights reserved.
//

#import "SvSaveToUtils.h"

@interface SvSaveToUtils () {
    NSInteger   _mediaItemCount;        // the count of all media item wait to save
}

@end


@implementation SvSaveToUtils

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        delegate = nil;
    }
    
    return self;
}

- (void)saveMediaToCameraRoll
{
    // // traverse the main bundle to find out all image files
    NSMutableArray *picArray = [NSMutableArray arrayWithCapacity:3];
    
    NSArray *jpgFiles = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg" inDirectory:nil];
    [picArray addObjectsFromArray:jpgFiles];
    
    jpgFiles = [[NSBundle mainBundle] pathsForResourcesOfType:@"JPG" inDirectory:nil];
    [picArray addObjectsFromArray:jpgFiles];
    
    NSArray *pngArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:nil];
    [picArray addObjectsFromArray:pngArray];
    
    pngArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"PNG" inDirectory:nil];
    [picArray addObjectsFromArray:pngArray];
    
    // exclude launch image of this project
    NSMutableArray *picExcludeDefault = [NSMutableArray arrayWithArray:picArray];
    for (NSString *path in picArray) {
        NSArray *pathCom = [path pathComponents];
        if ([pathCom containsObject:@"Default-568h@2x.png"]
            || [pathCom containsObject:@"Default.png"]
            || [pathCom containsObject:@"Default@2x.png"]) {
            [picExcludeDefault removeObject:path];
        }
    }
    picArray = picExcludeDefault;
    
    // traverse the main bundle to find out all mov files
    NSMutableArray *videoArray = [NSMutableArray arrayWithCapacity:3];
    
    NSArray *movs = [[NSBundle mainBundle] pathsForResourcesOfType:@"mov" inDirectory:nil];
    [videoArray addObjectsFromArray:movs];
    
    movs = [[NSBundle mainBundle] pathsForResourcesOfType:@"MOV" inDirectory:nil];
    [videoArray addObjectsFromArray:movs];
    
    _mediaItemCount = picArray.count + videoArray.count;
    
    if (delegate && [delegate respondsToSelector:@selector(saveToUtilStartCopy:)]) {
        [delegate saveToUtilStartCopy:_mediaItemCount];
    }
    
    // save pic to camera roll
    for (id item in picArray) {
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:item];
        
        // Note：save to camera roll is async, so the later item may copy complete than previous item 
        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        [img release];
    }
    
    // save video to camera roll
    for (id item in videoArray) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(item)) {
            
            // Note：save to camera roll is async, so the later item may copy complete than previous item
            UISaveVideoAtPathToSavedPhotosAlbum(item, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
        }
        else {
            [self updateProcessWithError:[NSError errorWithDomain:@"copy video error" code:-1 userInfo:nil]];
        }
    }
}


#pragma mark -
#pragma mark selector to observe save to process

- (void)               image:(UIImage *) image
    didFinishSavingWithError:(NSError *) error
                 contextInfo:(void *) contextInfo
{
    [self updateProcessWithError:error];
}

- (void)               video: (NSString *) videoPath
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo
{
    [self updateProcessWithError:error];
}

- (void)updateProcessWithError:(NSError *)error
{
    BOOL isSuccess = YES;
    if (error) {
        isSuccess = NO;
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if (delegate && [delegate respondsToSelector:@selector(mediaItemCopiedIsSuccess:)]) {
        [delegate mediaItemCopiedIsSuccess:isSuccess];
    }
    
    static int index = 0;
    index += 1;     // caculte copied item count
    if (index == _mediaItemCount) {
        if (delegate && [delegate respondsToSelector:@selector(savetoUtilCopyFinished)]) {
            [delegate savetoUtilCopyFinished];
        }
    }
}



@end
