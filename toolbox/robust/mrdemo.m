function mrdemo
%MRDEMO Demo of model reduction techniques.
%

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------
clc
disp(' ')
disp(' ')
disp('          <<<  Robust Basis Free Model Reduction Techniques Demo  >>>')
disp('    ')
disp('   ')
disp('                 1). Balanced model reduction techniques')
disp('                     (Schur method vs. Square-root method)')
disp(' ')
disp('                 2). Optimal Descriptor Hankel model reduction & ')
disp('                     anticausal projection w/o balancing')
disp(' ')
disp('                 3). Schur Balanced Stochastic Truncation /')
disp('                     Relative Error Method')
disp(' ')
disp('                 4). Comparison of 1, 2, and 3.')
disp('     ')
disp('                 5). Go to the main menu')
disp(' ')
disp('                 0). Quit ..')
disp('  ')
Demono=[];
while isempty(Demono),
   Demono = input('      Select one of the above options: ');
end
% ----------------------------------------------------------------------
if Demono == 0
   clc
   disp(' ')
   disp(' ')
   disp('  ')
   disp('  ')
   disp('                   * * * * * * * * * * * * * * * * *')
   disp('                   *  End of MRDEMO  ......        *')
   disp('                   *                               *')
   disp('                   * Good luck with your design !! *')
   disp('                   * * * * * * * * * * * * * * * * *')
   return
end
if Demono == 5
   rctdemo1
end
% ----------------------------------------------------------------------
clc
disp(' ' )
disp('                  << Motivation of Robust Model Reduction >>')
disp('    ')
disp('    Robust model reduction techniques have become more and more important.')
disp('  ')
disp('    This is due to the following:')
disp('     ')
disp('          1). Complexity of the design problem (e.g. large size plant)')
disp('  ')
disp('          2). Complexity of the design algorithm')
disp('  ')
disp('          3). Large size of the controller generated by modern control')
disp('              techniques -- e.g. LQG, LQG/LTR, H2, H-inf ..etc..')
disp('    ')
disp('    Model reduction algorithms must be both numerically robust and')
disp(' ')
disp('    be able to address closed-loop "robustness" issues.')
disp('   ')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
clc
disp('    The model reduction algorithms included here have the following features:')
disp(' ')
disp('       1). They all by-pass the ill-conditioned "balanced transformation"')
disp(' ')
disp('       2). They employ Schur decomposition as an intermediate step')
disp('    ')
disp('           for robust computation of orthonormal bases for eigenspaces.')
disp('    ')
disp('       3). They all have infinity-norm error bounds:')
disp('             ')
disp('                Methods                     Infinity-Norm Error Bounds')
disp('     ----------------------------         -------------------------------')
disp('      Schur/Square-root Balanced           twice of the tails of Hankel')
disp('           (schur.m & balmr.m)             singular values')
disp('  ')
disp('      Optimal Descriptor Hankel                  same as above')
disp('      without balancing (ohklmr.m)')
disp('                                            -1   ^            n    hsv')
disp('      Balanced Stochastic Truncation/     |G  (G-G) |   <= 2 Sum -------')
disp('      Relative Error Method (reschmr.m)              inf     k+1  1-hsv')
disp('  ')
disp('                                 (strike a key to continue ...)')
pause
% ---------------------------------------------------------------------
if Demono == 1
   baldemo
   mrdemo
end
% ----------------------------------------------------------------------
if Demono == 2
   ohkdemo
   mrdemo
end
% ----------------------------------------------------------------------
if Demono == 3
   remdemo
   mrdemo
end
% ----------------------------------------------------------------------
if Demono == 4
   bhrdemo
   mrdemo
end
%
% --------- End of MRDEMO.M --- RYC/MGS %