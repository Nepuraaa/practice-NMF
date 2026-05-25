clear; close all; clc;

% STFT用の変数を指定
inputFile = "pfcl.wav";
windowShift = 512; % シフト長
windowLength = 1024; % 窓長
windowName = 'hann'; % 窓名
[audioSig, fs] = audioread(inputFile);

% 元の波形をSTFT
F = DGTtool('windowShift',windowShift,'windowLength',windowLength,'windowName',windowName);
spect = F(audioSig);  % 複素スペクトルの取得
theta = angle(spect); % 位相の取得
X = abs(spect); % 振幅スペクトルに変換
I = size(X,1); % I
J = size(X,2); % J
maxRank = 2; %K
W = rand(I, maxRank); % Wを初期化
H = rand(maxRank, J); % Hを初期化
T = 1000; % 反復回数
A = zeros(1,T); % 誤差格納用の行列を予め取得

% Eu-NMFのMMアルゴリズムに基づく反復更新則
for t = 1:T
    W = W .* ((X * H.')./(W * (H * H.'))); % Wの更新
    H = H .* ((W.' * X)./(W.' * W * H)); % Hの更新
    A(1,t) = sum((X - W * H).^2,"all"); % 誤差のプロット用
end

nmfX = W * H; % 推定した振幅スペクトル
compNmfX = nmfX .* exp(1i*theta); % 推定した複素スペクトル
mixSig = F.pinv(compNmfX); % 逆STFT
plot(mixSig); % 波形をプロット

% 分離した信号ごとに分割
sepaSig = zeros(I,J,maxRank);
sepaSound = zeros(size(mixSig,1),2);


%音声信号の分離,音声信号の出力
outputDir = "./output/";

if ~exist(outputDir, 'dir')
    mkdir(outputDir); % ファイルがなければ作る
end

audiowrite(outputDir+"mixSig.wav", mixSig, fs);
for i = 1:maxRank
    sepaSig(:,:,i) = (W(:,i) * H(i,:)).* exp(1i * theta); % 複素スペクトルを取得
    sepaSound(:,i) = F.pinv(sepaSig(:,:,i)); % 逆STFT
    audiowrite(outputDir+"sig" + i + ".wav", sepaSound(:,i), fs); % 音声ファイル出力
end