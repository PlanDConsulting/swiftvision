#ifndef functions_h
#define functions_h

#include <stdio.h>
#import <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>

#endif /* functions_h */

double angleDistance(double angle_b, double angle_a);
double intervalOverlap(CGPoint int_a, CGPoint int_b);

void describe_vector(std::vector<double> vector, char const *name );
void describe_vector(std::vector<cv::Point> vector, char const *name );
void describe_vector( cv::Mat mat, char const *name );
void describe_vectord(std::vector<std::vector<double>> vector, char const *name );