#include "ms_minimizer.h"

#ifndef __IMAGE_H__
#define __IMAGE_H__

gray_img *read_image_data(const char*);
gray_img *initalize_raw_image(int, int, char);
void write_image_data(gray_img*, const char*);
void destroy_image(gray_img*);

#endif //__IMAGE_H__