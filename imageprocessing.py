"""
Created on Thu Jun 22 22:17:27 2023
@author:Karol
"""
import cv2
import glob
files = glob.glob("\\*.png")
cv2.namedWindow("display_img", cv2.WINDOW_AUTOSIZE)
thre=1
i=0

for file in files: 
    print file
    i= i+1
    img = cv2.imread(file, cv2.CV_LOAD_IMAGE_GRAYSCALE)
    img1= cv2.GaussianBlur(img, (3,3), 0)
    gau= cv2.GaussianBlur(img, (31,31), 0)
    sub = cv2.subtract(gau,img) 
    ret,thre = cv2.threshold(sub,25,255,cv2.THRESH_BINARY)
    ret,bin_img = cv2.threshold(sub,25,255,cv2.THRESH_TOZERO)
    
    cv2.imshow("image",img)
    cv2.imshow("first_Gassiun",img1)
    cv2.imshow("Second_Gassiun",gau)
    cv2.imshow("Difference_Gassiun",sub)
    cv2.imshow("bina",bin_img*5)
    cv2.imshow("bina_",thre) 
    
    Binayimage = "\\Binaryimage_{0}_.bmp".format(i)
    cv2.imwrite(Binayimage,thre)
    Gassiun_1 = "\\Gassium1_{0}_.bmp".format(i)
    cv2.imwrite(Gassiun_1,img1)
    Gassiun2 = "\\Gassium2_{0}_.bmp".format(i)
    cv2.imwrite(Gassiun2,gau)
    Diff_Gauss = "\\DiferenceGauss_1_{0}_.bmp".format(i)
    cv2.imwrite(Diff_Gauss,sub)
    cv2.waitKey()
cv2.destroyAllWindows()