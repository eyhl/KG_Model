function indeces = find_closest_times(model_time, data_time)
    %FIND_CLOSEST_TIMES Find the indeces of the closest times in data_time to
    %model_time

    indeces = zeros(length(data_time), 1);
    for i = 1:length(data_time)
        [~, indeces(i)] = min(abs(data_time(i) - model_time));
    end
    indeces = unique(indeces);
end