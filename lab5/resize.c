void resize(unsigned char *img, unsigned char *new_img, int w,int h, int c, int x, int y, int r, int k) {
    int ratio = (int)((w<<16) / (w * k) ) + 1;
    int x2, y2;
    int nx, ny, no;
    for (int i = 0; i < h; i++) {
        for (int j = 0; j < w; j++) {
            if ((j-x)*(j-x) + (i-y)*(i-y) < r*r){
                nx = k * x + (j-x);
                ny = k * y + (i-y);
                x2 = (nx *ratio)>>16;
                y2 = (ny *ratio)>>16;
                for (int k = 0; k < c; k++){
                    new_img[(i * w + j) * c + k] = img[(y2 * w + x2)*c + k];
                }
            } else
                for (int k = 0; k < c; k++)
                    new_img[(i * w + j) * c + k] = img[(i * w + j)*c + k];
        }
    }
}

