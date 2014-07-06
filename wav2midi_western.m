% MUSICAL NOTE RECOGNITION AND WAV TO MIDI CONVERSION

% Developed by Lohith Bellad
% Department of Electronics and Communication
% S.J.C.E,Mysore

clc;
clear all;% clear all variables
close all;% 
fprintf('Musical Note recognition and WAV to MIDI conversion\n\n');
fprintf('1.Titan music\n2.Phela Nasha\n3.Likhe jo khat tujhe\n4.Bekarar\n5.Bekarar_stanza\n6.Tu Hi Re\n7.Jannatein Kahan\n8.exit\n\n\n');
choice=input('Enter your choice\n');% select the song to be transcribed using a case statement
switch choice% read the music sample based on the users choice
    case 1
        [Y,Fs]=wavread('/users/lohith_bellad/documents/MATLAB/western/titan.wav');
    case 2
        [Y,Fs]=wavread('/users/lohith_bellad/documents/MATLAB/western/phela.wav');
    case 3
        [Y,Fs]=wavread('/users/lohith_bellad/documents/MATLAB/western/likhe.wav');
    case 4
        [Y,Fs]=wavread('/users/lohith_bellad/documents/MATLAB/western/bek.wav');
    case 5
        [Y,Fs]=wavread('/users/lohith_bellad/documents/MATLAB/western/beka.wav');
    case 6
        [Y,Fs]=wavread('/users/lohith_bellad/documents/MATLAB/western/tu.wav');
    case 7
        [Y,Fs]=wavread('/users/lohith_bellad/documents/MATLAB/western/tere.wav');
    case 8
        break;
    otherwise
        fprintf('Enter valid input....exiting.....\n');
        break;
end;

clc;
fprintf('Musical Note recognition and WAV to MIDI conversion\n\n');
fprintf('\n\nPROCESSING.....PLEASE WAIT..........');
tic;
mono=(Y(:,1)+Y(:,2))/2;%average the stereo samples to convert the music to mono format
len=length(mono);%determine the length of the music sample to be analysed

% fix the upper and lower threshold values, which help to determine the start and
% end of note.The values of upper and lower threshold depend upon the
% instrument and tempo of music being played.
if(choice == 1 || choice ==7)
    threshold1=0.3*max(mono);   %fixing the upper threshold
    threshold2=0.1*max(mono); %fixing the lower threshold
elseif(choice == 2 || choice == 3 ||choice == 6)
    threshold1=0.1*max(mono);%fixing the upper threshold
    threshold2=0.05*max(mono);%fixing the lower threshold
elseif(choice == 4 || choice == 5)
    threshold1=0.7*max(mono);%fixing the upper threshold
    threshold2=0.4*max(mono);%fixing the lower threshold
end;
%finding the start and end of the note using sliding window technique.
%The length of window is set to 100
sum=0;%initialize the sum to zero.
checkpoint=1;% variable used to indicate whether the note has started or not.
             %Initialize it to 1, which means the note has not started.
avg=0;
k=1;%variable used as index to the matrix which holds the note start and end sample number.
old_avg=0;
i=51;
while i<=len-50  
    for j=i-50:i+50 % finds the sum of 100 samples
        sum=sum+abs(mono(j));
    end
    avg=sum/100;% calculate the average of 100 samples
    diff=avg-old_avg;
    if(checkpoint==1)
        if(avg > threshold1)% detecting starting of the note
            s(k)=i;% store the sample number of start of note 
            checkpoint=0;% reset the varable to indicate that note has started.
            sum=0;
            k=k+1; %increment the tiime array index
        end
    else
        if(avg < threshold2)% detecting end of the note
            s(k)=i;% store the sample number of end of note 
            checkpoint=1;% set the variable to indicate that note has ended.
            sum=0;
            k=k+1;%increment the time array index
        end
    end
    if(checkpoint==0 || diff < 0)%if note starting is detected
        i=i+250;%skip 250 samples which is reliable
    else i=i+1;%otherwise increment by one
    end;
    sum=0;
    old_avg=avg;
end

for i=1:(length(s)/2)
    d(i)=(s(2*i)-s((2*i)-1))*(1/44100);%find the duration of each note and store it in d matrix.
    m=zeros(44100,1);%set the number of samples in a note to 44100, this is done to take 44100 point FFT.
    m=[mono(s((2*i)-1):s(2*i));zeros(Fs-(s(2*i)-s((2*i)-1)+1),1)];% take the induvidual note 
    wav_fft=abs(fft(m));%find the FFT of the note under consideration

    
    % HARMONIC PRODUCT SPECTRUM(HPS) technique of finding fundamental note frequency
    %initialize FFT spectrum and its scaled version of it to zero.
    for j = 1:length(wav_fft)
        wav_fft2(j,1)=0;
        wav_fft3(j,1)=0;
        wav_fft4(j,1)=0;
        wav_fft5(j,1)=0;
        wav_fft6(j,1)=0;
        wav_fft7(j,1)=0;
        wav_fft8(j,1)=0;
        wav_fft9(j,1)=0;
        
        %function to cancel noise from 0Hz to 50Hz....
        if(j<=50)       
            spec(j,1)=0;% reset amplitudes of frequency components less than 50 Hz
        else
            spec(j,1)=1;% set the amplitudes of frequency components greater than 50 Hz.
        end;
    end;

 
    for j=1:floor((length(wav_fft)-1)/2) %compressing by factor of 2(scaling frequency by a factor of 1/2)
        wav_fft2(j,1)=(wav_fft(2*j,1)+wav_fft((2*j)+1,1))/2;
    end

    for j=1:floor((length(wav_fft)-3)/3)
        wav_fft3(j,1)=(wav_fft(3*j,1)+wav_fft((3*j)+1,1)+wav_fft((3*j)+2,1))/3;%compressing by factor of 3(scaling frequency by a factor of 1/2)
    end
    
    for j= 1:floor((length(wav_fft)-4)/4)
        wav_fft4(j,1)=(wav_fft(4*j,1)+wav_fft((4*j)+1,1)+wav_fft((4*j)+2,1)+wav_fft((4*j)+3,1))/4;
    end %compressing by factor of 4(scaling frequency by factor of 1/4)
    
    for j= 1:floor((length(wav_fft)-5)/5)
        wav_fft5(j,1)=(wav_fft(5*j,1)+wav_fft((5*j)+1,1)+wav_fft((5*j)+2,1)+wav_fft((5*j)+3,1)+wav_fft((5*j)+4,1))/5;
    end %compressing by factor of 5(scaling frequency by factor of 1/5)
    
    for j= 1:floor((length(wav_fft)-6)/6)
        wav_fft6(j,1)=(wav_fft(6*j,1)+wav_fft((6*j)+1,1)+wav_fft((6*j)+2,1)+wav_fft((6*j)+3,1)+wav_fft((6*j)+4,1)+wav_fft((6*j)+5,1))/6;
    end %compressing by factor of 6(scaling frequency by factor of 1/6)
    
    for j= 1:floor((length(wav_fft)-7)/7)
        wav_fft7(j,1)=(wav_fft(7*j,1)+wav_fft((7*j)+1,1)+wav_fft((7*j)+2,1)+wav_fft((7*j)+3,1)+wav_fft((7*j)+4,1)+wav_fft((7*j)+5,1)+wav_fft((7*j)+6,1))/7;
    end%compressing by factor of 7(scaling frequency by factor of 1/7)
    
    for j= 1:floor((length(wav_fft)-8)/8)
        wav_fft8(j,1)=(wav_fft(8*j,1)+wav_fft((8*j)+1,1)+wav_fft((8*j)+2,1)+wav_fft((8*j)+3,1)+wav_fft((8*j)+4,1)+wav_fft((8*j)+5,1)+wav_fft((8*j)+6,1)+wav_fft((8*j)+7,1))/8;
    end%compressing by factor of 8(scaling frequency by factor of 1/8)
    
    for j= 1:floor((length(wav_fft)-9)/9)
        wav_fft9(j,1)=(wav_fft(9*j,1)+wav_fft((9*j)+1,1)+wav_fft((9*j)+2,1)+wav_fft((9*j)+3,1)+wav_fft((9*j)+4,1)+wav_fft((9*j)+5,1)+wav_fft((9*j)+6,1)+wav_fft((9*j)+7,1)+wav_fft((9*j)+8,1))/9;
    end%compressing by factor of 9(scaling frequency by factor of 1/9)

    wav_fftf = (1*wav_fft) .* (1*wav_fft2) .* (1*wav_fft3) .* (wav_fft4) .* (wav_fft5).* (wav_fft6).* (wav_fft7).* (wav_fft8).* (wav_fft9);%multiplying all the components
    wav_fftf = spec .* wav_fftf;%Cancelling noise from 0Hz to 50Hz...
  f(i)=(find((wav_fftf)==max(wav_fftf)));% finding the fundamental note frequency.
end;


% Note Detection part............    
n=length(f);% gives number of notes detected in the sample analysed
note=cell(n,1);
for i=1:n
    temp = round(12*log2(f(i)/27.5));%formula to find out standard western note representation from frequencies obtained
    m = mod(temp,12);
    
    switch m
          case 0
              p = 'A';
          case 1
              p = 'A#/Bb';
          case 2 
              p = 'B';
          case 3 
              p = 'C';
          case 4 
              p = 'C#/Db';
          case 5 
              p = 'D';
          case 6 
              p = 'D#/Eb';
          case 7 
              p = 'E';
          case 8 
              p = 'F';
          case 9 
              p = 'F#/Gb';
          case 10 
              p = 'G';
          case 11 
              p = 'G#/Ab';
    end
    if(i==1)
        scale=p;
    end;
    dot=(floor((temp+9)/12));
    
    if(dot == 3)
        p=[p,'.'];%displaying lower note with a single dot after note character
    elseif(dot == 4)
        p=[p,''];%displaying middle note with no dot after note character
    elseif(dot == 5)
        p=[p,'..'];%displaying upper note with two dots after note character
    end;
    note(i)=cellstr(p);
end;

% Note Detection............
n=length(f);%gives number of notes detected in the sample analysed
note1=cell(n,1);
for i=1:n
    temp1 = round(12*log2(f(i)/27.5));%formula to find out standard classical note representation from frequencies obtained
    m1 = mod(temp1,12);
    
    switch m1
        case 0
            p1 = 'Da2';
        case 1
            p1 = 'Ni1';
        case 2
            p1 = 'Ni2';
        case 3
            p1 = 'Sa';
        case 4
            p1 = 'Ri1';
        case 5
            p1 = 'Ri2';
        case 6
            p1 = 'Ga1';
        case 7
            p1 = 'Ga2';
        case 8
            p1 = 'Ma1';
        case 9
            p1 = 'Ma2';
        case 10
            p1 = 'Pa';
        case 11
            p1 = 'Da1';
    end
    
    
    
    dot1=(floor((temp1+9)/12));
    
    if(dot1 == 3)
        p1=[p1,'.'];%displaying lower note with a single dot after note character
    elseif(dot1 == 4)
        p1=[p1,''];%displaying middle note with no dot after note character
    elseif(dot1 == 5)
        p1=[p1,'..'];%displaying upper note with two dots after note character
    end;
    note1(i)=cellstr(p1);
end;

% MIDI matrix generation
for i=1:length(s)/2;%finding each note start and end time
    d1(i)=s((2*i)-1)/44100;
    %d2(i)=s(2*i)/44100;
end;

for i=1:(length(s)/2)-1;
    d2(i)=d1(i+1);
end;
d2((length(s)/2)) = len/44100;

for i=1:length(f)%formula to calculate MIDI note numbers from standard frequencies obtained
    pn(i)=round(69+(12*(log2(f(i)/440))));
end;

n=length(d);%total number of notes
M=zeros(n,6);%Creating a MIDI matrix of size nx6 where n is total number of notes
M(:,1)=1;%MIDI track number
M(:,2)=1;%MIDI channel number
M(:,3)=pn';%MIDI note number
M(:,4)=120;%Velocity
M(:,5)=d1';%note starting time
M(:,6)=d2';%note ending time

midi=matrix2midi(M);%Generating MIDI file from midi matrix
writemidi(midi,'/users/lohith_bellad/documents/matlab/western/midi_output.mid');%writing MIDI file

midi_new=readmidi('/users/lohith_bellad/documents/matlab/western/midi_output.mid');%reding MIDI file generated
notes=midiInfo(midi_new);%extracting notes from MIDI file to display piano roll
time=toc;
clc;
%display of sonf selected by user to get MIDI output
fprintf('Musical Note recognition and WAV to MIDI conversion\n\n');
if(choice == 1)
    display('Titan Music');
elseif(choice == 2)
    display('Phela Nasha');
elseif(choice == 3)
    display('Likhe jo khat tujhe');
elseif(choice == 4)
    display('Bekarar');
elseif(choice == 5)
    display('Bekarar_stanza');
elseif(choice == 6)
    display('Tu Hi Re');
elseif(choice == 7)
    display('Jannatein kahan');
end;
pause;
fprintf('\nTIME DURATION OF EACH NOTE IN SECONDS');
display(d');%display time duration of each note pressed
pause;
display('NOTE FREQUENCIES IN HERTZ');
display(f);%display fundamental note frequencies
pause;

fprintf('\n\nWestren Note Representation\n');
display(note');
fprintf('\nNOTES Representation\n');
display('lower note   -- Sa. Ri. Ga. Ma. Pa. Da. Ni.');%display how lower note representation is done
display('Main note    -- Sa Ri Ga Ma Pa Da Ni');%display how middle note representation is done
display('Higher note  -- Sa.. Ri.. Ga.. Ma.. Pa.. Da.. Ni..');%display how upper note representation is done
fprintf('\nClassical Note Representation\n');
display(note1');%display classical notes obtained 
pause;
fprintf('SCALE:-\t %c scale\n\n',scale);%display scale of the music sample
fprintf('TOTAL SAMPLE DURATION = %4.3f SECONDS\n\n',(len/Fs));%display total music sample duration
fprintf('TIME ELAPSED = %3.2f SECONDS\n\n',time);%display time taken to run the code
fprintf('TOTAL NUMBER OF NOTES PRESENT IN THE SAMPLE = %d\n\n',length(d));%display total number of notes detected
pause;
[PR,t,nn]=piano_roll(notes,1);%displaying piano roll
figure(1);
imagesc(t,nn,PR);
axis xy;
xlabel('time (sec)');
ylabel('note number');
   