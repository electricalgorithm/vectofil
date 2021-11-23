function [sorted_vectors, sorted_angles] = bvdf_sort_vectors(vectors)
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