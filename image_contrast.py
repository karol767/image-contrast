Enter file contents here# -*- coding: utf-8 -*-
"""
Created on Wed Jul 15 14:12:54 2022
@author: karol
"""# -*- coding: utf-8 -*-
"""
Vs Code
This is a temporary script file.
"""

import numpy
import cv2
import glob
import os
import matplotlib.pyplot as plt
import matplotlib.pyplot as pyplot
import sys

#import matplotlib.patches as mpatches


files = glob.glob("C:\\Users\\nlab\\Desktop\\all\\*.bmp")
#files.sort(key=os.path.getctime)
cv2.namedWindow("display_img",cv2.WINDOW_AUTOSIZE)

depth = []
imean = []
imini = []
imaxi = []
for file in files:
    print file
    img = cv2.imread(file,cv2.CV_LOAD_IMAGE_GRAYSCALE)
    gau =cv2.GaussianBlur(img, (3,3), 0)
    imean.append( gau.mean())
    imini.append(numpy.amin(gau))
    imaxi.append( numpy.amax(gau))
    filenamespl=file.split('\\')
    depth.append( int(filenamespl[-1][2:-4])*5 )
   
cv2.destroyAllWindows()


#plt.plot(depth, imaxi, depth, imini, depth, imean)
plt.plot(depth, imaxi,label = 'maximum')
plt.plot(depth, imean,label = 'mean')
plt.plot(depth, imini,label = 'minimum')

#pyplot.plot(depth, imaxi, label ='kk')

plt.legend(loc="lower left")
plt.title('Brightness & Depth of emulsion in Z-axis')

plt.xlabel('Depth along Z-axis (micron)')
plt.ylabel('Brightness')



axis = plt.gca()
axis.set_ylim(0,280)
#axis.set_xlim(0,180)
plt.savefig("11.png", dpi=150) 
#plt.show()