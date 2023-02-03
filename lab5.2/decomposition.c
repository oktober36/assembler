#include <stdio.h>

unsigned char *decomposition(unsigned char *img, unsigned char *new_img, int w, int h, int img_s, int channels){
    int c = 0;
    for (int i = 0; i < img_s; i+= channels){

        unsigned char r, g, b, max, lvl;
        r = img[i]; g = img[i + 1]; b = img[i + 2];


        lvl = i / (w * channels);
        if ( (i % (w * channels)) > (w * channels * lvl / h) ){
            new_img[i] = r;
            new_img[i+1] = g;
            new_img[i+2] = b;
            c ++;
        } else {
            max = (r > g && r > b)? r : ((g > b)? g : b);
            for (int j = 0; j < 3; j++)
                new_img[i + j] = max;
        }
        if (channels == 4)
            new_img[i+3] = img[i+3];
    }
    printf("Done %d\n", c);
    return new_img;
}
