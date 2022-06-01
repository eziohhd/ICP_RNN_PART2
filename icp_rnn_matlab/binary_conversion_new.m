%% Behavioral model for hardware implementation of GRU and Batch nomalization
% Size of model
%seq_length = 1;%375;
load('GRU_Weight_Quantized_WL8_FL7_ht16_hwtanh_Input12.mat');
n_recurrent = 128;
% GRU 1
n_input_x = 256;
size_hor = n_recurrent + n_input_x; % Size of input matix, horizontal
% GRU 2
GRU2_n_input_x = 128;
GRU2_size_hor = n_recurrent + GRU2_n_input_x;

s=1;
wl=16;
fl=13;

F = fimath('ProductMode','SpecifyPrecision','ProductWordLength',wl,'ProductFractionLength',fl,...
    'SumMode','SpecifyPrecision','SumWordLength',wl,'SumFractionLength',fl,...
    'RoundingMethod','Floor','OverflowAction','Saturate');

%% Loading input x(t) from file, Keras model
xt_org = csvread ('activation_out.csv');

for A=1:256
    for B=1:1375
        xt(A,B) = xt_org(B,A);
    end
end

% Input x(t) - Fixed point conversion
wl_xt=16;
fl_xt=13;
xt_f = fi(xt,s,wl_xt,fl_xt,F);
xt_d = data(xt_f);

%% Plotting of input
plot(xt_f(:,:))


%% Converting input, xt to binary
FID1 = fopen('binary_files/xt_binary_new.txt','w+');
% FID2 = fopen('binary_files/xt_binary_2.txt','w+');
% FID3 = fopen('binary_files/xt_binary_3.txt','w+');
% FID4 = fopen('binary_files/xt_binary_4.txt','w+');
% 
% fprintf(FID1,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID1,'MEMORY_INITIALIZATION_VECTOR=\n');
% 
% fprintf(FID2,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID2,'MEMORY_INITIALIZATION_VECTOR=\n');
% 
% fprintf(FID3,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID3,'MEMORY_INITIALIZATION_VECTOR=\n');
% 
% fprintf(FID4,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID4,'MEMORY_INITIALIZATION_VECTOR=\n');

noffbits = 13; % number of fractinonal bits

for k=176 : 1 : 176
    count256 = 1;
    for j=1 : 1 : 32
        for i=1 : 1 : 8
           if (xt_d(count256,k)==0)
               binary_nbit = ('0000000000000000');
           else
               temp10 = dec2bin(round(xt_d(count256,k)*2^noffbits),noffbits);
               binary_nbit = pad(temp10,wl_xt,'left','0');
           end

           count256 = count256 + 1;
           disp(binary_nbit)
           switch i
                case 1
                    fprintf(FID1,'%s\n',binary_nbit);
                case 2
                    fprintf(FID1,'%s\n',binary_nbit);
                case 3
                    fprintf(FID1,'%s\n',binary_nbit);
                case 4
                    fprintf(FID1,'%s\n',binary_nbit);
                case 5
                    fprintf(FID1,'%s\n',binary_nbit);
                case 6
                    fprintf(FID1,'%s\n',binary_nbit);
                case 7
                    fprintf(FID1,'%s\n',binary_nbit);
                otherwise
                    fprintf(FID1,'%s\n',binary_nbit);
            end        
        end       
       
    end
end
fclose('all');
%% Loading GRU 1 weights and biases from files, Keras model
gru1_weights = hdf5read('tr_model.h5','/model_weights/gru_5/gru_5/kernel:0');
gru1_weights_recurrent = hdf5read('tr_model.h5','/model_weights/gru_5/gru_5/recurrent_kernel:0');
gru1_bias = hdf5read('tr_model.h5','/model_weights/gru_5/gru_5/bias:0');

wlf = 32;
flf = 31;
wlq = 8;
flq = 7;

% Weights
Wu1 = gru1_weights_recurrent([1:128],:);%uu
Wu2 = gru1_weights([1:128],:);%wu
Wu = [Wu2 Wu1];
Wu_f = fi(Wu,s,wlf,flf,F);
Wu_q = quantize(Wu_f,s,wlq,flq);
Wu_qf = data(Wu_q);

Wr1 = gru1_weights_recurrent([129:256],:);
Wr2 = gru1_weights([129:256],:);
Wr = [Wr2 Wr1];
Wr_f = fi(Wr,s,wlf,flf,F);
Wr_q = quantize(Wr_f,s,wlq,flq);
Wr_qf = data(Wr_q);

Wc1 = gru1_weights_recurrent([257:384],:);
Wc2 = gru1_weights([257:384],:);
Wc = [Wc2 Wc1];
Wc_f = fi(Wc,s,wlf,flf,F);
Wc_q = quantize(Wc_f,s,wlq,flq);
Wc_qf = data(Wc_q);

% Biases
FID1 = fopen('gru_input_files/Bu.txt','r');
But=fscanf(FID1,'%f');
fclose(FID1);
for M=1:n_recurrent
    Bu(M,1) = But(M,1);
end
Bu_f = fi(Bu,s,wlf,flf,F);
Bu_q = quantize(Bu_f,s,wlq,flq);
Bu_qf = data(Bu_q);

FID1 = fopen('gru_input_files/Br.txt','r');
Brt=fscanf(FID1,'%f');
fclose(FID1);
for M=1:n_recurrent
    Br(M,1) = Brt(M,1);
end
Br_f = fi(Br,s,wlf,flf,F);
Br_q = quantize(Br_f,s,wlq,flq);
Br_qf = data(Br_q);

FID1 = fopen('gru_input_files/Bc.txt','r');
Bct=fscanf(FID1,'%f');
fclose(FID1);
for M=1:n_recurrent
    Bc(M,1) = Bct(M,1);
end
Bc_f = fi(Bc,s,wlf,flf,F);
Bc_q = quantize(Bc_f,s,wlq,flq);
Bc_qf = data(Bc_q);

%% Converting GRU 1 weights to binary
noffbits = 7; % number of fractinonal bits

% Wu weights
FID1 = fopen('binary_files/Wu_binary_new.txt','w+');
% FID2 = fopen('binary_files/Wu_binary_2.txt','w+');

% fprintf(FID1,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID1,'MEMORY_INITIALIZATION_VECTOR=\n');
% 
% fprintf(FID2,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID2,'MEMORY_INITIALIZATION_VECTOR=\n');

for j=1 : 1 : 128
    count384 = 1;
    for k=1 : 1 : 48
        for i=1 : 1 : 8      
           if (Wu_qf(j,count384)<0)
               temp = abs(Wu_qf(j,count384));
               temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
               temp3 = pad(temp2,wlq,'left','0');
               temp4 = not(temp3-'0');
               temp5 = num2str(temp4);
               binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           elseif (Wu_qf(j,count384)==0)
               binary_nbit = ('00000000');
           else
               temp10 = dec2bin(floor(Wu_qf(j,count384)*2^noffbits),noffbits);
               binary_nbit = pad(temp10,wlq,'left','0');
            end
            count384 = count384+1;

            switch i
                case 1
                    fprintf(FID1,'%s',binary_nbit);
                case 2
                    fprintf(FID1,'%s\n',binary_nbit);
                case 3
                    fprintf(FID1,'%s',binary_nbit);
                case 4
                    fprintf(FID1,'%s\n',binary_nbit);
                case 5
                    fprintf(FID1,'%s',binary_nbit);
                case 6
                    fprintf(FID1,'%s\n',binary_nbit);
                case 7
                    fprintf(FID1,'%s',binary_nbit);
                otherwise
                    fprintf(FID1,'%s\n',binary_nbit);
            end  
        end
    end
    
end
fclose('all');

% Wr weights
FID1 = fopen('binary_files/Wr_binary_new.txt','w+');
% FID2 = fopen('binary_files/Wr_binary_2.txt','w+');

for j=1 : 1 : 128
    count384 = 1;
    for k=1 : 1 : 48
        for i=1 : 1 : 8      
            if (Wr_qf(j,count384)<0)
               temp = abs(Wr_qf(j,count384));
               temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
               temp3 = pad(temp2,wlq,'left','0');
               temp4 = not(temp3-'0');
               temp5 = num2str(temp4);
               binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           elseif (Wr_qf(j,count384)==0)
               binary_nbit = ('00000000');
           else
               temp10 = dec2bin(floor(Wr_qf(j,count384)*2^noffbits),noffbits);
               binary_nbit = pad(temp10,wlq,'left','0');
            end
            count384 = count384+1;
            
            switch i
                case 1
                    fprintf(FID1,'%s',binary_nbit);
                case 2
                    fprintf(FID1,'%s\n',binary_nbit);
                case 3
                    fprintf(FID1,'%s',binary_nbit);
                case 4
                    fprintf(FID1,'%s\n',binary_nbit);
                case 5
                    fprintf(FID1,'%s',binary_nbit);
                case 6
                    fprintf(FID1,'%s\n',binary_nbit);
                case 7
                    fprintf(FID1,'%s',binary_nbit);
                otherwise
                    fprintf(FID1,'%s\n',binary_nbit);
            end  
        end
    end
    
end
fclose('all');

%% Wc weights
FID1 = fopen('binary_files/Wc_binary_new.txt','w+');
% FID2 = fopen('binary_files/Wc_binary_2.txt','w+');
for j=1 : 1 : 128
    count384 = 1;
    for k=1 : 1 : 48
        for i=1 : 1 : 8      
            if (Wc_qf(j,count384)<0)
               temp = abs(Wc_qf(j,count384));
               temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
               temp3 = pad(temp2,wlq,'left','0');
               temp4 = not(temp3-'0');
               temp5 = num2str(temp4);
               binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           elseif (Wc_qf(j,count384)==0)
               binary_nbit = ('00000000');
           else
               temp10 = dec2bin(floor(Wc_qf(j,count384)*2^noffbits),noffbits);
               binary_nbit = pad(temp10,wlq,'left','0');
           end
           count384 = count384+1;

            switch i
                case 1
                    fprintf(FID1,'%s',binary_nbit);
                case 2
                    fprintf(FID1,'%s\n',binary_nbit);
                case 3
                    fprintf(FID1,'%s',binary_nbit);
                case 4
                    fprintf(FID1,'%s\n',binary_nbit);
                case 5
                    fprintf(FID1,'%s',binary_nbit);
                case 6
                    fprintf(FID1,'%s\n',binary_nbit);
                case 7
                    fprintf(FID1,'%s',binary_nbit);
                otherwise
                    fprintf(FID1,'%s\n',binary_nbit);
            end  
        end
    end
    
end
fclose('all');

%% Converting biases to binary
% Bu & Br biases
FID = fopen('binary_files/BuBr_binary_new.txt','w+');
% fprintf(FID,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID,'MEMORY_INITIALIZATION_VECTOR=\n');

noffbits = 7; % number of fractinonal bits 
    for i=1 : 1 : 128
       if (Bu_qf(i,1)<0)
           temp = abs(Bu_qf(i,1));
           temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
           temp3 = pad(temp2,wlq,'left','0');
           temp4 = not(temp3-'0');
           temp5 = num2str(temp4);
           binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           fprintf(FID,'%s',binary_nbit);
       elseif (Bu_qf(i,1)==0)
           fprintf(FID,'00000000');
       else
           temp10 = dec2bin(floor(Bu_qf(i,1)*2^noffbits),noffbits);
           binary_nbit = pad(temp10,wlq,'left','0');
           fprintf(FID,'%s',binary_nbit);
       end

       if (Br_qf(i,1)<0)
           temp = abs(Br_qf(i,1));
           temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
           temp3 = pad(temp2,wlq,'left','0');
           temp4 = not(temp3-'0');
           temp5 = num2str(temp4);
           binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           fprintf(FID,'%s',binary_nbit);
       elseif (Br_qf(i,1)==0)
           fprintf(FID,'00000000');
       else
           temp10 = dec2bin(floor(Br_qf(i,1)*2^noffbits),noffbits);
           binary_nbit = pad(temp10,wlq,'left','0');
           fprintf(FID,'%s',binary_nbit);
       end
       
       fprintf(FID,'\n');
       
    end
fclose(FID);

%% Bc biases
FID = fopen('binary_files/Bc_binary_new.txt','w+');
% fprintf(FID,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID,'MEMORY_INITIALIZATION_VECTOR=\n');

noffbits = 7; % number of fractinonal bits 
    for i=1 : 1 : 128
       if (Bc_qf(i,1)<0)
           temp = abs(Bc(i,1));
           temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
           temp3 = pad(temp2,wlq,'left','0');
           temp4 = not(temp3-'0');
           temp5 = num2str(temp4);
           binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           fprintf(FID,'%s',binary_nbit);
       elseif (Bc_qf(i,1)==0)
           fprintf(FID,'00000000');
       else
           temp10 = dec2bin(floor(Bc_qf(i,1)*2^noffbits),noffbits);
           binary_nbit = pad(temp10,wlq,'left','0');
           fprintf(FID,'%s',binary_nbit);
       end   
       fprintf(FID,'00000000\n');
    end
fclose(FID);

%% Loading GRU 2 weights and biases from files, Keras model
gru2_weights = hdf5read('tr_model.h5','/model_weights/gru_6/gru_6/kernel:0');
gru2_weights_recurrent = hdf5read('tr_model.h5','/model_weights/gru_6/gru_6/recurrent_kernel:0');
gru2_bias = hdf5read('tr_model.h5','/model_weights/gru_6/gru_6/bias:0');

wlf = 32;
flf = 31;
wlq = 8;
flq = 7;

GRU2_Wu1 = gru2_weights_recurrent([1:128],:);
GRU2_Wu2 = gru2_weights([1:128],:);
GRU2_Wu = [GRU2_Wu2 GRU2_Wu1];
GRU2_Wu_f = fi(GRU2_Wu,s,wlf,flf,F);
GRU2_Wu_q = quantize(GRU2_Wu_f,s,wlq,flq);
GRU2_Wu_qf = data(GRU2_Wu_q);

GRU2_Wr1 = gru2_weights_recurrent([129:256],:);
GRU2_Wr2 = gru2_weights([129:256],:);
GRU2_Wr = [GRU2_Wr2 GRU2_Wr1];
GRU2_Wr_f = fi(GRU2_Wr,s,wlf,flf,F);
GRU2_Wr_q = quantize(GRU2_Wr_f,s,wlq,flq);
GRU2_Wr_qf = data(GRU2_Wr_q);

GRU2_Wc1 = gru2_weights_recurrent([257:384],:);
GRU2_Wc2 = gru2_weights([257:384],:);
GRU2_Wc = [GRU2_Wc2 GRU2_Wc1];
GRU2_Wc_f = fi(GRU2_Wc,s,wlf,flf,F);
GRU2_Wc_q = quantize(GRU2_Wc_f,s,wlq,flq);
GRU2_Wc_qf = data(GRU2_Wc_q);

FID1 = fopen('gru_input_files/GRU2_Bu.txt','r');
GRU2_But=fscanf(FID1,'%f');
fclose(FID1);
for M=1:n_recurrent
    GRU2_Bu(M,1) = GRU2_But(M,1);
end
GRU2_Bu_f = fi(GRU2_Bu,s,wlf,flf,F);
GRU2_Bu_q = quantize(GRU2_Bu_f,s,wlq,flq);
GRU2_Bu_qf = data(GRU2_Bu_q);

FID1 = fopen('gru_input_files/GRU2_Br.txt','r');
GRU2_Brt=fscanf(FID1,'%f');
fclose(FID1);
for M=1:n_recurrent
    GRU2_Br(M,1) = GRU2_Brt(M,1);
end
GRU2_Br_f = fi(GRU2_Br,s,wlf,flf,F);
GRU2_Br_q = quantize(GRU2_Br_f,s,wlq,flq);
GRU2_Br_qf = data(GRU2_Br_q);

FID1 = fopen('gru_input_files/GRU2_Bc.txt','r');
GRU2_Bct=fscanf(FID1,'%f');
fclose(FID1);
for M=1:n_recurrent
    GRU2_Bc(M,1) = GRU2_Bct(M,1);
end
GRU2_Bc_f = fi(GRU2_Bc,s,wlf,flf,F);
GRU2_Bc_q = quantize(GRU2_Bc_f,s,wlq,flq);
GRU2_Bc_qf = data(GRU2_Bc_q);

FID1 = fopen('gru_input_files/fc_weights.txt','r');
FC_Wt=fscanf(FID1,'%f');
fclose(FID1);
for M=1:n_recurrent
    FC_W(M,1) = FC_Wt(M,1);
end
FC_W_f = fi(FC_W,s,wlf,flf,F);
FC_W_q = quantize(FC_W_f,s,wlq,flq);
FC_W_qf = data(FC_W_q);

%% Converting GRU 2 weights to binary
noffbits = 7; % number of fractinonal bits

% Wu weights
FID1 = fopen('binary_files/GRU2_Wu_binary_new.txt','w+');
% FID2 = fopen('binary_files/GRU2_Wu_binary_2.txt','w+');
% 
% fprintf(FID1,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID1,'MEMORY_INITIALIZATION_VECTOR=\n');
% 
% fprintf(FID2,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID2,'MEMORY_INITIALIZATION_VECTOR=\n');

for j=1 : 1 : 128
    count256 = 1;
    for k=1 : 1 : 32
        for i=1 : 1 : 8      
           if (GRU2_Wu_qf(j,count256)<0)
               temp = abs(GRU2_Wu_qf(j,count256));
               temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
               temp3 = pad(temp2,wlq,'left','0');
               temp4 = not(temp3-'0');
               temp5 = num2str(temp4);
               binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           elseif (GRU2_Wu_qf(j,count256)==0)
               binary_nbit = ('00000000');
           else
               temp10 = dec2bin(floor(GRU2_Wu_qf(j,count256)*2^noffbits),noffbits);
               binary_nbit = pad(temp10,wlq,'left','0');
            end
            count256 = count256+1;

            switch i
                case 1
                    fprintf(FID1,'%s',binary_nbit);
                case 2
                    fprintf(FID1,'%s\n',binary_nbit);
                case 3
                    fprintf(FID1,'%s',binary_nbit);
                case 4
                    fprintf(FID1,'%s\n',binary_nbit);
                case 5
                    fprintf(FID1,'%s',binary_nbit);
                case 6
                    fprintf(FID1,'%s\n',binary_nbit);
                case 7
                    fprintf(FID1,'%s',binary_nbit);
                otherwise
                    fprintf(FID1,'%s\n',binary_nbit);
            end  
        end
    end
    
end
fclose('all');

% Wr weights
FID1 = fopen('binary_files/GRU2_Wr_binary_new.txt','w+');
% FID2 = fopen('binary_files/GRU2_Wr_binary_2.txt','w+');
% 
% fprintf(FID1,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID1,'MEMORY_INITIALIZATION_VECTOR=\n');
% 
% fprintf(FID2,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID2,'MEMORY_INITIALIZATION_VECTOR=\n');

for j=1 : 1 : 128
    count256 = 1;
    for k=1 : 1 : 32
        for i=1 : 1 : 8      
            if (GRU2_Wr_qf(j,count256)<0)
               temp = abs(GRU2_Wr_qf(j,count256));
               temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
               temp3 = pad(temp2,wlq,'left','0');
               temp4 = not(temp3-'0');
               temp5 = num2str(temp4);
               binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           elseif (GRU2_Wr_qf(j,count256)==0)
               binary_nbit = ('00000000');
           else
               temp10 = dec2bin(floor(GRU2_Wr_qf(j,count256)*2^noffbits),noffbits);
               binary_nbit = pad(temp10,wlq,'left','0');
            end
            count256 = count256+1;
            
            switch i
                case 1
                    fprintf(FID1,'%s',binary_nbit);
                case 2
                    fprintf(FID1,'%s\n',binary_nbit);
                case 3
                    fprintf(FID1,'%s',binary_nbit);
                case 4
                    fprintf(FID1,'%s\n',binary_nbit);
                case 5
                    fprintf(FID1,'%s',binary_nbit);
                case 6
                    fprintf(FID1,'%s\n',binary_nbit);
                case 7
                    fprintf(FID1,'%s',binary_nbit);
                otherwise
                    fprintf(FID1,'%s\n',binary_nbit);
            end  
        end
    end
    
end
fclose('all');

% Wc weights
FID1 = fopen('binary_files/GRU2_Wc_binary_new.txt','w+');
% FID2 = fopen('binary_files/GRU2_Wc_binary_2.txt','w+');
% 
% fprintf(FID1,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID1,'MEMORY_INITIALIZATION_VECTOR=\n');
% 
% fprintf(FID2,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID2,'MEMORY_INITIALIZATION_VECTOR=\n');

for j=1 : 1 : 128
    count256 = 1;
    for k=1 : 1 : 32
        for i=1 : 1 : 8      
            if (GRU2_Wc_qf(j,count256)<0)
               temp = abs(GRU2_Wc_qf(j,count256));
               temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
               temp3 = pad(temp2,wlq,'left','0');
               temp4 = not(temp3-'0');
               temp5 = num2str(temp4);
               binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           elseif (GRU2_Wc_qf(j,count256)==0)
               binary_nbit = ('00000000');
           else
               temp10 = dec2bin(floor(GRU2_Wc_qf(j,count256)*2^noffbits),noffbits);
               binary_nbit = pad(temp10,wlq,'left','0');
           end
           count256 = count256+1;

            switch i
                case 1
                    fprintf(FID1,'%s',binary_nbit);
                case 2
                    fprintf(FID1,'%s\n',binary_nbit);
                case 3
                    fprintf(FID1,'%s',binary_nbit);
                case 4
                    fprintf(FID1,'%s\n',binary_nbit);
                case 5
                    fprintf(FID1,'%s',binary_nbit);
                case 6
                    fprintf(FID1,'%s\n',binary_nbit);
                case 7
                    fprintf(FID1,'%s',binary_nbit);
                otherwise
                    fprintf(FID1,'%s\n',binary_nbit);
            end  
        end
    end
    
end
fclose('all');

%% Converting GRU 2 biases to binary
% Bu & Br biases
FID = fopen('binary_files/GRU2_BuBr_binary_new.txt','w+');
% fprintf(FID,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID,'MEMORY_INITIALIZATION_VECTOR=\n');

noffbits = 7; % number of fractinonal bits 
    for i=1 : 1 : 128
       if (GRU2_Bu_qf(i,1)<0)
           temp = abs(GRU2_Bu_qf(i,1));
           temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
           temp3 = pad(temp2,wlq,'left','0');
           temp4 = not(temp3-'0');
           temp5 = num2str(temp4);
           binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           fprintf(FID,'%s',binary_nbit);
       elseif (GRU2_Bu_qf(i,1)==0)
           fprintf(FID,'00000000');
       else
           temp10 = dec2bin(floor(GRU2_Bu_qf(i,1)*2^noffbits),noffbits);
           binary_nbit = pad(temp10,wlq,'left','0');
           fprintf(FID,'%s',binary_nbit);
       end

       if (GRU2_Br_qf(i,1)<0)
           temp = abs(GRU2_Br_qf(i,1));
           temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
           temp3 = pad(temp2,wlq,'left','0');
           temp4 = not(temp3-'0');
           temp5 = num2str(temp4);
           binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           fprintf(FID,'%s',binary_nbit);
       elseif (GRU2_Br_qf(i,1)==0)
           fprintf(FID,'00000000');
       else
           temp10 = dec2bin(floor(GRU2_Br_qf(i,1)*2^noffbits),noffbits);
           binary_nbit = pad(temp10,wlq,'left','0');
           fprintf(FID,'%s',binary_nbit);
       end
       fprintf(FID,'\n');
       
    end
fclose(FID);

%% Bc biases
FID = fopen('binary_files/GRU2_Bc_binary_new.txt','w+');
% fprintf(FID,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID,'MEMORY_INITIALIZATION_VECTOR=\n');

noffbits = 7; % number of fractinonal bits 
    for i=1 : 1 : 128
       if (GRU2_Bc_qf(i,1)<0)
           temp = abs(GRU2_Bc_qf(i,1));
           temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
           temp3 = pad(temp2,wlq,'left','0');
           temp4 = not(temp3-'0');
           temp5 = num2str(temp4);
           binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           fprintf(FID,'%s',binary_nbit);
       elseif (GRU2_Bc_qf(i,1)==0)
           fprintf(FID,'00000000');
       else
           temp10 = dec2bin(floor(GRU2_Bc_qf(i,1)*2^noffbits),noffbits);
           binary_nbit = pad(temp10,wlq,'left','0');
           fprintf(FID,'%s',binary_nbit);
       end  
           fprintf(FID,'00000000\n');
    end
fclose(FID);

%%FC_weights
FID1 = fopen('binary_files/fc_weights_new.txt','w+');

noffbits = 7; % number of fractinonal bits
count128 = 1;
    for k=1 : 1 : 16
        for i=1 : 1 : 8      
           if (FC_W_qf(count128,1)<0)
               temp = abs(FC_W_qf(count128,1));
               temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
               temp3 = pad(temp2,wlq,'left','0');
               temp4 = not(temp3-'0');
               temp5 = num2str(temp4);
               binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           elseif (FC_W_qf(count128,1)==0)
               binary_nbit = ('00000000');
           else
               temp10 = dec2bin(floor(FC_W_qf(count128,1)*2^noffbits),noffbits);
               binary_nbit = pad(temp10,wlq,'left','0');
            end
            count128 = count128+1;

            switch i
                case 1
                    fprintf(FID1,'%s',binary_nbit);
                case 2
                    fprintf(FID1,'%s\n',binary_nbit);
                case 3
                    fprintf(FID1,'%s',binary_nbit);
                case 4
                    fprintf(FID1,'%s\n',binary_nbit);
                case 5
                    fprintf(FID1,'%s',binary_nbit);
                case 6
                    fprintf(FID1,'%s\n',binary_nbit);
                case 7
                    fprintf(FID1,'%s',binary_nbit);
                otherwise
                    fprintf(FID1,'%s\n',binary_nbit);
            end  
        end
    end
    
fclose('all');

%%FC_BIAS
fc_bias = -0.42403632;
fc_bias_f = fi(fc_bias,s,wlf,flf,F);
fc_bias_q = quantize(fc_bias_f,s,wlq,flq);
fc_bias_qf = data(fc_bias_q);
temp = abs(fc_bias_qf);
temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
temp3 = pad(temp2,wlq,'left','0');
temp4 = not(temp3-'0');
temp5 = num2str(temp4);
binary_bias = dec2bin(bin2dec(temp5)+bin2dec('1'));

%% Binary conversion of h_q(175) for initializing of GRU layer 1 to start with input x(176)
h_q_175 = h_q(:,175);
h_q_176 = h_q(:,176);
xt_f_176 = xt_f(:,176);

FID1 = fopen('memory_files/x176_h175_binary.txt','w+');
fprintf(FID1,'MEMORY_INITIALIZATION_RADIX=2;\n');
fprintf(FID1,'MEMORY_INITIALIZATION_VECTOR=\n');

count256 = 1;
for j=1 : 1 : 32
    for i=1 : 1 : 8
        tmp = xt_f_176(count256);
        count256 = count256 + 1;
    
        if i == 8
            fprintf(FID1,'%s,\n',tmp.bin);
        else
            fprintf(FID1,'%s',tmp.bin);
        end        
    end
end

count128 = 1;
for j=1 : 1 : 16
    for i=1 : 1 : 8
        tmp = h_q_175(count128);
        count128 = count128 + 1;

        if i == 8
            fprintf(FID1,'%s,\n',tmp.bin);
        else
            fprintf(FID1,'%s',tmp.bin);
        end        
    end
end


fclose('all');
%%
FID1 = fopen('binary_files/h175_binary_1.txt','w+');
FID2 = fopen('binary_files/h175_binary_2.txt','w+');
FID3 = fopen('binary_files/h175_binary_3.txt','w+');
FID4 = fopen('binary_files/h175_binary_4.txt','w+');

fprintf(FID1,'MEMORY_INITIALIZATION_RADIX=2;\n');
fprintf(FID1,'MEMORY_INITIALIZATION_VECTOR=\n');
fprintf(FID2,'MEMORY_INITIALIZATION_RADIX=2;\n');
fprintf(FID2,'MEMORY_INITIALIZATION_VECTOR=\n');
fprintf(FID3,'MEMORY_INITIALIZATION_RADIX=2;\n');
fprintf(FID3,'MEMORY_INITIALIZATION_VECTOR=\n');
fprintf(FID4,'MEMORY_INITIALIZATION_RADIX=2;\n');
fprintf(FID4,'MEMORY_INITIALIZATION_VECTOR=\n');

wl_175 = 16;
noffbits = 13; % number of fractinonal bits 
count128 = 1;

    for j=1 : 1 : 16
        for i=1 : 1 : 8
           if (h_q_175(count128,1)<0)
               temp = abs(h_q_175(count128,1));
               temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
               temp3 = pad(temp2,wl_175,'left','0');
               temp4 = not(temp3-'0');
               temp5 = num2str(temp4);
               binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           elseif (h_q_175(count128,1)==0)
               binary_nbit = ('0000000000000000');
           else
               temp10 = dec2bin(floor(h_q_175(count128,1)*2^noffbits),noffbits);
               binary_nbit = pad(temp10,wl_175,'left','0');
           end
           count128 = count128 + 1;
            switch i
                case 1
                    fprintf(FID1,'%s',binary_nbit);
                case 2
                    if count128 > 120
                        fprintf(FID1,'%s;',binary_nbit);
                    else
                        fprintf(FID1,'%s,\n',binary_nbit);
                    end
                case 3
                    fprintf(FID2,'%s',binary_nbit);
                case 4
                    if count128 > 122
                        fprintf(FID2,'%s;',binary_nbit);
                    else
                        fprintf(FID2,'%s,\n',binary_nbit);
                    end
                case 5
                    fprintf(FID3,'%s',binary_nbit);
                case 6
                    if count128 > 124
                        fprintf(FID3,'%s;',binary_nbit);
                    else
                        fprintf(FID3,'%s,\n',binary_nbit);
                    end
                case 7
                    fprintf(FID4,'%s',binary_nbit);
                otherwise
                    if count128 > 126
                        fprintf(FID4,'%s;',binary_nbit);
                    else
                        fprintf(FID4,'%s,\n',binary_nbit);
                    end
            end
               
        end
    end
fclose('all');
