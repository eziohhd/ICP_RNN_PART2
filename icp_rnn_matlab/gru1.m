
input_matrix=xt_f_176';
h_prev=h_q_175';
r_u_wghts=[Wr_q' Wu_q'];
r_u_bias=[Br_q' Bu_q'];
neurons=128;
input = input_matrix;
concat = [input h_prev];
% input layer mac m - multiplier a - accumulate
r_u_layer_m = fi(concat * r_u_wghts,1,24,13);
r_u_layer_a = fi(r_u_layer_m + r_u_bias,1,16,6);

sig_value   = fi(sigmoid(single(r_u_layer_a)),1,16,6);
       
% Split the reset and update gate matrices
 r_gate = sig_value(1:neurons);
 u_gate = sig_value(neurons+1:end);
       
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

candidate_layer_m1=fi(input * candidate_wghts1,1,24,13);
candidate_layer_m2=fi(h_prev * candidate_wghts2,1,24,13);
r_state = fi(r_gate .* candidate_layer_m2,1,16,6);
candidate_layer_a = fi(candidate_layer_m1 + r_state + candidate_bias,1,16,6);
tanh_value        = fi(tanh(single(candidate_layer_a)),1,16,6);

% Candidate state
h_new  = fi(fi(u_gate .* h_prev,1,24,12) + fi((1 - u_gate) .* tanh_value,1,24,12),1,16,6);
h_prev = h_new;
h_test = h_prev;
 %h_new_bin=dec2bin(round(h_new_f*2^6),6);

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
        