
all_errors=[];
for i=1:10
    SS_Final_variable_frames;
    all_errors=[all_errors average_error];
end

%% plots
ave=mean(all_errors,2);

stds=std(all_errors');
frame_ind=2:30;
figure;
hold on;
errorbar(frame_ind,ave,stds);
h=plot(frame_ind,ave,'r');
set(h,'LineWidth',2);
xlabel('Frames Not in Subtraction Estimate');
ylabel('Absolute Error');
title('Error Across Differing Frames Allowed in Estimate');
hold off;


figure;
hold on;
errorbar(frame_ind,ave./frame_ind',stds./frame_ind);
h=plot(frame_ind,ave./frame_ind','r');
set(h,'LineWidth',2);
xlabel('Frames Not in Subtraction Estimate');
ylabel('Absolute Error');
title('Error Across Differing Frames Allowed in Estimate');
hold off;

figure;
hold on;
errorbar(frame_ind,mag2db(ave),mag2db(stds));
h=plot(frame_ind,mag2db(ave),'r');
set(h,'LineWidth',2);
xlabel('Frames Not in Subtraction Estimate');
ylabel('AbsoluteError (dB)');
title('Error Across Differing Frames Allowed in Estimate');
hold off;



figure;
hold on;
errorbar(frame_ind,mag2db(ave./frame_ind'),mag2db(stds./frame_ind));
h=plot(frame_ind,mag2db(ave./frame_ind'),'r');
set(h,'LineWidth',2);
xlabel('Frames Not in Subtraction Estimate');
ylabel('AbsoluteError (dB)');
title('Error Across Differing Frames Allowed in Estimate');
hold off;
