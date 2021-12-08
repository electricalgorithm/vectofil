function filtered_image = DistanceDirectionalFilter(corrupted_image, window_size, BVDFratio, yValueVMF)
    image_X = size(corrupted_image, 1);
    image_Y = size(corrupted_image, 2);

    filtered_image = zeros(size(corrupted_image));
    starting_points = [ceil(window_size/2), ceil(window_size/2)];
    choosing_distance = [floor(window_size/2), floor(window_size/2)];
    
    for x_index = starting_points(1):(image_X-starting_points(1))
        for y_index = starting_points(2):(image_Y-starting_points(2))
            
            area2filter = corrupted_image(x_index-choosing_distance(1):x_index+choosing_distance(2),...
                                y_index-choosing_distance(2):y_index+choosing_distance(2), :);                
            area2filter = im2double(area2filter).*255;
            vectors_list = reshape(area2filter , [], 3)';
            
            % Sorting Process
            % In here, one array of vectors is created. First row will give
            % us the distances calculated with VMF, second row will give us
            % the angles calculated with BVDF. That's why there is "+2".
            calculations = zeros(size(vectors_list, 1) + 3, size(vectors_list, 2));
            calculations(4:end, :) = vectors_list;
            
            for index = 1:size(vectors_list, 2)
                for jndex = 1:size(vectors_list, 2)
                    
                    % For each pixel, we are choosing the window-size of
                    % pixels, and calculate the angles and distances from
                    % them.

                    vectA = vectors_list(:, index);
                    vectB = vectors_list(:, jndex);

                    if vectA == vectB
                        continue;
                    end
                    
                    % BVDF method for window-sized vectors.
                    calculations(3, index) = calculations(2, index) + ...
                        acosd(dot(vectA, vectB) / (norm(vectA) * norm(vectB)));
                    
                    % VMF method for window-sized vectors with Euclodien distances.
                    colorRed = (vectA(1) - vectB(1)).^(yValueVMF);
                    colorGreen = (vectA(2) - vectB(2)).^(yValueVMF);
                    colorBlue = (vectA(3) - vectB(3)).^(yValueVMF);
                    VMF_distance = (colorRed + colorGreen + colorBlue).^(1/yValueVMF);
                    calculations(2, index) = calculations(2, index) + VMF_distance;
                    
                end
            end
            
            % Combination of VMF and BVDF: Distance Directional Filter
            calculations(1, :) = (calculations(3, :).^(BVDFratio)) .* (calculations(2, :).^(1-BVDFratio));
            
            % Sorting the vectors inside the window, with the rules of BVDF
            % and VMF.
            % [~, VMForder] = sort(calculations(2, :));
            % [~, BVDForder] = sort(calculations(3, :));
            % VMFSortedVects = calculations(3:end, VMForder);
            % BVDFSortedVects = calculations(3:end, BVDForder);
            % VMF_Vector = VMFSortedVects(:, 1);
            % BVDF_Vector = BVDFSortedVects(:, 1);
            [~, DDForder] = sort(calculations(1, :));
            DDFSortedVects = calculations(4:end, DDForder);
            DDF_Vector = DDFSortedVects(:, 1);
            
            filtered_image(x_index, y_index, :) = DDF_Vector;
            
        end
    end
    
    filtered_image = cast(filtered_image, 'uint8');
end