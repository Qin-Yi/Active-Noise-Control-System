function [ signal_out, err, weights_out ] = lms(signal_in, desired, reset, adapt, step_size)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
%   signal_in:  the pure noise signal captured by Exterior Mic
%   desired:    the input signal mixed with the noise signal(xn)
%   reset:      the switch for resetting the ANC procedure (true for reset)
%   adapt:      the switch for the filter to complete the ANC procedure or not
%   step_size:  a constant which need to adjust to apply the best effect
%
% Outputs:
%   signal_out: the estimated noise
%   err:        music with noise signal - estimated noise
%   weights_out:the weights matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Set weights and fifo persisitent to keep the LMS Filter active and affective
  persistent weights;
  persistent fifo;
  % initialization
  signal_out = zeros(length(signal_in),1);  
  err = zeros(length(signal_in),1);
  % get the framesize(32) and the channel number(1) of the input signal,
  % which can be changed if changing the set of microphones
  [ FrameSize,ChannelCount ] = size(signal_in);

      FilterLength = 32;

      mu = step_size;% the parameter we need to adjust by the experiment
        
      if ( reset || isempty(weights) )% the reset usage, the same as the input of LMS Filter of simulink
     
          weights = zeros(FilterLength,1);

          fifo = zeros(FilterLength,ChannelCount);
      end
      
    %the LMS-Filter algorithm is here
    for ch = 1:ChannelCount

       for n = 1:FrameSize
           % iteration to get one new sample and remain the total sample number is 32
           fifo(1:FilterLength-1,ch) = fifo(2:FilterLength,ch);
           fifo(FilterLength,ch) = signal_in(n,ch);
            % yn = wn * xn
            signal_out(n,ch) = weights' * fifo(:,ch);
            % en = dn - yn
            err(n,ch) = desired(n,ch) - signal_out(n,ch) ;
            if adapt % implrment ANC when adapt is true
                % w(n+1) = w(n) + mu * err * fifo
                weights = weights + mu * err(n,ch) * fifo(:,ch);
            end
        end
    end
      weights_out = weights;
end