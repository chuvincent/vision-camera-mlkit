#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>

#import "VisionCameraOcr-Swift.h"

@interface OCRFrameProcessorPlugin (FrameProcessorPluginLoader)
@end

@implementation OCRFrameProcessorPlugin (FrameProcessorPluginLoader)

+ (void)load
{
    [FrameProcessorPluginRegistry addFrameProcessorPlugin:@"scanOCR"
                                        withInitializer:^FrameProcessorPlugin* (VisionCameraProxyHolder* proxy, NSDictionary* options) {
        return [[OCRFrameProcessorPlugin alloc] initWithProxy:proxy withOptions:options];
    }];
}

@end


@interface ImageLabelerFrameProcessorPlugin (FrameProcessorPluginLoader)
@end

@implementation ImageLabelerFrameProcessorPlugin (FrameProcessorPluginLoader)

+ (void)load
{
    [FrameProcessorPluginRegistry addFrameProcessorPlugin:@"labelImage"
                                        withInitializer:^FrameProcessorPlugin* (VisionCameraProxyHolder* proxy, NSDictionary* options) {
        return [[ImageLabelerFrameProcessorPlugin alloc] initWithProxy:proxy withOptions:options];
    }];
}

@end
