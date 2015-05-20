#include "arithmetic_functions.h"

void markRed(GrayscaleImage& src, RGBImage& dst, int type) {
    unsigned short height = src.get_height(), width = src.get_width();
    // dst.reset_image(height, width, type);
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            if (src.get_gray_pixel_at_position(i, j) > 50) {
                dst.set_color_pixel_at_position(i, j, 0, 0);
                dst.set_color_pixel_at_position(i, j, 1, 0);
                dst.set_color_pixel_at_position(i, j, 2, 0);
            }
        }
    }
}

void addGrayscaleImages(GrayscaleImage& src1, GrayscaleImage& src2, GrayscaleImage& dst) { // needs some more problem testing!!!
    unsigned short height = src1.get_height(), width = src1.get_width();
    dst.reset_image(height, width, src1.get_type());
    int sum = 0;
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            sum = src1.get_gray_pixel_at_position(i, j) + src2.get_gray_pixel_at_position(i, j);
            sum = sum > 255 ? 255 : sum;
            dst.set_gray_pixel_at_position(i, j, sum);
        }
    }
}

void multiplyGrayscaleImages(GrayscaleImage& src1, GrayscaleImage& src2, GrayscaleImage& dst) { // needs some more problem testing!!!
    unsigned short height = src1.get_height(), width = src1.get_width();
    dst.reset_image(height, width, src1.get_type());
    // int sum = 0;
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            if (src1.get_gray_pixel_at_position(i, j) != 255) {
                src2.set_gray_pixel_at_position(i, j, 0);
            }
            if (src2.get_gray_pixel_at_position(i, j) != 255) {
                src2.set_gray_pixel_at_position(i, j, 0);
            }
            // sum = src1.get_gray_pixel_at_position(i, j) * src2.get_gray_pixel_at_position(i, j);
            // sum = sum >= 255 ? 255 : 0;
            // sum = sum <+ 0 ? 0 : 255;
            // // sum = sum > 255 ? sum - 255 : sum;
            // dst.set_gray_pixel_at_position(i, j, sum);
        }
    }
}

// void multiplyGrayscaleImages(GrayscaleImage& src1, GrayscaleImage& src2, GrayscaleImage& dst) { // needs some more problem testing!!!
//     unsigned short height = src1.get_height(), width = src1.get_width();
//     dst.reset_image(height, width, src1.get_type());
//     int sum = 0;
//     for (int i = 0; i < height; i++) {
//         for (int j = 0; j < width; j++) {
//             sum = src1.get_gray_pixel_at_position(i, j) * src2.get_gray_pixel_at_position(i, j);
//             sum = sum >= 255 ? 255 : 0;
//             sum = sum <+ 0 ? 0 : 255;
//             // sum = sum > 255 ? sum - 255 : sum;
//             dst.set_gray_pixel_at_position(i, j, sum);
//         }
//     }
// }

void addColorImages(RGBImage& src1, RGBImage& src2, RGBImage& dst) { // needs some more problem testing!!!
    unsigned short height = src1.get_height(), width = src1.get_width();
    dst.reset_image(height, width, src1.get_type());
    int sum = 0;
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            for (int k = 0; k < 3; k++) {
                sum = src1.get_color_pixel_at_position(i, j, k) + src2.get_color_pixel_at_position(i, j, k);
                sum = sum > 255 ? sum - 255 : sum;
                dst.set_color_pixel_at_position(i, j, k, sum);
            }
        }
    }
}

void inRangeGrayscaleImage(GrayscaleImage& src, GrayscaleImage& dst, int firstChannelMin, int firstChannelMax) {
    unsigned short height = src.get_height(), width = src.get_width();
    dst.reset_image(height, width, src.get_type());
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            if (src.get_gray_pixel_at_position(i, j) >= firstChannelMin && src.get_gray_pixel_at_position(i, j) <= firstChannelMax) {
                dst.set_gray_pixel_at_position(i, j, 255);
            } else {
                dst.set_gray_pixel_at_position(i, j, 0);
            }
        }
    }
}

void inRangeColorImage(RGBImage& src, RGBImage& dst, int firstChannelMin, int firstChannelMax, int secondChannelMin,
            int secondChannelMax, int thirdChannelMin, int thirdChannelMax) {
    unsigned short height = src.get_height(), width = src.get_width();
    dst.reset_image(height, width, src.get_type());
    int first = 0, second = 0, third = 0;
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
        	first = (src.get_color_pixel_at_position(i, j, 0) >= firstChannelMin && src.get_color_pixel_at_position(i, j, 0) <= firstChannelMax) ? 1 : 0;
        	second = (src.get_color_pixel_at_position(i, j, 1) >= secondChannelMin && src.get_color_pixel_at_position(i, j, 1) <= secondChannelMax) ? 1 : 0;
        	third = (src.get_color_pixel_at_position(i, j, 2) >= thirdChannelMin && src.get_color_pixel_at_position(i, j, 2) <= thirdChannelMax) ? 1 : 0;
        	if (second && third) {
        		dst.set_color_pixel_at_position(i, j, 0, 255);
        		dst.set_color_pixel_at_position(i, j, 1, 255);
        		dst.set_color_pixel_at_position(i, j, 2, 255);
        	} else {
        		dst.set_color_pixel_at_position(i, j, 0, 0);
        		dst.set_color_pixel_at_position(i, j, 1, 0);
        		dst.set_color_pixel_at_position(i, j, 2, 0);
        	}
            // if (src.get_color_pixel_at_position(i, j, 0) >= firstChannelMin && src.get_color_pixel_at_position(i, j, 0) <= firstChannelMax) {
            //     dst.set_color_pixel_at_position(i, j, 0, 255);
            // } else {
            //     dst.set_color_pixel_at_position(i, j, 0, 0);
            // }
            // if (src.get_color_pixel_at_position(i, j, 1) >= secondChannelMin && src.get_color_pixel_at_position(i, j, 1) <= secondChannelMax) {
            //     dst.set_color_pixel_at_position(i, j, 1, 255);
            // } else {
            //     dst.set_color_pixel_at_position(i, j, 1, 0);
            // }
            // if (src.get_color_pixel_at_position(i, j, 2) >= thirdChannelMin && src.get_color_pixel_at_position(i, j, 2) <= thirdChannelMax) {
            //     dst.set_color_pixel_at_position(i, j, 2, 255);
            // } else {
            //     dst.set_color_pixel_at_position(i, j, 2, 0);
            // }
        }
    }
}