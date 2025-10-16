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
