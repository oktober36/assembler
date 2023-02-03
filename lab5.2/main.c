#include <stdlib.h>
#include <time.h>
#include <string.h>
unsigned char *decomposition(unsigned char *img, unsigned char *new_img, int w, int h, int img_size, int channels);

unsigned char *decomposition_asm(unsigned char *img, unsigned char *new_img, int w, int h, int channels);

#define STB_IMAGE_IMPLEMENTATION
#include "stb/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb/stb_image_write.h"

int main(){
    char *input, *output;
    input = getenv("INPUT");
    if(!input){
        printf("Must be existed env variable INPUT");
        return 1;
    }

    output = getenv("OUTPUT");
    if(!output){
        printf("Must be existed env variable OUTPUT");
        return 1;
    }

    if (strcmp(input + strlen(input) - 4, ".png") != 0){
        printf("Loaded image is not .png\n");
        return 2;
    }

    int width, height, channels;
    unsigned char *img = stbi_load(input, &width, &height, &channels, 0);
    if(img == NULL) {
        printf("Error in loading the image\n");
        return 2;
    }

    printf("Loaded image with a width of %dpx, a height of %dpx and %d channels\n", width, height, channels);

    int img_size = width * height * channels, g_img_size = width * height * channels;
    unsigned char *g_img = malloc(g_img_size);
    if(g_img == NULL) {
        printf("Unable to allocate memory for the new image.\n");
        return 3;
    }
    clock_t t, t1;
    printf("Working C function...\n");
    t = clock();
    g_img = decomposition(img, g_img, width, height, img_size, channels);
    t = clock() - t;
    printf("time C function %.7lf seconds\n", ((double) t)/CLOCKS_PER_SEC);

    printf("Working asm function...\n");
    t1 = clock();
    g_img = decomposition_asm(img, g_img,  width, height, channels);
    t1 = clock() - t1;
    printf("time asm function %.7lf seconds\n", ((double) t1)/CLOCKS_PER_SEC);

    stbi_write_png(output, width, height, channels, g_img, 0);
    free(img);
    free(g_img);
    return 0;
}

