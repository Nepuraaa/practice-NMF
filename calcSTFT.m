function S = calcSTFT(audioSig, fs, windowLength, shiftLength, windowType, drawSpect)
% STFTの一連の動作を行う関数
%
% [syntax]
% S = calcSTFT(audioSig, fs, windowLength, shiftLength, windowType, drawSpect)
%
% [inputs]
% audiosig, 音声信号の振幅 (信号長×1)
% fs, サンプリング周波数 (スカラー)
% windowLength, 窓長 (スカラー)
% shiftLength, シフト長 (スカラー)
% windowType, 窓関数の種類 (string)
% drawSpect, スペクトログラムの表示を切り替え (true or false, trueで表示，falseで非表示)
% [output]
% S, 対数振幅スペクトル (信号長×1)


signalLength = length(audioSig);
% 零詰め
paddedSig = [zeros(windowLength / 2, 1) ; audioSig ; zeros(windowLength - 1, 1)];
numFlames = ceil((windowLength / 2 + signalLength) / shiftLength); % 分割数
A = zeros(windowLength,numFlames);

% 音声信号の分割
for i = 1 : numFlames
    startIndex = 1 + (i-1) * shiftLength;
    endIndex = startIndex + windowLength - 1;
    A(:,i) = paddedSig(startIndex : endIndex);    
end

% スイッチ文でwindowType別に窓を用意
switch windowType
    case "rec" % 方形窓
        win = rectwin(windowLength);
    case "hann" % ハン窓
        win = hann(windowLength);
    case "hamming" % ハミング窓
        win = hamming(windowLength);
    case "blackman" % ブラックマン窓
        win = blackman(windowLength);
    otherwise 
        error("窓関数の文字列を見直してください！");
end

winA = win .* A; % 暗黙的拡張で計算

% fft
spect = fft(winA);
ampSpect = abs(spect);
S = 20 * log10(ampSpect); % 利得[db]に変換

% パワースペクトログラムの表示(drawSpectがtrueで表示)
if drawSpect == true
    freqAxis = linspace(0, fs, windowLength); % 縦軸(周波数)取得
    timeAxis = linspace(0, signalLength/fs, numFlames); % 横軸(時間)取得
    imagesc (timeAxis, freqAxis, S); % グラフ表示
    axis xy; % y軸を上下反転
    c = colorbar;
    c.Label.String = ("利得[db]");
    xlabel("時間[s]");
    ylabel("周波数[Hz]")
    ylim([0, fs/2]);
else
end

end
