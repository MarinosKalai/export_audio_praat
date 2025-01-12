%--------------------------------------------------------------------------
% File Name:    export_audio_praat.m
% Author:       Marinos Kalaitzakis
% Date:         11-01-2025
%
% Description:
% Export audio clip(s) from TextGrid file. Also, there are fade in and fade
% out in the algorithm.
% This algorithm works only in IntervalTier class.
%
% Inputs:
% audio_name
% TextGird_name
% layer_name
% Outputs:
% audio files (wav)

function export_audio_praat(inputs)

arguments
    inputs.audio_name
    inputs.TextGrid_name
    inputs.layer_name
end

% load .TextGrid

[audio_signal,fs] = audioread(inputs.audio_name);
audio_signal = audio_signal(:,1);
info_audio = audioinfo(inputs.audio_name);
bit = info_audio.BitsPerSample;

praat = readlines(inputs.TextGrid_name);
praat_length = length(praat);
praat = categorical(praat([1:praat_length],1));

duration_audio = length(audio_signal);
duration_TextGrid = praat(5);
duration_TextGrid = cellstr(duration_TextGrid);
duration_TextGrid = duration_TextGrid{1,1};
duration_TextGrid = duration_TextGrid(8:length(duration_TextGrid)-1);
duration_TextGrid = str2double(duration_TextGrid);
duration_TextGrid = duration_TextGrid * fs;
duration_TextGrid = ceil(duration_TextGrid);

if (duration_TextGrid - duration_audio) == 0
else
    fprintf('\n\n Maybe, this audio do not relate to this TextGrid file. It looks that the durations are different. \n\n')
end

% find layer name in TextGrid file

scan_name = (['name = "' inputs.layer_name '"']);

start_sample = find(praat==scan_name); % pointer
start_sample = start_sample + 1;  % pointer
end_sample = start_sample + 1 ; % pointer

IntervalTier_check = ('class = "IntervalTier"');

if praat((find(praat==scan_name))-1) == IntervalTier_check
else
    fprintf('\n\n This algorithm works only in IntervalTier class. \n\n')
    return
end

start_sample_value = praat(start_sample);
end_sample_value = praat(end_sample);

% pointer aux

item_num = praat((find(praat==scan_name))-2);
item_num = cellstr(item_num);
item_num = item_num{1,1};
item_num = item_num(7);
item_num = str2double(item_num);

last_table_aux = (item_num*2)+1;
table_aux = (3:2:last_table_aux);
pointer_aux = table_aux(item_num);

%

first_cut = find(praat==start_sample_value);
first_cut = first_cut(pointer_aux);
last_cut = find(praat==end_sample_value);
last_cut = last_cut(pointer_aux);


check_error = [""];

error = find(praat==check_error);


if isempty(error) > 0

    for i=first_cut:4:last_cut

        xmin = i;
        xmin = praat(xmin);
        xmin = cellstr(xmin);
        xmin = xmin{1,1};
        xmin_length = length(xmin);
        xmin = xmin(8:xmin_length-1);
        xmin = str2num(xmin);
        xmin = xmin*fs;
        xmin = fix(xmin);


        xmax = i+1;
        xmax = praat(xmax);
        xmax = cellstr(xmax);
        xmax = xmax{1,1};
        xmax_length = length(xmax);
        xmax = xmax(8:xmax_length-1);
        xmax = str2num(xmax);
        xmax = xmax*fs;
        xmax = ceil(xmax);

        text = i+2;
        text = praat(text);
        text = cellstr(text);
        text = text{1,1};
        xmax_length = length(text);
        text = text(9:xmax_length-1);

        num = i-1;
        num = praat(num);
        num = cellstr(num);
        num = num{1,1};
        xmax_length = length(num);
        num = num(12:xmax_length-2);

        if xmin ~= 0
            if text ~= ""
                vector_name = ([text '_audio_' num '_' num2str(fs) 'kHz_' num2str(bit) 'bit.wav']);
                new_vector = audio_signal(xmin:xmax,1);
                new_vector_length = length(new_vector);

                % fade

                if length(new_vector) > ((fs/10)*2+2)

                    duration_fade = fs/10+1;

                    fade_in = 0:1/(fs/10):1;
                    fade_in = fade_in';
                    fade_in_signal = new_vector(1:duration_fade,1) .* fade_in;

                    fade_out = wrev(fade_in);
                    fade_out_signal = new_vector(new_vector_length-duration_fade+1:end) .* fade_out;

                    new_vector(1:duration_fade) = fade_in_signal;
                    new_vector(new_vector_length-duration_fade+1:end) = fade_out_signal;

                    %     new_vector(end-point_fade:end) = fade_out_signal;
                else
                    fprintf('\n\n It cannot be use fade in and fade out in the audio clip. \n\n')
                end

                % render

                audiowrite(vector_name,new_vector,fs,"BitsPerSample",bit);
            else
                %                 fprintf('\n\nerror 2\n\n');
            end
        else
            %             fprintf('\n\nerror 1\n\n');
        end
    end

else
    fprintf('error 3');
end

end