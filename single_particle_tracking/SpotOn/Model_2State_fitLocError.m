function Binned_y = Model_2State_fitLocError(parameter_guess, JumpProb, data_to_fit)
%Model_2State_fitLocError 2-state model, fitted localization error

dT = data_to_fit.dT;
HistVecJumps = data_to_fit.HistVecJumps;
dZ = data_to_fit.dZ;
HistVecJumpsCDF = data_to_fit.HistVecJumpsCDF;
ModelFit = data_to_fit.ModelFit;
Z_corr_a = data_to_fit.Z_corr_a;
Z_corr_b = data_to_fit.Z_corr_b;
JumpsPerdT = data_to_fit.JumpsPerdT;
UseWeights = data_to_fit.UseWeights;

% define key parameters
r = HistVecJumpsCDF;
y = zeros(size(JumpProb,1), length(r));
Binned_y_PDF = zeros(size(JumpProb,1), size(JumpProb,2));


%Assign a value to each parameter
D_FREE = parameter_guess(1);
D_BOUND = parameter_guess(2);
F_BOUND = parameter_guess(3);
FIT_LocError = parameter_guess(4);

%Assume ABSORBING BOUNDARIES
Z_corr = zeros(1,size(JumpProb,1));

for iterator=1:size(JumpProb,1)
    %Calculate the jump length distribution of the parameters for each time-jump
    curr_dT = iterator*dT;
    
    %Calculate the axial Z-correction
    %First calculate the corrected DeltaZ:
    DeltaZ_use = dZ + Z_corr_a  * sqrt(D_FREE) + Z_corr_b;
    
    % use half DeltaZ
    HalfDeltaZ_use = DeltaZ_use/2;
    
    %Compute the integral
    Z_corr(1,iterator) =  1/DeltaZ_use * integral(@(z)C_AbsorBoundAUTO(z,curr_dT, D_FREE, HalfDeltaZ_use),-HalfDeltaZ_use,HalfDeltaZ_use);
    
    %update the function output
    y(iterator,:) = Z_corr(1,iterator).*(1-F_BOUND).*(r./(2*(D_FREE*curr_dT+FIT_LocError^2))).*exp(-r.^2./(4*(D_FREE*curr_dT+FIT_LocError^2))) + F_BOUND.*(r./(2*(D_BOUND*curr_dT+FIT_LocError^2))).*exp(-r.^2./(4*(D_BOUND*curr_dT+FIT_LocError^2))) ;
end

% Make sure the model output (PDF or CDF) fits the model input:
if ModelFit == 1
    % Now bin the output y so that it matches the JumpProb variable: 
    for i=1:size(JumpProb,1)
        for j=1:size(JumpProb,2)
            if j == size(JumpProb,2)
                Binned_y_PDF(i,j) = mean(y(i,maxIndex:end));
            else
                [~, minIndex] = min(abs(r-HistVecJumps(j)));
                [~, maxIndex] = min(abs(r-HistVecJumps(j+1)));
                Binned_y_PDF(i,j) = mean(y(i,minIndex:maxIndex-1));
            end
        end
    end

    %Normalize:
    for i=1:size(JumpProb,1)
        Binned_y_PDF(i,:) = Binned_y_PDF(i,:)./sum(Binned_y_PDF(i,:));
    end

    %You want to fit to a histogram
    %So no need to calculate the CDF
    Binned_y = Binned_y_PDF;

    % Perform weighting: at increasing dT, there is less data, so weigh
    % Binned_y based on the amount of data available:
    if UseWeights == 1
        for iter = 1:size(Binned_y,1)
            Binned_y(iter,:) = Binned_y(iter,:).*JumpsPerdT(iter);
        end
    end
    
elseif ModelFit == 2
    %You want to fit to a CDF function
    %So first we must calculate the CDF from the finely binned PDF
    Binned_y_CDF = zeros(size(JumpProb,1), size(JumpProb,2));

    %Normalize the PDF
    for i=1:size(Binned_y_CDF,1)
        Binned_y_PDF(i,:) = y(i,:)./sum(y(i,:));
    end
    %calculate the CDF
    for i=1:size(Binned_y_CDF,1)
        for j=2:size(Binned_y_CDF,2)
            Binned_y_CDF(i,j) = sum(Binned_y_PDF(i,1:j));
        end
    end

    %Output the final variable
    Binned_y = Binned_y_CDF;
    
    % Perform weighting: at increasing dT, there is less data, so weigh
    % Binned_y based on the amount of data available:
    if UseWeights == 1
        for iter = 1:size(Binned_y,1)
            Binned_y(iter,:) = Binned_y(iter,:).*JumpsPerdT(iter);
        end
    end
end