function G = spm_sem(Data, C, Misc);

% Interface for SEM on functional imaging data
% FORMAT G = spm_sem(Data, C, Misc);
%=======================================================================
% Provides key routine for the implementation of Structural Equation Modeling
% (SEM) under SPM
%_______________________________________________________________________
%
% INPUT: 
%
% In general we have k data sets and h models 
%
%
% Struct array Data
% -----------------
% Data(k).X      - n x m matrix of time-series of m regions
% Data(k).L      - 3 x m matrix for centers of VOI for m regions
% Data(k).Rname	 - m x l matrix containing string descriptors (length l) 
%		   for m regions 
% Data(k).useit	 - index vector, indicating which regions of X are used 
%		   (max(useit) <= m)
% Data(k).FlagOb - Vector of size(useit) indicating whether a variable 
%		   is observed (=1) or latent (=0)
% Data(k).mod	 - Flag to indicate whether backwards modulatory connections 
%		   should be introduced for all (driving) connections
% Data(k).RT	 - Repetition time for experiment (to correct for 
%		   autocorrelation)
% Data(k).U 	 - 2 x g matrix coding g unilateral connections 
%		   (U(1,:) = sources and U(2,:) = destination)
% Data(k).B 	 - 2 x f matrix coding f bidirectional connections 
%		   between (B(1,:) and B(2,:)
%
%
% Cell array C
% --------------
% C{h}(f)	 - struct array cantaining f constraints
% C{h}(f).value	 - constrain the following paths to value, 
%		   if value = Inf impose equality constraint
% C{h}(f).conn	 - 2 x n matrix, (1,n) is index into 'Data(k)', 
%		   (2,n) denotes which paths within "Data"
%		   !note, counting starts with U and then B	 
%
% Struct Misc
% -----------
% Misc.Output 	 - Degree of output wanted: 0 = none, 1 = some, 2 = all tables, 		   
% Misc.Descr     - String to describe the analysis
% Misc.random	 - Use random starting estimates
%
%_______________________________________________________________________
%
% OUTPUT:
%
% Struct array G
% --------------
% G(h).value	 - constrain the following paths to value, 
%		   if value = Inf impose equality constraint
% G(h).conn	 - 2 x n matrix, (1,n) is index into Data array (k),
%		   (2,n) denotes which paths within "Data"
%		   !note, counting starts with U and then B	 
% G(h).Free      - Matrix of free parameters
% G(h).xfix      - fixed parameters
% G(h).SEM	 - see SEM
% G(h).x0        - starting parameters for optimisation 
% G(h).chi_sq	 - chi squared goodness of fit
% G(h).df	 - degrees of freedom
% G(h).p	 - p value
% G(h).RMSEA	 - RMSEA fit index
% G(h).ECVI	 - scale AIC fit index 
%
% Struct array SEM 
% ----------------
% SEM(k).Ustring	- Strings describing uni-directional connections
% SEM(k).Bstring	- Strings describing bi-directional connections
% SEM(k).Rname		- Strings describing regions (only updated 
%		          if modulatory connections are modelled)
% SEM(k).Constring	- Strings describing all
% SEM(k).Fil	 	- Filter to calculate covariances with latent variables 
% SEM(k).Cov		- covariance matrix
% SEM(k).df     	- degrees of freedom
% SEM(k).ConX	 	- matrix of unidirectional paths
% SEM(k).ConZ	 	- matrix of bidirectional paths
% SEM(k).A		- asymmetric path coefficients
% SEM(k).S		- symmetric path coefficients
% SEM(k).AL		- Modification indices for asymmetric path coefficients (*)
% SEM(k).SL		- Modification indices for symmetric path coefficients
% SEM(k).f		- fit index from optimisation
% SEM(k).Res		- residual covariances
% SEM(k).Est 		- estimated covariances
% SEM(k).L 		- modification indices for each parameter of 
%
% (*) Modification indices are based on first and second order partial derivatives. The bigger
%     the value, the more would the fit benefit from freeing this parameter. Free parameters
%     should have a modification index of zero. 
%
%
% Ref.: Büchel C and Friston KJ (1997) Cerebral Cortex 7: 768-778
%       Büchel C, Coull JT and Friston KJ (1999) Science 283:1538-41
%___________________________________________________________________________
%
% Arguments are necessary, no GUI provided
%_______________________________________________________________________
% @(#)spm_sem	1.0b Christian Buchel 99/10/19



% get figure handles 
%--------------------------------------------------------------------------- 
SCCSid  = '1.0b';

% Interface for SEM on functional imaging data
%===========================================================================
SPMid = spm('FnBanner',mfilename,SCCSid);
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','spm_sem',0);

spm_clf(Finter)



Free1 = [];
Inc  = 0;

for k = 1:size(Data,2)
    
    if Data(k).mod			%include all backwards modulatory connections
        
        % Introduce backwards modulatory connections
        %-------------------------------------------
        
        % Create simple matrix of connections
        %------------------------------------
        SEM(k).A = zeros(size(Data(k).useit,2));
        for g = 1:size(Data(k).U,2)
            SEM(k).A(Data(k).U(2,g),Data(k).U(1,g)) = 1;
        end
        % search for unidirectional connections columnwise
        %-------------------------------------------------
        int = [0;0];					%fake for missing boolean bypass
        for row = 1:size(SEM(k).A,1)
            for col = 1:size(SEM(k).A,2)
                if SEM(k).A(row,col)
                    pin = find(SEM(k).A(col,:));		%find previous stage input ie. col as row
                    if ~isempty(pin)
                        for g = pin
                            if isempty(find(int(1,:) == g & int(2,:) == row))
                                int = [int [g;row]];
                                % Add variable to X if necessary
                                % ------------------------------
                                Data(k).X = [Data(k).X normit(Data(k).X(:,Data(k).useit(g)) .* Data(k).X(:,Data(k).useit(row)))];
                                Data(k).useit  = [Data(k).useit size(Data(k).X,2)];				% update useit
                                Data(k).FlagOb = [Data(k).FlagOb 1];						% update FlagOb
                                % Include covariances
                                % -------------------
                                Data(k).B = [Data(k).B [length(Data(k).useit);length(Data(k).useit)]];	% Residual variance
                                Data(k).B = [Data(k).B [g;length(Data(k).useit)]];							% Covariances for product term
                                Data(k).B = [Data(k).B [row;length(Data(k).useit)]];
                                % Update Rname
                                % ------------
                                st = sprintf('I%1.0f_%1.0f',g,row);
                                Data(k).Rname = str2mat(Data(k).Rname,st);
                                % Include free parameter
                                % ----------------------
                                Data(k).U = [Data(k).U [length(Data(k).useit);col]];
                            else	%Interaction already created
                                w = find(int(1,:) == g & int(2,:) == row);
                                % Include free parameter
                                % ----------------------
                                Data(k).U = [Data(k).U [length(Data(k).useit)-size(int,2)+w;col]];
                            end
                        end
                    end
                end
            end
        end
        int(:,1) = [];				% eliminate fake
    end	% if mod ...
    
    
    SEM(k).Rname = Data(k).Rname;			% Add Rname to output
    
    
    % Create descriptor strings for command window output
    % ---------------------------------------------------
    
    [SEM(k).Ustring, SEM(k).Bstring] = create_str(Data(k).U,Data(k).B,Data(k).Rname,Data(k).useit);
    
    
    % Print paths for user info and set vector of free parameters
    % -----------------------------------------------------------
    
    SEM(k).Constring = [SEM(k).Ustring;SEM(k).Bstring]; 
    
    
    % Set up F to filter latent variable
    % Remember Latent variables must have a column in X (any value)
    % -------------------------------------------------------------
    F           = diag(Data(k).FlagOb);
    SEM(k).Fil  = F(find(sum(F')),:);
    
    
    % Create covariances and 'filter' them using Fil
    % ----------------------------------------------
    
    SEM(k).Cov = SEM(k).Fil*cov(Data(k).X(:,Data(k).useit))*SEM(k).Fil';
    
    
    % Calculate effective degrees of freedom
    % --------------------------------------
    
    SEM(k).df = eff_df(size(Data(k).X,1),Data(k).RT);       
    
    H     = [Data(k).U Data(k).B];
    HC    = zeros(1,size(H,2));
    
    for l = 1:size(H,2)
        a      = H(1,l);
        b      = H(2,l);
        HC(l)  = SEM(k).Cov(b,a);
    end
    Free1 = [Free1 [(1:size(H,2))+Inc;1:size(H,2);ones(1,size(H,2))*k;HC]];
    Inc   = Inc + size(H,2);
    
    if Misc.Output > 0
        fprintf('----Group %1.0f----\n',k)
        for ij = 1:size(H,2)
            fprintf([sprintf('%3.0f',ij) ' ' SEM(k).Constring(ij,:) '\n']);
        end
    end
    
    
end % for k = 1:


% Evaluate constraints and set up matrices with free parameters
% -------------------------------------------------------------

for h = 1:size(C,2)
    
    keyboard;
    [G(h).Free, G(h).xfix]    = get_equ(Free1, C{h});
    [G(h).SEM, G(h).x0] 	   = set_mat(Data, G(h).Free, SEM);
    
    % Start optimisation proper
    % ------------------------
    
    G(h).chi_sq = [];
    G(h).df     = [];
    G(h).p      = [];
    G(h).RMSEA  = [];
    G(h).ECVI   = [];
    G(h).Pars   = [];
    
    G(h)        = get_result(Data, G(h), Misc);
end



 