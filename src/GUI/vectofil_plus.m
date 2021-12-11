classdef vectofil_plus < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        VectofilUIFigure           matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        LeftPanel                  matlab.ui.container.Panel
        MadeforComputerVisionandImageProcessingcourseinZUTLabel_6  matlab.ui.control.Label
        MadeforComputerVisionandImageProcessingcourseinZUTLabel_3  matlab.ui.control.Label
        MadeforComputerVisionandImageProcessingcourseinZUTLabel_2  matlab.ui.control.Label
        InputImageCanvas           matlab.ui.control.Image
        MadeforComputerVisionandImageProcessingcourseinZUTLabel  matlab.ui.control.Label
        PleasechooseanimagetoprocessLabel  matlab.ui.control.Label
        VectofilLabel              matlab.ui.control.Label
        HellowelcometoLabel        matlab.ui.control.Label
        InputImageBrowseButton     matlab.ui.control.Button
        ImageLocationTextBox       matlab.ui.control.EditField
        CenterPanel                matlab.ui.container.Panel
        NoiseWantSwitch            matlab.ui.control.RockerSwitch
        NoiseTypeSelector          matlab.ui.control.RockerSwitch
        NoiseText                  matlab.ui.control.Label
        NoiseLabel                 matlab.ui.control.Label
        ColorShowLamp              matlab.ui.control.Lamp
        PerformTheNoiseButton      matlab.ui.control.Button
        NoisyImageCanvas           matlab.ui.control.Image
        PercentageLabel            matlab.ui.control.Label
        UnderLineDesign            matlab.ui.control.Label
        NoiseAdditionLabel         matlab.ui.control.Label
        BlueLabel                  matlab.ui.control.Label
        GreenLabel                 matlab.ui.control.Label
        RedLabel                   matlab.ui.control.Label
        ColourLabel                matlab.ui.control.Label
        BlueSpinner                matlab.ui.control.Spinner
        GreenSpinner               matlab.ui.control.Spinner
        RedSpinner                 matlab.ui.control.Spinner
        NoisePercentageSlider      matlab.ui.control.Slider
        RightPanel                 matlab.ui.container.Panel
        yValueLabel                matlab.ui.control.Label
        pValueText                 matlab.ui.control.Label
        pValueSelector             matlab.ui.control.Slider
        pValueLabel                matlab.ui.control.Label
        yValueTextBox              matlab.ui.control.NumericEditField
        yValueHelpText             matlab.ui.control.Label
        MethodLabel                matlab.ui.control.Label
        FilteringStatusLamp        matlab.ui.control.Lamp
        MethodSelectorKnob         matlab.ui.control.DiscreteKnob
        WindowSizeLabel            matlab.ui.control.Label
        PerformTheFilteringButton  matlab.ui.control.Button
        SaveTheProcess             matlab.ui.control.Button
        SaveTheResults             matlab.ui.control.Button
        FilteredImageCanvas        matlab.ui.control.Image
        WindowSizeKnob             matlab.ui.control.DiscreteKnob
        FilteringLabel             matlab.ui.control.Label
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
        twoPanelWidth = 768;
    end

    
    properties (Access = private)
        IsNoiseWanted = true; % To share if the user wants noise or not.
        ImageItself           % Variable to hold image uint8 matrix.
        NoisyImage            % Variable to hold noisy image.
        NoiseColour = [255, 255, 255];
        NoisePercentage = 0; 
        FilteringWindowSize = 3;
        FilteredImage
        LambColorWorking = [1, 0, 0];
        LambColorFree = [0, 1, 0];
        FilteringMethod = 'VMF';
        DDFSettings = [2, 1];
        NoiseType = 'g';
    end
    
    methods (Access = public)
        
        function NoiseAddition(app)
            app.NoisyImage = app.ImageItself;
    
            % Travel throught every pixel.
            for index = 1:size(app.ImageItself, 1)
                for jndex = 1:size(app.ImageItself, 2)
                    
                    % Randomly creating a vector size of channel size.
                    random_vector = randi(255, size(app.ImageItself, 3), 1);
                    
                    % Accoring to percentage, make the interval for each channel.
                    limit_down = floor(random_vector.*((100-app.NoisePercentage)/100));
                    limit_up = floor(random_vector.*((100+app.NoisePercentage)/100));
                    interval = [limit_down, limit_up];
                    
                    % Setting the vector negative numbers as 0 (black),
                    % and the number greater then 255 as 255 (white).
                    interval(interval < 0) = 0;
                    interval(interval > 255) = 255;
                    
                    reshaped_area = reshape(app.ImageItself(index, jndex, :), [], size(app.ImageItself, 3))';
                     % If Gaussian selected.
                    if lower(app.NoiseType) == 'g'
                        app.NoisyImage = imnoise(image, 'gaussian');
                    end
                
                    % If Pseudo selected.
                    if lower(app.NoiseType) == 'p'
                        % Check condition if its in interval for assign noise.
                        if (min((interval(:, 1) < reshaped_area)) && ...
                            min(reshaped_area < interval(:, 2)))
                            
                            CurrentNoiseColour = app.NoiseColour;
                            % Checking for [-1, 0) interval in the RGB color
                            % spinner. If a negative value given, it means that
                            % we want it to be random.
                            if app.NoiseColour(1) < 0
                                CurrentNoiseColour(1) = randi([0, 255], [1, 1]);
                            end
                            if app.NoiseColour(2) < 0
                                CurrentNoiseColour(2) = randi([0, 255], [1, 1]);
                            end
                            if app.NoiseColour(3) < 0
                                CurrentNoiseColour(3) = randi([0, 255], [1, 1]);
                            end
                            
                            app.NoisyImage(index, jndex, :) = CurrentNoiseColour;
                        end
                    end
                end
            end
            
            app.NoisyImageCanvas.ImageSource = app.NoisyImage;
        end
        
        function [sorted_vectors, sorted_angles] = SortVectorsbyAngle(~, vectors)
        % BVDF_VECTOR_SORT A function to sort the given n-dimensional vectors.
        % Parameter vectors has to be a matrix which every column represents a
        % vector. Function returns a vector, first element is the sorted vectors'
        % matrix, and the second element is the sorted angles.
        
            % Create a zero-matrix for results, and assign our vectors into. First
            % row for the angles, and the remaining rows for the vectors. I'm
            % making this way, because sorting function works only this way.
            angles = zeros(size(vectors, 1) + 1, size(vectors, 2));
            angles(2:end, :) = vectors;
            
            % Choose the reference point for calculation.
            for index = 1:size(vectors, 2)
                % Travel every element to find angle according to reference element.
                for jndex = 1:size(vectors, 2)
                    
                    vectorA = vectors(:, index);
                    vectorB = vectors(:, jndex);
                    
                    % If it's the same element, do not calculate angle because it's
                    % zero.
                    if vectorA == vectorB
                        continue;
                    end
                    
                    % Add the indexth elements' angle for each element angle.
                    angles(1, index) = angles(1, index) + acosd(dot(vectorA, vectorB) / (norm(vectorA) * norm(vectorB)));
                end
            end
            
            % Sort process according the first row.
            [sorted_angles, order] = sort(angles(1, :));
            sorted_vectors = angles(2:end, order);
        end
        
        function filtered_image = BasicVectorDirectionalFilter(app, image, window_size)
        % BVDF_FILTER Function to filter the image according the BVDF rule.
            if nargin < 2
                error("You have to give the image as uint8 matrix, and dimensions of the vectoral process.");
            end
            
            color_count = size(image, 3);
            image_X = size(image, 1);
            image_Y = size(image, 2);
            
            starting_points = [ceil(window_size/2), ceil(window_size/2)];
            choosing_distance = [floor(window_size/2), floor(window_size/2)];
            filtered_image = zeros(image_X, image_Y, color_count);
            
            for x_index = starting_points(1):1:(image_X-starting_points(1))
                for y_index = starting_points(2):1:(image_Y-starting_points(2))
                    
                    area2filter = image(x_index-choosing_distance(1):x_index+choosing_distance(2),...
                                        y_index-choosing_distance(2):y_index+choosing_distance(2), :);
                                    
                    area2filter = im2double(area2filter).*255;
                    
                    vectors_list = reshape(area2filter , [], 3)';
                    sorted_vectors = app.SortVectorsbyAngle(vectors_list);
                    filtered_image(x_index, y_index, :) = sorted_vectors(:, 1);
                end
            end
            
            filtered_image = cast(filtered_image, 'uint8');
            
        end
        
        function filtered_image = VectorMedianFilter(app, image, window_size)
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
        
        
        function filtered_image = DistanceDirectionalFilter(app, corrupted_image, window_size, BVDFratio, yValueVMF)
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
                    [~, DDForder] = sort(calculations(1, :));
                    DDFSortedVects = calculations(4:end, DDForder);
                    DDF_Vector = DDFSortedVects(:, 1);
                    
                    filtered_image(x_index, y_index, :) = DDF_Vector;
                    
                end
            end
            
            filtered_image = cast(filtered_image, 'uint8');
            
        end
    end
    
    methods (Access = private)
        
        function BVDFfilter(app)
            app.FilteringStatusLamp.Color = app.LambColorWorking;
            
            app.FilteredImage = app.BasicVectorDirectionalFilter(app.NoisyImage, app.FilteringWindowSize);
            
            app.FilteredImageCanvas.ImageSource = app.FilteredImage;
            app.FilteringStatusLamp.Color = app.LambColorFree;
        end
        
        function VMFfilter(app)
            app.FilteringStatusLamp.Color = app.LambColorWorking;
            
            app.FilteredImage = app.VectorMedianFilter(app.NoisyImage, app.FilteringWindowSize);
            
            app.FilteredImageCanvas.ImageSource = app.FilteredImage;
            app.FilteringStatusLamp.Color = app.LambColorFree;
            
        end
        
        function DDFfilter(app)
            app.FilteringStatusLamp.Color = app.LambColorWorking;
            
            app.FilteredImage = app.DistanceDirectionalFilter(...
                app.NoisyImage, ...
                app.FilteringWindowSize, ...
                str2double(app.pValueTextBox.Value),...
                str2double(app.yValueTextBox.Value)...
            );
            
            app.FilteredImageCanvas.ImageSource = app.FilteredImage;
            app.FilteringStatusLamp.Color = app.LambColorFree;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.VectofilUIFigure.Name = 'Vectofil+';
            
            app.ColorShowLamp.Color = app.NoiseColour./255;
            app.RedSpinner.Value = app.NoiseColour(1);
            app.GreenSpinner.Value = app.NoiseColour(2);
            app.BlueSpinner.Value = app.NoiseColour(3);
            app.NoiseText.Text = sprintf("%%%d", app.NoisePercentage);
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.VectofilUIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 3x1 grid
                app.GridLayout.RowHeight = {549, 549, 549};
                app.GridLayout.ColumnWidth = {'1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 1;
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 3;
                app.RightPanel.Layout.Column = 1;
            elseif (currentFigureWidth > app.onePanelWidth && currentFigureWidth <= app.twoPanelWidth)
                % Change to a 2x2 grid
                app.GridLayout.RowHeight = {549, 549};
                app.GridLayout.ColumnWidth = {'1x', '1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = [1,2];
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 2;
            else
                % Change to a 1x3 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {335, '1x', 677};
                app.LeftPanel.Layout.Row = 1;
                app.LeftPanel.Layout.Column = 1;
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 2;
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 3;
            end
        end

        % Button pushed function: InputImageBrowseButton
        function InputImageBrowseButtonPushed(app, event)
            % Get the location and image within a dialog window.
            [in_img_name, in_img_location] = uigetfile({'*.png'; '*.jpg'; '*.jpeg';});
            app.ImageItself = imread(fullfile(in_img_location, in_img_name));
            
            % Add the image to image canvas for user.
            app.InputImageCanvas.ImageSource = app.ImageItself;
            app.InputImageCanvas.Visible = 'on';
            app.InputImageCanvas.Enable = 'on';
            
            % Show the radio button of noise.
            app.NoiseWantSwitch.Visible = 'on';
            app.NoiseWantSwitch.Enable = 'on';
            
            % Change the button name browse.
            app.InputImageBrowseButton.Text = "Another!";
            
            % Put the file location into the box of location.
            app.ImageLocationTextBox.Value = fullfile(in_img_location, in_img_name);
            
            % Enable the selection of noise.
            app.NoiseWantSwitch.Enable = 'on';
            
            % Enable the filtering section.
            app.WindowSizeKnob.Enable = 'on';
            app.PerformTheFilteringButton.Enable = 'on';
            app.FilteringStatusLamp.Enable = 'on';
            app.MethodSelectorKnob.Enable = 'on';
            app.SaveTheProcess.Enable = 'on';
            app.SaveTheResults.Enable = 'on';
            app.FilteringLabel.Enable = 'on';
            app.FilteringStatusLamp.Color = app.LambColorFree;
        end

        % Callback function
        function NoiseWantSwitchValueChanged(app, event)
            value = app.NoiseWantSwitch.Value;
            if (value == "Salt, pepper, noise!")
                app.NoiseTypeSelector.Enable = 'on';
                app.PercentageLabel.Enable = 'on';
                app.NoisePercentageSlider.Enable = 'on';
                
                app.ColorShowLamp.Enable = 'on';
                app.ColourLabel.Enable = 'on';
                app.BlueLabel.Enable = 'on';
                app.BlueSpinner.Enable = 'on';
                app.RedLabel.Enable = 'on';
                app.RedSpinner.Enable = 'on';
                app.GreenLabel.Enable = 'on';
                app.GreenSpinner.Enable = 'on';
                
                app.NoiseLabel.Enable = 'on';
                app.NoiseText.Enable = 'on';
                
                app.PerformTheNoiseButton.Enable = 'on';
            else
                app.PercentageLabel.Enable = 'off';
                app.NoisePercentageSlider.Enable = 'off';
                
                app.ColorShowLamp.Enable = 'off';
                app.ColourLabel.Enable = 'off';
                app.BlueLabel.Enable = 'off';
                app.BlueSpinner.Enable = 'off';
                app.RedLabel.Enable = 'off';
                app.RedSpinner.Enable = 'off';
                app.GreenLabel.Enable = 'off';
                app.GreenSpinner.Enable = 'off';
                
                app.NoiseLabel.Enable = 'off';
                app.NoiseText.Enable = 'off';
                
                app.PerformTheNoiseButton.Enable = 'off';
            end
            
        end

        % Value changing function: RedSpinner
        function RedSpinnerValueChanging(app, event)
            changingValue = event.Value;
            app.NoiseColour = [changingValue, app.NoiseColour(2), app.NoiseColour(3)];
            
            if min(app.NoiseColour) < 0
                app.ColorShowLamp.Enable = "off";
            else
                app.ColorShowLamp.Enable = "on";
                app.ColorShowLamp.Color = app.NoiseColour./255;
            end
        end

        % Value changing function: GreenSpinner
        function GreenSpinnerValueChanging(app, event)
            changingValue = event.Value;
            app.NoiseColour = [app.NoiseColour(1), changingValue, app.NoiseColour(3)];
            
            if min(app.NoiseColour) < 0
                app.ColorShowLamp.Enable = "off";
            else
                app.ColorShowLamp.Enable = "on";
                app.ColorShowLamp.Color = app.NoiseColour./255;
            end
        end

        % Value changing function: BlueSpinner
        function BlueSpinnerValueChanging(app, event)
            changingValue = event.Value;
            app.NoiseColour = [app.NoiseColour(1), app.NoiseColour(2), changingValue];
            
            if min(app.NoiseColour) < 0
                app.ColorShowLamp.Enable = "off";
            else
                app.ColorShowLamp.Enable = "on";
                app.ColorShowLamp.Color = app.NoiseColour./255;
            end
        end

        % Value changing function: NoisePercentageSlider
        function NoisePercentageSliderValueChanging(app, event)
            changingValue = event.Value;
            app.NoisePercentage = changingValue;
            app.NoiseText.Text = sprintf("%%%d", floor(app.NoisePercentage));
        end

        % Button pushed function: PerformTheNoiseButton
        function PerformTheNoiseButtonPushed(app, event)
            NoiseAddition(app);
            app.NoisyImageCanvas.Visible = 'on';
            app.NoisyImageCanvas.Enable = 'on';
            app.WindowSizeKnob.Visible = 'on';
            app.WindowSizeKnob.Enable = 'on';
            app.FilteringStatusLamp.Enable = 'on';
            app.FilteringStatusLamp.Visible = 'on';
        end

        % Value changed function: WindowSizeKnob
        function WindowSizeKnobValueChanged(app, event)
            value = app.WindowSizeKnob.Value;
            if (value == "Stop") 
                app.FilteringWindowSize = 3;
            else
                app.FilteringWindowSize = str2double(value);
            end
        end

        % Button pushed function: PerformTheFilteringButton
        function PerformTheFilteringButtonPushed(app, event)
            BVDFfilter(app);
            app.FilteredImageCanvas.Enable = 'on';
            app.FilteredImageCanvas.Visible = 'on';
            app.SaveTheResults.Enable = 'on';
            app.SaveTheResults.Visible = 'on';
            app.SaveTheProcess.Enable = 'on';
            app.SaveTheProcess.Visible = 'on';
        end

        % Value changed function: MethodSelectorKnob
        function MethodSelectorKnobValueChanged(app, event)
            NewMethod = app.MethodSelectorKnob.Value;
            if ~strcmpi(app.FilteringMethod, NewMethod)
                app.FilteringMethod = NewMethod;
                app.FilteredImage = zeros(size(app.ImageItself));
                app.FilteredImageCanvas.Visible = 'off';
            end
            
            if (app.FilteringMethod == "DDF")
                app.yValueTextBox.Enable =      'on';
                app.yValueTextBox.Visible =     'on';
                app.yValueHelpText.Enable =     'on';
                app.yValueHelpText.Visible =    'on';
                app.yValueLabel.Enable =        'on';
                app.yValueLabel.Visible =       'on';
                
                app.pValueSelector.Visible =    'on';
                app.pValueSelector.Enable =     'on';
                app.pValueLabel.Visible =       'on';
                app.pValueLabel.Enable =        'on';
                app.pValueText.Visible =        'on';
                app.pValueText.Enable =         'on';
            else
                app.yValueTextBox.Enable =      'off';
                app.yValueTextBox.Visible =     'off';
                app.yValueHelpText.Enable =     'off';
                app.yValueHelpText.Visible =    'off';
                app.yValueLabel.Enable =        'off';
                app.yValueLabel.Visible =       'off';
                
                app.pValueSelector.Visible =    'off';
                app.pValueSelector.Enable =     'off';
                app.pValueLabel.Visible =       'off';
                app.pValueLabel.Enable =        'off';
                app.pValueText.Visible =        'off';
                app.pValueText.Enable =         'off';
            end
        end

        % Value changing function: pValueSelector
        function pValueSelectorValueChanging(app, event)
            changingValue = event.Value;
            changingValue = changingValue/100;
            app.DDFSettings(2) = changingValue;
            app.pValueText.Text = sprintf("%%%d", floor(app.DDFSettings(2)*100));
        end

        % Value changed function: NoiseWantSwitch
        function NoiseWantSwitchValueChanged2(app, event)
            value = app.NoiseWantSwitch.Value;
            if (value == "Salt, pepper, noise!")
                app.NoiseTypeSelector.Enable = 'on';
                app.PerformTheNoiseButton.Enable = 'on';
            else
                app.NoiseTypeSelector.Enable = 'off';
                app.PercentageLabel.Enable = 'off';
                app.NoisePercentageSlider.Enable = 'off';
                
                app.ColorShowLamp.Enable = 'off';
                app.ColourLabel.Enable = 'off';
                app.BlueLabel.Enable = 'off';
                app.BlueSpinner.Enable = 'off';
                app.RedLabel.Enable = 'off';
                app.RedSpinner.Enable = 'off';
                app.GreenLabel.Enable = 'off';
                app.GreenSpinner.Enable = 'off';
                
                app.NoiseLabel.Enable = 'off';
                app.NoiseText.Enable = 'off';
                
                app.PerformTheNoiseButton.Enable = 'off';
                
                app.NoisyImage = app.ImageItself;
            end
            
        end

        % Value changed function: NoiseTypeSelector
        function NoiseTypeSelectorValueChanged(app, event)
            value = app.NoiseTypeSelector.Value;
            if (value == "Pseudo Noise")
                app.NoiseType = 'p';
                
                app.PercentageLabel.Enable = 'on';
                app.NoisePercentageSlider.Enable = 'on';
                
                app.ColorShowLamp.Enable = 'on';
                app.ColourLabel.Enable = 'on';
                app.BlueLabel.Enable = 'on';
                app.BlueSpinner.Enable = 'on';
                app.RedLabel.Enable = 'on';
                app.RedSpinner.Enable = 'on';
                app.GreenLabel.Enable = 'on';
                app.GreenSpinner.Enable = 'on';
                
                app.NoiseLabel.Enable = 'on';
                app.NoiseText.Enable = 'on';
            else
                app.NoiseType = 'g';
                app.PerformTheNoiseButton.Enable = 'on';
                app.PercentageLabel.Enable = 'off';
                app.NoisePercentageSlider.Enable = 'off';
                
                app.ColorShowLamp.Enable = 'off';
                app.ColourLabel.Enable = 'off';
                app.BlueLabel.Enable = 'off';
                app.BlueSpinner.Enable = 'off';
                app.RedLabel.Enable = 'off';
                app.RedSpinner.Enable = 'off';
                app.GreenLabel.Enable = 'off';
                app.GreenSpinner.Enable = 'off';
                
                app.NoiseLabel.Enable = 'off';
                app.NoiseText.Enable = 'off';
            end
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create VectofilUIFigure and hide until all components are created
            app.VectofilUIFigure = uifigure('Visible', 'off');
            app.VectofilUIFigure.AutoResizeChildren = 'off';
            app.VectofilUIFigure.Position = [100 100 1348 549];
            app.VectofilUIFigure.Name = 'Vectofil+';
            app.VectofilUIFigure.Resize = 'off';
            app.VectofilUIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
            app.VectofilUIFigure.Tag = 'version Jeden';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.VectofilUIFigure);
            app.GridLayout.ColumnWidth = {335, '1x', 677};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create ImageLocationTextBox
            app.ImageLocationTextBox = uieditfield(app.LeftPanel, 'text');
            app.ImageLocationTextBox.Placeholder = 'With some smile, please!';
            app.ImageLocationTextBox.Position = [21 371 192 22];

            % Create InputImageBrowseButton
            app.InputImageBrowseButton = uibutton(app.LeftPanel, 'push');
            app.InputImageBrowseButton.ButtonPushedFcn = createCallbackFcn(app, @InputImageBrowseButtonPushed, true);
            app.InputImageBrowseButton.Position = [222 371 100 22];
            app.InputImageBrowseButton.Text = 'Browse';

            % Create HellowelcometoLabel
            app.HellowelcometoLabel = uilabel(app.LeftPanel);
            app.HellowelcometoLabel.HorizontalAlignment = 'center';
            app.HellowelcometoLabel.FontSize = 25;
            app.HellowelcometoLabel.FontWeight = 'bold';
            app.HellowelcometoLabel.Position = [25 492 226 31];
            app.HellowelcometoLabel.Text = 'Hello, welcome to ';

            % Create VectofilLabel
            app.VectofilLabel = uilabel(app.LeftPanel);
            app.VectofilLabel.HorizontalAlignment = 'center';
            app.VectofilLabel.FontSize = 35;
            app.VectofilLabel.FontWeight = 'bold';
            app.VectofilLabel.Position = [25 450 150 43];
            app.VectofilLabel.Text = 'Vectofil+';

            % Create PleasechooseanimagetoprocessLabel
            app.PleasechooseanimagetoprocessLabel = uilabel(app.LeftPanel);
            app.PleasechooseanimagetoprocessLabel.Position = [21 396 200 22];
            app.PleasechooseanimagetoprocessLabel.Text = 'Please choose an image to process.';

            % Create MadeforComputerVisionandImageProcessingcourseinZUTLabel
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel = uilabel(app.LeftPanel);
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel.HorizontalAlignment = 'center';
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel.FontSize = 10;
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel.Position = [27 317 295 22];
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel.Text = {'Made for Computer Vision and Image Processing course in ZUT.'; 'License: GPL v2 (2021-2022 Fall)'};

            % Create InputImageCanvas
            app.InputImageCanvas = uiimage(app.LeftPanel);
            app.InputImageCanvas.Enable = 'off';
            app.InputImageCanvas.Visible = 'off';
            app.InputImageCanvas.Position = [69 89 197 200];

            % Create MadeforComputerVisionandImageProcessingcourseinZUTLabel_2
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_2 = uilabel(app.LeftPanel);
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_2.HorizontalAlignment = 'center';
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_2.FontSize = 10;
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_2.FontWeight = 'bold';
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_2.Position = [22 338 299 22];
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_2.Text = 'https://github.com/electricalgorithm/vectofil';

            % Create MadeforComputerVisionandImageProcessingcourseinZUTLabel_3
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_3 = uilabel(app.LeftPanel);
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_3.HorizontalAlignment = 'center';
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_3.FontSize = 10;
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_3.Position = [21 44 290 22];
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_3.Text = 'Twitter: @gkhnkcmrli & LinkedIn: in/gokhankocmarli';

            % Create MadeforComputerVisionandImageProcessingcourseinZUTLabel_6
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_6 = uilabel(app.LeftPanel);
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_6.HorizontalAlignment = 'center';
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_6.FontSize = 10;
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_6.Position = [23 31 293 22];
            app.MadeforComputerVisionandImageProcessingcourseinZUTLabel_6.Text = 'Icon: Hydra @ flaticon.com';

            % Create CenterPanel
            app.CenterPanel = uipanel(app.GridLayout);
            app.CenterPanel.Layout.Row = 1;
            app.CenterPanel.Layout.Column = 2;

            % Create NoisePercentageSlider
            app.NoisePercentageSlider = uislider(app.CenterPanel);
            app.NoisePercentageSlider.ValueChangingFcn = createCallbackFcn(app, @NoisePercentageSliderValueChanging, true);
            app.NoisePercentageSlider.Enable = 'off';
            app.NoisePercentageSlider.Position = [132 439 171 3];

            % Create RedSpinner
            app.RedSpinner = uispinner(app.CenterPanel);
            app.RedSpinner.ValueChangingFcn = createCallbackFcn(app, @RedSpinnerValueChanging, true);
            app.RedSpinner.Limits = [-1 255];
            app.RedSpinner.RoundFractionalValues = 'on';
            app.RedSpinner.Enable = 'off';
            app.RedSpinner.Position = [123 359 64 22];

            % Create GreenSpinner
            app.GreenSpinner = uispinner(app.CenterPanel);
            app.GreenSpinner.ValueChangingFcn = createCallbackFcn(app, @GreenSpinnerValueChanging, true);
            app.GreenSpinner.Limits = [-1 255];
            app.GreenSpinner.RoundFractionalValues = 'on';
            app.GreenSpinner.Enable = 'off';
            app.GreenSpinner.Position = [188 359 64 22];

            % Create BlueSpinner
            app.BlueSpinner = uispinner(app.CenterPanel);
            app.BlueSpinner.ValueChangingFcn = createCallbackFcn(app, @BlueSpinnerValueChanging, true);
            app.BlueSpinner.Limits = [-1 255];
            app.BlueSpinner.RoundFractionalValues = 'on';
            app.BlueSpinner.Enable = 'off';
            app.BlueSpinner.Position = [253 359 64 22];

            % Create ColourLabel
            app.ColourLabel = uilabel(app.CenterPanel);
            app.ColourLabel.WordWrap = 'on';
            app.ColourLabel.Enable = 'off';
            app.ColourLabel.Position = [27 359 93 22];
            app.ColourLabel.Text = 'Colour';

            % Create RedLabel
            app.RedLabel = uilabel(app.CenterPanel);
            app.RedLabel.HorizontalAlignment = 'center';
            app.RedLabel.FontSize = 10;
            app.RedLabel.Enable = 'off';
            app.RedLabel.Position = [125 338 62 22];
            app.RedLabel.Text = 'Red';

            % Create GreenLabel
            app.GreenLabel = uilabel(app.CenterPanel);
            app.GreenLabel.HorizontalAlignment = 'center';
            app.GreenLabel.FontSize = 10;
            app.GreenLabel.Enable = 'off';
            app.GreenLabel.Position = [187 338 62 22];
            app.GreenLabel.Text = 'Green';

            % Create BlueLabel
            app.BlueLabel = uilabel(app.CenterPanel);
            app.BlueLabel.HorizontalAlignment = 'center';
            app.BlueLabel.FontSize = 10;
            app.BlueLabel.Enable = 'off';
            app.BlueLabel.Position = [252 338 62 22];
            app.BlueLabel.Text = 'Blue';

            % Create NoiseAdditionLabel
            app.NoiseAdditionLabel = uilabel(app.CenterPanel);
            app.NoiseAdditionLabel.HorizontalAlignment = 'center';
            app.NoiseAdditionLabel.FontSize = 25;
            app.NoiseAdditionLabel.FontWeight = 'bold';
            app.NoiseAdditionLabel.Position = [29 44 175 31];
            app.NoiseAdditionLabel.Text = 'noise addition';

            % Create UnderLineDesign
            app.UnderLineDesign = uilabel(app.CenterPanel);
            app.UnderLineDesign.HorizontalAlignment = 'center';
            app.UnderLineDesign.FontSize = 25;
            app.UnderLineDesign.FontWeight = 'bold';
            app.UnderLineDesign.Position = [28 40 287 31];
            app.UnderLineDesign.Text = '____________________';

            % Create PercentageLabel
            app.PercentageLabel = uilabel(app.CenterPanel);
            app.PercentageLabel.WordWrap = 'on';
            app.PercentageLabel.Enable = 'off';
            app.PercentageLabel.Position = [27 429 93 22];
            app.PercentageLabel.Text = 'Percentage';

            % Create NoisyImageCanvas
            app.NoisyImageCanvas = uiimage(app.CenterPanel);
            app.NoisyImageCanvas.Enable = 'off';
            app.NoisyImageCanvas.Visible = 'off';
            app.NoisyImageCanvas.Position = [56 90 226 201];

            % Create PerformTheNoiseButton
            app.PerformTheNoiseButton = uibutton(app.CenterPanel, 'push');
            app.PerformTheNoiseButton.ButtonPushedFcn = createCallbackFcn(app, @PerformTheNoiseButtonPushed, true);
            app.PerformTheNoiseButton.Enable = 'off';
            app.PerformTheNoiseButton.Position = [123 304 188 22];
            app.PerformTheNoiseButton.Text = 'Perform the Noise';

            % Create ColorShowLamp
            app.ColorShowLamp = uilamp(app.CenterPanel);
            app.ColorShowLamp.Enable = 'off';
            app.ColorShowLamp.Position = [101 360 20 20];
            app.ColorShowLamp.Color = [0 0 0];

            % Create NoiseLabel
            app.NoiseLabel = uilabel(app.CenterPanel);
            app.NoiseLabel.FontWeight = 'bold';
            app.NoiseLabel.Enable = 'off';
            app.NoiseLabel.Position = [30 304 42 22];
            app.NoiseLabel.Text = 'Noise';

            % Create NoiseText
            app.NoiseText = uilabel(app.CenterPanel);
            app.NoiseText.FontSize = 10;
            app.NoiseText.Enable = 'off';
            app.NoiseText.Position = [72 304 49 22];
            app.NoiseText.Text = '%100';

            % Create NoiseTypeSelector
            app.NoiseTypeSelector = uiswitch(app.CenterPanel, 'rocker');
            app.NoiseTypeSelector.Items = {'Pseudo Noise', 'Gaussian Noise'};
            app.NoiseTypeSelector.Orientation = 'horizontal';
            app.NoiseTypeSelector.ValueChangedFcn = createCallbackFcn(app, @NoiseTypeSelectorValueChanged, true);
            app.NoiseTypeSelector.Enable = 'off';
            app.NoiseTypeSelector.Position = [145 466 45 20];
            app.NoiseTypeSelector.Value = 'Gaussian Noise';

            % Create NoiseWantSwitch
            app.NoiseWantSwitch = uiswitch(app.CenterPanel, 'rocker');
            app.NoiseWantSwitch.Items = {'No need for noise.', 'Salt, pepper, noise!'};
            app.NoiseWantSwitch.Orientation = 'horizontal';
            app.NoiseWantSwitch.ValueChangedFcn = createCallbackFcn(app, @NoiseWantSwitchValueChanged2, true);
            app.NoiseWantSwitch.Enable = 'off';
            app.NoiseWantSwitch.Position = [146 492 45 20];
            app.NoiseWantSwitch.Value = 'No need for noise.';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 3;

            % Create FilteringLabel
            app.FilteringLabel = uilabel(app.RightPanel);
            app.FilteringLabel.HorizontalAlignment = 'right';
            app.FilteringLabel.WordWrap = 'on';
            app.FilteringLabel.FontSize = 35;
            app.FilteringLabel.FontWeight = 'bold';
            app.FilteringLabel.Position = [61 480 134 43];
            app.FilteringLabel.Text = 'filtering';

            % Create WindowSizeKnob
            app.WindowSizeKnob = uiknob(app.RightPanel, 'discrete');
            app.WindowSizeKnob.Items = {'3', '5', '7', '9'};
            app.WindowSizeKnob.ValueChangedFcn = createCallbackFcn(app, @WindowSizeKnobValueChanged, true);
            app.WindowSizeKnob.Enable = 'off';
            app.WindowSizeKnob.Position = [69 380 64 64];
            app.WindowSizeKnob.Value = '3';

            % Create FilteredImageCanvas
            app.FilteredImageCanvas = uiimage(app.RightPanel);
            app.FilteredImageCanvas.Enable = 'off';
            app.FilteredImageCanvas.Visible = 'off';
            app.FilteredImageCanvas.Position = [215 90 424 354];

            % Create SaveTheResults
            app.SaveTheResults = uibutton(app.RightPanel, 'push');
            app.SaveTheResults.Enable = 'off';
            app.SaveTheResults.Position = [355 44 108 22];
            app.SaveTheResults.Text = 'Save the Result';

            % Create SaveTheProcess
            app.SaveTheProcess = uibutton(app.RightPanel, 'push');
            app.SaveTheProcess.Enable = 'off';
            app.SaveTheProcess.Position = [470 44 124 22];
            app.SaveTheProcess.Text = 'Save The Process';

            % Create PerformTheFilteringButton
            app.PerformTheFilteringButton = uibutton(app.RightPanel, 'push');
            app.PerformTheFilteringButton.ButtonPushedFcn = createCallbackFcn(app, @PerformTheFilteringButtonPushed, true);
            app.PerformTheFilteringButton.Enable = 'off';
            app.PerformTheFilteringButton.Position = [23 44 313 22];
            app.PerformTheFilteringButton.Text = 'Perform the Filtering';

            % Create WindowSizeLabel
            app.WindowSizeLabel = uilabel(app.RightPanel);
            app.WindowSizeLabel.HorizontalAlignment = 'center';
            app.WindowSizeLabel.FontWeight = 'bold';
            app.WindowSizeLabel.Enable = 'off';
            app.WindowSizeLabel.Position = [61 347 79 22];
            app.WindowSizeLabel.Text = 'Window Size';

            % Create MethodSelectorKnob
            app.MethodSelectorKnob = uiknob(app.RightPanel, 'discrete');
            app.MethodSelectorKnob.Items = {'VMF', 'BVDF', 'DDF'};
            app.MethodSelectorKnob.ValueChangedFcn = createCallbackFcn(app, @MethodSelectorKnobValueChanged, true);
            app.MethodSelectorKnob.Enable = 'off';
            app.MethodSelectorKnob.Position = [69 247 64 64];
            app.MethodSelectorKnob.Value = 'VMF';

            % Create FilteringStatusLamp
            app.FilteringStatusLamp = uilamp(app.RightPanel);
            app.FilteringStatusLamp.Enable = 'off';
            app.FilteringStatusLamp.Position = [27 485 27 27];
            app.FilteringStatusLamp.Color = [1 0 0];

            % Create MethodLabel
            app.MethodLabel = uilabel(app.RightPanel);
            app.MethodLabel.HorizontalAlignment = 'center';
            app.MethodLabel.FontWeight = 'bold';
            app.MethodLabel.Enable = 'off';
            app.MethodLabel.Position = [77 214 48 22];
            app.MethodLabel.Text = 'Method';

            % Create yValueHelpText
            app.yValueHelpText = uilabel(app.RightPanel);
            app.yValueHelpText.HorizontalAlignment = 'right';
            app.yValueHelpText.WordWrap = 'on';
            app.yValueHelpText.FontSize = 10;
            app.yValueHelpText.Visible = 'off';
            app.yValueHelpText.Position = [27 157 177 22];
            app.yValueHelpText.Text = {'2 for Eucledean, 1 for Manhatten'; ''};

            % Create yValueTextBox
            app.yValueTextBox = uieditfield(app.RightPanel, 'numeric');
            app.yValueTextBox.Limits = [1 999];
            app.yValueTextBox.ValueDisplayFormat = '%.2f';
            app.yValueTextBox.Visible = 'off';
            app.yValueTextBox.Position = [156 178 48 22];
            app.yValueTextBox.Value = 2;

            % Create pValueLabel
            app.pValueLabel = uilabel(app.RightPanel);
            app.pValueLabel.Enable = 'off';
            app.pValueLabel.Visible = 'off';
            app.pValueLabel.Position = [23 124 116 22];
            app.pValueLabel.Text = 'Percentage of BVDF';

            % Create pValueSelector
            app.pValueSelector = uislider(app.RightPanel);
            app.pValueSelector.ValueChangingFcn = createCallbackFcn(app, @pValueSelectorValueChanging, true);
            app.pValueSelector.Enable = 'off';
            app.pValueSelector.Visible = 'off';
            app.pValueSelector.Position = [25 114 173 3];

            % Create pValueText
            app.pValueText = uilabel(app.RightPanel);
            app.pValueText.FontWeight = 'bold';
            app.pValueText.Enable = 'off';
            app.pValueText.Visible = 'off';
            app.pValueText.Position = [160 124 49 22];
            app.pValueText.Text = '%0';

            % Create yValueLabel
            app.yValueLabel = uilabel(app.RightPanel);
            app.yValueLabel.Enable = 'off';
            app.yValueLabel.Visible = 'off';
            app.yValueLabel.Position = [23 178 87 22];
            app.yValueLabel.Text = 'y Value of VMF';

            % Show the figure after all components are created
            app.VectofilUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = vectofil_plus

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.VectofilUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.VectofilUIFigure)
        end
    end
end
