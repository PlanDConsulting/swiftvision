#import "OpenCV.h"
#import "UIImage+OpenCV.h"

@implementation OpenCV
+ (NSString *)version {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (cv::Mat)imRead:(NSString *)fileName {
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:fileName];
    return [img mat];
}

@end