function noisy_img = AddPseudoNoise(image, perc, channel_size, assigned)
    noisy_img = image;
    
    % Travel throught every pixel.
    for index = 1:size(image, 1)
        for jndex = 1:size(image, 2)
            
            % Randomly creating a vector size of channel size.
            random_vector = randi(255, channel_size, 1);
            
            % Accoring to percentage, make the interval for each channel.
            limit_down = floor(random_vector.*((100-perc)/100));
            limit_up = floor(random_vector.*((100+perc)/100));
            interval = [limit_down, limit_up];
            
            % Setting the vector negative numbers as 0 (black),
            % and the number greater then 255 as 255 (white).
            interval(interval < 0) = 0;
            interval(interval > 255) = 255;
            
            reshaped_area = reshape(image(index, jndex, :), [], channel_size)';
            
            % Check condition if its in interval for assign noise.
            if (min((interval(:, 1) < reshaped_area)) && ...
                min(reshaped_area < interval(:, 2)))
                noisy_img(index, jndex, :) = assigned;
            end
        end
    end
end
