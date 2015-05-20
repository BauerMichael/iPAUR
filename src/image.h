#include <string>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"

using namespace std;
using namespace cv;

#ifndef __IMAGE_H__
#define __IMAGE_H__

class Image
{
public:
	virtual unsigned short get_height() = 0;
	virtual unsigned short get_width() = 0;
	virtual unsigned short get_type() = 0;
	virtual unsigned char get_gray_pixel_at_position(int, int) {return 0;}
	virtual unsigned char get_color_pixel_at_position(int, int, int) {return 0;}
};

class WriteableImage : public Image
{
public:
	virtual void set_gray_pixel_at_position(int, int, unsigned char) {}
	virtual void set_color_pixel_at_position(int, int, int, unsigned char) {}
};

struct grayscaled_image
{
	float* approximation;
	int image_height;
	int image_width;
	int image_type;
};

typedef struct grayscaled_image gray_img;

struct colored_image
{
	float* red;
	float* green;
	float* blue;
	int image_height;
	int image_width;
	int image_type;
};

typedef struct colored_image color_img;

gray_img *read_image_data(const char*);
gray_img *initalize_raw_image(int, int, char);
void write_image_data(gray_img*, const char*);
void destroy_image(gray_img*);

color_img *read_image_data_color(const char*);
color_img *initalize_raw_image_color(int, int, char);
void write_image_data_color(color_img*, const char*);
void destroy_image_color(color_img*);

#endif //__IMAGE_H__