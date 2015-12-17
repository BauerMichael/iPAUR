template<typename aType>
void TypeConversion<aType>::RGB2Gray(RGBImage<aType>& src, GrayscaleImage<aType>& dst) {
    dst.Reset(src.GetHeight(), src.GetWidth(), CV_8UC1);
    for (int i = 0; i < src.GetHeight()*src.GetWidth(); i++)
        dst.Set(0, i, 0, src.Get(0, i, 2) * 0.299 + src.Get(0, i, 1) * 0.587 + src.Get(0, i, 0) * 0.114);
}

template<typename aType>
void TypeConversion<aType>::Gray2RGB(GrayscaleImage<aType>& src, RGBImage<aType>& dst) {
    dst.Reset(src.GetHeight(), src.GetWidth(), CV_8UC3);
    for (int k = 0; k < src.GetChannels(); k++) {
        for (int i = 0; i < src.GetHeight()*src.GetWidth(); i++) {
            dst.Set(0, i, k, src.Get(0, i, 0));
        }
    }
}

template<typename aType>
void TypeConversion<aType>::RGB2YCrCb(RGBImage<aType>& src, YCrCbImage<aType>& dst) {
    dst.Reset(src.GetHeight(), src.GetWidth(), CV_8UC3);
    for (int i = 0; i < src.GetHeight()*src.GetWidth(); i++) {
        dst.Set(0, i, 0, src.Get(0, i, 2) * 0.299 + src.Get(0, i, 1) * 0.587 + src.Get(0, i, 0) * 0.114);
        dst.Set(0, i, 1, (src.Get(0, i, 2) - dst.Get(0, i, 0)) * 0.713 + 128); // delta = 128
        dst.Set(0, i, 2, (src.Get(0, i, 0) - dst.Get(0, i, 0)) * 0.564 + 128); // delta = 128
    }
}

template<typename aType>
void TypeConversion<aType>::RGB2HSI(RGBImage<aType>& src, HSIImage<aType>& dst) {
    dst.Reset(src.GetHeight(), src.GetWidth(), CV_8UC3);
    int max, min, max_minus_min, s_value, h_value;
    for (int i = 0; i < src.GetHeight(); i++) {
        for (int j = 0; j < src.GetWidth(); j++) {
            max = 0;
            min = 255;
            for (int k = 0; k < src.GetChannels(); k++) {
                max = src.Get(i, j, k) <= max ? max : src.Get(i, j, k);
                min = src.Get(i, j, k) >= min ? min : src.Get(i, j, k);
            }
            max_minus_min = max - min;
            dst.Set(i, j, 2, max);
            s_value = max != 0 ? 255 * (max_minus_min) / max : 0;
            dst.Set(i, j, 1, s_value);
            h_value = max == min ? 0 : -1;
            if (h_value == -1) {
                if (max == src.Get(i, j, 2)) {
                    h_value = 60 * (src.Get(i, j, 1) - src.Get(i, j, 0)) / max_minus_min;
                    h_value = h_value < 0 ? h_value + 360 : h_value;
                } else if (max == src.Get(i, j, 1)) {
                    h_value = 120 + 60 * (src.Get(i, j, 0) - src.Get(i, j, 2)) / max_minus_min;
                    h_value = h_value < 0 ? h_value + 360 : h_value;
                } else if (max == src.Get(i, j, 0)) {
                    h_value = 240 + 60 * (src.Get(i, j, 2) - src.Get(i, j, 1)) / max_minus_min;
                    h_value = h_value < 0 ? h_value + 360 : h_value;
                }
            }
            dst.Set(i, j, 0, h_value / 2);
        }
    }
}