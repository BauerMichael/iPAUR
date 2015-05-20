#include "image.h"
#include "grayscale.h"
#include "create_filter.h"
#include "linear_filter.h"
#include "sobel.h"

#ifndef __CANNY_H__
#define __CANNY_H__

void nonMaximumSupression(GrayscaleImage&, GrayscaleImage&, GrayscaleImage&);
void hystersis(GrayscaleImage&, GrayscaleImage&, int, int);
void canny(GrayscaleImage&, GrayscaleImage&, int, int);

#endif //__CANNY_H__