function scaledlg(this)
% Opens and manages dialog for rescaling Y axis

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.1 $  $Date: 2004/02/06 00:41:12 $
%   Copyright 1990-2004 The MathWorks, Inc. 
DlgH = 7;
DlgW = 57;
UIColor = get(0,'DefaultUIControlBackgroundColor');
Dlg = figure('Name','Scale Constraint', ...
    'Visible','off', ...
    'DockControls','off',...
    'Resize','off',...
    'MenuBar','none', ...
    'Units','character',...
    'Position',[0 0 DlgW DlgH], ...
    'Color', UIColor, ...
    'IntegerHandle','off', ...
    'HandleVisibility','off',...
    'NumberTitle','off');
centerfig(Dlg,this.Parent);
ud.Listener = handle.listener(this.Axes,...
   'ObjectBeingDestroyed',@(x,y) delete(Dlg(ishandle(Dlg))));

% Button group
xgap = 2;
BW = 10;  BH = 1.5; Bgap = 1;
X0 = (DlgW - (3*BW+2*Bgap))/2;
Y0 = 0.5;
Handles.OK = uicontrol('Parent',Dlg, ...
   'Units','character', ...
   'Position',[X0 Y0 BW BH], ...
   'Callback',{@localOK Dlg this},...
   'String','OK');
X0 = X0+BW+Bgap;
uicontrol('Parent',Dlg, ...
   'Units','character', ...
   'Callback','', ...
   'Position',[X0 Y0 BW BH], ...
   'Callback',@(x,y) delete(Dlg),...
   'String','Cancel');
X0 = X0+BW+Bgap;
uicontrol('Parent',Dlg, ...
   'Units','character', ...
   'Callback','helpview([docroot ''/toolbox/sloptim/sloptim.map''],''scale'')', ...
   'Position',[X0 Y0 BW BH], ...
   'String','Help');

y0 = Y0+BH+1.7;
x0 = xgap;
uicontrol('Parent',Dlg, ...
   'BackgroundColor',UIColor,...
   'Style','text', ...
   'String','Scale Y range by factor', ...
   'HorizontalAlignment','left', ...
   'Units','character',...
   'Position',[x0 y0 24 1.2]);
x0 = x0 + 24;
ud.Factor = uicontrol(Dlg, ...
   'Style','edit', ...
   'BackgroundColor','white', ...
   'HorizontalAlignment','left', ...
   'Units','character',...
   'String','1',...
   'Position',[x0 y0 9 1.4]);
x0 = x0 + 10;
uicontrol('Parent',Dlg, ...
   'BackgroundColor',UIColor,...
   'Style','text', ...
   'String','about y =', ...
   'HorizontalAlignment','left', ...
   'Units','character',...
   'Position',[x0 y0 10 1.2]);
x0 = x0 + 10;
ud.Y0 = uicontrol(Dlg, ...
   'Style','edit', ...
   'BackgroundColor','white', ...
   'HorizontalAlignment','left', ...
   'String','0',...
   'Units','character',...
   'Position',[x0 y0 9 1.4]);

set(Dlg,'UserData',ud,'Visible','on');



function localOK(eventsrc,eventdata,Dlg,this)
% Deletes dialog when parent axes go away
ud = get(Dlg,'UserData');
Factor = localGetValue(ud.Factor);
Y0 = localGetValue(ud.Y0);
if ~(isscalar(Factor) && isreal(Factor) && Factor>0)
   errordlg('Scaling factor must be a positive real scalar.','Scaling Error','modal')
elseif ~(isscalar(Y0) && isreal(Y0))
   errordlg('Invalid Y value.','Scaling Error','modal')
else
   % Scale constraint
   Transaction = ctrluis.transaction(this.Constraint,'Name','Scale Constraint',...
      'OperationStore','on','InverseOperationStore','on');
   % Scale consraint
   this.Constraint.scale(Factor,Y0)
   % Commit and stack transaction
   commit(Transaction)
   this.Recorder.pushundo(Transaction)
   % Update display
   update(this)
   % Close dialog
   delete(Dlg)
end


   
function val = localGetValue(editbox)
% Evaluates string
str = get(editbox,'String');
if length(str)
   val = evalin('base',str,'[]');
else
   val = [];
end
