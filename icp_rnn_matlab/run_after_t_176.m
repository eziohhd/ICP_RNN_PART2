cstr = textread('binary_files\h_t.txt','%s');
m = length(cstr{1});
n = length(cstr);
d = zeros(n,1);
for i=1:n
s = bin2dec( cstr{i}(1) ); % 符号
if s==1
d(i)=bin2dec(cstr{i})-2^m;
else
d(i) = bin2dec( cstr{i} ) ;
end
end
d1=d/64;
plot(d1);
hold on;
ht=data([h_test,h_new]);
plot(ht);


ts=177; %% change for time step 177,178,179,180
%%
h_q_175 = d1(1:128,1);
GRU2_h_prev=d1(129:256,1);
FID1 = fopen('binary_files/h175_binary_new.txt','w+');
FID2 = fopen('binary_files/GRU2_h_prev_binary_new.txt','w+');
% FID2 = fopen('binary_files/h175_binary_2.txt','w+');
% FID3 = fopen('binary_files/h175_binary_3.txt','w+');
% FID4 = fopen('binary_files/h175_binary_4.txt','w+');

% fprintf(FID1,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID1,'MEMORY_INITIALIZATION_VECTOR=\n');
% fprintf(FID2,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID2,'MEMORY_INITIALIZATION_VECTOR=\n');
% fprintf(FID3,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID3,'MEMORY_INITIALIZATION_VECTOR=\n');
% fprintf(FID4,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID4,'MEMORY_INITIALIZATION_VECTOR=\n');

wl_175 = 16;
noffbits = 13; % number of fractinonal bits 
count128 = 1;
count128_new = 1;

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
 
    for j=1 : 1 : 16
        for i=1 : 1 : 8
           if (GRU2_h_prev(count128_new,1)<0)
               temp = abs(GRU2_h_prev(count128_new,1));
               temp2 = dec2bin(floor(temp*2^noffbits),noffbits);
               temp3 = pad(temp2,wl_175,'left','0');
               temp4 = not(temp3-'0');
               temp5 = num2str(temp4);
               binary_nbit = dec2bin(bin2dec(temp5)+bin2dec('1'));
           elseif (GRU2_h_prev(count128_new,1)==0)
               binary_nbit = ('0000000000000000');
           else
               temp10 = dec2bin(floor(GRU2_h_prev(count128_new,1)*2^noffbits),noffbits);
               binary_nbit = pad(temp10,wl_175,'left','0');
           end
           count128_new = count128_new + 1;
            switch i
                case 1
                    fprintf(FID2,'%s\n',binary_nbit);
                case 2
                    fprintf(FID2,'%s\n',binary_nbit);
                case 3
                    fprintf(FID2,'%s\n',binary_nbit);
                case 4
                    fprintf(FID2,'%s\n',binary_nbit);
                case 5
                    fprintf(FID2,'%s\n',binary_nbit);
                case 6
                    fprintf(FID2,'%s\n',binary_nbit);
                case 7
                    fprintf(FID2,'%s\n',binary_nbit);
                otherwise
                    fprintf(FID2,'%s\n',binary_nbit);
            end
               
        end
    end
fclose('all');
%% Converting input, xt to binary
%xt_f_176 = xt_f(:,177);

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

for k=ts : 1 : ts%change for next time step 177,178,179,180
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


xt_f_177 = xt_d(:,ts); %change for next time step
input_matrix=xt_f_177';
h_prev=data(h_test);
r_u_wghts=[Wr_qf' Wu_qf'];
r_u_bias=[Br_qf' Bu_qf'];
neurons=128;
input = input_matrix;
concat = [input h_prev];
% input layer mac m - multiplier a - accumulate
r_u_layer_m = fi(concat * r_u_wghts,1,24,IFL);
r_u_layer_a = fi(r_u_layer_m + r_u_bias,1,16,6);

sig_value   = fi(sigmoid(single(r_u_layer_a)),1,16,6);
       
% Split the reset and update gate matrices
 r_gate = sig_value(1:neurons);
 u_gate = sig_value(neurons+1:end);
 r_gate_gru1 =       r_gate;
 u_gate_gru1 =       u_gate;
% Reset gate multiplied with previous hidden state
% r_state = fi(r_gate .* h_prev,1,16,6);

% Candidate hidden state
%concat            = [input r_state];
%candidate_layer_m = fi(concat * candidate_wghts,1,24,13);
%candidate_layer_a = fi(candidate_layer_m + candidate_bias',1,16,6);
%tanh_value        = fi(tanh(single(candidate_layer_a)),1,16,6);
candidate_wghts1=Wc2_q';
candidate_wghts2=Wc1_q';
candidate_bias=Bc_q';

candidate_layer_m1=fi(input * candidate_wghts1 + candidate_bias,1,24,IFL);
candidate_layer_m2=fi(h_prev * candidate_wghts2,1,24,IFL);

can_x_gru1=candidate_layer_m1;
can_h_gru1=candidate_layer_m2;

r_state = fi(r_gate .* candidate_layer_m2,1,16,6);
candidate_layer_a = fi(candidate_layer_m1 + r_state ,1,16,6);
can_gru1 = candidate_layer_a;

tanh_value        = fi(tanh(single(candidate_layer_a)),1,16,6);
tanh_value_gru1 =tanh_value;
% Candidate state
h_new  = fi(fi(u_gate .* h_prev,1,24,12) + fi((1 - u_gate) .* tanh_value,1,24,12),1,16,6);
h_prev = h_new;
h_test = h_prev;
 %h_new_bin=dec2bin(round(h_new_f*2^6),6);
 
 %%
input_matrix=data(h_prev);
h_prev=data(h_test2);
r_u_wghts=[GRU2_Wr_qf' GRU2_Wu_qf'];
r_u_bias=[GRU2_Br_qf' GRU2_Bu_qf'];
neurons=128;
input = input_matrix;
concat = [input h_prev];
% input layer mac m - multiplier a - accumulate
r_u_layer_m = fi(concat * r_u_wghts,1,24,IFL);
r_u_layer_a = fi(r_u_layer_m + r_u_bias,1,16,6);

sig_value   = fi(sigmoid(single(r_u_layer_a)),1,16,6);
       
% Split the reset and update gate matrices
 r_gate = sig_value(1:neurons);
 u_gate = sig_value(neurons+1:end);
 r_gate_gru2 =       r_gate;
 u_gate_gru2 =       u_gate;      
% Reset gate multiplied with previous hidden state
% r_state = fi(r_gate .* h_prev,1,16,6);

% Candidate hidden state
%concat            = [input r_state];
%candidate_layer_m = fi(concat * candidate_wghts,1,24,13);
%candidate_layer_a = fi(candidate_layer_m + candidate_bias',1,16,6);
%tanh_value        = fi(tanh(single(candidate_layer_a)),1,16,6);
candidate_wghts1=GRU2_Wc2_q';
candidate_wghts2=GRU2_Wc1_q';
candidate_bias=GRU2_Bc_q';

candidate_layer_m1=fi(input * candidate_wghts1+ candidate_bias,1,24,IFL);
candidate_layer_m2=fi(h_prev * candidate_wghts2,1,24,IFL);

can_x_gru2=candidate_layer_m1;
can_h_gru2=candidate_layer_m2;

r_state = fi(r_gate .* candidate_layer_m2,1,16,6);
candidate_layer_a = fi(candidate_layer_m1 + r_state ,1,16,6);
can_gru2 = candidate_layer_a;

tanh_value        = fi(tanh(single(candidate_layer_a)),1,16,6);
tanh_value_gru2 =tanh_value;
% Candidate state
h_new  = fi(fi(u_gate .* h_prev,1,24,12) + fi((1 - u_gate) .* tanh_value,1,24,12),1,16,6);
h_prev = h_new;
h_test2=h_prev;
 %h_new_bin=dec2bin(round(h_new_f*2^6),6);
 
 %%fc_layer
fc_in = data(h_prev);
%fc_bias = -0.42403632; 
fc_bias = -0.4296875;%after quantilization
FID1 = fopen('gru_input_files/fc_weights.txt','r');
FCWe= fscanf(FID1,'%f');
fclose(FID1);
fc_out = fi(fi(fc_in*FCWe,1,24,IFL) + fc_bias,1,16,6);
fc_out_final = sigmoid(single(fc_out));

% function x = sigmoid(input)
%     x = 1./(1 + exp(-input));
% end
% function x = sigmoid(input)
%     if (input > 2.5)
%         x = 1;
%     elseif(input < (-2.5))
%         x = 0;
%     else
%         x = 0.2*input+0.5;
%     end
% end
function x=sigmoid(input)
 x = 0.*(input<-2.5)+1.*(input>2.5)+(0.2*input+0.5).*(input>=-2.5 & input<=2.5);
end     