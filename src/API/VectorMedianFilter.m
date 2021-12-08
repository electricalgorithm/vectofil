function filtered_image = VectorMedianFilter(image, window_size)
    image_X = size(image, 1);
    image_Y = size(image, 2);

    filtered_image = zeros(size(image));
    starting_points = [ceil(window_size/2), ceil(window_size/2)];
    choosing_distance = [floor(window_size/2), floor(window_size/2)];
    
    for x_index = starting_points(1):1:(image_X-starting_points(1))
        for y_index = starting_points(2):1:(image_Y-starting_points(2))
            
            area2filter = image(x_index-choosing_distance(1):x_index+choosing_distance(2),...
                                y_index-choosing_distance(2):y_index+choosing_distance(2), :);                
            area2filter = im2double(area2filter).*255;
            vectors_list = reshape(area2filter , [], 3)';
            
            % SORTING
            distances = zeros(size(vectors_list, 1) + 1, size(vectors_list, 2));
            distances(2:end, :) = vectors_list;
            
            for index = 1:size(vectors_list, 2)
                for jndex = 1:size(vectors_list, 2)

                    vectA = vectors_list(:, index);
                    vectB = vectors_list(:, jndex);

                    if vectA == vectB
                        continue;
                    end

                    % No need for abs() function, because it'll be
                    % rised by 2.
                    dist_r = vectA(1) - vectB(1);
                    dist_g = vectA(2) - vectB(2);
                    dist_b = vectA(3) - vectB(3);
                    euclidean_dist = floor(sqrt(dist_r^2 + dist_g^2 + dist_b^2));
                    
                    distances(1, index) = distances(1, index) + euclidean_dist;
                end
            end
            
            [~, order] = sort(distances(1, :));
            sorted_vectors = distances(2:end, order);
            filtered_image(x_index, y_index, :) = sorted_vectors(:, 1);
            
        end
    end
    
    filtered_image = cast(filtered_image, 'uint8');
end