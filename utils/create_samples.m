function [samples] = create_samples(nominalVals, varPercentages, numSamples)
%createUQstruct Creates a table of NxM where N is the number of samples and
% M is the number of elements


%% Create samples
% Samples are drawn from a uniform random distribution within the upper and
% lower limits defined by the percentage differences from the nominal
% values specified

% Initialize array
samples = zeros(numSamples, length(nominalVals));

for jj = 1:numSamples
    for ii = 1:length(nominalVals)
        % Calculate the minimum and maximum sample values based on the
        % nominal value and variation percentage
        minLimit = nominalVals(ii) - varPercentages(ii)/100*nominalVals(ii);
        if minLimit < 0 
            minLimit = 0; 
        end
        maxLimit = nominalVals(ii) + varPercentages(ii)/100*nominalVals(ii);

        % Randomly select the sample between the min. and max.
        % limits from a uniform distribution
        samples(jj,ii) = minLimit + (maxLimit - minLimit)*rand();
    end
end


end

