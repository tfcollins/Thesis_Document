clc;
!sudo sysctl -w net.core.rmem_max=50000000
!sudo sysctl -w net.core.wmem_max=1048576

!LD_LIBRARY_PATH=""   &&   /home/sdruser/COLLINS/SS/top_block_SS_R.py

%% Spectral Subtraction
addpath('/home/sdruser/GNURadio/gnuradio/gnuradio-core/src/utils');
received=read_complex_binary('received.txt');
received_GMSK=read_float_binary('received_GMSK.txt');

known=read_complex_binary('known_modulated.txt').*0.1;

%remove startup transient
cut=20001;
received=received(cut:end);
recSig=received;

%% Timing Recovery
L=2;
g=0.07;
hSync = comm.MuellerMullerTimingSynchronizer('SamplesPerSymbol', L, ...
    'ErrorUpdateGain', g);

% Estimate the delay from the received signal
[sig, phase] = step(hSync, recSig);

% apply phase
recSig=recSig.*exp(1i*phase(end)*pi/180);


%% find data
r=double(sign(received_GMSK));
                
                
s_saved=[ -1     1     1     1     1    -1     1    -1];
s_saved=[s_saved s_saved s_saved]';
prea=s_saved;
s=s_saved.';

% Find Preambles
indexs=[];
for i=1:length(r)-length(s_saved)-2000
    x=sum(r(i:i+length(s_saved)-1)==s_saved);
    %if x>10
    %    disp(x);
    %end
   if sum(r(i:i+length(s_saved)-1)==s_saved)==length(s_saved)
        indexs=[indexs i]; 
   end
end


% Retry is no signal found
if isempty(indexs)
    disp('Looped');
    SS_Final;
    break
end

%% calculated channel coefficients
loc=indexs(1);
w=zeros(10,1);
%Real message
dd=read_char_binary('/home/sdruser/COLLINS/SS/input.txt');
true_message=de2bi(dd',8,'left-msb');
mbits=reshape(true_message',size(true_message,2)*size(true_message,1),1);
mu=0.001;
e_s=[];
for i=length(w)+1:length(mbits)-length(w)
    rr=mbits(i:-1:i-length(w)+1);
    
    disp([w'*rr received_GMSK(loc+i-1) mbits(i)]);
    
    e=w'*rr-received_GMSK(loc+i-1);
    e_s=[e_s e];
    
    w=w-mu*rr*conj(e);

end

%% Section of Signal
large_SR=recSig;
frames=20;
sample=18*8*2*frames;
section=filter(w,1,known);
error_saved=[];
for i=1:sample:length(large_SR)-sample

recSig=large_SR(i:i+sample-1);

%% Find position of Frame in full signal
section=filter(w,1,known);
xc = xcorr(recSig,section);
middle=ceil(length(xc)/2);
xc=xc(middle:end);
%stem(real(xc));
[~,index]=max(real(xc));
section=filter(w,1,known);

if index+length(section)>sample
   continue 
end
% Spectral Subtract
subtraction=1;
result=[];
section=recSig(index:index+length(section)-1);

for i=index:length(section):length(recSig)-length(section)
    
    result=[result;recSig(i:i+length(section)-1)-section.*subtraction];
    
end

% Try Catch if no signal found
if isempty(result)
    continue
end

%% Plots
figure;
plot(real(recSig(index:index+length(result)-1)));
hold on;
plot(real(result),'r');
plot(real(section*subtraction),'g');
xlabel('Samples')
ylabel('Magnitude')
title(['Spectral Subtraction Over Subtraction Factor ',num2str(subtraction)]);
legend('Original Signal','Subtracted Result','Estimate of Original');
hold off;
%refreshdata
%drawnow

disp('Paused');
pause(.1);
error_saved=[error_saved sum(abs(result))];

end

%% Plots
figure;
plot(error_saved(1:300));
title('Error Across Transmission Frames')
xlabel('Frames');
ylabel('Error');
