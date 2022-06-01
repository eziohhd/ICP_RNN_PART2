%% Binary conversion of h_q(175) for initializing of GRU layer 1 to start with input x(176)
load('GRU_Weight_Quantized_WL8_FL7_ht16_hwtanh_Input12.mat');
h_q_175 = data(h_q(:,175));
xt_f_176 = xt_f(:,176);

% FID1 = fopen('memory_files/x176_h175_binary.txt','w+');
% fprintf(FID1,'MEMORY_INITIALIZATION_RADIX=2;\n');
% fprintf(FID1,'MEMORY_INITIALIZATION_VECTOR=\n');
% 
% count256 = 1;
% for j=1 : 1 : 32
%     for i=1 : 1 : 8
%         tmp = xt_f_176(count256);
%         count256 = count256 + 1;
%     
%         if i == 8
%             fprintf(FID1,'%s,\n',tmp.bin);
%         else
%             fprintf(FID1,'%s',tmp.bin);
%         end        
%     end
% end
% 
% count128 = 1;
% for j=1 : 1 : 16
%     for i=1 : 1 : 8
%         tmp = h_q_175(count128);
%         count128 = count128 + 1;
% 
%         if i == 8
%             fprintf(FID1,'%s,\n',tmp.bin);
%         else
%             fprintf(FID1,'%s',tmp.bin);
%         end        
%     end
% end
% 
% 
% fclose('all');
%%

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

