%% FC layer

fc_bias = -0.42403632; % from Keras model
gru2_out = h_prev';
seq_length = 1;
% Loading FC weights

FID1 = fopen('gru_input_files/fc_weights.txt','r');

FCWe= fscanf(FID1,'%f');

fclose(FID1);

fc_out = zeros(1,seq_length);

 

for B=1:seq_length

    fc = 0;

    for A=1:n_recurrent

        fc = gru2_out(A,1) * FCWe(A) + fc;

    end

    fc_out(1,B) = fc + fc_bias;

end

fc_out_final = logsig(fc_out);