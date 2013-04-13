%% OFDM BLISS

% First Blind Look
!LD_LIBRARY_PATH="" &&   /home/sdruser/COLLINS/BLISS/GNURadio/USRP_Receiver/receiver_f.py
interfere_org=read_complex_binary('/home/sdruser/COLLINS/BLISS/GNURadio/OFDM/Received_f.txt');
pause;

% Run receiver
!LD_LIBRARY_PATH="" &&   /home/sdruser/COLLINS/BLISS/GNURadio/USRP_Receiver/receiver_f.py
mixed_input=read_complex_binary('/home/sdruser/COLLINS/BLISS/GNURadio/OFDM/Received_f.txt');
bliss_SS( mixed_input,interfere_org, 512 );

% Run Demod and Eval
!LD_LIBRARY_PATH="" && /home/sdruser/COLLINS/BLISS/GNURadio/OFDM/OFDM_demod.py
!ls -l BLISS/GNURadio/OFDM/output.txt

