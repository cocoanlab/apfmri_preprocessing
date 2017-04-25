function inria_realign_ui(arg1)
% User Interface for inria_realign.
%___________________________________________________________________________
%
% The INRIAlign toolbox enhances the standard SPM realignment routine
% (see topic: spm_realign_ui). In the latter, rigid registration is
% achieved by minimization of the sum of squared intensity differences
% (SSD) between two images. As noted by several SPM users, SSD based
% registration may be biased by a variety of image artifacts and also
% by activated areas. To get around this problem, INRIAlign reduces
% the influence of large intensity differences by weighting errors
% using a non-quadratic, slowly-increasing function (rho
% function). This is basically the principle of an M-estimator.
%
% When launching INRIAlign, the user may select a specific rho
% function as well as an associated relative cut-off distance (which
% is needed by most of the rho functions). By default, the rho
% function is that of Geman-McClure while the relative cut-off
% distance is set to 2.5.
%
% Apart from this distinction, the method is very similar to
% spm_realign and uses the same editable default parameters. Most of
% the implementation has been directly adapted from the code written
% by J. Ashburner.
%
%
%__________________________________________________________________________
% Refs:
%
% Roche A et al (2001). In preparation... 
%
% Freire L & Mangin JF (2001). Motion Correction Algorithms of the
% Brain Mapping Community Create Spurious Functional
% Activations. IPMI'01. 
%
% Rousseeuw PJ and Leroy AM (1987). Robust Regression and Outlier
% Detection. Wiley Series in Probability and Mathematical
% Statistics. 
%
%__________________________________________________________________________
% @(#)inria_realign_ui.m  1.1  Alexis Roche, INRIA (EPIDAURE project) 01/03/06


global MODALITY sptl_WhchPtn sptl_DjstFMRI sptl_CrtWht sptl_MskOptn SWD
global BCH sptl_RlgnQlty sptl_WghtRg
global sptl_CostFun sptl_CutOff sptl_Smooth

if isempty(sptl_CostFun) | isempty(sptl_CutOff) | isempty(sptl_Smooth),
  sptl_CostFun = 'geman';
  sptl_CutOff = 2.5;
  if strcmp(MODALITY,'FMRI'),
    sptl_Smooth = 6;
  else,
    sptl_Smooth = 8;
  end,
end,

if (nargin == 0)
	% User interface.
	%_______________________________________________________________________
	SPMid = spm('FnBanner',mfilename,'1.1');
	[Finter,Fgraph,CmdLine] = spm('FnUIsetup','INRIAlign');
	spm_help('!ContextHelp','inria_realign_ui.m');

	pos = 1;

	% Enables editing default parameters
	%-----------------------------------------------------------------------
	if spm_input(['Check local parameters?'], pos, 'm',['Use defaults|' ...
		    'Edit parameters'], [0 1], 1, 'batch',{}, ...
		     'edit_params'),
	  pos = pos + 4;
	  edit_local_defaults;
	end,
	
	n     = spm_input('number of subjects', pos, 'e', 1,...
                          'batch',{},'subject_nb');
	if (n < 1)
		spm_figure('Clear','Interactive');
		return;
	end

	P = cell(n,1);
	pos = pos + 1;
	for i = 1:n,
		if strcmp(MODALITY,'FMRI'),
			ns = spm_input(['num sessions for subject ',num2str(i)], pos,...
                                       'e', 1,'batch',{},'num_sessions');
			pp = cell(1,ns);
			for s=1:ns,
				p = '';
				while size(p,1)<1,
					if isempty(BCH),
						p = spm_get(Inf,'.img',...
						['scans for subj ' num2str(i) ', sess' num2str(s)]);
					else,
						p = spm_input('batch',{'sessions',i},'images',s);
					end;
				end;
				pp{s} = p;
			end;
			P{i} = pp;
		else, %- no batch mode for 'PET'
			p  = cell(1,1);
			p{1} = '';
			while size(p{1},1)<1,
			      p{1} = spm_get(Inf,'.img',...
				  ['select scans for subject ' num2str(i)]);
			end;
			P{i} = p;
		end;
	end;


	if strcmp(MODALITY,'PET'),
	  FlagsC = struct('quality',sptl_RlgnQlty,'fwhm',sptl_Smooth,'rtm',[],...
			  'rho_func',sptl_CostFun,'cutoff',sptl_CutOff);
	else,
	  FlagsC = struct('quality',sptl_RlgnQlty,'fwhm',sptl_Smooth,...
			  'rho_func',sptl_CostFun,'cutoff',sptl_CutOff);
	end;

	if sptl_WhchPtn == 1,
		WhchPtn = 3;
	else,
		WhchPtn = spm_input('Which option?', pos, 'm',...
			'Coregister only|Reslice Only|Coregister & Reslice',...
			[1 2 3],3,'batch',{},'option');
		pos = pos + 1;
	end;

	PW = '';
	if (WhchPtn == 1 | WhchPtn == 3) & sptl_WghtRg,
		if spm_input(...
			['Weight the reference image(s)?'],...
			2, 'm',...
			['Dont weight registration|'...
			 'Weight registration'], [0 1], 1,...
			 'batch',{},'weight_reg'),

			if isempty(BCH),
				PW = spm_get(n,'.img',...
					'Weight images for each subj');
			else,
				PW = spm_input('batch',{'sessions',i},'weights',s);
			end;
		end;
	end;

	% Reslicing options
	%-----------------------------------------------------------------------
	if WhchPtn == 2 | WhchPtn == 3,
		FlagsR = struct('hold',1,'mask',0,'which',2,'mean',1);
		FlagsR.hold = spm_input('Reslice interpolation method?',pos,'m',...
			     'Trilinear Interpolation|Sinc Interpolation|Fourier space Interpolation',...
			     [1 -9 Inf],2,'batch',{},'reslice_method');
		pos = pos + 1;

		if sptl_CrtWht == 1,
			p = 3;
		else
			p = spm_input('Create what?',pos,'m',...
				[' All Images (1..n)| Images 2..n|'...
				 ' All Images + Mean Image| Mean Image Only'],...
				[1 2 3 4],3,'batch',{},'create');
			pos = pos + 1;
		end
		if (p == 1) FlagsR.which = 2; FlagsR.mean = 0; end
		if (p == 2) FlagsR.which = 1; FlagsR.mean = 0; end
		if (p == 3) FlagsR.which = 2; FlagsR.mean = 1; end
		if (p == 4) FlagsR.which = 0; FlagsR.mean = 1; end
		if FlagsR.which > 0,
			if sptl_MskOptn == 1,
				FlagsR.mask = 1;
			else,
				if spm_input('Mask the resliced images?',pos,'y/n',...
                                              'batch',{},'mask') == 'y',
					FlagsR.mask = 1;
				end;
				pos = pos + 1;
			end;
			if strcmp(MODALITY, 'FMRI'),
				if finite(FlagsR.hold),
					if sptl_DjstFMRI == 1,
						FlagsR.fudge = 1;
					elseif sptl_DjstFMRI ~= 0,
						if spm_input(...
							'Adjust sampling errors?',pos,'y/n','batch',...
                                                        {},'adjust_sampling_errors') == 'y',
						FlagsR.fudge = 1;
						end;
						pos = pos + 1;
					end;
				end
			end
		end
	end

	spm('Pointer','Watch');
	for i = 1:n
		spm('FigName',['INRIAlign: working on subject ' num2str(i)],Finter,CmdLine);
		fprintf('\rRealigning Subject %d: ', i);
		if WhchPtn==1 | WhchPtn==3,
			flagsC = FlagsC;
			if ~isempty(PW), flagsC.PW = deblank(PW(i,:)); end;
			inria_realign(P{i},flagsC);
		end
		if WhchPtn==2 | WhchPtn==3,
			spm_reslice(P{i},FlagsR)
		end;
	end
	fprintf('\r%60s%s', ' ',sprintf('\b')*ones(1,60));
	spm('FigName','INRIAlign: done',Finter,CmdLine);
	spm('Pointer');
	return;

elseif nargin == 1 & strcmp(arg1,'Defaults'),
	edit_defaults;
	return;
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function edit_defaults
global MODALITY sptl_WhchPtn sptl_DjstFMRI sptl_CrtWht sptl_MskOptn SWD
global sptl_RlgnQlty sptl_WghtRg
global sptl_CostFun sptl_CutOff sptl_Smooth

%- in batch mode, the top level variable here is 'RealignCoreg',iA

tmp = 1;
if sptl_WhchPtn == 1, tmp = 2; end;
sptl_WhchPtn = spm_input(...
	['Coregistration and reslicing?'],...
	2, 'm',...
	['Allow separate coregistration and reslicing|'...
	 'Combine coregistration and reslicing'], [-1 1], tmp,...
         'batch',{},'separate_combine');

tmp = 2;
if sptl_CrtWht == 1,
	tmp = 1;
end
sptl_CrtWht   = spm_input(['Images to create?'], 3, 'm',...
	       'All Images + Mean Image|Full options', [1 -1], tmp,...
               'batch',{},'create');

tmp = 3;
if sptl_DjstFMRI == 1,
	tmp = 1;
elseif sptl_DjstFMRI == 0
	tmp = 2;
end
sptl_DjstFMRI = spm_input(['fMRI adjustment for interpolation?'],4,'m',...
	          '   Always adjust |    Never adjust|Optional adjust',...
	          [1 0 -1], tmp,'batch',{},'adjust');

tmp = 2;
if sptl_MskOptn == 1,
	tmp = 1;
end
sptl_MskOptn  = spm_input(['Option to mask images?'], 5, 'm',...
		'  Always mask|Optional mask', [1 -1], tmp,...
	        'batch',{},'mask');

tmp2 = [1.00 0.90 0.75 0.50 0.25 0.10 0.05 0.01 0.005 0.001];
tmp = find(sptl_RlgnQlty == tmp2);
if isempty(tmp) tmp = length(0.5); end
sptl_RlgnQlty = spm_input('Registration Quality?','+1','m',...
	['Quality 1.00  (slowest/most accurate) |Quality 0.90|' ...
	 'Quality 0.75|Quality 0.50|Quality 0.25|Quality 0.10|' ...
	 'Quality 0.05|Quality 0.01|' ...
	 'Quality 0.005|Quality 0.001 (fastest/poorest)'],tmp2, tmp,...
                'batch',{},'reg_quality');


tmp = 0; if sptl_WghtRg == 1, tmp = 1; end;
sptl_WghtRg = spm_input(...
	['Allow weighting of reference image?'],...
	'+1', 'm',...
	['Allow weighting|'...
	 'Dont allow weighting'], [1 0], tmp,...
         'batch',{},'weight_reg');


sptl_Smooth = spm_input('Spatial smoothing (mm)', '+1', 'e', sptl_Smooth,...
			'batch',{},'spatial_smoothing');

tmp2 = str2mat('quadratic','absolute','huber','cauchy','geman','leclerc','tukey');
tmp = strmatch(sptl_CostFun,tmp2);
aux = spm_input('Cost function?','+1','m',...
		['Quadratic  (SPM standard)|Absolute value|Huber|'...
		 'Cauchy|Geman-McClure|Leclerc-Welsch|Tukey|'],(1:size(tmp2,1)), tmp,...
		'batch',{},'cost_function');
sptl_CostFun = deblank(tmp2(aux,:));

if strcmp(sptl_CostFun,'quadratic') | strcmp(sptl_CostFun,'absolute'), 
  return; 
end,

sptl_CutOff = spm_input('Relative cut-off distance', '+1', 'e', sptl_CutOff,...
			'batch',{},'cut_off');

return;
%_______________________________________________________________________
%_______________________________________________________________________
function edit_local_defaults
global sptl_CostFun sptl_CutOff sptl_Smooth


sptl_Smooth = spm_input('Spatial smoothing (mm)', '+1', 'e', sptl_Smooth,...
			'batch',{},'spatial_smoothing');

tmp2 = str2mat('quadratic','absolute','huber','cauchy','geman','leclerc','tukey');
tmp = strmatch(sptl_CostFun,tmp2);
aux = spm_input('Cost function?','+1','m',...
		['Quadratic  (SPM standard)|Absolute value|Huber|'...
		 'Cauchy|Geman-McClure|Leclerc-Welsch|Tukey|'],(1:size(tmp2,1)), tmp,...
		'batch',{},'cost_function');
sptl_CostFun = deblank(tmp2(aux,:));

if strcmp(sptl_CostFun,'quadratic') | strcmp(sptl_CostFun,'absolute'), 
  return; 
end,

sptl_CutOff = spm_input('Relative cut-off distance', '+1', 'e', sptl_CutOff,...
			'batch',{},'cut_off');

return;
