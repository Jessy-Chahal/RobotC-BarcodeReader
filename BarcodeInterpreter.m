% ========================================================
% BarcodeInterpreter.m
% 
% Interprets a CSV file generated by BarcodeReader.c
% into an ASCII/Unicode character and displays the result.
% ========================================================

clear;

csv = csvread('LetterZ_Data.csv', 1);
colorData = csv(:, 3);

colorData = filterAmplify(colorData);
[bars, spaces] = getBarcode(colorData);
character = native2unicode(getDecASCII(bars, spaces), 'US-ASCII');

disp(character);

function data = filterAmplify(data)
    % set all data points above mean to 100, below mean to 0
	avg = trimmean(data, 10);
    for i = 1:length(data)
        if data(i) < avg
			data(i) = 0;
		else
			data(i) = 100;
        end
    end
    % compute running average
	windowSize = cast(length(data)/100, 'uint16');
    for i = 1:length(data)-windowSize
		data(i) = sum(data(i:i+windowSize-1))/windowSize;
    end
end

function [bars, spaces] = getBarcode(data)
	avg = trimmean(data, 10);
	currColor = data(end) > avg;
    firstColor = currColor;
    bars = [];
    spaces = [];
	startIndex = length(data);
    
    % reverse iterate through data and record bar and space widths
    for i = length(data):-1:1
		if not(currColor) && data(i) > avg
            bars(end+1) = startIndex-i;
		elseif currColor && data(i) < avg
			spaces(end+1) = startIndex-i;
		else
			continue;
		end
		currColor = not(currColor);
		startIndex = i;
    end
    % flip arrays to get barcode parts in normal order, ignore extras
	bars = fliplr(bars(1:5));
	spaces = fliplr(spaces(1+firstColor:4+firstColor));
end

function decASCII = getDecASCII(bars, spaces)
	BAR_VALUES = [1 2 4 7 0];
	SPACE_VALUES = [30 0 10 20];
    
    % Find two wide bars and a wide space
	[~, barIndices] = maxk(bars, 2);
	[~, spaceIndex] = max(spaces);
	barVal = BAR_VALUES(barIndices(1))+BAR_VALUES(barIndices(2));
	spaceVal = SPACE_VALUES(spaceIndex);
    
	% compute code 39 decimal value with offset to get ascii value
	if spaceVal == 0
		if barVal == 11
			barVal = 0;
		end
		decASCII = barVal+spaceVal+48;
	else
		if barVal == 11
			barVal = 10;
		end
		decASCII = barVal+spaceVal+54;
	end
end
