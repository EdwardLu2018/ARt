import cv2
import numpy
import imutils
from PIL import Image, ImageOps
import requests
import io

def getImages(imageList):

	fileList = [];
	for url in imageList:

		filePath = requests.get(url)

		byteCode = io.BytesIO(filePath.content)

		pilImg = Image.open(byteCode).convert('RGB')

		width, height= pilImg.size

		print(str(width))
		print(str(height))

		tbBorder = 0;
		lrBorder = 0;

		if height/width < 2:
			totalHeight = width*2
			borderHeight = totalHeight-height
			tbBorder = borderHeight/2
		elif height/width>2:
			totalWidth = height/2
			borderWidth = totalWidth-width
			lrBorder = borderWidth/2

		print(str(tbBorder))
		print(str(lrBorder))

		borderIn = (int(lrBorder), int(tbBorder),int(lrBorder), int(tbBorder))

		bordered = ImageOps.expand(pilImg, border = borderIn, fill = "white")
		#add border to fit 2:1 ratio
		resized = bordered.resize((350,700))
		
		imgByteArr = io.BytesIO()
		resized.save(imgByteArr, format='PNG')
		imgByteArr = imgByteArr.getvalue() 
		fileList.append(imgByteArr)

	return fileList
# open_cv_image = numpy.array(resized)

# print(type(pilImg))

# open_cv_image = open_cv_image[:, :, ::-1].copy() 


# cv2.imshow('img', open_cv_image) 
# cv2.waitKey(0)
# cv2.destroyAllWindows()

#return a list of all images



