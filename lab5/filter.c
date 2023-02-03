void filter(unsigned char **extended, unsigned char *new_img, int w, int h, int c, char *matrix, int m_size) {
    int line = w * c;
    unsigned char res;

    for (int i = 0; i < h; i ++){
        for (int j = 0; j < w; j++){

            for (int k = 0; k < 3; k++){
                res = 0;
                for (int l = 0; l < m_size; l++) {

                    int y_dif = (1 - m_size) / 2 + l;
                    for (int m = 0; m < m_size; m++) {

                        int x_dif = (1 - m_size) / 2 + m;
                        res += extended[i + 1 + y_dif][(j + 1 + x_dif) * c + k] * matrix[l * m_size + m];
                    }
                }
                new_img[i * line + j * c + k] = res;
            }
            if (c == 4){
                new_img[i * line + j * c + 3] = extended[i + 1][(j + 1) * c + 3];
            }
        }
    }
}
