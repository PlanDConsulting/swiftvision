#import <opencv2/opencv.hpp>
#import "UIImage+Contour.h"
// model
#import "Contour.h"
#import "ContourSpan.h"
#import "ContourEdge.h"
#import "Contour+internal.h"
#import "ContourSpan+internal.h"
#import "UIImage+Mat.h"

using namespace std;
using namespace cv;

@implementation UIImage (Contour)
// MARK: -
- (NSArray<Contour *> *)contoursFilteredBy:(BOOL (^)(Contour *contour))filter {
    int TEXT_MIN_WIDTH = 15;         //# min px width of detected text contour
    int TEXT_MIN_HEIGHT = 2;        //# min px height of detected text contour
    int TEXT_MIN_ASPECT = 1.5;      //# filter out text contours below this w/h ratio
    int TEXT_MAX_THICKNESS = 10;    //# max px thickness of detected text contour

    Mat cvMat = [self grayScaleMat];
    NSMutableArray <Contour *> *foundContours = @[].mutableCopy;
    vector<vector<cv::Point> > contours;
    findContours(cvMat, contours, RETR_EXTERNAL, CHAIN_APPROX_NONE);

    for (int j = 0; j < contours.size(); j++) {
        vector<cv::Point> points = contours.at(j);
        cv::Rect rect = cv::boundingRect(points);
        if (rect.width < TEXT_MIN_WIDTH ||
            rect.height < TEXT_MIN_HEIGHT ||
            rect.width < TEXT_MIN_ASPECT * rect.height)
            continue;

        Contour *contour = [[Contour alloc] initWithCVMat:Mat(points)];

        if (filter)
            if (!filter(contour))
                continue;

        Mat summedMask = Mat::zeros(0, 0, CV_64FC1);
        cv::reduce(contour.mask, summedMask, 0, CV_REDUCE_SUM, CV_64FC1);

        double max;
        minMaxLoc(summedMask, NULL, &max);
        if (max > TEXT_MAX_THICKNESS)
           continue;

        [foundContours addObject:contour];
    }

    return foundContours;
}

- (NSArray<ContourSpan *> *)spansFromContours:(NSArray<Contour *> *)contours {
    CGFloat SPAN_MIN_WIDTH = 30;

    NSArray <Contour *> *sortedContours = [self sortContoursByBounds:contours];
    NSArray <ContourEdge *> *edges = [self generateContourEdgesFromContours:sortedContours];
    NSArray <ContourEdge *> *sortedEdges = [self sortedEdgesByScore:edges];

    for (ContourEdge *edge in sortedEdges) {
        // if left and right are unassigned, join them
        if (!edge.contourA.next && !edge.contourB.previous) {
            edge.contourA.next = edge.contourB;
            edge.contourB.previous = edge.contourA;
        }
    }

    // generate list of spans as output
    NSMutableArray <ContourSpan *> *spans = @[].mutableCopy;

    NSMutableArray *mutableContours = sortedContours.mutableCopy;
    // until we have removed everything from the list
    while (mutableContours.count > 0) {
        // get the first on the list
        Contour *contour = mutableContours[0];

        // keep following predecessors until none exists
        while (contour.previous)
            contour = contour.previous;

        // start a new span
        NSMutableArray <Contour *> *curSpan = @[].mutableCopy;
        CGFloat width = 0;

        // follow successors til end of span
        while (contour) {
            // remove from list (sadly making this loop *also* O(n^2)
            [mutableContours removeObject:contour];
            // add to span

            [curSpan addObject:contour];

            width += contour.localxMax - contour.localxMin;

            // set successor
            contour = contour.next;
        }

        // add if long enough
        if (width > SPAN_MIN_WIDTH) {
            ContourSpan *span = [[ContourSpan alloc] initWithImage:self contours:curSpan];
            [spans addObject:span];
        }
    }

    return spans;
}

// MARK: -
- (NSArray <ContourEdge *> *)generateContourEdgesFromContours:(NSArray <Contour *> *)contours {
    NSMutableArray <ContourEdge *> *edges = @[].mutableCopy;
    NSInteger contourCount = contours.count;
    for (int i = 0; i < contourCount; i++) {
        Contour *currentContour = contours[i];
        for (int j = 0; j < i; j++) {
            Contour *adjacentContour = contours[j];
            ContourEdge *edge = [currentContour contourEdgeWithAdjacentContour:adjacentContour];
            if (edge)
                [edges addObject:edge];
        }
    }
    return edges;
}

- (NSArray <Contour *> *)sortContoursByBounds:(NSArray <Contour *> *)contours {
    return [contours sortedArrayUsingComparator:^NSComparisonResult(Contour *obj1, Contour *obj2){
        if (CGRectGetMinY(obj1.bounds) < CGRectGetMinY(obj2.bounds))
            return NSOrderedAscending;
        else if (CGRectGetMinY(obj1.bounds) > CGRectGetMinY(obj2.bounds))
            return NSOrderedDescending;

        return NSOrderedSame;
    }];
}

- (NSArray <ContourEdge *> *)sortedEdgesByScore:(NSArray <ContourEdge *> *)edges {
    return [edges sortedArrayUsingComparator:^NSComparisonResult(ContourEdge *edge1, ContourEdge *edge2){
        if (edge1.score < edge2.score)
            return NSOrderedAscending;
        else if (edge1.score > edge2.score)
            return NSOrderedDescending;

        return NSOrderedSame;
    }];
}
@end