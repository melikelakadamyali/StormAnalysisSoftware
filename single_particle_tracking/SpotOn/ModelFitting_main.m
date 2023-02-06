function data_to_fit = ModelFitting_main(data_to_fit,j)
%ModelFitting_main The is the master function for model fitting
%   All model-fitting is performed within this function and its dependent
%   functions

% Define global variables
UseWeights = data_to_fit.UseWeights;
ModelFit = data_to_fit.ModelFit;
FitLocError = data_to_fit.FitLocError;
NumberOfStates = data_to_fit.NumberOfStates;
FitLocErrorRange = data_to_fit.FitLocErrorRange;
FitIterations = data_to_fit.FitIterations;
D_Free_2State = data_to_fit.D_Free_2State;
D_Bound_2State = data_to_fit.D_Bound_2State;
D_Free1_3State = data_to_fit.D_Free1_3State;
D_Free2_3State = data_to_fit.D_Free2_3State;
D_Bound_3State = data_to_fit.D_Bound_3State;
JumpsPerdT = data_to_fit.JumpsPerdT;
JumpProb = data_to_fit.JumpProb(j,:);
JumpProbCDF = data_to_fit.JumpProbCDF(j,:);
HistVecJumpsCDF = data_to_fit.HistVecJumpsCDF;
HistVecJumps = data_to_fit.HistVecJumps;
% min/max in each state:
FractionInState = [0 1]; % has to be between 0 and 100%.

%%%%%%%%%%%%%%%%%% DEFINE RANGES FOR FITTED PARAMETERS %%%%%%%%%%%%%%%%%%%%
% Define parameters to be fitted depending on:
%   - 2-state or 3-state fitting
%   - Fitting LocError or not 
% so 4 options total
if NumberOfStates == 2 && FitLocError == 0 % 2-state model, fixed Loc Error
    % Lower and Upper parameter bounds
    LB = [D_Free_2State(1,1) D_Bound_2State(1,1) FractionInState(1,1)];
    UB = [D_Free_2State(1,2) D_Bound_2State(1,2) FractionInState(1,2)];
    list_of_model_parameters = {'D_Free', 'D_Bound', 'Frac_Bound'};
    
elseif NumberOfStates == 2 && FitLocError == 1 % 2-state model, Loc Error from fitting
    % Lower and Upper parameter bounds
    LB = [D_Free_2State(1,1) D_Bound_2State(1,1) FractionInState(1,1) FitLocErrorRange(1,1)];
    UB = [D_Free_2State(1,2) D_Bound_2State(1,2) FractionInState(1,2) FitLocErrorRange(1,2)];
    list_of_model_parameters = {'D_Free', 'D_Bound', 'Frac_Bound', 'LocError'};
    
elseif NumberOfStates == 3 && FitLocError == 0 % 3-state model, fixed Loc Error
    % Lower and Upper parameter bounds
    LB = [D_Free1_3State(1,1) D_Free2_3State(1,1) D_Bound_3State(1,1) FractionInState(1,1) FractionInState(1,1)];
    UB = [D_Free1_3State(1,2) D_Free2_3State(1,2) D_Bound_3State(1,2) FractionInState(1,2) FractionInState(1,2)];
    list_of_model_parameters = {'D_Free1', 'D_Free2', 'D_Bound', 'Frac_Bound', 'Frac_Free1'};
    
elseif NumberOfStates == 3 && FitLocError == 1 % 3-state model, Loc Error from fitting
    % Lower and Upper parameter bounds
    LB = [D_Free1_3State(1,1) D_Free2_3State(1,1) D_Bound_3State(1,1) FractionInState(1,1) FractionInState(1,1) FitLocErrorRange(1,1)];
    UB = [D_Free1_3State(1,2) D_Free2_3State(1,2) D_Bound_3State(1,2) FractionInState(1,2) FractionInState(1,2) FitLocErrorRange(1,2)];
    list_of_model_parameters = {'D_Free1', 'D_Free2', 'D_Bound', 'Frac_Bound', 'Frac_Free1', 'LocError'};
end

%%%%% Initial parameters for the model-fitting
diff_bounds = UB - LB; %difference: used for initial parameters guess
best_ssq2 = 5e10; %initial error
% Options for the non-linear least squares parameter optimisation
options = optimset('MaxIter',1000,'MaxFunEvals', 5000, 'TolFun',1e-8,'TolX',1e-8,'Display','on');

% Histogram vectors for model-fitting
%Need to ensure that the x-input is the same size as y-output
if ModelFit == 1
    ModelHistVecJumps = zeros(size(JumpProb,1), length(HistVecJumps));
    for i = 1:size(JumpProb,1)
        ModelHistVecJumps(i,:) = HistVecJumps;
    end
elseif ModelFit == 2
    ModelHistVecJumps = zeros(size(JumpProb,1), length(HistVecJumpsCDF));
    for i = 1:size(JumpProb,1)
        ModelHistVecJumps(i,:) = HistVecJumpsCDF;
    end
end
%Do you want to fit the data by fitting to the histogram of displacements 
%   (ModelFit == 1; PDF)
%	(ModelFit == 2; CDF)?
%   Define new variable: FitJumpProb for this purpose
if ModelFit == 1
    FitJumpProb = JumpProb;
elseif ModelFit == 2
    FitJumpProb = JumpProbCDF;    
end

if UseWeights == 1
    % Perform weighting: at increasing dT, there is less data, so weigh
    % FitJumpProb based on the amount of data available:
    for iter = 1:size(FitJumpProb,1)
        FitJumpProb(iter,:) = FitJumpProb(iter,:).*JumpsPerdT(iter);
    end
end

%   If you do 3-state fitting, add extra penalty function to ensure that:
%       F_bound + F_Free1 < 1
%   but this is only neccesary for 3-state fitting;
if NumberOfStates == 3
    extra_cost = zeros(1,size(FitJumpProb,2));
    FitJumpProb = vertcat(FitJumpProb, extra_cost);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%% NON-LINEAR LEAST SQUARED FITTING PROCEDURE %%%%%%%%%%%%%%
for iter=1:FitIterations
    %Guess a random set of parameters
    parameter_guess =rand(1,length(LB)).*diff_bounds+LB; 

    % if you do 3-state fitting, need to make sure that the sum of Frac_Bound 
    % and Frac_Free1 does not exceed 1 initially:
    if NumberOfStates == 3
        % check sum of the fractions:
        FracSum = parameter_guess(4) + parameter_guess(5);
        if FracSum > 1
            while FracSum > 1 % keep generating random numbers until they are less than 1
                parameter_guess(4) = rand();
                parameter_guess(5) = rand();
                FracSum = parameter_guess(4) + parameter_guess(5);
            end
        end
    end  
    
    % Perform actual Least-Squares fitting
    if NumberOfStates == 2 && FitLocError == 0 % 2-state model, fixed Loc Error
        [values, ssq2, residuals] = lsqcurvefit('Model_2State', parameter_guess, ModelHistVecJumps, FitJumpProb, LB, UB, options, data_to_fit);

    elseif NumberOfStates == 2 && FitLocError == 1 % 2-state model, Loc Error from fitting
        [values, ssq2, residuals] = lsqcurvefit('Model_2State_fitLocError', parameter_guess, ModelHistVecJumps, FitJumpProb, LB, UB, options, data_to_fit);

    elseif NumberOfStates == 3 && FitLocError == 0 % 3-state model, fixed Loc Error
        [values, ssq2, residuals] = lsqcurvefit('Model_3State', parameter_guess, ModelHistVecJumps, FitJumpProb, LB, UB, options, data_to_fit);

    elseif NumberOfStates == 3 && FitLocError == 1 % 3-state model, Loc Error from fitting
        [values, ssq2, residuals] = lsqcurvefit('Model_3State_fitLocError', parameter_guess, ModelHistVecJumps, FitJumpProb, LB, UB, options, data_to_fit);
    end

    % See if the current fit is an improvement:
    if ssq2 < best_ssq2
        best_vals = values; 
        best_ssq2 = ssq2;
        %OUTPUT THE NEW BEST VALUES TO THE SCREEN
        disp('==================================================');
        disp(['Improved fit on iteration ', num2str(iter)]);
        disp(['Improved error is ', num2str(ssq2)]);
        for k = 1:length(best_vals)
            disp([char(list_of_model_parameters{k}), ' = ', num2str(best_vals(k))]);
        end
        disp('==================================================');
    else
        disp(['Iteration ', num2str(iter), ' did not yield an improved fit']);
    end
end
data_to_fit.best_vals(j,:) = best_vals;
%data_to_fit.residuals(j,:) = residuals;
data_to_fit.list_of_model_parameters(j,:) = list_of_model_parameters;
end