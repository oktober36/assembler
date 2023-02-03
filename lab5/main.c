#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION
#define STBI_FAILURE_USERMSG

#include <time.h>
#include "stb/stb_image.h"
#include "stb/stb_image_write.h"

int work(char *input, char *output, int* matrix, int m_size);
unsigned char **extend(unsigned char *image, int width, int height, int comp);
void filter(unsigned char **extended, unsigned char *new_img, int w, int h, int c, char *matrix, int m_size);
void filter_asm(unsigned char **extended, unsigned char *new_img, int w, int h, int c, char *matrix, int m_size);


int main(int argc, char **argv) {

    if(argc < 3) {
        printf("Usage: %s input_filename output_filename\n", argv[0]);
        return 0;
    }

    char* input = argv[1], *output = argv[2];
    int h, w, c, m_size = 3;
    char matrix[9]= {-1, -1, -1, -1, 8, -1, -1, -1, -1};

    unsigned char *img = stbi_load(input, &w, &h, &c, 0);

    if (!img){
        printf("Error in loading image\n");
        return 1;
    }

    printf("Loaded %dx%dpx image with %d chanels\n", w, h, c);


    unsigned char **ext_img = extend(img, w, h, c);
    stbi_image_free(img);
    unsigned char *new_img = calloc(w * h, c);

    clock_t begin = clock();
    filter(ext_img, new_img, w, h, c,  matrix, m_size);
    printf("C function: %lf secs\n", (double)(clock() - begin) / CLOCKS_PER_SEC);

    begin = clock();
    filter_asm(ext_img, new_img, w, h, c,  matrix, m_size);
    printf("ASM function: %lf secs\n", (double)(clock() - begin) / CLOCKS_PER_SEC);
    stbi_write_png(output, w, h, c, new_img, 0);
    stbi_image_free(new_img);

}

unsigned char **extend(unsigned char *image, int w, int h, int comp) {
    unsigned char **extended = calloc(h + 2, sizeof(unsigned char *));
    for (int i = 0; i < h + 2; i++)
        extended[i] = calloc(w + 2, comp);

    // Copy pixels in cornenrs
    memmove(extended[0], image, comp);
    memmove(extended[0] + (w + 1) * comp, image + (w - 1) * comp, comp);
    memmove(extended[h + 1], image + (h - 1) * w * comp, comp);
    memmove(extended[h + 1] + (w + 1) * comp, image + (h - 1) * w * comp + (w - 1) * comp, comp);

    // ... in horisontal borders
    memmove(extended[0] + comp, image, w * comp);
    memmove(extended[h + 1] + comp, image + (h - 1) * w * comp, w * comp);

    //... in vertical borders and insideи
    for (int i = 0; i < h; i++) {
        //inside
        memmove(extended[i + 1] + comp, image + (i * w) * comp, w * comp);
        //left border
        memmove(extended[i + 1], image + (i * w) * comp, comp);
        //right border
        memmove(extended[i + 1] + (w + 1) * comp, image + (i * w + (w - 1)) * comp, comp);
    }
    return extended;
}



