%Cal GRC
!sudo sysctl -w net.core.rmem_max=50000000
!sudo sysctl -w net.core.wmem_max=1048576
close all;
errors=0;
samples=0;
%% Plotting stuff
n=10;
f=zeros(n,1);
f2=zeros(n,1);

[hf,w]=freqz(f,1);
hold on;
h=semilogy(w,abs(hf),'r');
h2=semilogy(w,abs(hf),'b');
hold off;
ylim([0 2]);
title('Channel response');
grid on;

freqzz=[];

%Real message
%dd=read_char_binary('/home/sdruser/COLLINS/BLISS/Data/input.txt');

dd=read_char_binary('/home/sdruser/COLLINS/Pre/Input.txt');
true_message=de2bi(dd',8,'left-msb');
mbits=reshape(true_message',size(true_message,2)*size(true_message,1),1);

final_BER=[];
RUNS=30;
for j=RUNS:-2:1
%% Run USRP Receiver
command=['LD_LIBRARY_PATH=""   &&   /home/sdruser/COLLINS/BLISS/GNURadio/USRP_Receiver/receiver.py ',num2str(j)];
system(command);
%clc
%% Read File
%received
r=read_float_binary('/home/sdruser/COLLINS/Pre/Channel1_f.txt');
r2=read_float_binary('/home/sdruser/COLLINS/Pre/Channel2_f.txt');
r_saved=r;
r_saved2=r2;
r=double(sign(r));
r2=double(sign(r2));

%known symbols
%s_saved=[1 1 -1 1 1 1 1 -1 1 1 1 -1 1 1 -1 1]';
s_saved=[ -1     1     1     1     1    -1     1    -1];
s_saved=[s_saved s_saved s_saved]';
prea=s_saved;
s=s_saved.';

%% Find Preambles
indexs=[];
for i=1:length(r)-length(s_saved)-2000
   if sum(r(i:i+length(s_saved)-1)==s_saved)==length(s_saved)
        indexs=[indexs i]; 
   end
end
indexs2=[];
for i=1:length(r2)-length(s_saved)-2000
   if sum(r2(i:i+length(s_saved)-1)==s_saved)==length(s_saved)
        indexs2=[indexs2 i]; 
   end
end
est=length(r)/(18*8);

disp(['Indexs: ',num2str(length(indexs)),' | Estimated: ',num2str(est)]);

%% Look through all preambles
for k=1:min([length(indexs),length(indexs2)])
    if ((length(r_saved)-indexs(k)+1000)<0)
        disp('Break');
        break
    end
start=indexs(k); 
start2=indexs2(k); 


% Two frames
% message = 15 message + 3 preambles bytes
frames=2;
r=r_saved(start:start+(15+3)*8*frames).';
r2=r_saved2(start2:start2+(15+3)*8*frames).';


%% Equalize
preamble_len=24;
%n=10; %f=zeros(n,1);           % initialize equalizer at 0
%f2=zeros(n,1);
mu=.01; delta=0;             % stepsize and delay delta
for i=n+1:preamble_len                  % iterate
  %F1
  rr=r(i:-1:i-n+1)';         % vector of received signal
  e=s(i-delta)-rr'*f;        % calculate error
  f=f+mu*e*rr;               % update equalizer coefficients
  %F2
  rr2=r2(i:-1:i-n+1)';         % vector of received signal
  e=s(i-delta)-rr2'*f2;        % calculate error
  f2=f2+mu*e*rr2;               % update equalizer coefficients

end

%% MRC get weights
fs=sum(f);
f2s=sum(f2);
ftotal=fs+f2s;
w1=1-fs/ftotal;
w2=1-f2s/ftotal;

mu=.01;                       % stepsize
for i=preamble_len+1:length(r)          % iterate
  %F1
  rr=r(i:-1:i-n+1)';         % vector of received signal
  e=sign(f'*rr)-f'*rr;       % calculate error
  f=f+mu*e*rr;               % update equalizer coefficients
  %F2
  rr2=r2(i:-1:i-n+1)';         % vector of received signal
  e=sign(f2'*rr2)-f2'*rr2;       % calculate error
  f2=f2+mu*e*rr2;               % update equalizer coefficients

end

%Filter
result=filter(f,1,r);
result2=filter(f2,1,r2);


%% MRC 
result=sum([result.*w1;result2.*w2]);

%% Quantize to bits
final=int8(result>0);

%% Find errors
m=length(mbits);
mbits=int8(mbits);
for sh=0:n                   % if equalizer is working, one
  err(sh+1)=0.5*sum(abs(final(sh+1:m)'-mbits(1:m-sh)));
end                          % of these delays has zero error
[~,mm]=min(err);

final=final(mm:end-mm+1);

%Add Messages together bitwise
last=floor(length(final)/length(mbits));
final=final(1:last*length(mbits));
finals=reshape(final,length(mbits),last)';
final=sum(finals,1)>=last/2;



%Decode Messages
last=round(length(final)/8);
final=final(1:last*8);% remove exending bits
f_r=reshape(final,8,length(final)/8)';
f_c=bi2de(f_r,'left-msb');
message=char(f_c)';

%% Calculate Errors
%disp('--------');
%disp(message); 
samples=samples+15*8;
errors=(errors+sum(final'~=mbits));

end
% Wait between loops
disp('paused');
disp(j);
final_BER=[final_BER; errors/samples];

end

%% Plot
disp(['Final BER: ',num2str(mean(final_BER))]);

semilogy(RUNS:-2:1,final_BER);

fclose(u);
delete(u);
