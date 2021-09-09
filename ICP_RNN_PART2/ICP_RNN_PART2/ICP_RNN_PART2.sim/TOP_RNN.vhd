library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP_RNN is
port(
      clk                     : in std_logic;--top pad
      reset                   : in std_logic;--top pad
      initial                 : in std_logic;--top pad
      start                   : in std_logic;--top pad
      data_in                 : in std_logic_vector(15 downto 0);--top pad
      input_write_en_wu       : out std_logic; --top pad
      input_write_en_wr       : out std_logic; --top pad
      input_write_en_wc       : out std_logic; --top pad
      input_write_en_bubr     : out std_logic; --top pad
      input_write_en_bc       : out std_logic; --top pad
      input_write_en_xt       : out std_logic; --top pad
      input_write_en_hprev    : out std_logic; --top pad    
      input_write_en_gru2_wu  : out std_logic; --top pad
      input_write_en_gru2_wr  : out std_logic; --top pad
      input_write_en_gru2_wc  : out std_logic; --top pad
      input_write_en_gru2_bubr: out std_logic; --top pad
      input_write_en_gru2_bc  : out std_logic; --top pad   
      input_write_en_gru2_hprev: out std_logic; --top pad     
      input_write_en_fc_weights: out std_logic;--top pad 
      data_out                : out std_logic_vector(15 downto 0)--top pad 
      );
end TOP_RNN;

architecture Behavioral of TOP_RNN is

component Mem_initial is
    Port (
        clk                     : in std_logic;--top pad
        reset                   : in std_logic;--top pad
        initial                 : in std_logic;--top pad
        start                   : in std_logic;--top pad
        r_u_valid               : in std_logic;
        xt_state                : in std_logic;
        hprev_state             : in std_logic;
        xt_state_gru2           : in std_logic;
        hprev_state_gru2        : in std_logic;
        data_in                 : in std_logic_vector(15 downto 0);--top pad
        ht_in                   : in std_logic_vector(15 downto 0);
        addr_input_in           : in std_logic_vector(6 downto 0);                  
        addr_w_u_in             : in std_logic_vector(12 downto 0);--13 bit:6144
        addr_bias_in            : in std_logic_vector(6 downto 0); --128                                         
        addr_hprev_in           : in std_logic_vector(6 downto 0);    
        addr_input_in_gru2      : in std_logic_vector(6 downto 0);                  
        addr_w_u_in_gru2        : in std_logic_vector(12 downto 0);--13 bit:4096
        addr_bias_in_gru2       : in std_logic_vector(6 downto 0); --128                                         
        addr_hprev_in_gru2      : in std_logic_vector(6 downto 0);   
        addr_fc_in              : in std_logic_vector(5 downto 0);
        start_gru2              : out std_logic;   
        input_write_en_wu       : out std_logic; --top pad
        input_write_en_wr       : out std_logic; --top pad
        input_write_en_wc       : out std_logic; --top pad
        input_write_en_bubr     : out std_logic; --top pad
        input_write_en_bc       : out std_logic; --top pad
        input_write_en_xt       : out std_logic; --top pad
        input_write_en_hprev    : out std_logic; --top pad    
        input_write_en_gru2_wu  : out std_logic; --top pad
        input_write_en_gru2_wr  : out std_logic; --top pad
        input_write_en_gru2_wc  : out std_logic; --top pad
        input_write_en_gru2_bubr: out std_logic; --top pad
        input_write_en_gru2_bc  : out std_logic; --top pad   
        input_write_en_gru2_hprev: out std_logic; --top pad     
        input_write_en_fc_weights: out std_logic; --top pad            
        weight_u1_out           : out std_logic_vector(31 downto 0);
        weight_u2_out           : out std_logic_vector(31 downto 0);
        weight_r1_out           : out std_logic_vector(31 downto 0);
        weight_r2_out           : out std_logic_vector(31 downto 0);
        weight_c1_out           : out std_logic_vector(31 downto 0);
        weight_c2_out           : out std_logic_vector(31 downto 0);
        input1_out              : out std_logic_vector(31 downto 0);
        input2_out              : out std_logic_vector(31 downto 0);
        input3_out              : out std_logic_vector(31 downto 0);
        input4_out              : out std_logic_vector(31 downto 0);
        fc_weights_out          : out std_logic_vector(31 downto 0);
        bias_out                : out std_logic_vector(31 downto 0)
       
     );
end component;

component input_controller is
    generic(
            INPUT_NUMBER_WIDTH:integer:=8;--256 inputs
            HIDDEN_UNITS_NUMBER_WIDTH:integer:=7;--128 h(t-1) 
            HIDDEN_LAYERS_NUMBER_WIDTH:integer:=7;--128 layers    
            PARALLELISM_WIDTH: integer:= 3--8
            );
    Port (
        clk              : in std_logic; 
        reset            : in std_logic;
        start            : in std_logic;
        input_done       : in std_logic;
        h_prev_done      : in std_logic;
        op_done          : in std_logic;
--        initial          : out std_logic;
        xt_state         : out std_logic;
        hprev_state      : out std_logic;
        addr_input_out   : out std_logic_vector(INPUT_NUMBER_WIDTH-PARALLELISM_WIDTH-1 downto 0);--5 bit:32 , 4 bit:16
        addr_w_u_out     : out std_logic_vector(INPUT_NUMBER_WIDTH + 8 -PARALLELISM_WIDTH-1 downto 0);--13 bit:6144 12 bit:4096
        addr_bias_out    : out std_logic_vector(HIDDEN_LAYERS_NUMBER_WIDTH-1 downto 0);
        addr_hprev_out   : out std_logic_vector(HIDDEN_UNITS_NUMBER_WIDTH-PARALLELISM_WIDTH-1 downto 0)
         );
end component;
component counter is
  generic(INPUT_SIZE:integer:=256;
          SIZE_HOR  :integer:=384
           );
  Port (
        clk         : in std_logic;
        reset       : in std_logic;
        start       : in std_logic;
        input_done  : out std_logic;
        h_prev_done : out std_logic;
        op_done     : out std_logic;
        count_hor   : out std_logic_vector(5 downto 0);
        count_ver   : out std_logic_vector(6 downto 0)
         );
end component;
component counter_gate is
  generic(INPUT_SIZE:integer:=256;
          SIZE_HOR  :integer:=384
           );
  Port (
        clk           : in std_logic;
        reset         : in std_logic;
        GRU_en        : in std_logic;
        input_done_g  : out std_logic;
        h_prev_done_g : out std_logic;
        op_done_g     : out std_logic;
        count_hor_g   : out std_logic_vector(5 downto 0);
        count_ver_g   : out std_logic_vector(6 downto 0)
         );
end component;
component input_buffer is
  Port (clk         : in std_logic; 
        reset       : in std_logic;
        start       : in std_logic;
        input1      : in std_logic_vector(31 downto 0);
        input2      : in std_logic_vector(31 downto 0);
        input3      : in std_logic_vector(31 downto 0);
        input4      : in std_logic_vector(31 downto 0);
        weight_u1   : in std_logic_vector(31 downto 0);
        weight_u2   : in std_logic_vector(31 downto 0);
        weight_r1   : in std_logic_vector(31 downto 0);
        weight_r2   : in std_logic_vector(31 downto 0);
        weight_c1   : in std_logic_vector(31 downto 0);
        weight_c2   : in std_logic_vector(31 downto 0);
        bias        : in std_logic_vector(31 downto 0);
        GRU_en      : out std_logic;
        input1_o     : out std_logic_vector(31 downto 0);
        input2_o     : out std_logic_vector(31 downto 0);
        input3_o     : out std_logic_vector(31 downto 0);
        input4_o     : out std_logic_vector(31 downto 0);
        weight_u1_o  : out std_logic_vector(31 downto 0);
        weight_u2_o  : out std_logic_vector(31 downto 0);
        weight_r1_o  : out std_logic_vector(31 downto 0);
        weight_r2_o  : out std_logic_vector(31 downto 0);
        weight_c1_o  : out std_logic_vector(31 downto 0);
        weight_c2_o  : out std_logic_vector(31 downto 0);
        bias_o       : out std_logic_vector(31 downto 0)
         );
end component;

component h_prev_buffer is
  generic(INPUT_SIZE:integer:=256;
          SIZE_HOR  :integer:=384 
----          SIG_WL:integer:=1;
----          SIG_FL:integer:=7;
----          RES_WL:integer:=11;
----          RES_FL:integer:=13;
----          TANH_WL:integer:=1;
----          TANH_FL:integer:=7
          );
  Port (
        clk  : in std_logic; 
        reset: in std_logic;
        count_hor_g   : in std_logic_vector(5 downto 0);
        count_ver_g   : in std_logic_vector(6 downto 0);
        input1      : in std_logic_vector(31 downto 0);
        input2      : in std_logic_vector(31 downto 0);
        input3      : in std_logic_vector(31 downto 0);
        input4      : in std_logic_vector(31 downto 0);
        h_prev      : out std_logic_vector(15 downto 0)
        );
end component;

component GRU_select is
  Port (clk   : in std_logic; 
        reset : in std_logic;
        start : in std_logic;
        start_gru2 : in std_logic;
        GRU_sel:  out std_logic
         );
end component;


component GRU_layer is
  generic(MED_WL:integer:=24;
          MED_FL:integer:=13
          );
  Port (clk           : in std_logic;                            
        reset          : in std_logic;                            
        GRU_en        : in std_logic;                           
        input_done_g  : in std_logic;                   
        h_prev_done_g : in std_logic;                   
        op_done_g     : in std_logic;
        h_prev      : in std_logic_vector(15 downto 0);                     
        input1      : in std_logic_vector(31 downto 0); 
        input2      : in std_logic_vector(31 downto 0); 
        input3      : in std_logic_vector(31 downto 0); 
        input4      : in std_logic_vector(31 downto 0); 
        weight_u1   : in std_logic_vector(31 downto 0); 
        weight_u2   : in std_logic_vector(31 downto 0); 
        weight_r1   : in std_logic_vector(31 downto 0); 
        weight_r2   : in std_logic_vector(31 downto 0);
        weight_c1   : in std_logic_vector(31 downto 0); 
        weight_c2   : in std_logic_vector(31 downto 0);  
        bias        : in std_logic_vector(31 downto 0); 
        r_u_valid_o : out std_logic; 
        h_t         : out std_logic_vector(15 downto 0)       
       );
end component;

component fc_counter is
  generic(INPUT_SIZE:integer:=128
           );
  Port (
        clk         : in std_logic;
        reset       : in std_logic;
        fc_en       : in std_logic;
        fc_done     : out std_logic
         );
end component;
component fully_connected is
  generic(FC_WL:integer:=24;
          FC_FL:integer:=13;
          H_WL: integer:=16;
          H_FL: integer:=6
          );
           
  Port ( 
        clk       : in std_logic; 
        reset     : in std_logic;
        fc_en     : in std_logic; 
        fc_done   : in std_logic;
        h_t_in    : in std_logic_vector(15 downto 0);
        weight_fc_in : in std_logic_vector(31 downto 0);
        addr_fc_out: out std_logic_vector(5 downto 0);
        result_valid : out std_logic;
        fc_out    : out std_logic_vector(15 downto 0)        
        );
end component;
component sigmoid_fc is
--  generic(SIG_WL:integer:=16;
--          SIG_FL:integer:=6
--          );
  Port (clk  : in std_logic; 
        reset: in std_logic;
        result_valid : in std_logic;
        fc_in       : in std_logic_vector(15 downto 0);
        result       : out std_logic_vector(15 downto 0);
        final_result : out std_logic
          );
end component;

component write_file is
    generic (
        FILE_NAME: string ;
        INPUT_WIDTH: positive
        ); 
    Port (
        clk: in std_logic;
        reset: in std_logic;
        write_file_en: in std_logic;
	end_sim      : in std_logic;
        input_sample: in std_logic_vector(INPUT_WIDTH-1 downto 0)
        );
        end component;

------signals_gru1------------------------------------------------------------
constant MED_WL          :integer:=24;
constant MED_FL          :integer:=13;
constant FC_WL           :integer:=24;
signal start_gru1        :std_logic;
signal GRU_en            : std_logic;
signal input_done_g        : std_logic;                   
signal h_prev_done_g      : std_logic;                   
signal op_done_g           : std_logic; 
signal input_done        : std_logic;                   
signal h_prev_done       : std_logic;                   
signal op_done           : std_logic;    
signal r_u_valid         : std_logic; 
signal xt_state          : std_logic;
signal hprev_state       : std_logic;           
signal count_hor         : std_logic_vector(5 downto 0);
signal count_ver         : std_logic_vector(6 downto 0); 
signal count_hor_g       : std_logic_vector(5 downto 0);
signal count_ver_g       : std_logic_vector(6 downto 0);
signal addr_input_temp   : std_logic_vector(4 downto 0);
signal addr_input        : std_logic_vector(6 downto 0);
signal addr_w_u          : std_logic_vector(12 downto 0);
signal addr_bias         : std_logic_vector(6 downto 0); 
signal addr_hprev        : std_logic_vector(6 downto 0); 
signal addr_hprev_temp   : std_logic_vector(3 downto 0); 
signal weight_u1         : std_logic_vector(31 downto 0);
signal weight_u2         : std_logic_vector(31 downto 0);
signal weight_r1         : std_logic_vector(31 downto 0);
signal weight_r2         : std_logic_vector(31 downto 0);
signal weight_c1         : std_logic_vector(31 downto 0);
signal weight_c2         : std_logic_vector(31 downto 0);
signal input1            : std_logic_vector(31 downto 0);
signal input2            : std_logic_vector(31 downto 0);
signal input3            : std_logic_vector(31 downto 0);
signal input4            : std_logic_vector(31 downto 0);
signal bias                : std_logic_vector(31 downto 0);
signal weight_u1_o         : std_logic_vector(31 downto 0);
signal weight_u2_o         : std_logic_vector(31 downto 0);
signal weight_r1_o         : std_logic_vector(31 downto 0);
signal weight_r2_o         : std_logic_vector(31 downto 0);
signal weight_c1_o         : std_logic_vector(31 downto 0);
signal weight_c2_o         : std_logic_vector(31 downto 0);
signal input1_o            : std_logic_vector(31 downto 0);
signal input2_o            : std_logic_vector(31 downto 0);
signal input3_o            : std_logic_vector(31 downto 0);
signal input4_o            : std_logic_vector(31 downto 0);
signal bias_o              : std_logic_vector(31 downto 0);
signal output_u          : std_logic_vector(15 downto 0);
signal output_r          : std_logic_vector(15 downto 0);
signal u_t               : std_logic_vector(15 downto 0);
signal r_t               : std_logic_vector(15 downto 0);
signal output_cx         : std_logic_vector(MED_WL-1 downto 0);
signal output_ch         : std_logic_vector(MED_WL-1 downto 0);
signal h_can             : std_logic_vector(15 downto 0); 
signal h_t               : std_logic_vector(15 downto 0);
--------------signals_gru2 and fc_layer----------------------------------------------------------
signal start_gru2        : std_logic ;
signal GRU_en_gru2            : std_logic;
signal input_done_g_gru2        : std_logic;                   
signal h_prev_done_g_gru2      : std_logic;                   
signal op_done_g_gru2           : std_logic; 
signal input_done_gru2        : std_logic;                   
signal h_prev_done_gru2       : std_logic;                  
signal op_done_gru2           : std_logic;    
signal r_u_valid_gru2         : std_logic; 
signal xt_state_gru2          : std_logic;
signal hprev_state_gru2       : std_logic; 
signal count_hor_gru2         : std_logic_vector(5 downto 0);
signal count_ver_gru2         : std_logic_vector(6 downto 0); 
signal count_hor_g_gru2       : std_logic_vector(5 downto 0);
signal count_ver_g_gru2       : std_logic_vector(6 downto 0);
signal addr_input_temp_gru2   : std_logic_vector(3 downto 0);
signal addr_input_gru2        : std_logic_vector(6 downto 0);
signal addr_w_u_temp_gru2     : std_logic_vector(11 downto 0);
signal addr_w_u_gru2          : std_logic_vector(12 downto 0);
signal addr_bias_gru2         : std_logic_vector(6 downto 0); 
signal addr_hprev_gru2        : std_logic_vector(6 downto 0); 
signal addr_hprev_temp_gru2   : std_logic_vector(3 downto 0); 
signal addr_fc                : std_logic_vector(5 downto 0); 
signal fc_weights             : std_logic_vector(31 downto 0);
signal weight_u1_o_gru2         : std_logic_vector(31 downto 0);
signal weight_u2_o_gru2         : std_logic_vector(31 downto 0);
signal weight_r1_o_gru2         : std_logic_vector(31 downto 0);
signal weight_r2_o_gru2         : std_logic_vector(31 downto 0);
signal weight_c1_o_gru2         : std_logic_vector(31 downto 0);
signal weight_c2_o_gru2         : std_logic_vector(31 downto 0);
signal input1_o_gru2            : std_logic_vector(31 downto 0);
signal input2_o_gru2            : std_logic_vector(31 downto 0);
signal input3_o_gru2            : std_logic_vector(31 downto 0);
signal input4_o_gru2            : std_logic_vector(31 downto 0);
signal bias_o_gru2              : std_logic_vector(31 downto 0);
signal output_u_gru2          : std_logic_vector(15 downto 0);
signal output_r_gru2          : std_logic_vector(15 downto 0);
signal u_t_gru2               : std_logic_vector(15 downto 0);
signal r_t_gru2               : std_logic_vector(15 downto 0);
signal output_cx_gru2         : std_logic_vector(MED_WL-1 downto 0);
signal output_ch_gru2         : std_logic_vector(MED_WL-1 downto 0);
signal h_can_gru2             : std_logic_vector(15 downto 0); 
signal h_t_gru2               : std_logic_vector(15 downto 0);
signal fc_done                : std_logic;
signal result_valid           : std_logic;
signal final_result           : std_logic;
signal fc                     : std_logic_vector(15 downto 0); 
signal result                 : std_logic_vector(15 downto 0);
signal h_prev                 : std_logic_vector(15 downto 0); 
signal h_prev_gru1                 : std_logic_vector(15 downto 0);     
signal h_prev_gru2                 : std_logic_vector(15 downto 0); 

signal GRU_sel                : std_logic;  
signal input_done_gru1        : std_logic;
signal h_prev_done_gru1       : std_logic;
signal op_done_gru1           : std_logic;
signal input_done_g_gru1        : std_logic;
signal h_prev_done_g_gru1       : std_logic;
signal op_done_g_gru1           : std_logic;
signal start_ib                : std_logic;
signal GRU_en_gru1            : std_logic;
signal r_u_valid_gru1         : std_logic;  
----signals for pads---------------------------------------------------------------------
signal clki,reseti                   : std_logic;  
signal starti                        : std_logic;  
signal initiali                      : std_logic; 
signal data_ini                      : std_logic_vector(15 downto 0);
signal data_outi                     : std_logic_vector(15 downto 0);
signal input_write_en_wui            : std_logic;  
signal input_write_en_wri            : std_logic;  
signal input_write_en_wci            : std_logic;  
signal input_write_en_bubri          : std_logic;  
signal input_write_en_bci            : std_logic;  
signal input_write_en_xti            : std_logic;  
signal input_write_en_hprevi         : std_logic;  
signal input_write_en_gru2_wui       : std_logic;  
signal input_write_en_gru2_wri       : std_logic;  
signal input_write_en_gru2_wci       : std_logic;  
signal input_write_en_gru2_bubri     : std_logic;  
signal input_write_en_gru2_bci       : std_logic;  
signal input_write_en_gru2_hprevi    : std_logic; 
signal input_write_en_fc_weightsi    : std_logic;

signal end_sim : std_logic:='0';
begin
----------------------------------------------------------------------------------
     addr_hprev <= "000"&addr_hprev_temp;   
     addr_input <= "00"&addr_input_temp;
     addr_hprev_gru2 <= "000"&addr_hprev_temp_gru2;   
     addr_input_gru2 <= "000"&addr_input_temp_gru2;
     addr_w_u_gru2 <= '0' & addr_w_u_temp_gru2;
     
  start_ib<=starti or start_gru2;  
  input_done_g  <=  input_done_g_gru1 when GRU_sel='0' else
                    input_done_g_gru2; 
  h_prev_done_g <=  h_prev_done_g_gru1 when GRU_sel='0' else
                    h_prev_done_g_gru2;   
  op_done_g     <=  op_done_g_gru1 when GRU_sel='0' else
                    op_done_g_gru2;
    h_prev     <=   h_prev_gru1 when GRU_sel='0' else
                    h_prev_gru2;
--   GRU_en    <=  GRU_en_gru1 when GRU_sel='0' else
--                 GRU_en_gru2;  
  GRU_en_gru1 <= GRU_en when GRU_sel='0' else
                 '0';
  GRU_en_gru2 <= GRU_en when GRU_sel='1' else
                 '0';                 
  r_u_valid_gru2<=r_u_valid when GRU_sel='1' else
                  '0';
  r_u_valid_gru1<=r_u_valid when GRU_sel='0' else
                  '0';
-----duts------------------------------------------------------------------
     dut1:Mem_initial
     port map(
        clk                     => clk                  ,
        reset                   => reset                ,
        initial                 => initial              ,
        start                   => start                ,
        r_u_valid               => r_u_valid            ,
        xt_state                => xt_state             ,
        hprev_state             => hprev_state          ,
        xt_state_gru2           => xt_state_gru2     ,
        hprev_state_gru2        => hprev_state_gru2  ,
        data_in                 => data_in              ,
        ht_in                   => h_t                 ,
        addr_input_in           => addr_input           ,
        addr_w_u_in             => addr_w_u             ,
        addr_bias_in            => addr_bias            ,
        addr_hprev_in           => addr_hprev           ,
        addr_input_in_gru2      => addr_input_gru2      ,
        addr_w_u_in_gru2        => addr_w_u_gru2        ,
        addr_bias_in_gru2       => addr_bias_gru2       ,
        addr_hprev_in_gru2      => addr_hprev_gru2      ,
        addr_fc_in              => addr_fc,
        start_gru2              => start_gru2             ,
        input_write_en_wu       => input_write_en_wu       ,
        input_write_en_wr       => input_write_en_wr       ,
        input_write_en_wc       => input_write_en_wc       ,
        input_write_en_bubr     => input_write_en_bubr     ,
        input_write_en_bc       => input_write_en_bc       ,
        input_write_en_xt       => input_write_en_xt       ,
        input_write_en_hprev    => input_write_en_hprev    ,
        input_write_en_gru2_wu  => input_write_en_gru2_wu  ,
        input_write_en_gru2_wr  => input_write_en_gru2_wr  ,
        input_write_en_gru2_wc  => input_write_en_gru2_wc  ,
        input_write_en_gru2_bubr=> input_write_en_gru2_bubr,
        input_write_en_gru2_bc  => input_write_en_gru2_bc  ,
        input_write_en_gru2_hprev => input_write_en_gru2_hprev,
        input_write_en_fc_weights => input_write_en_fc_weights,
        weight_u1_out           => weight_u1           ,
        weight_u2_out           => weight_u2           ,
        weight_r1_out           => weight_r1           ,
        weight_r2_out           => weight_r2           ,
        weight_c1_out           => weight_c1           ,
        weight_c2_out           => weight_c2           ,
        input1_out              => input1              ,
        input2_out              => input2              ,
        input3_out              => input3              ,
        input4_out              => input4              ,
        fc_weights_out          => fc_weights          ,
        bias_out                => bias                                    
             );
    dut2:GRU_select 
  Port map (
            clk         =>   clk        ,
            reset       =>   reset      ,
            start       =>   start      ,
            start_gru2  =>   start_gru2 ,
            GRU_sel     =>   GRU_sel    
            );
    
    dut3:counter_gate
    generic map(INPUT_SIZE => 256,SIZE_HOR => 384)       
    port map(
        clk           => clk        ,
        reset         => reset      ,
        GRU_en        => GRU_en_gru1      ,
        input_done_g  => input_done_g_gru1 ,
        h_prev_done_g => h_prev_done_g_gru1,
        op_done_g     => op_done_g_gru1    ,
        count_hor_g   => count_hor_g  ,
        count_ver_g   => count_ver_g    
            );
    dut4:counter
    generic map(INPUT_SIZE => 256,SIZE_HOR => 384)       
    port map(
        clk         => clk        ,
        reset       => reset      ,
        start       => start      ,
        input_done  => input_done_gru1 ,
        h_prev_done => h_prev_done_gru1,
        op_done     => op_done_gru1    ,
        count_hor   => count_hor  ,
        count_ver   => count_ver     
            );
    dut5:input_controller
    generic map(INPUT_NUMBER_WIDTH=>8,HIDDEN_UNITS_NUMBER_WIDTH=>7,HIDDEN_LAYERS_NUMBER_WIDTH=>7,PARALLELISM_WIDTH=>3)
    port map(
        clk            => clk           ,
        reset          => reset         ,
        start          => start         ,
        input_done     => input_done_gru1    ,
        h_prev_done    => h_prev_done_gru1   ,
        op_done        => op_done_gru1       ,
        xt_state       => xt_state   ,
        hprev_state    => hprev_state,
        addr_input_out => addr_input_temp,
        addr_w_u_out   => addr_w_u      ,
        addr_bias_out  => addr_bias     ,
        addr_hprev_out => addr_hprev_temp
            );
    dut6: h_prev_buffer 
  generic map(INPUT_SIZE =>256,
              SIZE_HOR => 384 
               )
  Port map(
           clk             => clk        ,   
           reset           => reset      ,   
           count_hor_g     =>  count_hor_g ,
           count_ver_g     =>  count_ver_g ,
           input1          =>  input1_o      ,
           input2          =>  input2_o      ,
           input3          =>  input3_o      ,
           input4          =>  input4_o      ,
           h_prev          =>  h_prev_gru1      
           );     

    dut7: input_buffer 
  Port map(clk         => clk        ,
           reset       => reset      ,
           start       => start_ib      ,
           input1      => input1     ,
           input2      => input2     ,
           input3      => input3     ,
           input4      => input4     ,
           weight_u1   => weight_u1  ,
           weight_u2   => weight_u2  ,
           weight_r1   => weight_r1  ,
           weight_r2   => weight_r2  ,
           weight_c1   => weight_c1  ,
           weight_c2   => weight_c2  ,
           bias        => bias       ,
           GRU_en      => GRU_en     ,
           input1_o    => input1_o   ,
           input2_o    => input2_o   ,
           input3_o    => input3_o   ,
           input4_o    => input4_o   ,
           weight_u1_o => weight_u1_o,
           weight_u2_o => weight_u2_o,
           weight_r1_o => weight_r1_o,
           weight_r2_o => weight_r2_o,
           weight_c1_o => weight_c1_o,
           weight_c2_o => weight_c2_o,
           bias_o      => bias_o     
         );
    dut8:GRU_layer 
  generic map(MED_WL=>24,
              MED_FL=>13
               )
  Port map(clk               =>    clk             ,
           reset             =>    reset           ,
           GRU_en            =>    GRU_en          ,
           input_done_g      =>    input_done_g    ,
           h_prev_done_g     =>    h_prev_done_g   ,
           op_done_g         =>    op_done_g       ,
           h_prev            =>    h_prev          ,
           input1            =>    input1_o          ,
           input2            =>    input2_o        ,
           input3            =>    input3_o        ,
           input4            =>    input4_o        ,
           weight_u1         =>    weight_u1_o     ,
           weight_u2         =>    weight_u2_o     ,
           weight_r1         =>    weight_r1_o     ,
           weight_r2         =>    weight_r2_o     ,
           weight_c1         =>    weight_c1_o     ,
           weight_c2         =>    weight_c2_o     ,
           bias              =>    bias_o          ,
           r_u_valid_o       =>    r_u_valid       ,
           h_t               =>    h_t             
           );
    
    
dut9:counter_gate
    generic map(INPUT_SIZE => 128,SIZE_HOR => 256)       
    port map(
        clk           => clk        ,
        reset         => reset      ,
        GRU_en        => GRU_en_gru2      ,
        input_done_g  => input_done_g_gru2 ,
        h_prev_done_g => h_prev_done_g_gru2,
        op_done_g     => op_done_g_gru2    ,
        count_hor_g   => count_hor_g_gru2  ,
        count_ver_g   => count_ver_g_gru2    
            );
    dut10:counter
    generic map(INPUT_SIZE => 128,SIZE_HOR => 256)       
    port map(
        clk         => clk        ,
        reset       => reset      ,
        start       => start_gru2      ,
        input_done  => input_done_gru2 ,
        h_prev_done => h_prev_done_gru2,
        op_done     => op_done_gru2    ,
        count_hor   => count_hor_gru2  ,
        count_ver   => count_ver_gru2     
            );
    dut11: h_prev_buffer 
  generic map(INPUT_SIZE =>128,
              SIZE_HOR => 256 
               )
  Port map(
           clk             => clk        ,   
           reset           => reset      ,   
           count_hor_g     =>  count_hor_g_gru2 ,
           count_ver_g     =>  count_ver_g_gru2 ,
           input1          =>  input1_o      ,
           input2          =>  input2_o      ,
           input3          =>  input3_o      ,
           input4          =>  input4_o      ,
           h_prev          =>  h_prev_gru2      
           );      
        
    dut12:input_controller
    generic map(INPUT_NUMBER_WIDTH=>7,HIDDEN_UNITS_NUMBER_WIDTH=>7,HIDDEN_LAYERS_NUMBER_WIDTH=>7,PARALLELISM_WIDTH=>3)
    port map(
        clk            => clk           ,
        reset          => reset         ,
        start          => start_gru2     ,
        input_done     => input_done_gru2    ,
        h_prev_done    => h_prev_done_gru2   ,
        op_done        => op_done_gru2       ,
        xt_state       => xt_state_gru2   ,
        hprev_state    => hprev_state_gru2,
        addr_input_out => addr_input_temp_gru2,
        addr_w_u_out   => addr_w_u_temp_gru2      ,
        addr_bias_out  => addr_bias_gru2     ,
        addr_hprev_out => addr_hprev_temp_gru2
            );
 
  dut13: fc_counter 
  generic map(INPUT_SIZE=>128
           )
  Port map(
        clk         => clk ,   
        reset       => reset , 
        fc_en       => r_u_valid_gru2,  
        fc_done     => fc_done
         );                                                                    
  dut14: fully_connected 
  generic map(FC_WL=>24,
          FC_FL=>13,
          H_WL=>16,
          H_FL=>6
          )        
  Port map ( 
        clk         => clk          ,
        reset       => reset        ,
        fc_en       => r_u_valid_gru2       ,
        fc_done     => fc_done      ,
        h_t_in      => h_t       ,
        weight_fc_in=> fc_weights , 
        addr_fc_out => addr_fc     ,
        result_valid=> result_valid , 
        fc_out      => fc           
        );
dut15: sigmoid_fc 
--  generic(SIG_WL:integer:=16;
--          SIG_FL:integer:=6
--          );
  Port map (clk             => clk          ,
        reset           => reset        ,
        result_valid    => result_valid ,
        fc_in           => fc        ,
        result          => data_out       ,
        final_result    => final_result 
          );

dut16:write_file
 generic map(
        FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/h_t.txt",
        INPUT_WIDTH=> 16
        )
    Port map(
        clk =>clk,
        reset  => reset,
        write_file_en=>r_u_valid,
         end_sim =>end_sim,
        input_sample=>h_t
        );

dut17:write_file
 generic map(
        FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/h_prev.txt",
        INPUT_WIDTH=> 16
        )
    Port map(
        clk =>clk,
        reset  => reset,
        write_file_en=>r_u_valid,
         end_sim =>end_sim,
        input_sample=>h_prev
        );

end Behavioral;
