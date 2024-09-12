% average field per year
function [yearly_average] = averagePerYear(data, time, startP, endP)
    yearly_average = zeros(size(data, 1), length(startP));    
    for i = 1:length(startP)
        yearly_average(:, i) = averageOverTime(data, time, startP(i), endP(i));
    end
end