# Unripe-Banana-Image-Analysis

Repository for analyzing browning of pretreated unripe banana slices using computer vision (CVS) and MATLAB.

---

## Overview

This repository provides MATLAB code to perform image analysis on unripe banana slices pretreated with citric acid, l-ascorbic acid, and potassium metabisulfite. The purpose is to measure browning and color changes over time using a Computer Vision System (CVS).

Key objectives:

- Quantify browning using L*, a*, b* color indices.
- Compare pretreatment effectiveness in preventing browning.
- Provide a robust MATLAB code for analyzing multiple images.

---

## Requirements

- MATLAB R2019a (9.6) or later
- Image Processing Toolbox
- Images of banana slices captured under controlled conditions (black background, consistent lighting, fixed distance).

---

## Image Acquisition

- Camera: Nikon D3400 with 18-55 mm and 70-300 mm lenses
- Illumination: Philips Base B22 4-W bulb (350 lm)
- Image format: JPEG, size reduced to 3000x2000
- Distance from object: 15 cm
- Each slice captured three times

---

## MATLAB Code Usage

1. Place images in a folder.
2. Update the path in the code to point to the image folder.
3. Run the MATLAB script `Banana_Image_Analysis.m`.
4. The script outputs L*, a*, b* values for each slice.

---

## Robust MATLAB Code: `Banana_Image_Analysis.m`

```matlab
clc;
clear all;
close all;

% Set path to the image folder
imagePath = 'C:\Users\HP\Desktop\Sumit 4\Image analysis photos\SET 1\';
imageFiles = dir(fullfile(imagePath, '*.jpg'));

% Initialize result storage
results = [];

for idx = 1:length(imageFiles)
    imgName = fullfile(imagePath, imageFiles(idx).name);
    img = imread(imgName);
    meanRGB = zeros(1,3);
    
    for z = 1:3 % process R,G,B channels
        channelImg = img(:,:,z);
        origChannel = channelImg;
        [m,n] = size(channelImg);
        
        % Thresholding
        channelImg(channelImg > 18) = 255;
        channelImg(channelImg <= 18) = 0;
        
        % Morphological operations
        se = strel('disk',7);
        f = imopen(channelImg,se);
        f = imclose(f,se);
        BW = f > 100;
        
        % Label regions
        labeledImage = bwlabel(BW);
        measurements = regionprops(labeledImage, 'BoundingBox', 'Area');
        
        % Find the main object (largest area >100 pixels)
        for k = 1:length(measurements)
            thisBB = measurements(k).BoundingBox;
            I2 = imcrop(f,[thisBB(1), thisBB(2), thisBB(3), thisBB(4)]);
            J2 = imcrop(origChannel,[thisBB(1), thisBB(2), thisBB(3), thisBB(4)]);
            [rows, cols] = size(I2);
            if rows*cols > 100
                break;
            end
        end
        
        % Calculate mean pixel value
        J2 = im2double(J2);
        sumPix = sum(J2(I2>0));
        countPix = nnz(I2>0);
        meanRGB(z) = sumPix / countPix;
    end
    
    % Convert to 8-bit and RGB
    meanRGB = im2uint8(meanRGB);
    meanRGB = reshape(meanRGB,1,1,3);
    
    % Convert RGB to LAB
    lab = rgb2lab(meanRGB);
    L_val = lab(:,:,1);
    a_val = lab(:,:,2);
    b_val = lab(:,:,3);
    
    % Store results
    results = [results; {imageFiles(idx).name, L_val, a_val, b_val}];
end

% Display results
disp('Image Name | L* | a* | b*');
disp(results);
```

---

## Notes

- The code is robust for multiple images in a folder.
- Threshold and morphological parameters can be adjusted for different datasets.
- L*, a*, b* values can be used for further browning index, whiteness index, and DPPH activity calculations.

---

## License

MIT License (can be changed as needed)

---

## Citation

Please cite the original study if using this code or methodology.
Pathak, S. S., Sonawane, A., Srinivas, A., & Pradhan, R. C. (2021). Application of image analysis for detecting the browning of unripe banana slices. ACS Food Science & Technology, 1(9), 1507-1513. https://doi.org/10.1021/acsfoodscitech.1c00193 


