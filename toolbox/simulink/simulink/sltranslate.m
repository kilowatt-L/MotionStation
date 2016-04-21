function [out] = sltranslate(saveAsVersion)
%SLTRANSLATE Returns information used by save_system to save models.
%   SLTRANSLATE is an internal function used by save_system for saving
%   to a previous version. It is not meant to be called directly.
%
%   Copyright 1990-2004 The MathWorks, Inc.

  out = [];
  
  % Check for valid versions
  validVersions = {'SAVEAS_R13SP1', 'SAVEAS_R13', 'SAVEAS_R12', 'SAVEAS_R12P1'};
  if ~any(strcmp(saveAsVersion, validVersions))
    error(['Invalid version in sltranslate.m', saveAsVersion]);
  end
  
  % The structure of the output data is as follows:
  % o All the data is encapulated in a MATLAB struct data type.
  % o The struct has the following fields:
  %   - A field storing a list of old and new reference block locations
  %     The format of this is a cell array containing a list of cell arrays.
  %     Each sub cell array has the current and old reference block name.
  %   - A field consisting of new blocks that have been added.
  %     The format of this field is a cell array containing the name of the block
  %     followed by a 1x2 vector containing the number of input and output ports.
  %   - A field containing all new block parameters. The format of this
  %     is a cell array of block names (strings) followed by a cell array
  %     of param names. 
  %   - A field containing all new block parameters that are common across all
  %     blocks. These parameters can also be specified on a block by block basis
  
  RefMap = {{'simulink/Logic and Bit\nOperations/Bit Clear', ...
             'fixpt_lib_4/Bits/Bit Clear'}, ...
            {'simulink/Logic and Bit\nOperations/Bit Set', ...
             'fixpt_lib_4/Bits/Bit Set'}, ...
            {'simulink/Logic and Bit\nOperations/Bitwise\nOperator', ...
             'fixpt_lib_4/Bits/Bitwise\nOperator'}, ...
            {'simulink/Logic and Bit\nOperations/Compare\nTo Constant', ...
             'fixpt_lib_4/Logic & Comparison/Compare\nTo Constant'}, ...
            {'simulink/Logic and Bit\nOperations/Compare\nTo Zero', ...
             'fixpt_lib_4/Logic & Comparison/Compare\nTo Zero'}, ...
            {'simulink/Sources/Counter\nFree-Running', ...
             'fixpt_lib_4/Sources/Counter\nFree'}, ...
            {'simulink/Sources/Counter\nLimited', ...
             'fixpt_lib_4/Sources/Counter\nLimited'}, ...
            {'simulink/Signal\nAttributes/Data Type\nDuplicate', ...
             'fixpt_lib_4/Data Type/Data Type\nDuplicate'}, ...
            {'simulink/Signal\nAttributes/Data Type\nPropagation', ...
             'fixpt_lib_4/Data Type/Data Type\nPropagation'}, ...
            {'simulink/Signal\nAttributes/Data Type\nScaling Strip', ...
             'fixpt_lib_4/Data Type/Scaling Strip'}, ...
            {'simulink/Discontinuities/Dead Zone\nDynamic', ...
             'fixpt_lib_4/Nonlinear/Dead Zone\nDynamic'}, ...
            {'simulink/Additional Math\n& Discrete/Additional Math:\nIncrement - Decrement/Decrement\nReal World', ...
             'fixpt_lib_4/Math/Decrement\nReal World'}, ...
            {'simulink/Additional Math\n& Discrete/Additional Math:\nIncrement - Decrement/Decrement\nStored Integer', ...
             'fixpt_lib_4/Math/Decrement\nStored Integer'}, ...
            {'simulink/Additional Math\n& Discrete/Additional Math:\nIncrement - Decrement/Decrement\nTo Zero', ...
             'fixpt_lib_4/Math/Decrement\nTo Zero'}, ...
            {'simulink/Additional Math\n& Discrete/Additional Math:\nIncrement - Decrement/Decrement Time\nTo Zero', ...
             'fixpt_lib_4/Math/Decrement Time\nTo Zero'}, ...
            {'simulink/Logic and Bit\nOperations/Detect\nChange', ...
             'fixpt_lib_4/Edge Detect/Detect\nChange'}, ...
            {'simulink/Logic and Bit\nOperations/Detect\nDecrease', ...
             'fixpt_lib_4/Edge Detect/Detect\nDecrease'}, ...
            {'simulink/Logic and Bit\nOperations/Detect\nIncrease', ...
             'fixpt_lib_4/Edge Detect/Detect\nIncrease'}, ...
            {'simulink/Logic and Bit\nOperations/Detect Fall\nNegative', ...
             'fixpt_lib_4/Edge Detect/Detect Fall\nNegative'}, ...
            {'simulink/Logic and Bit\nOperations/Detect Fall\nNonpositive', ...
             'fixpt_lib_4/Edge Detect/Detect Fall\nNonpositive'}, ...
            {'simulink/Logic and Bit\nOperations/Detect Rise\nNonnegative', ...
             'fixpt_lib_4/Edge Detect/Detect Rise\nNonnegative'}, ...
            {'simulink/Logic and Bit\nOperations/Detect Rise\nPositive', ...
             'fixpt_lib_4/Edge Detect/Detect Rise\nPositive'}, ...
            {'simulink/Discrete/Difference', ...
             'fixpt_lib_4/Calculus/Difference'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Fixed-Point\nState-Space', ...
             'fixpt_lib_4/Filters/State-Space'}, ...
            {'simulink/Additional Math\n& Discrete/Additional Math:\nIncrement - Decrement/Increment\nReal World', ...
             'fixpt_lib_4/Math/Increment\nReal World'}, ...
            {'simulink/Additional Math\n& Discrete/Additional Math:\nIncrement - Decrement/Increment\nStored Integer', ...
             'fixpt_lib_4/Math/Increment\nStored Integer'}, ...
            {'simulink/Discrete/Integer Delay', ...
             'fixpt_lib_4/Delays & Holds/Integer Delay'}, ...
            {'simulink/Logic and Bit\nOperations/Interval Test', ...
             'fixpt_lib_4/Logic & Comparison/Interval Test'}, ...
            {'simulink/Logic and Bit\nOperations/Interval Test\nDynamic', ...
             'fixpt_lib_4/Logic & Comparison/Interval Test\nDynamic'}, ...
            {'simulink/Math\nOperations/MinMax\nRunning\nResettable',...
             'fixpt_lib_4/Math/MinMax\nRunning\nResettable'}, ...
            {'simulink/Sources/Repeating\nSequence\nInterpolated', ...
             'fixpt_lib_4/Sources/Repeating\nSequence\nInterpolated'}, ...
            {'simulink/Sources/Repeating\nSequence\nStair', ...
             'fixpt_lib_4/Sources/Repeating\nSequence\nStair'}, ...
            {'simulink/Logic and Bit\nOperations/Shift\nArithmetic', ...
             'fixpt_lib_4/Bits/Shift\nArithmetic'}, ...
            {'simulink/Lookup\nTables/Sine', ...
             'fixpt_lib_4/LookUp/Sine'}, ...
            {'simulink/Lookup\nTables/Cosine', ...
             'fixpt_lib_4/LookUp/Cosine'}, ...
            {'simulink/Discrete/Tapped Delay', ...
             'fixpt_lib_4/Delays & Holds/Tapped Delay'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Transfer Fcn\nDirect Form II', ...
             'fixpt_lib_4/Filters/Filter\nDirect Form II'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Transfer Fcn\nDirect Form II\nTime Varying', ...
             'fixpt_lib_4/Filters/Filter\nDirect Form II\nTime Varying'}, ...
            {'simulink/Discrete/Transfer Fcn\nFirst Order', ...
             'fixpt_lib_4/Filters/Filter\nFirst Order'}, ...
            {'simulink/Discrete/Transfer Fcn\nLead or Lag', ...
             'fixpt_lib_4/Filters/Filter\nLead or Lag'}, ...
            {'simulink/Math\nOperations/Unary Minus', ...
             'fixpt_lib_4/Math/Unary Minus'}, ... 
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Unit Delay\nEnabled', ...
             'fixpt_lib_4/Delays & Holds/Unit Delay\nEnabled'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Unit Delay\nEnabled\nExternal IC', ...
             'fixpt_lib_4/Delays & Holds/Unit Delay\nEnabled\nExternal IC'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Unit Delay\nEnabled\nResettable', ...
             'fixpt_lib_4/Delays & Holds/Unit Delay\nEnabled\nResettable'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Unit Delay\nEnabled\nResettable\nExternal IC', ...
             'fixpt_lib_4/Delays & Holds/Unit Delay\nEnabled\nResettable\nExternal IC'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Unit Delay\nExternal IC', ...
             'fixpt_lib_4/Delays & Holds/Unit Delay\nExternal IC'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Unit Delay\nResettable', ...
             'fixpt_lib_4/Delays & Holds/Unit Delay\nResettable'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Unit Delay\nResettable\nExternal IC', ...
             'fixpt_lib_4/Delays & Holds/Unit Delay\nResettable\nExternal IC'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Unit Delay\nWith Preview\nEnabled', ...
             'fixpt_lib_4/Delays & Holds/Unit Delay\nWith Preview\nEnabled'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Unit Delay\nWith Preview\nEnabled\nResettable', ...
             'fixpt_lib_4/Delays & Holds/Unit Delay\nWith Preview\nEnabled\nResettable'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Unit Delay\nWith Preview\nEnabled\nResettable\nExternal RV', ...
             'fixpt_lib_4/Delays & Holds/Unit Delay\nWith Preview\nEnabled\nResettable\nExternal RV'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Unit Delay\nWith Preview\nResettable', ...
             'fixpt_lib_4/Delays & Holds/Unit Delay\nWith Preview\nResettable'}, ...
            {'simulink/Additional Math\n& Discrete/Additional\nDiscrete/Unit Delay\nWith Preview\nResettable\nExternal RV', ...
             'fixpt_lib_4/Delays & Holds/Unit Delay\nWith Preview\nResettable\nExternal RV'}, ...
            {'simulink/Discrete/Weighted\nMoving Average', ...
             'fixpt_lib_4/Filters/FIR'}, ...
            {'simulink/Signal\nAttributes/Weighted\nSample Time', ...
             'fixpt_lib_4/Calculus/Sample Time\nMultiply'}, ...
            {'simulink/Math\nOperations/Weighted\nSample Time\nMath', ...
             'fixpt_lib_4/Calculus/Sample Time\nMultiply'}, ...
            {'simulink/Discontinuities/Wrap To Zero', ...
             'fixpt_lib_4/Nonlinear/Wrap To Zero'}, ...
            {'simulink/Lookup\nTables/Lookup\nTable (n-D)', ...
             'simulink/Look-Up\nTables/Look-Up\nTable (n-D)'}, ...
            {'simulink/Lookup\nTables/PreLookup\nIndex Search', ...
             'simulink/Look-Up\nTables/PreLook-Up\nIndex Search'}, ...
            {'simulink/Lookup\nTables/Interpolation (n-D)\nusing PreLookup', ...
             'simulink/Look-Up\nTables/Interpolation (n-D)\nusing PreLook-Up'}, ...
            {'simulink/Lookup\nTables/Direct Lookup\nTable (n-D)', ...
             'simulink/Look-Up\nTables/Direct Look-Up\nTable (n-D)'}, ...
            {'simulink/Lookup\nTables/Lookup\nTable\nDynamic', ...
             'fixpt_lib_4/LookUp/Look-Up\nTable\nDynamic'}, ...
            {'simulink/Discontinuities/Saturation\nDynamic', ...
             'fixpt_lib_4/Nonlinear/Saturation\nDynamic'}, ...
            {'simulink/Discontinuities/Rate Limiter\nDynamic', ...
             'fixpt_lib_4/Nonlinear/Rate Limiter\nDynamic'}, ...
            {'simulink/Discrete/Discrete Derivative', ...
            'fixpt_lib_4/Calculus/Derivative'}};
            
  NewBlocks = {'ModelReference', [-1, -1], ...
               'Bias', [1, 1], ...
               'SignalConversion', [1, 1], ...
               'RateTransition', [1, 1], ...
               ['simulink/Signal', 10, 'Routing/Environment', 10, 'Controller'], [2, 1], ...
               ['simulink/Model-Wide', 10, 'Utilities/Model Advisor'], [0, 0], ...
               ['simulink/Model-Wide', 10, 'Utilities/Block Support', 10, 'Table'], [0, 0], ...
               ['simulink/Logic and Bit', 10, 'Operations/Extract Bits'], [1, 1], ...
               ['simulink/Discrete/Transfer Fcn', 10, 'Real Zero'], [1, 1], ...
               'M-S-Function', [1, 1]};

  NewBlockParams = {'DataTypeConversion', {'OutDataTypeMode', 'OutDataType', 'OutScaling', ...
                      'LockScale', 'ConvertRealWorld', 'RndMeth'}, ...
                    'Inport', {'IconDisplay', 'BusOutputAsStruct', 'UseBusObject'}, ...
                    'Assignment', {'IndexMode', 'IndexIsStartValue', 'OutputDimensions', ...
                      'DiagnosticForDimensions', 'OutputInitialize'}, ...
                    'Math', {'OutDataTypeMode', 'OutDataType', 'OutScaling', 'LockScale', ...
                      'RndMeth', 'SaturateOnIntegerOverflow'}, ...
                    'DiscretePulseGenerator', {'TimeSource'}, ...
                    'PulseGenerator', {'TimeSource'}, ...
                    'SignalGenerator', {'TimeSource'}, ...
                    'ToWorkspace', {'FixptAsFi'}, ...
                    'ForIterator', {'IndexMode'}, ...
                    'Derivative', {'LinearizePole'}, ...
                    'RateLimiter', {'SampleTimeMode', 'InitialCondition'}, ...
                    'DiscreteIntegrator', {'gainval', 'InitialConditionMode', 'OutDataTypeMode', ...
                      'OutDataType', 'OutScaling', 'LockScale', 'RndMeth', 'SaturateOnIntegerOverflow', ...
                      'ICPrevOutput', 'ICPrevScaledInput'}, ...
                    'DataStoreMemory', {'ShowAdditionalParam', 'DataType', 'OutDataType', ...
                      'OutScaling', 'SignalType'}, ...
                    'From', {'IconDisplay'}, ...
                    'Goto', {'IconDisplay'}, ...
                    'Sin', {'TimeSource', 'RTWParamStorageClass', 'Tunable'}, ...
                    'BusCreator', {'UseBusObject'}, ...
                    'Selector', {'IndexMode', 'IndexIsStartValue', 'OutputPortSize'}, ...
                    'Probe', {'ProbeFramedSignal', 'ProbeWidthDataType', 'ProbeSampleTimeDataType', ...
                      'ProbeComplexityDataType', 'ProbeDimensionsDataType', 'ProbeFrameDataType', ...
                      'ProbeFramedSignal'}, ...
                    'Scope', {'IOSignalStrings'}, ...
                    'Lookup', {'LUTDesignTableMode', 'LUTDesignDataSource', 'LUTDesignFunctionName', ...
                      'LUTDesignUseExistingBP', 'LUTDesignRelError', 'LUTDesignAbsError'}, ...
                    'MinMax', {'InputSameDT', 'OutDataTypeMode', 'OutDataType', 'OutScaling', ...
                      'LockScale', 'RndMeth', 'SaturateOnIntegerOverflow'}, ...
                    'Outport', {'IconDisplay', 'BusOutputAsStruct', 'PortDimensions', 'SampleTime', ...
                      'DataType', 'OutDataType', 'OutScaling', 'SignalType', 'SamplingMode', 'UseBusObject'}, ...
                    'SubSystem', {'SystemSampleTime', 'MinAlgLoopOccurrences', ...
                      'EnableExecutionContextPropagation', 'AvailSigsInstanceProps', 'AvailSigsLoadSave', ...
                      'PermitHierarchicalResolution', 'PropExecContextAcrossSSBoundary'}, ...
                    'simulink/Discrete/Tapped Delay', {'includeCurrent'}, ...
                    'simulink/Discrete/First-Order\nHold', {'DisableCoverage'}, ...
                    'Lookup2D', {'LUTDesignTableMode', 'LUTDesignDataSource', 'LUTDesignFunctionName', ...
                      'LUTDesignUseExistingBP', 'LUTDesignRelError', 'LUTDesignAbsError'}, ...
                    'simulink/Lookup\nTables/PreLookup\nIndex Search', {'IndexDataType'}, ...
                    'simulink/Lookup\nTables/Interpolation (n-D)\nusing PreLookup', {'NumSelectionDims'}, ...
                    'simulink/Logic and Bit\nOperations/Interval Test\nDynamic', {'LogicOutDataTypeMode'}, ...
                    'simulink/Logic and Bit\nOperations/Interval Test', {'LogicOutDataTypeMode'}, ...
                    'simulink/Logic and Bit\nOperations/Compare\nTo Constant', {'LogicOutDataTypeMode'}, ...
                    'simulink/Logic and Bit\nOperations/Compare\nTo Zero', {'LogicOutDataTypeMode'}, ...
                    'FromWorkspace', {'VnvData', 'IOType', 'IOSignalStrings'}};
      
  NewCommonBlockParams = {'BusObject', 'NonVirtualBus', 'DialogController', 'ShowPortLabels', 'DisableCoverage', ...
                      'MaskTabNames', 'MaskTabNameString', 'StateMustResolveToSignalObject'};
  
  % R13 specific information will be added here
  if ~strcmp(saveAsVersion, 'SAVEAS_R13SP1')
    AdditionalCommonBlockParams = {'SampleTime'};
    AdditionalBlockParams = {'Trigger', {'StatesWhenEnabling', 'SampleTimeType'}, ...
                        'ForIterator', {'ExternalIncrement'}};
    
    NewCommonBlockParams = cat(2, NewCommonBlockParams, AdditionalCommonBlockParams);
    NewBlockParams = cat(2, NewBlockParams, AdditionalBlockParams);
  end
  
  out.RefMap = RefMap;
  out.NewBlocks = NewBlocks;
  out.NewBlockParams = NewBlockParams;
  out.NewCommonBlockParams = NewCommonBlockParams;