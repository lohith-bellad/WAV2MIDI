% MUSICAL NOTE RECOGNITION AND WAV TO MIDI CONVERSION

% Developed by Lohith Bellad
% Department of Electronics and Communication
% S.J.C.E,Mysore

clc;
clear all;
close all;
fprintf('Musical Note recognition and WAV to MIDI conversion\n\n');
fprintf('1.MAYAMALAVAGHAWLA(2)\n2.MAYAMALAVAGHAWLA(4)\n3.MAYAMALAVAGHAWLA(5)\n4.MAYAMALAVAGHAWLA(6)\n5.VARAVEENA\n6.KAMALASULOCHANA\n7.Exit\n\n\n');
choice=input('Enter your choice\n');% select the song to be transcribed using a case statement
switch choice% read the music sample based on the users choice
    case 1
        [Y,Fs]=wavread('/users/lohith/documents/matlab/classical/8_over_f.wav');
    case 2
        [Y,Fs]=wavread('/users/lohith/documents/matlab/classical/6_over_f_new.wav');
    case 3
        [Y,Fs]=wavread('/users/lohith/documents/matlab/classical/5_over_f.wav');
    case 4
        [Y,Fs]=wavread('/users/lohith/documents/matlab/classical/4_over_f_new.wav');
    case 5
        [Y,Fs]=wavread('/users/lohith/documents/matlab/classical/11_over_f.wav');
    case 6
        [Y,Fs]=wavread('/users/lohith/documents/matlab/classical/12_over_f.wav');
    case 7
        break;
    otherwise
        fprintf('Enter valid input....exiting.....\n');
        break;
end;

clc;
fprintf('Musical Note recognition and WAV to MIDI conversion\n\n');
fprintf('\n\nPROCESSING...............PLEASE WAIT.......');
tic;
mono=(Y(:,1)+Y(:,2))/2;%average the stereo samples to convert the music to mono format
len=length(mono);%determine the length of the music sample to be analysed

% fix the upper and lower threshold values, which help to determine the start and
% end of note.
threshold1=0.3*max(mono); %fixing the upper threshold
threshold2=0.1*max(mono); %fixing the lower threshold

%finding the start and end of the note using sliding window technique.
%The length of window is set to 100
sum=0;%initialize the sum to zero.
checkpoint=1;% variable used to indicate whether the note has started or not.
             %Initialize it to 1, which means the note has not started.
avg=0;
k=1;%variable used as index to the matrix which holds the note start and end sample number.
old_avg=0;
i=51;
while i<=len-50 %finding the start and end of the note using sliding window of length 100 
    for j=i-50:i+50 % find the sum of 100 samples
        sum=sum+abs(mono(j));
    end
    avg=sum/100;% calculating the average of 100 samples
    diff=avg-old_avg;
    if(checkpoint==1)
        if(avg > threshold1)% detecting starting of the note
            s(k)=i;% store the sample number of start of note
            checkpoint=0;% reset the varable to indicate that note has started.
            sum=0;
            k=k+1;%increment the time array index
        end
    else
        if(avg < threshold2)% detecting end of the note
            s(k)=i;% store the sample number of end of note 
            checkpoint=1;% set the variable to indicate that note has ended
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
    d(i)=(s(2*i)-s((2*i)-1))*(1/44100);%finding the duration of each note
    m=zeros(44100,1);%set the number of samples in a note to 44100, this is done to take 44100 point FFT.
    m=[mono(s((2*i)-1):s(2*i));zeros(Fs-(s(2*i)-s((2*i)-1)+1),1)];% take the induvidual note
    wav_fft=abs(fft(m));%find the FFT of the note under consideration

    % HARMONIC PRODUCT SPECTRUM(HPS), technique of finding fundamental note frequency
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
    end

 
    for j=1:floor((length(wav_fft)-1)/2) %compressing by factor of 2(scaling the frequency by a factor of 1/2)
        wav_fft2(j,1)=(wav_fft(2*j,1)+wav_fft((2*j)+1,1))/2;
    end

    for j=1:floor((length(wav_fft)-3)/3)
        wav_fft3(j,1)=(wav_fft(3*j,1)+wav_fft((3*j)+1,1)+wav_fft((3*j)+2,1))/3;%compressing by factor of 3(scaling the frequency by a factor of 1/3)
    end
    
    for j= 1:floor((length(wav_fft)-4)/4)
        wav_fft4(j,1)=(wav_fft(4*j,1)+wav_fft((4*j)+1,1)+wav_fft((4*j)+2,1)+wav_fft((4*j)+3,1))/4;
    end %compressing by factor of 4(scaling the frequency by a factor of 1/4)
    
    for j= 1:floor((length(wav_fft)-5)/5)
        wav_fft5(j,1)=(wav_fft(5*j,1)+wav_fft((5*j)+1,1)+wav_fft((5*j)+2,1)+wav_fft((5*j)+3,1)+wav_fft((5*j)+4,1))/5;
    end %compressing by factor of 5(scaling the frequency by a factor of 1/5)
    
    for j= 1:floor((length(wav_fft)-6)/6)
        wav_fft6(j,1)=(wav_fft(6*j,1)+wav_fft((6*j)+1,1)+wav_fft((6*j)+2,1)+wav_fft((6*j)+3,1)+wav_fft((6*j)+4,1)+wav_fft((6*j)+5,1))/6;
    end %compressing by factor of 6(scaling the frequency by a factor of 1/6)
    
    for j= 1:floor((length(wav_fft)-7)/7)
        wav_fft7(j,1)=(wav_fft(7*j,1)+wav_fft((7*j)+1,1)+wav_fft((7*j)+2,1)+wav_fft((7*j)+3,1)+wav_fft((7*j)+4,1)+wav_fft((7*j)+5,1)+wav_fft((7*j)+6,1))/7;
    end%compressing by factor of 7(scaling the frequency by a factor of 1/7)
    
    for j= 1:floor((length(wav_fft)-8)/8)
        wav_fft8(j,1)=(wav_fft(8*j,1)+wav_fft((8*j)+1,1)+wav_fft((8*j)+2,1)+wav_fft((8*j)+3,1)+wav_fft((8*j)+4,1)+wav_fft((8*j)+5,1)+wav_fft((8*j)+6,1)+wav_fft((8*j)+7,1))/8;
    end%compressing by factor of 8(scaling the frequency by a factor of 1/8)
    
    for j= 1:floor((length(wav_fft)-9)/9)
        wav_fft9(j,1)=(wav_fft(9*j,1)+wav_fft((9*j)+1,1)+wav_fft((9*j)+2,1)+wav_fft((9*j)+3,1)+wav_fft((9*j)+4,1)+wav_fft((9*j)+5,1)+wav_fft((9*j)+6,1)+wav_fft((9*j)+7,1)+wav_fft((9*j)+8,1))/9;
    end%compressing by factor of 9(scaling the frequency by a factor of 1/9)

  wav_fftf = (1*wav_fft) .* (1*wav_fft2) .* (1*wav_fft3) .* (wav_fft4) .* (wav_fft5).* (wav_fft6).* (wav_fft7).* (wav_fft8).* (wav_fft9);%multiplying all the components
  wav_fftf = spec .* wav_fftf;%Cancelling noise from 0Hz to 50Hz...
  f_fake(i)=(find((wav_fftf)==max(wav_fftf)));% finding the fundamental note frequency.
end;

% mapping music to different scales
fake_freq=f_fake(1);
clc;
fprintf('Musical Note recognition and WAV to MIDI conversion\n\n');%giving user a choice to map music onto three different scales
fprintf('1.C3 scale\n2.C4 scale\n3.C5 scale\n\n\n');%C3,C4 and C5 scale
choose=input('Enter the scale to map the music \n');

if(choose==1)
f(1)= 130.8127;%C3 scale standard starting frequency
elseif(choose==2)
f(1)= 261.6255;%C4 scale standard starting frequency
elseif(choose==3)
f(1)=  523.2510;%C5 scale standard starting frequency   
else
    fprintf('Enter valid input......mapping to C3 scale');
    f(1)= 130.8127;% default mapping is on to C3 scale
    pause;
end

for m=1:13
    std_database(m)=2^((m-1)/12)*f(1);%Creating a database of standard frequencies present in the particular scale entered by the user
end;

%mapping of frequencies obtained into standard frequenies according to
%scale entered by the user.
for i=1:length(f_fake)-1
    temp=f_fake(i+1)/f_fake(1);
    FREQ(i)=f(1)*temp;
    
    for j=1:12
        if(FREQ(i)-std_database(j) == 0)
            f(i+1)= std_database(j);
        
        elseif(FREQ(i)<std_database(j+1) && FREQ(i)>std_database(j))
            temp1= abs(FREQ(i)-std_database(j));
            temp2= abs(FREQ(i)-std_database(j+1));
           
                if(temp1>temp2)
                    f(i+1)=std_database(j+1);
                else
                    f(i+1)=std_database(j);
                end;   
                
        elseif(FREQ(i)> std_database(13))
             f(i+1)=std_database(13);
                
        elseif(FREQ(i)< std_database(1))
            f(i+1)=std_database(1);
        end;       
    end;  
end;

% Note Detection............
n=length(f);%total number of fundamental note frequencies
note=cell(n,1);
for i=1:n
    temp = round(12*log2(f_fake(i)/27.5));%formula to find out standard classical note representation from frequencies obtained
    m = mod(temp,12);
    
    switch m
        case 0
            p = 'Da2';
        case 1
            p = 'Ni1';
        case 2
            p = 'Ni2';
        case 3
            p = 'Sa';
        case 4
            p = 'Ri1';
        case 5
            p = 'Ri2';
        case 6
            p = 'Ga1';
        case 7
            p = 'Ga2';
        case 8
            p = 'Ma1';
        case 9
            p = 'Ma2';
        case 10
            p = 'Pa';
        case 11
            p = 'Da1';
    end
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

% MIDI MATRIX GENERATION
for i=1:length(s)/2;%finding each note start and end time
    d1(i)=s((2*i)-1)/44100;
    d2(i)=s(2*i)/44100;
end;

%for i=1:(length(s)/2)-1;
  %  d2(i)=d1(i+1);
%end;

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
writemidi(midi,'/users/lohith/documents/matlab/classical/midi_output.mid');%writing MIDI file
midi_new=readmidi('/users/lohith/documents/matlab/classical/midi_output.mid');%reding MIDI file generated
notes=midiInfo(midi_new);%extracting notes from MIDI file to display piano roll
clc;
time=toc;
clc;
%display of song selected by user to get MIDI output
fprintf('WAV to MIDI conversion\n\n');
if(choice == 1)
    display('MAYAMALAVAGHAWLA(2)');
elseif(choice == 2)
    display('MAYAMALAVAGHAWLA(4)');
elseif(choice == 3)
    display('MAYAMALAVAGHAWLA(5)');
elseif(choice == 4)
    display('MAYAMALAVAGHAWLA(6)');
elseif(choice == 5)
    display('VARAVEENA');
elseif(choice == 6)
    display('KAMALASULOCHANA');
end;
pause;
fprintf('\nTIME DURATION OF EACH NOTE IN SECONDS');
display(d');%display time duration of each note pressed
pause;
display('NOTE FREQUENCIES IN HERTZ');
display(f_fake);%display fundamental note frequencies
pause;
fprintf('\nNOTES Representation\n');
display('lower note   -- Sa. Ri. Ga. Ma. Pa. Da. Ni.');%display how lower note representation is done 
display('Main note    -- Sa Ri Ga Ma Pa Da Ni');%display how middle note representation is done
display('Higher note  -- Sa.. Ri.. Ga.. Ma.. Pa.. Da.. Ni..');%display how upper note representation is done
fprintf('\n\nNOTES PLAYED');
display(note');%display classical notes obtained 
pause;
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
