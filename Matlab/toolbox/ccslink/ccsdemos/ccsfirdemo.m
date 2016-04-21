function varargout = ccsfirdemo(varargin)
% CCSFIRDEMO FIR Demo for the 'Link for Code Composer Studio�'.
%    CCSFIRDEMO launches a GUI demonstration of the 'Link for Code Composer
%    Studio�' product.  It uses the power of MATLAB to design a FIR filter
%    that will be tested directly and interactively on the target DSP
%    processor.  The resulting filter performance is plotted and compared
%    to a theoretical response generated by MATLAB.  
%
%    To run this demo, a small target project must be modified to match the
%    user's specific configuration.  The necessary target source code is
%    provided in the subdirectory CCSFIR, along with some sample project
%    files. 
%
%    To run the CCSFIRDEMO from MATLAB, type 'ccsfirdemo' at the command
%    prompt. 
%
%    See also CCSTUTORIAL, RTDXTUTORIAL, CCSFIRDEMO, RTDXLMSDEMO,
%             CCSINSPECT , CCSDSP 

% CCSFIRDEMO('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 02-Nov-2001 09:46:58

%   Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.27.4.4 $ $Date: 2004/04/06 01:04:19 $
% Copyright  The MathWorks, Inc.

if nargin == 0  % LAUNCH GUI
    
    fig = openfig(mfilename,'reuse');
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    % include spaces for some later additions
    handles = guihandles(fig);
    handles.cc = [];
    handles.symbols = [];
    handles.bcoef = [];
    handles.halt = [];
    handles.swdb = [] ;
    handles.scodb = [];
    guidata(fig, handles);
    
    if nargout > 0
        varargout{1} = fig;
    end
    blockdiagram(handles.axes);
    drawnow;
    set(handles.exit,'UserData',1);    % Halt a loop
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
        disp(lasterr);
    end
    
end
%----------------------------------------------------------------
% Local routine will modify theoritical filter plot
function plotfilter(h, eventdata, handles, varargin)
% Plot the (theortical) response of the filter and save coefficients for target
ftype = get(handles.type,'Value');
n = get(handles.order,'UserData');
wb(1) = get(handles.w1,'UserData');
wb(2) = get(handles.w2,'UserData');

if ftype ==1,  %Low Pass
    set(handles.w2,'Enable','off');
    bcoef = fir1(n,wb(1));
elseif ftype == 2, %High pass  
    set(handles.w2,'Enable','off');
    bcoef = fir1(n,wb(1),'high');
elseif ftype ==3, %Band pass
    set(handles.w2,'Enable','on');
    if  wb(1) > wb(2),
        warndlg('Warning - adjust freq. so that W1 < W2 ','Cut-Off Frequency Error');
        return;
    end
    bcoef = fir1(n,wb);
elseif ftype == 4, %Band Stop
    set(handles.w2,'Enable','on');
    if wb(1) > wb(2),
        warndlg('Warning - adjust freq. so that W1 < W2 ','Cut-Off Frequency Error');
        return;
    end
    bcoef = fir1(n,wb,'stop');
else
    error('Unknown filter type selected.');
end
handles.bcoef = bcoef;       % save for later

% Now plot response
warnsave = warning;  % turn off "Log of zero" messages
warning('off')
[sco sw]=freqz(bcoef,1);
scodb = 20*log10(abs(sco));
swdb = sw./pi;
plot(swdb,scodb,'Parent',handles.axes);
grid(handles.axes);
warning(warnsave);

handles.swdb = swdb;
handles.scodb = scodb;
guidata(gcbo,handles);       % store the changes...

set(handles.titletxt,'Visible','on');
set(handles.xlabeltxt,'Visible','on');

%    set(gca,'UserData',h)



%----------------------------------------------------------------
% functions used to create block diagram of MATLAB <-> CCS <-> Target
function blockdiagram(ph)
% Inserts a sketch of the Link for Code Composer Studio(R) IDE
patch([0 1 1 0 0],[0 0 1 1 0],'w','LineStyle','none','Parent',ph);
box(ph,0.02,0.98,0.78,0.95,'c','Host Computer');
box(ph,0.04,0.85,0.30,0.78,[0.9 0.9 0.9],{'MATLAB', 'Application', '>.'});
box(ph,0.06,0.60,0.26,0.25,'w',{'Link to CCS:', 'cc = ccsdsp;'});
box(ph,0.06,0.35,0.26,0.25,'w',{'Link to RTDX:', 'cc.rtdx(i);'});
box(ph,0.38,0.85,0.38,0.78,[0.7 0.7 0.9],{'Code Composer', 'Studio(R) IDE'})
box(ph,0.40,0.60,0.30,0.40,[0.9 0.7 0.7],{'DSP Project:', 'ccsfir.pjt'})
box(ph,0.82,0.80,0.17,0.60,[0.8 0.8 0.8],{'Board'});
box(ph,0.84,0.67,0.13,0.40,[0.9 0.8 0.7],{'Target', 'DSP','Proc.'});
arrow(ph,0.23,0.20,0.51,0.36,0.04);
arrow(ph,0.23,0.42,0.50,0.40,0.04);
arrow(ph,0.60,0.30,0.9,0.42,0.04);

function box(ph,x,y,xle,yle,color,tstr)
% upper left hand corner + length
pH = patch([x x x+xle x+xle x],[y y-yle y-yle y y],color,'Parent',ph); 
set(pH,'LineWidth',2);
tH = text(x+0.02,y-0.02,tstr,'Parent',ph);
set(tH,'VerticalAlignment','Top');

function arrow(ph,x1,y1,x2,y2,len)
% Draws an arrow that is +/-25 degrees from straight
el = atan2(y2-y1,x2-x1);
dle = 0.3;
x1a = x1+len*cos(el+dle);
x1b = x1+len*cos(el-dle);
y1a = y1+len*sin(el+dle);
y1b = y1+len*sin(el-dle);
el = atan2(y1-y2,x1-x2);
x2a = x2+len*cos(el-dle);
x2b = x2+len*cos(el+dle);
y2a = y2+len*sin(el-dle);
y2b = y2+len*sin(el+dle);
lH = line([x1 x1a x1b x1 x2 x2a x2b x2],[y1 y1a y1b y1 y2 y2a y2b y2],'Parent',ph);
set(lH,'Color','r')

%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

% --------------------------------------------------------------------
function varargout = boardnum_Callback(h, eventdata, handles, varargin)
% Callback for Board number entry box.  This allows user to directly
% define the 'boardnum' parameter of the Link
oldval = get(h,'UserData');
newstr = get(h,'String');
newval = eval(newstr,num2str(oldval));
if newval<0, newval = oldval; end
newval = round(newval);
set(h,'Userdata',newval,'String',num2str(newval));

% --------------------------------------------------------------------
function varargout = procnum_Callback(h, eventdata, handles, varargin)
% Callback for Processor number entry box.  This allows user to directly
% define the 'procnum' parameter of the Link
oldval = get(h,'UserData');
newstr = get(h,'String');
newval = eval(newstr,num2str(oldval));
if newval<0, newval = oldval; end
newval = round(newval);
set(h,'Userdata',newval,'String',num2str(newval));

% --------------------------------------------------------------------
function varargout = select_Callback(h, eventdata, handles, varargin)
% Invokes the Board/Processor Selection GUI
try
    [bdnum,prnum] = boardprocsel;
catch
    warndlg(...
        { 'Unable to run Board Selection Utility',...
            '[bdnum,prnum] = boardprocsel;',...
            'Board and Processor must be entered manually',...
            lasterr},'GUI Error');
end
if ~isempty(bdnum),
    set(handles.boardnum,'String',int2str(bdnum));
    set(handles.boardnum,'UserData',bdnum);
end
if ~isempty(prnum),
    set(handles.procnum,'String',int2str(prnum));
    set(handles.procnum,'UserData',prnum);
end

% --------------------------------------------------------------------
function varargout = type_Callback(h, eventdata, handles, varargin)
% Callback to specify filter type (lowpass, highpass, etc)
% NOTE highpass and bandstop must use even number of coefficients
set(handles.exit,'UserData',1);   % This will halt execution!
handles.halt = 1;
pointsave=get(gcbf,'Pointer');
set(gcbf,'Pointer','watch');
process_order_type(handles);
plotfilter(h, eventdata, handles, varargin);
set(gcbf,'Pointer',pointsave);

% --------------------------------------------------------------------
function varargout = order_Callback(h, eventdata, handles, varargin)
% Callback to specify filter order 
set(handles.exit,'UserData',1);   % This will halt execution!
handles.halt = 1;
pointsave=get(gcbf,'Pointer');
set(gcbf,'Pointer','watch');
process_order_type(handles);
plotfilter(h, eventdata, handles, varargin);
set(gcbf,'Pointer',pointsave);

% --------------------------------------------------------------------
% special implementation to handle odd filters
function varargout = process_order_type(handles)
ftype = get(handles.type,'Value');
oldval = get(handles.order,'UserData');
newstr = get(handles.order,'String');
newval = eval(newstr,num2str(oldval));
if newval<1, newval = oldval; end
if ftype ==2 | ftype == 4,  %High or Stop
    if mod(newval,2) == 1,  %odd!
        newval = newval+1;
    end
end
if newval>63,
    if ftype ==2 | ftype == 4,  %High or Stop
        newval = 62;
    else
        newval = 63;
    end
end
newval = round(newval);
set(handles.order,'Userdata',newval,'String',num2str(newval));

% --------------------------------------------------------------------
function varargout = w1_Callback(h, eventdata, handles, varargin)
% Callback to specify filter type (lowpass, highpass, etc)
set(handles.exit,'UserData',1);   % This will halt execution!
oldval = get(h,'UserData');
newstr = get(h,'String');
newval = eval(newstr,num2str(oldval));
if newval<0, newval = 0;
elseif newval>1, newval =1; end
set(h,'Userdata',newval,'String',num2str(newval));
pointsave=get(gcbf,'Pointer');
set(gcbf,'Pointer','watch');
plotfilter(h, eventdata, handles, varargin);
set(gcbf,'Pointer',pointsave);

% --------------------------------------------------------------------
function varargout = w2_Callback(h, eventdata, handles, varargin)
% Callback to specify filter type (lowpass, highpass, etc)
set(handles.exit,'UserData',1);   % This will halt execution!
oldval = get(h,'UserData');
newstr = get(h,'String');
newval = eval(newstr,num2str(oldval));
if newval<0, newval = 0;
elseif newval>1, newval =1; end
set(h,'Userdata',newval,'String',num2str(newval));
pointsave=get(gcbf,'Pointer');
set(gcbf,'Pointer','watch');
plotfilter(h, eventdata, handles, varargin);
set(gcbf,'Pointer',pointsave);

% --------------------------------------------------------------------
function varargout = plotcoeff_Callback(h, eventdata, handles, varargin)
% Callback for next slide buttion -> steps through demo
disp('pushbutton1 Callback not implemented yet.')
set(handles.exit,'UserData',1);   % This will halt execution!

% --------------------------------------------------------------------
function varargout = help_Callback(h, eventdata, handles, varargin)
% Callback to specify filter type (lowpass, highpass, etc)
slidenum = get(handles.slide,'UserData');
if slidenum == 1,
    ttlStr = 'Selecting a Board and Processor';
    hlpStr = [ ... 
        'This demo applies the ''Link for Code Composer(R)'' to      '
        'a simple filter design task. It uses the power of MATLAB  '
        'to design and characterize a digital FIR filter that      '
        'executes on a target CPU.                                 '
        'The coefficients for the filter are generated with the    '
        'MATLAB function: FIR1.  The resulting coefficents are     '
        'directly transferred to the DSP processor''s memory.       '
        'Different filter options can be selected and immediately  '
        'tested on the target without modifying the target code.   '
        'The first step is to create the COM/ActiveX link to Code  '
        'Composer Studio (CCS).  The CCS enviroment can support    '
        'multiple DSP processors and PC boards.  The link is to    '    
        'a single device, which is specified by a board number and '
        'processor number.  If you are unsure what devices are     '
        'available, use the ''Selection Tool'' button to find the    '
        'correct board and processor. In single processor systems, '
        'the defaults values (0,0) should work.                    '
        '                                                          '
        ' File name: ccsfirdemo.m                                  '];
    
elseif slidenum == 2,
    ttlStr = 'Loading the Target Project';
    hlpStr = [ ...   
        'Code Composer Sudio is an application for developing DSP  '
        'target code. The resulting target code can be loaded      '
        'and executed on the target CPU.  Debugging tools provided '
        'by Code Composer can interactively modify the target''s    '
        'enviroment, including its local memory.  This toolbox     '
        'extends the same functionality to MATLAB.  After the      '
        'target code is built, the target can be loaded and        '
        'executed by MATLAB.  By interactively modifying and       '
        'reading memory locations in the DSP, it is possible to    '
        'directly evaluate the target''s algorithms, in place!      '
        ' The first step is to create the necessary target program.'
        'This requires assembling a Code Composer(R) project and   '
        'building the necessary program files.  By pressing the    '
        '''Load Project'' button, a sample project file is loaded.   '
        'This project has the required source files:               '
        '  ccsfir.c      - C Source file supplied with this demo.  '
        '  vectos_x.asm  - Assembly source file which implements   '
        '                 vector table.                            '
        '  ccsfir_x.cmd  - Linker command file                     '
        '      (x = will depend on the user''s processor type)      '
        '                                                          '
        ' See also OPEN                                            '
        ' File name: ccsfirdemo.m                                  '];
    
elseif slidenum == 3,
    ttlStr = 'Loading the Program File';
    hlpStr = [ ...
        'The supplied Code Composer project has all the necessary  '
        'source files to implement the demo.  These files must be  '
        'compiled and linked to produce an executable COEFF file,  '
        'which can be loaded into the target DSP processor.        '
        'Several sample projects are supplied with this demo for   '
        'different families of processors.  This demo will try to  '
        'load the version which best matches your processor.  The  '
        'following projects are supplied:                          '
        '  TMS320C6000 family - ccsfir_67x.pjt, ccsfir_64x.pjt,    '
        '                       ccsfir_67xe.pjt, ccsfir_64xe.pjt   '
        '  TMS320C54xx family - ccsfir_54xx.pjt                    '
        '  TMS320C55xx family - ccsfir_55xx.pjt                    '
        '  TMS320C2000 family - ccsfir_28xx.pjt, ccsfir_27xx.pjt,  '
        '                       ccsfir_24xx.pjt                    '
        '  TMS470Rxx   family - ccsfir_r1x.pjt, ccsfir_r2x.pjt,    '
        '                       ccsfir_r1xe.pjt, ccsfir_r2xe.pjt   '
        ' If your processor is not on this list, or it has a unique'
        'memory arrangement, some modification to the project      '
        'may be necessary.  Before proceeding, these changes must  '
        'be applied and a suitable program file generated.  This   '
        'file should have the default name: ''a.out.''   This file   '
        'should be built with symbol generation enabled.  When the '
        'program file is ready, press ''Load Program'' to proceed    '
        'with the demo.                                            '
        '                                                          '
        ' See also OPEN                                            '
        ' File name: ccsfirdemo.m                                  '];
    
elseif slidenum == 4,
    ttlStr = 'Query Symbol Table';
    hlpStr = [ ...
            'The Target now has the code necessary to execute the      '
        'demo.  The next step is to determine the proper locations '
        'in target memory for the data values that will be         '
        'manipulated by this demo.  This is done by querying the   '
        'symbol table for global variables that were defined in the'
        'main source file: ''ccsfir.c''.  By writing into these      '
        'memory locations, it is possible to directly modify the   '
        'target program''s filter characteristics.                  '
        ' To implement this demo, the coefficients of the filter   '
        'are written to the target.  Also, a block of random data  '
        'is transferred to the target and then processed by the    '
        'FIR filter.   The post-filter data is then read to produce'
        'direct measurements of filter performance.                '
        'Press ''Read Symbols'' to proceed with demo.                '
        '                                                          '    
        ' See also ADDRESS,SYMBOL,READ,WRITE                       '
        ' File name: ccsfirdemo.m                                  '];
    
else
    ttlStr = 'Execute Target Filter and Measure Response';
    hlpStr = [ ...
            'By changing the filter options, the user can modify the   '
        'filter coefficients.  The expected filter response is     ' 
        'plotted in the plot window as the blue trace.  Note, this '
        'response does NOT include the effects of quantization.    '
        'Therefore, the measured and expected will differ,         '
        'particularly in the rejected bands.  The theoretical      '
        'response is generated by the MATLAB function: FREQZ.      '
        ' By pressing the ''Run Target'' button, the target          '
        'processors''s implementation of the filter is tested and   '
        'plotted in red.  This testing is done continuously in     '
        'blocks of 512 data points.  Use ''Halt'' to suspend the     '
        'execution.  After halting, it is possible to modify the   '
        'filter parameters and re-run the target characterization  '
        'program. The filter options are as follows:               '
        ' W0 - First cutoff frequency                              '
        ' W1 - Second cutoff frequency (bandpass, bandstop only)   '
        ' Ncoeff - Number of filter coefficient (max 64).          '
        ' Filter Type - Lowpass, Highpass, Bandpass, Bandstop      '
        'Frequencies are normalized such that 1 = fsamp/2 .        '
        '                                                          '
        ' See also FIR1, FREQZ, FREQZPLOT, RUN                     '  
        ' File name: ccsfirdemo.m                                  '];
end
helpdlg(hlpStr,ttlStr);


% --------------------------------------------------------------------
function varargout = viewscript_Callback(h, eventdata, handles, varargin)
% Callback to specify filter type (lowpass, highpass, etc)
edit ccsfirdemo_script.m

% --------------------------------------------------------------------
function varargout = exit_Callback(h, eventdata, handles, varargin)
% Callback to quit demo
if isempty(get(handles.exit,'UserData'))
    set(handles.exit,'UserData',2);    % Halt execution (synchronously)
else
    delete(gcbf);
end


% --------------------------------------------------------------------
function varargout = slide_Callback(h, eventdata, handles, varargin)
% Callback to advance the slides
slidenum = get(h,'UserData');

pointsave=get(gcbf,'Pointer');
set(gcbf,'Pointer','watch');

if slidenum == 1,
    
    % Slide 1 -> activate Code Composer: 'Make Link'
    drawnow;
    bdnum = get(handles.boardnum,'UserData');
    procnum = get(handles.procnum,'UserData');
    
    cmd = ['cc=ccsdsp(''boardnum'',' num2str(bdnum) ',''procnum'',' num2str(procnum) ');' ];
    try
        eval(cmd);
        set(cc,'timeout',30);   % extend default timeout to ensure slow targets do not timeout
    catch
        set(gcbf,'Pointer','arrow');
        errordlg({lasterr 'Failed to establish a link to Code Composer(R)'},'Link Error','modal');
        return;
    end
    if isC2401(cc)
        set(gcbf,'Pointer','arrow');
        errordlg('The CCSFIRDEMO does not run on the C2401 DSP processor.',...
            'Cannot run demo','modal');
        return;
    end    
    msg = { ['>> ' cmd],...
            '',...
            'Link to Code Composer(R) established (cc).',...
            'Next a sample target project can be loaded by',... 
            'pressing ''Load Project''. Three sample projects',...
            'are provided with support for several TI DSP',...
            'processors.  However, modifications to the'...
            'project may be required in some cases.'...
        };
    set(handles.infobox,'String',msg);
    
    handles.cc = cc;       % save for later
    guidata(gcbo,handles); % store the changes...
    
    set(h,'String','Load Project');
    set([handles.boardnum handles.procnum handles.select],'Enable','off');  %Disable 
    set(h,'UserData',slidenum+1);    %  Move to next slide    
    
elseif slidenum == 2,
    % Slide 2 -> Load Project File
    cc = handles.cc;
    drawnow;
    visible(cc,1);
    board = GetDemoProp(cc,'ccsfirdemo');
    outmak = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','ccsfir',board.ccsfir.projname);
    if ~exist(outmak,'file'),
        set(gcbf,'Pointer',pointsave);
        warndlg({'Error - unable to locate project file:' outmak},'Project File Error');
        return;
    end
    try
        open(cc,outmak);
    catch
        set(gcbf,'Pointer',pointsave);
        warndlg({lasterr 'Failed to load project file:' outmak},'CCS File Error');
        return; 
    end
    msg = { ['>> open(cc,''' board.ccsfir.projname ''');'],...
            'A sample project has been loaded into CCS. ',...
            'This includes all the necessary source files.',...
            'The linker switches should be adjusted for',...
            'the target. A program file will be loaded',...
            'next. If not successful, you will be',...
            'prompted to build the program file and load',...
            'manually. If necessary, load a valid GEL file.',...
            'Press ''Load Program'' to continue.'...
        };
    set(handles.infobox,'String',msg);
    set(h,'String','Load Program');
    set(h,'UserData',slidenum+1);    %  Move to next slide    
elseif slidenum == 3,
    % Slide 3 -> Load Program File
    drawnow;
    cc = handles.cc;
    board = GetDemoProp(cc,'ccsfirdemo');
    outprog = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','ccsfir',board.ccsfir.loadfile);
    if ~exist(outprog,'file'),
        set(gcbf,'Pointer',pointsave);
        warndlg({'Error - unable to locate program file:' outprog},'Program File Error');
        return;
    end
    try
        cd(cc,fullfile(matlabroot,'toolbox','ccslink','ccsdemos','ccsfir'))
        load(cc,board.ccsfir.loadfile);
    catch
        set(gcbf,'Pointer',pointsave);
        uiwait(warndlg({lasterr ;'Failed during loading of program file:'; outprog ;
            'We will now rebuild the program file and try to load again...' },'CCS File Error','modal'));
        
        setbuildopt(cc,'Compiler',board.ccsfir.Cbuildopt);
        % Directing output program file to a temporary directory on your system
        setbuildopt(cc,'Linker', ['-c -o "' tempdir board.ccsfir.loadfile '" -x']);
        
        build(cc,'all',60);
        try
            load(cc,[tempdir board.ccsfir.loadfile],40);
        catch
            warndlg({lasterr; 'Failed during loading of program file:'; outprog;
                'Try to build the program file and load manually, then enter 1 and press return from Matlab to procceed ...' },'CCS File Error');
            proceed = input('Enter 1 and press return to proceed with the demo, or 0 to exit: ');
            if (proceed == 0)
                visible(cc,0);
                clear cc
                error('Demo aborted by user...');
            end
            
        end       
    end    
    msg = { ['>> load(cc,''' board.ccsfir.loadfile ''');'],...
            '',...
            'A sample program has been loaded into the DSP. ',...
            'The target code should now be ready to run!',...
            'Next, press ''Read Symbols'' to query the',...
            'target for relevant memory locations.'...
        };
    
    set(handles.infobox,'String',msg);
    set(h,'String','Read Symbols');
    set(h,'UserData',slidenum+1);    %  Move to next slide 
elseif slidenum == 4,
    % Slide 4 -> Check Symbol Table Values
    drawnow;
    cc = handles.cc;
    symbt = struct('coeff',[]);  
    try
        symbt.coeff  = address(cc,'coeff');
        symbt.din    = address(cc,'din');
        symbt.dout   = address(cc,'dout');
        symbt.ncoeff = address(cc,'ncoeff');
        symbt.nbuf   = address(cc,'nbuf');
        symbt.state  = address(cc,'state');
    catch 
        warndlg({lasterr 'Failed to read Target''s symbol table'},'CCS Symbol Error');
        return; 
    end
    msg = { '>> address(cc,''coeff'');',...
            '',...
            'The location in the target''s memory of ',...
            'the data and coefficient arrays has been',...
            'located and read into MATLAB.  For',...
            'example, the filter coefficents are',...
            ['located at address & page: [' int2str(symbt.coeff) ']'],....
            'Define the desired FIR filter and press',...
            '''Run Target'' to perform characterization.'
    };
    set(handles.infobox,'String',msg);       
    
    handles.symbols = symbt;       % save for later
    guidata(gcbo,handles); % store the changes...
    
    set([handles.type handles.order handles.w1 handles.w2],'Enable','on');
    plotfilter(h, eventdata, handles, varargin);
    set(h,'String','Run Target');
    set(h,'UserData',slidenum+1);    %  Move to next slide    
elseif slidenum == 5,
    % Slide 5 -> Execute
    warning('off','MATLAB:integerConversionNowRoundsInsteadOfTruncating')
    warning('off','MATLAB:intConvertNonIntVal')

    set(handles.exit,'UserData',[]);    % Clear any old breaks
    set(gcbf,'Pointer',pointsave);
    set(h,'String','Halt');
    drawnow;
    
    cc = handles.cc;
    cc.timeout = 30; % increase time-out value

    visible(cc,0); % seems to make it much faster
    
    symbt = handles.symbols;
    nfrm = 256;
    bcoeff = handles.bcoef;
    ncoeff = length(bcoeff);
    set(h,'UserData',6);    % Temporarily re-map this callback!
    cscaling = 2^15;
    write(cc,symbt.coeff,int16(cscaling.*bcoeff));
    write(cc,symbt.ncoeff,int32(ncoeff));
    write(cc,symbt.nbuf,int32(nfrm));
    write(cc,symbt.state,int16(zeros(ncoeff+1,1)));     
    
    msg1 = {'>> write(cc,s.din,int16(randn(n,1)))',...
            '',...
            'The data arrays and coefficents have been',...
            'written to the target DSP.'
    };
    msg2 = {'>> run(cc,''runtohalt'')',...
            '>> dout = read(cc,symbols.din,''int16'',n)',...
            '',...
            'The filtered data has been read and',...
            'processed to produce the red plot trace.',...
            'These steps will be repeated to measure the',...
            'filter reponse with new data. Press ''Halt''',...
            'to modify the filter or ''Close'' to leave'...
            'the demo.'
    };
    iter = 0;
    
    Pxx=zeros(1+nfrm/2,1);   % auto and cross power spectrum for 
    Cxy=zeros(1+nfrm/2,1);   % frequency response estimation
    
    while isempty(get(handles.exit,'UserData')),
        % Compute Data Arrays
        din = randn(nfrm,1);      % uniformly distributed random number, unit variance
        glim = max([abs(max(din)) abs(min(din))]);  % find largest element
        dscale = 0.99*2^15/(glim); % limit to +/- 0.99
        idin   = int16(dscale*din); 
        f_idin = double(idin);    
        
        cc.write(symbt.din,idin);      % send frame to ti device 
        
        if ~iter, set(handles.infobox,'String',msg1);  end
        if ~isempty(get(handles.exit,'UserData')), break; end
        
        % Now ready to execute target
        cc.restart;
        tout = 15+ncoeff;          % allow one second per coef + 15
        cc.run('runtohalt',tout);
        
        % read the data and convert to double
        dout = double(cc.read(symbt.dout,'int16',nfrm))';
        
        X = fft(hanning(nfrm).*f_idin); X=X(1:(1+nfrm/2));
        Y = fft(hanning(nfrm).*dout);   Y=Y(1:(1+nfrm/2));
        
        Pxx = Pxx+ X.*conj(X);
        Cxy = Cxy+ X.*conj(Y);
        magXfer = 20*log10(abs(Cxy./Pxx));
        wsdn=(0:(nfrm/2))/(nfrm/2); 
        plot(handles.swdb,handles.scodb,'b',wsdn,magXfer,'r','Parent',handles.axes);
        grid(handles.axes);        
        
        %  legend('Theoretical','Measured','Parent',handles.axes)
        
        if ~iter, set(handles.infobox,'String',msg2); end
        iter = iter +1;
        drawnow;

    end
    msg = {'! Execution halted by user.',...
            '',...
            'Modify filter parameters and then press',...
            '''Run Filter'' to measure the response of',...
            'the new coefficients.  At any time, press',...
            '''Close'' to leave the demo.'
    };
    set(handles.infobox,'String',msg);
    set(h,'String','Run Filter');
    set(h,'UserData',5);    %  Undo remap
    if get(handles.exit,'UserData') == 2,  % Commanded to Exit
        delete(gcbf); drawnow;
    end
    
    warning('on','MATLAB:integerConversionNowRoundsInsteadOfTruncating')
    warning('on','MATLAB:intConvertNonIntVal')
    
elseif slidenum > 5,   % Break command   
    set(handles.exit,'UserData',1);    % Halt a loop
end
set(gcbf,'Pointer',pointsave);

% [EOF] ccsfirdemo.m