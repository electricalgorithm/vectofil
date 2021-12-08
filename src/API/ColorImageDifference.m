% COLORIMAGEDIFFERENCE

function [resultedImage, differentPixelCount] = ColorImageDifference(image1, image2)
    sizeImg1 = size(image1);
    sizeImg2 = size(image2);
    differentPixelCount = 0;
    
    if (sizeImg1 - sizeImg2) ~= zeros(1, 3)
        error("Given input images' sizes are not matched.");
    end
    
    resultedImage = zeros(sizeImg1);
    
    for rowPixel = 1:sizeImg1(1)
        for colPixel = 1:sizeImg1(2)
            if min(...
                image1(rowPixel, colPixel, :) == image2(rowPixel, colPixel, :)...
                ) == 0
                
                resultedImage(rowPixel, colPixel, :) = [255, 255, 255]';
                differentPixelCount = differentPixelCount + 1;
            end
        end
    end
end