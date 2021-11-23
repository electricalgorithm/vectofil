function filtered_image = bvdf_filter(image, sample_dims)
% BVDF_FILTER Function to filter the image according the BVDF rule.
    if nargin < 2
        error("You have to give the image as uint8 matrix, and dimensions of the vectoral process.");
    end
    
    color_count = size(image, 3);
    image_X = size(image, 1);
    image_Y = size(image, 2);
    
    starting_points = [ceil(sample_dims/2), ceil(sample_dims/2)];
    choosing_distance = [floor(sample_dims/2), floor(sample_dims/2)];
    filtered_image = zeros(image_X, image_Y, color_count);
    
    for x_index = starting_points(1):1:(image_X-starting_points(1))
        for y_index = starting_points(2):1:(image_Y-starting_points(2))
            
            area2filter = image(x_index-choosing_distance(1):x_index+choosing_distance(2),...
                                y_index-choosing_distance(2):y_index+choosing_distance(2), :);
                            
            area2filter = im2double(area2filter).*255;
            
            vectors_list = reshape(area2filter , [], 3)';
            sorted_vectors = bvdf_sort_vectors(vectors_list);
            filtered_image(x_index, y_index, :) = sorted_vectors(:, 1);
        end
    end
    
    filtered_image = cast(filtered_image, 'uint8');
    
end