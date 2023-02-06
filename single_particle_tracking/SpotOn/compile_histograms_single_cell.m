function data_struct = compile_histograms_single_cell(data_struct)
UseEntireTraj = data_struct.UseEntireTraj;
GapsAllowed = data_struct.GapsAllowed;
TimePoints = data_struct.TimePoints;
JumpsToConsider = data_struct.JumpsToConsider;
HistVecJumps = data_struct.HistVecJumps;
HistVecJumpsCDF = data_struct.HistVecJumpsCDF;
trackedPar = data_struct.trackedPar;
CellLocs = 0; % for counting the total number of localizations
LastIdx = length(trackedPar);
TempLastFrame = max(trackedPar(1,LastIdx).Frame);
CellFrames = 100*round(TempLastFrame/100);
for n=1:length(trackedPar)
    CellLocs = CellLocs + length(trackedPar(1,n).Frame);
end

% total number of trajectories
TrajNumb = length(trackedPar);
%Compile histograms for each jump length
Min3Traj = 0; %for counting number of min3 trajectories;
CellJumps = 0; %for counting the total number of jumps
CellJumps_used = 0; %for counting the total number of jumps actually used
TransFrames = TimePoints+GapsAllowed*(TimePoints-1); TransLengths = struct; 
% Matlab strongly prefers memory to be pre-initialized: to avoid appending
% displacements and thus increasing the vector size with each iteration, do
% the following:
%   - make an educated gues as to vector length and initialize with zeroes
%   - keep a counter of actual number of displacements and then remove the
%   padding at the end
% This is a bit inelegent, but it improves performance
for i=1:TransFrames
    TransLengths(1,i).Step = zeros(1,6000); %each iteration is a different number of timepoints
    TransLengths(1,i).Counter = 0; 
end
JumpsPerdT = zeros(TransFrames,1); % for counting how many jumps per dT

% compile all of the jumps
if UseEntireTraj == 1 %Use all displacements of the trajectory
    for i=1:length(trackedPar)
        CurrTrajLength = size(trackedPar(i).xy,1);
        %save lengths
        if CurrTrajLength >= 3
            Min3Traj = Min3Traj + 1;
        end
        %Now loop through the trajectory. Keep in mind that there are missing
        %timepoints in the trajectory, so some gaps may be for multiple
        %timepoints.
        if CurrTrajLength > 1
            %Figure out what the max jump to consider is:
            HowManyFrames = min(TimePoints-1, CurrTrajLength);
            for n=1:HowManyFrames
                for k=1:CurrTrajLength-n
                    %Find the current XY coordinate and frames between
                    %timepoints
                    CurrXY_points = vertcat(trackedPar(i).xy(k,:), trackedPar(i).xy(k+n,:));
                    CurrFrameJump = trackedPar(i).Frame(k+n) - trackedPar(i).Frame(k);
                    % update the counter:
                    TransLengths(1,CurrFrameJump).Counter = TransLengths(1,CurrFrameJump).Counter + 1;
                    %Calculate the distance between the pair of points
                    TransLengths(1,CurrFrameJump).Step(1,TransLengths(1,CurrFrameJump).Counter) = pdist(CurrXY_points);
                    % increment the number of jumps per dT counter:
                    JumpsPerdT(CurrFrameJump) =  JumpsPerdT(CurrFrameJump) + 1;
                end
            end
        end    
    end
    CellJumps = JumpsPerdT(1,1);
    CellJumps_used = CellJumps; % all jumps were used, so these are the same
elseif UseEntireTraj == 0 % Use only the first JumpsToConsider displacements
    for i=1:length(trackedPar)
        CurrTrajLength = size(trackedPar(i).xy,1);
        if CurrTrajLength >= 3
            Min3Traj = Min3Traj + 1;
        end
        %Loop through the trajectory. If it is a short trajectory, you need to
        %make sure that you do not overshoot. So first figure out how many
        %jumps you can consider.
        if CurrTrajLength > 1
            %Figure out what the max jump to consider is:
            HowManyFrames = min([TimePoints-1, CurrTrajLength]);
            CellJumps = CellJumps + CurrTrajLength - 1; %for counting all the jumps
            CellJumps_used = CellJumps_used + min([CurrTrajLength-1 JumpsToConsider]); %for counting all the jumps actually used
            for n=1:HowManyFrames
                FrameToStop = min([CurrTrajLength, n+JumpsToConsider]);                
                for k=1:(FrameToStop-n)                   
                    %Find the current XY coordinate and frames between
                    %timepoints
                    CurrXY_points = vertcat(trackedPar(i).xy(k,:), trackedPar(i).xy(k+n,:));
                    CurrFrameJump = trackedPar(i).Frame(k+n) - trackedPar(i).Frame(k);
                    % update the counter:
                    TransLengths(1,CurrFrameJump).Counter = TransLengths(1,CurrFrameJump).Counter + 1;
                    %Calculate the distance between the pair of points
                    TransLengths(1,CurrFrameJump).Step(1,TransLengths(1,CurrFrameJump).Counter) = pdist(CurrXY_points);
                    % increment the number of jumps per dT counter:
                    JumpsPerdT(CurrFrameJump) =  JumpsPerdT(CurrFrameJump) + 1;
                end
            end
        end  
    end
end 

% Remove padding introduces in the step/displacement vectors:
for i=1:TransFrames
    TransLengths(1,i).Step = TransLengths(1,i).Step(1,1:TransLengths(1,i).Counter);
    % this removes all of the "zeroes" from the padding
end

%CALCULATE THE PDF HISTOGRAMS
JumpProb = zeros(TimePoints-1, length(HistVecJumps));
JumpProbFine = zeros(TimePoints-1, length(HistVecJumpsCDF));
for i=1:size(JumpProb,1)
    % make sure that there are enough jumps:
    if isempty(TransLengths(1,i).Step)
        error(['Spot-On cannot continue: for ', num2str(i), 'dT there are no displacements and Spot-On therefore cannot calculate a displacement histogram. Please change "TimePoints" or collect more data.']);
    end    
    JumpProb(i,:) = histc(TransLengths(1,i).Step, HistVecJumps)/length(TransLengths(1,i).Step);
    JumpProbFine(i,:) = histc(TransLengths(1,i).Step, HistVecJumpsCDF)/length(TransLengths(1,i).Step);
end  

%CALCULATE THE CDF HISTOGRAMS:
JumpProbCDF = zeros(TimePoints-1, length(HistVecJumpsCDF));
for i=1:size(JumpProbCDF,1)
    for j=2:size(JumpProbCDF,2)
        JumpProbCDF(i,j) = sum(JumpProbFine(i,1:j));
    end
end  

% re-size JumpsPerdT
JumpsPerdT = JumpsPerdT(1:(TimePoints-1));
% normalize JumpsPerdT
JumpsPerdT = JumpsPerdT./JumpsPerdT(1,1);

data_struct.JumpProb = JumpProb;
data_struct.JumpProbCDF = JumpProbCDF;
data_struct.Min3Traj = Min3Traj;
data_struct.CellLocs = CellLocs;
data_struct.CellJumps = CellJumps;
data_struct.CellJumps_used = CellJumps_used;
data_struct.CellFrames = CellFrames; 
data_struct.TrajNumb = TrajNumb;
data_struct.JumpsPerdT = JumpsPerdT;
end