function bvdf_present(org_image, noise_percentage, filtering_window, fill_with, direction)
% BVDF_PRESENT Apply noise to a given image, and then filter it with Basic
% Directional Vector Filters.
%   Usage:
%       bvdf_present(IMAGE, NOISE_PERCENTAGE, FITLERING_WIN_SIZE, FILL_COLOUR[, DIRECTION])
%   Parameters:
%       - IMAGE: NxMxK size uint8 matrix. You can use the return of
%       imopen() function.
%       - NOISE_PERCENTAGE: Percentage of the noise for the image.
%       - FILTERING_WIN_SIZE: Window size of the filtering process. Type
%       only one dimension.
%       - FILL_COLOUR: A row vector for filling noise pixels.
%       - DIRECTION: (Optional) 'v' for vertical graph, 'h' for horizontal
%       graph.
%   Example (25% Noise with 3x3 Window Size):
%       img = imopen("/home/some/location/);
%       bvdf_present(img, 25, 3, [155, 155, 155]);

    noisy_image = bvdf_add_noise(org_image, noise_percentage, size(org_image, 3), fill_with');
    filtered_image = bvdf_filter(noisy_image, filtering_window);
    
    % Checking arguments.
    if (nargin < 5) 
        direction = 'v';
    end
    if (nargin < 4)
        error("Not enought arguments. Please provide a image, a percentage for noise, filtering window size, and noise filling color as row vector.");
    end
    
    % Choose horizontal or vertical layout for representation.
    figure;
    if (lower(direction) == 'h')
        tiledlayout(1, 3);
    else
        tiledlayout(3, 1);
    end
    
    % Show the original image.
    nexttile
        imshow(org_image);
        title("Original Image");
    
    % Show the noisy image.
    nexttile
        imshow(noisy_image);
        title2_text = sprintf("Original Image with %d%% Noise", noise_percentage);
        title(title2_text);
    
    % Show the filtered image.
    nexttile
        imshow(filtered_image);
        title3_text = sprintf("Filtered Image with Window Size %dx%d", filtering_window, filtering_window);
        title(title3_text);
end