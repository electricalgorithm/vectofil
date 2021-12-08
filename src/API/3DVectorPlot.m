function 3DVectorPlot(vectors, origin, ColorScheme)
% 3DVectorPlot The function plots the 3D vectors in space.
% Only and first parameter is the matrix which every column is a vector.
    
    % Control if the optional arguments are given.
    if nargin < 1
        error("Not enough input arguments. You have to give vector list.");
    end
    if ~exist('origin', 'var')
        origin = [0, 0, 0];
    end
    if ~exist('ColorScheme', 'var')
        ColorScheme = 'RGB';
    end

    vector_count = size(vectors, 2);
    
    % Make plot settings.
    figure;
    xlabel('Red'); ylabel('Green'); zlabel('Blue');
    grid on; hold on; view(3); axis equal;

    for index = 1:vector_count
        vector_x = vectors(1, index);
        vector_y = vectors(2, index);
        vector_z = vectors(3, index);
        
        plot3([origin(1), vector_x],...
            [origin(2), vector_y],  ...
            [origin(3), vector_z],  ...
            'color', [vector_x/255, vector_y/255, vector_z/255], ...
            'LineWidth', 3 ...
           );
    end
    
    hold off;
end
