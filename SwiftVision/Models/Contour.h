#import <UIKit/UIKit.h>

@class ContourEdge;
@interface Contour: NSObject
@property (nonatomic, assign, readonly) CGPoint *_Nonnull points;
@property (nonatomic, assign, readonly) CGRect bounds;
@property (nonatomic, assign, readonly) CGFloat aspect;
@property (nonatomic, assign, readonly) NSInteger size;
@property (nonatomic, assign, readonly) CGFloat area;

@property (nonatomic, assign, readonly) CGPoint center;
@property (nonatomic, assign, readonly) CGPoint tangent;
@property (nonatomic, assign, readonly) double angle;
@property (nonatomic, strong, readonly) NSArray <NSNumber *> *_Nonnull clx;

@property (nonatomic, assign, readonly) CGPoint clxMin;
@property (nonatomic, assign, readonly) CGPoint clxMax;

@property (nonatomic, strong) Contour *_Nullable previous;
@property (nonatomic, strong) Contour *_Nullable next;

- (ContourEdge * _Nullable)generateEdge:(Contour * _Nonnull)adjacentContour;
@end
