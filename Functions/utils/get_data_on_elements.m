function [element_data, elements, areas_domain, areas_masked] = get_data_on_elements(md, data, masked, weights)
%GET_DATA_ON_ELEMENTS - get data on elements
% 
%   Usage:
%      [data, elements, areas] = get_data_on_elements(md, data)
%

    % if no weights are given, set them to 1
    if nargin < 4
        weights = ones(size(data));

        % if no mask is given, set it to 0
        if nargin < 3
            masked = logical(zeros(size(data)));
        end
    end
    % Set the area with masked=1 to nan
    data(masked) = nan;
    weights(masked) = nan;

    % get the mesh
    elements=md.mesh.elements;
    x=md.mesh.x;
    y=md.mesh.y;

    %compute areas;
    eleAreas=GetAreas(elements,x,y);
    areas_domain = 1/3 * eleAreas.*(weights(elements(:,1),:)+weights(elements(:,2),:)+weights(elements(:,3),:));

    % filter all nans
    masked = masked | isnan(data) | isnan(weights);

    % Set the area with masked=1 to nan
    data(masked) = nan;
    weights(masked) = nan;

    % integrate nodal data to element
    element_data = 1/3 * eleAreas.*(data(elements(:,1),:).*weights(elements(:,1),:) + data(elements(:,2),:).*weights(elements(:,2),:) + data(elements(:,3),:).*weights(elements(:,3),:));
    areas_masked = 1/3 * eleAreas.*(weights(elements(:,1),:)+weights(elements(:,2),:)+weights(elements(:,3),:));
end