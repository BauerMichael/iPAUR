#include "ycrcb.h"

YCrCbImage::~YCrCbImage() {
    free(image);
    image = NULL;
    this->type = 0;
    this->height = 0;
    this->width = 0;
    this->channels = 0;
}