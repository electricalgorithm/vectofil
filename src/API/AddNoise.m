function noisy_img = AddNoise(image, type, perc, assigned)
    noisy_img = image;
    
    % Check if image and type of noise given.
    if nargin < 2
        error("Not enough arguments.");
    else
        % Check if percentage given.
        if nargin < 3
            perc = 0.5;
        end
        % Check if assigned RGB color given.
        if nargin < 4
            assigned = [-1, -1, -1];
        end
    end
    
    % If Gaussian selected.
    if lower(type) == "gaussian" || lower(type) == 'g'
        noisy_img = imnoise(image, 'gaussian');
    end

    % If Pseudo selected.
    if lower(type) == "pseudo" || lower(type) == 'p'
        % Travel throught every pixel.
        for index = 1:size(image, 1)
            for jndex = 1:size(image, 2)
                
                % Randomly creating a vector size of channel size.
                random_vector = randi(255, size(image, 3), 1);
                
                % Accoring to percentage, make the interval for each channel.
                limit_down = floor(random_vector.*((100-perc)/100));
                limit_up = floor(random_vector.*((100+perc)/100));
                interval = [limit_down, limit_up];
                
                % Setting the vector negative numbers as 0 (black),
                % and the number greater then 255 as 255 (white).
                interval(interval < 0) = 0;
                interval(interval > 255) = 255;
                
                reshaped_area = reshape(image(index, jndex, :), [], size(image, 3))';
                
                % Check condition if its in interval for assign noise.
                if (min((interval(:, 1) < reshaped_area)) && ...
                    min(reshaped_area < interval(:, 2)))
    
                    CurrentNoiseColour = assigned;
                    % Checking for [-1, 0) interval in the RGB color
                    % spinner. If a negative value given, it means that
                    % we want it to be random.
                    if CurrentNoiseColour(1) < 0
                        CurrentNoiseColour(1) = randi([0, 255], [1, 1]);
                    end
                    if CurrentNoiseColour(2) < 0
                        CurrentNoiseColour(2) = randi([0, 255], [1, 1]);
                    end
                    if CurrentNoiseColour(3) < 0
                        CurrentNoiseColour(3) = randi([0, 255], [1, 1]);
                    end
    
                    noisy_img(index, jndex, :) = CurrentNoiseColour;
                end
            end
        end
    end
end
