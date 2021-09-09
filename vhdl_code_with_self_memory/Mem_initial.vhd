
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2021 03:47:07 PM
-- Design Name: 
-- Module Name: Mem_initial - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Mem_initial is
    Port (
        clk               : in std_logic;--top pad
        reset             : in std_logic;--top pad
        initial           : in std_logic;--top pad
        start             : in std_logic;--top pad
        r_u_valid         : in std_logic;
        xt_state          : in std_logic;
        hprev_state       : in std_logic;
        xt_state_gru2     : in std_logic;
        hprev_state_gru2  : in std_logic;
        data_in           : in std_logic_vector(15 downto 0);--top pad
        ht_in             : in std_logic_vector(15 downto 0);
        addr_input_in     : in std_logic_vector(6 downto 0);                  
        addr_w_u_in       : in std_logic_vector(12 downto 0);--13 bit:6144
        addr_bias_in      : in std_logic_vector(6 downto 0); --128                                         
        addr_hprev_in     : in std_logic_vector(6 downto 0);    
        addr_input_in_gru2: in std_logic_vector(6 downto 0);                  
        addr_w_u_in_gru2  : in std_logic_vector(12 downto 0);--13 bit:4096
        addr_bias_in_gru2 : in std_logic_vector(6 downto 0); --128                                         
        addr_hprev_in_gru2: in std_logic_vector(6 downto 0);   
        addr_fc_in        : in std_logic_vector(5 downto 0);
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
        weight_u1_out     : out std_logic_vector(31 downto 0);
        weight_u2_out     : out std_logic_vector(31 downto 0);
        weight_r1_out     : out std_logic_vector(31 downto 0);
        weight_r2_out     : out std_logic_vector(31 downto 0);
        weight_c1_out     : out std_logic_vector(31 downto 0);
        weight_c2_out     : out std_logic_vector(31 downto 0);
        input1_out        : out std_logic_vector(31 downto 0);
        input2_out        : out std_logic_vector(31 downto 0);
        input3_out        : out std_logic_vector(31 downto 0);
        input4_out        : out std_logic_vector(31 downto 0);
        fc_weights_out    : out std_logic_vector(31 downto 0);
        bias_out          : out std_logic_vector(31 downto 0)
       
     );
end Mem_initial;

architecture Behavioral of Mem_initial is
--components------------------------------------------------------
component FF 
  generic(N:integer:=1);
  port(   D  :  in std_logic_vector(N-1 downto 0);
          Q  : out std_logic_vector(N-1 downto 0);
        clk  :  in std_logic;
        reset:  in std_logic
      );
end component;
component ram 
  GENERIC(
    d_width  : INTEGER := 8;    --width of each data word
    size     : INTEGER := 64);  --number of data words the memory can store
  PORT(
    clk      : IN   STD_LOGIC;                             --system clock
    wrn_ena  : IN   STD_LOGIC;                             --write enable negative
    addr     : IN   INTEGER RANGE 0 TO size-1;             --address to write/read
    data_in  : IN   STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --input data to write
    data_out : OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)); --output data read
END component;

------signals------------------------------------------------------------

type state_type_mem is (idle, initial_wu,initial_wr,initial_wc,initial_bubr,initial_bc,initial_xt1,initial_xt2,wait_0_cc,initial_hprev1,initial_hprev2,load,
                         initial_gru2_wu,initial_gru2_wr,initial_gru2_wc,initial_gru2_bubr,initial_gru2_bc,
                          initial_gru2_hprev1,initial_gru2_hprev2,wait_1_cc,initial_fc_weights,wait_for_load_gru2,load_gru2);
type state_type_ht is (idle_ht,initial_ht,wait_for_load); 
signal current_state,next_state: state_type_mem;
signal c_state,n_state         : state_type_ht;
signal weight_u1               : std_logic_vector(31 downto 0);--weights output for calculation
signal weight_u2               : std_logic_vector(31 downto 0);
signal weight_r1               : std_logic_vector(31 downto 0);
signal weight_r2               : std_logic_vector(31 downto 0);
signal weight_c1               : std_logic_vector(31 downto 0);
signal weight_c2               : std_logic_vector(31 downto 0);
signal weight_1u               : std_logic_vector(63 downto 0);--update gate weights
signal weight_1r               : std_logic_vector(63 downto 0);
signal weight_1c               : std_logic_vector(63 downto 0);
signal xt1,xt2                 : std_logic_vector(63 downto 0);
signal hprev1,hprev2           : std_logic_vector(63 downto 0);
signal ht1,ht2                 : std_logic_vector(63 downto 0);
signal bias_bubr               : std_logic_vector(31 downto 0); 
signal bias_bc                 : std_logic_vector(31 downto 0);
signal bitstream_weights       : std_logic_vector(63 downto 0);
signal bitstream_weights_next  : std_logic_vector(63 downto 0);
signal bitstream_bias          : std_logic_vector(31 downto 0);
signal bitstream_bias_next     : std_logic_vector(31 downto 0);
signal bitstream_xt            : std_logic_vector(63 downto 0);
signal bitstream_xt_next       : std_logic_vector(63 downto 0);
signal bitstream_hprev         : std_logic_vector(63 downto 0);
signal bitstream_hprev_next    : std_logic_vector(63 downto 0);
signal bitstream_ht            : std_logic_vector(63 downto 0);
signal bitstream_ht_next       : std_logic_vector(63 downto 0);
signal addr_weights            : std_logic_vector(13 downto 0);
signal addr_bias               : std_logic_vector(7 downto 0);
signal addr_xt,addr_hprev      : std_logic_vector(5 downto 0);
signal addr_weights_n          : std_logic_vector(13 downto 0);
signal addr_bias_n             : std_logic_vector(7 downto 0);
signal addr_xt_n,addr_hprev_n  : std_logic_vector(5 downto 0);
signal addr_ht_n,addr_ht       : std_logic_vector(5 downto 0);
signal addr_weights_mem        : std_logic_vector(13 downto 0);
signal addr_bias_mem           : std_logic_vector(7 downto 0);
signal addr_xt_mem,addr_hprev_mem:std_logic_vector(5 downto 0);
signal addr_ht_mem             : std_logic_vector(5 downto 0);
signal addr_weights_mem_int        : integer range 0 to 6145;
signal addr_bias_mem_int           : integer range 0 to 255;
signal addr_xt_mem_int,addr_hprev_mem_int:integer range 0 to 32;
signal addr_ht_mem_int             : integer range 0 to 32;
signal counter_weights         : std_logic_vector(14 downto 0);
signal counter_weights_next    : std_logic_vector(14 downto 0);
signal counter_bias            : std_logic_vector(7 downto 0);
signal counter_bias_next       : std_logic_vector(7 downto 0);
signal counter_xt              : std_logic_vector(7 downto 0);
signal counter_xt_next         : std_logic_vector(7 downto 0);
signal counter_hprev           : std_logic_vector(6 downto 0);
signal counter_hprev_next      : std_logic_vector(6 downto 0);
signal counter_ht              : std_logic_vector(6 downto 0);
signal counter_ht_next         : std_logic_vector(6 downto 0);
signal counter_change_next     : std_logic_vector(7 downto 0);
signal counter_change          : std_logic_vector(7 downto 0);
signal wen_ht1_n,wen_ht1_c     : std_logic_vector(0 downto 0);
signal wen_ht2_n,wen_ht2_c     : std_logic_vector(0 downto 0);
signal loading                 : std_logic;
signal wen_wu,wen_wr,wen_wc    : std_logic;
signal wen_bubr,wen_bc         : std_logic;
signal wen_xt1,wen_hprev1      : std_logic;
signal wen_xt2,wen_hprev2      : std_logic;
signal wen_ht1,wen_ht2         : std_logic;
--------------signals_gru2 and fc_layer--------------------------------------------
signal weight_u1_gru2          : std_logic_vector(31 downto 0);--weights output for calculation
signal weight_u2_gru2          : std_logic_vector(31 downto 0);
signal weight_r1_gru2          : std_logic_vector(31 downto 0);
signal weight_r2_gru2          : std_logic_vector(31 downto 0);
signal weight_c1_gru2          : std_logic_vector(31 downto 0);
signal weight_c2_gru2          : std_logic_vector(31 downto 0);
signal bitstream_fc            : std_logic_vector(31 downto 0);
signal bitstream_fc_next       : std_logic_vector(31 downto 0);
signal fc_weights              : std_logic_vector(31 downto 0);
signal loading_gru2            : std_logic; 
signal wen_fc                  : std_logic; 
signal wen_fc_c,wen_fc_n       : std_logic_vector(0 downto 0);
signal addr_fc_n,addr_fc       : std_logic_vector(6 downto 0);
signal addr_fc_mem             : std_logic_vector(6 downto 0);
signal addr_fc_mem_int         : integer range 0 to 255;
signal counter_fc              : std_logic_vector(6 downto 0);
signal counter_fc_next         : std_logic_vector(6 downto 0);
begin
---------------------ht_store------------------------------------------------
wen_ht1_n(0) <= wen_ht1;            
wen_ht2_n(0) <= wen_ht2;
wen_fc_n(0) <= wen_fc;            
---------------combinational_logic_out-------------------------------------------
weight_u1_out <= weight_u1;
weight_u2_out <= weight_u2;
weight_r1_out <= weight_r1;
weight_r2_out <= weight_r2;
weight_c1_out <= weight_c1;
weight_c2_out <= weight_c2;
input1_out    <= xt1(63 downto 32) when xt_state = '1' else
                 hprev1(63 downto 32) when hprev_state = '1' else
                 ht1(56 downto 48)&"0000000"&ht1(40 downto 32)&"0000000" when xt_state_gru2 = '1' else
                 hprev1(63 downto 32) when hprev_state_gru2 = '1' else
                 (others => '0');   
input2_out    <= xt1(31 downto 0) when xt_state = '1' else
                 hprev1(31 downto 0) when hprev_state = '1' else
                 ht1(24 downto 16)&"0000000"&ht1(8 downto 0)&"0000000" when xt_state_gru2 = '1' else
                 hprev1(31 downto 0) when hprev_state_gru2 = '1' else
                 (others => '0');  
input3_out    <= xt2(63 downto 32) when xt_state = '1' else
                 hprev2(63 downto 32) when hprev_state = '1' else
                 ht2(56 downto 48)&"0000000"&ht2(40 downto 32)&"0000000" when xt_state_gru2 = '1' else
                 hprev2(63 downto 32) when hprev_state_gru2 = '1' else
                 (others => '0');  
input4_out    <= xt2(31 downto 0) when xt_state = '1' else
                 hprev2(31 downto 0) when hprev_state = '1' else
                 ht2(24 downto 16)&"0000000"&ht2(8 downto 0)&"0000000" when xt_state_gru2 = '1' else
                 hprev2(31 downto 0) when hprev_state_gru2 = '1' else
                 (others => '0');   
bias_out      <= bias_bubr(31 downto 16) & bias_bc(31 downto 16); 
fc_weights_out <= fc_weights;
--------------------addresses------------------------------------------------
addr_weights_mem  <= addr_weights when loading ='0'and loading_gru2 = '0' else 
                    '0'&addr_w_u_in when loading = '1' and loading_gru2 = '0' else
                    '0'&addr_w_u_in_gru2 when loading = '0' and loading_gru2 = '1' else
                    (others => '0');
addr_bias_mem <=  addr_bias when loading ='0'and loading_gru2 = '0' else          
                    '0'&addr_bias_in when loading = '1' and loading_gru2 = '0' else      
                    '0'&addr_bias_in_gru2 when loading = '0' and loading_gru2 = '1' else 
                    (others => '0');                                                    
addr_ht_mem  <= addr_ht when loading_gru2 = '0' else addr_input_in_gru2(5 downto 0);
addr_xt_mem   <= addr_xt when loading = '0' else addr_input_in(5 downto 0);
addr_hprev_mem <= addr_hprev when loading ='0'and loading_gru2 = '0' else            
                    addr_hprev_in(5 downto 0) when loading = '1' and loading_gru2 = '0' else     
                    addr_hprev_in_gru2(5 downto 0) when loading = '0' and loading_gru2 = '1' else
                    (others => '0');   
addr_fc_mem <= addr_fc when loading_gru2 = '0' else '0'&addr_fc_in; 
  
addr_weights_mem_int <= to_integer(unsigned(addr_weights_mem));
addr_bias_mem_int <= to_integer(unsigned(addr_bias_mem));
addr_ht_mem_int <= to_integer(unsigned(addr_ht_mem));
addr_xt_mem_int <= to_integer(unsigned(addr_xt_mem));
addr_hprev_mem_int <= to_integer(unsigned(addr_hprev_mem));
addr_fc_mem_int <= to_integer(unsigned(addr_fc_mem));
                                         
--------------------combinational_logic_gru1---------------------------------------------
weight_u1 <= weight_1u(63 downto 32) when addr_w_u_in < 6145 else
             (others =>'0');
weight_u2 <= weight_1u(31 downto 0) when addr_w_u_in < 6145 else
             (others =>'0');    
weight_r1 <= weight_1r(63 downto 32) when addr_w_u_in < 6145 else
             (others =>'0');
weight_r2 <= weight_1r(31 downto 0) when addr_w_u_in < 6145 else
             (others =>'0');
weight_c1 <= weight_1c(63 downto 32) when addr_w_u_in < 6145 else
             (others =>'0');
weight_c2 <= weight_1c(31 downto 0) when addr_w_u_in < 6145 else
             (others =>'0');       
-----------------combinational_logic_gru2--------------------------------------------
weight_u1_gru2 <= weight_1u(63 downto 32) when addr_w_u_in_gru2 < 4097 else
             (others =>'0');
weight_u2_gru2 <= weight_1u(31 downto 0) when addr_w_u_in_gru2 < 4097 else
             (others =>'0');    
weight_r1_gru2 <= weight_1r(63 downto 32) when addr_w_u_in_gru2< 4097 else
             (others =>'0');
weight_r2_gru2 <= weight_1r(31 downto 0) when addr_w_u_in_gru2 < 4097 else
             (others =>'0');
weight_c1_gru2 <= weight_1c(63 downto 32) when addr_w_u_in_gru2 < 4097 else
             (others =>'0');
weight_c2_gru2 <= weight_1c(31 downto 0) when addr_w_u_in_gru2 < 4097 else
             (others =>'0');             
-------------fsm------------------------------------------------------------
sequential:process(clk,reset)
    begin
        if rising_edge(clk) then
            if reset='1' then
                current_state<=idle;
                c_state <= idle_ht;
            else 
                current_state<=next_state;
                c_state <= n_state;
            end if;
        end if;
end process;  
mem_controll:process(current_state,initial,counter_weights,counter_bias,counter_xt,counter_hprev,
                    counter_change,counter_fc,start,data_in,addr_w_u_in,addr_w_u_in_gru2)
    begin
        wen_wu <= '1';
        wen_wr <= '1';
        wen_wc <= '1';
        wen_bubr <= '1';
        wen_bc <= '1';
        wen_xt1 <= '1';
        wen_xt2 <= '1';
        wen_hprev1 <= '1';
        wen_hprev2 <= '1';
        wen_fc     <= '1';
        start_gru2 <= '0';
        loading <= '0';
        loading_gru2 <= '0';
        input_write_en_wu <= '0';
        input_write_en_wr <= '0';
        input_write_en_wc <= '0';
        input_write_en_bubr    <= '0';
        input_write_en_bc      <= '0';
        input_write_en_gru2_wu <= '0';
        input_write_en_gru2_wr <= '0';
        input_write_en_gru2_wc <= '0';
        input_write_en_gru2_bubr    <= '0';
        input_write_en_gru2_bc      <= '0';
        input_write_en_gru2_hprev <= '0';
        input_write_en_xt      <= '0';
        input_write_en_hprev      <= '0';
        input_write_en_fc_weights <= '0';
        addr_weights_n  <= (others => '0');        
        addr_bias_n <= (others => '0');
        addr_hprev_n<= (others => '0');
        addr_xt_n   <= (others => '0');
        addr_fc_n   <= (others => '0');
        bitstream_weights_next <= (others => '0');
        bitstream_bias_next <= (others => '0');
        bitstream_xt_next <= (others => '0');
        bitstream_hprev_next <= (others => '0');
        bitstream_fc_next <= (others => '0');
        counter_weights_next <= (others => '0');   
        counter_bias_next <= (others => '0'); 
        counter_xt_next <= (others => '0'); 
        counter_hprev_next <= (others => '0');
        counter_change_next <= (others => '0');
        counter_fc_next <= (others => '0');  
        next_state<=current_state;
        case current_state is 
            when idle=>  
                addr_weights_n <= addr_weights;   
                if initial='1' then
                    next_state<=initial_wu;
                    bitstream_weights_next <= bitstream_weights(47 downto 0)&data_in;
                    input_write_en_wu <= '1';
                else
                    next_state<=idle;
                end if;
            when initial_wu=>
                input_write_en_wu <= '1';
                wen_wu <= '0';
                counter_weights_next <= counter_weights + 1;
                addr_weights_n <= '0'&counter_weights(14 downto 2);
                bitstream_weights_next <= bitstream_weights(47 downto 0)&data_in;
                if counter_weights = 24576 then
                    counter_weights_next <= (others => '0');
                    addr_weights_n  <= (others => '0');
                    input_write_en_wr <= '1';
                    next_state <= initial_wr;
                else 
                    next_state <= initial_wu;
                end if;
            when initial_wr=>
                input_write_en_wr <= '1';
                wen_wr <= '0';
                counter_weights_next <= counter_weights + 1;
                addr_weights_n <= '0'&counter_weights(14 downto 2); 
                bitstream_weights_next <= bitstream_weights(47 downto 0)&data_in;
                if counter_weights = 24576 then 
                    input_write_en_wc <= '1';
                    counter_weights_next <= (others => '0');
                    addr_weights_n  <= (others => '0'); 
                    next_state <= initial_wc;    
                else 
                    next_state <= initial_wr;
                end if;
            when initial_wc=>
                input_write_en_wc <= '1';
                wen_wc <= '0';
                counter_weights_next <= counter_weights + 1;
                addr_weights_n <= '0'&counter_weights(14 downto 2);  
                bitstream_weights_next <= bitstream_weights(47 downto 0)&data_in;
                if counter_weights = 24576 then               
                    next_state <= initial_bubr;
                    counter_bias_next <= (others => '0');
                    bitstream_bias_next <= data_in&bitstream_bias(15 downto 0);
                    input_write_en_bubr <= '1';
                else 
                    next_state <= initial_wc;
                end if;
            when initial_bubr=>
                input_write_en_bubr <= '1';
                wen_bubr <= '0';
                bitstream_bias_next <= data_in&bitstream_bias(15 downto 0);
                counter_bias_next <= counter_bias + 1;
                addr_bias_n <= counter_bias;
                if addr_bias = 128 then
                    bitstream_bias_next <= bitstream_bias;
                    next_state <= initial_bc;
                    counter_bias_next <= (others => '0');
                    input_write_en_bc <= '1';
                else
                    next_state <= initial_bubr;
                end if;
            when initial_bc=>
                input_write_en_bc <= '1';
                wen_bc <= '0';
                bitstream_bias_next <= data_in&bitstream_bias(15 downto 0);
                counter_bias_next <= counter_bias + 1;
                addr_bias_n <= counter_bias; 
                if addr_bias = 128 then
                    bitstream_bias_next <= bitstream_bias;
                    next_state <= initial_xt1;
                    bitstream_xt_next <= bitstream_xt(47 downto 0)&data_in;
                    input_write_en_xt <= '1';
                else 
                    next_state <= initial_bc;
                end if;
            when initial_xt1=>
                input_write_en_xt <= '1';
                wen_xt1 <= '0';
                addr_xt_n <= '0'&counter_xt(7 downto 3);
                counter_xt_next <= counter_xt+1;
                counter_change_next <= counter_xt; 
                bitstream_xt_next <= bitstream_xt(47 downto 0)&data_in;
                if counter_change(1 downto 0) = 3 then 
                    next_state <= initial_xt2;    
                else
                    next_state <= initial_xt1;                
                end if;
            when initial_xt2=>
                input_write_en_xt <= '1';
                wen_xt2 <= '0'; 
                addr_xt_n <= '0'&counter_xt(7 downto 3);
                counter_xt_next <= counter_xt+1; 
                counter_change_next <= counter_xt;  
                bitstream_xt_next <= bitstream_xt(47 downto 0)&data_in;
                if counter_change = 255 then
                    next_state <= wait_0_cc;
                    bitstream_hprev_next <= bitstream_hprev(47 downto 0)&data_in; 
                    input_write_en_hprev <= '1';
                elsif counter_change(1 downto 0) = 3 then
                    next_state <= initial_xt1;  
                else
                    next_state <= initial_xt2; 
                end if;
            when wait_0_cc =>
		next_state <= initial_hprev1;    
            when initial_hprev1=>
                input_write_en_hprev <= '1';
                wen_hprev1 <= '0';
                counter_hprev_next <= counter_hprev + 1; 
                counter_change_next <= '0'&counter_hprev;
                addr_hprev_n <= addr_hprev;
                bitstream_hprev_next <= bitstream_hprev(47 downto 0)&data_in;             
                if counter_change(1 downto 0)=3 then
                    next_state <= initial_hprev2;  
                else
                    next_state <= initial_hprev1;  
                end if;  
            when initial_hprev2=>
                wen_hprev2 <= '0';
                input_write_en_hprev <= '1';
                if counter_hprev = 127 then
                    counter_hprev_next <= counter_hprev;        
                else
                    counter_hprev_next <= counter_hprev + 1;
                end if;
                counter_change_next <= '0'&counter_hprev;
                if start = '0' then 
                    if counter_change = 127 then
                        bitstream_hprev_next <= bitstream_hprev;
                        addr_hprev_n <= addr_hprev;
                        next_state <= initial_hprev2;                   
                    elsif counter_change(1 downto 0) = 3 then
                        bitstream_hprev_next <= bitstream_hprev(47 downto 0)&data_in;
                        next_state <= initial_hprev1;
                        addr_hprev_n <= addr_hprev + 1;
                    else
                        addr_hprev_n <=addr_hprev;
                        bitstream_hprev_next <= bitstream_hprev(47 downto 0)&data_in; 
                        next_state <= initial_hprev2;  
                    end if; 
                else
                    next_state <= load;
                end if;
            when load =>
                loading <= '1';
                if addr_w_u_in < 6144 then
                    next_state <= load;     
                else
                    next_state <= initial_gru2_wu;   
                    bitstream_weights_next <= bitstream_weights(47 downto 0)&data_in;
                    input_write_en_gru2_wu <= '1';
                end if; 
            when initial_gru2_wu =>
                input_write_en_gru2_wu <= '1';
                wen_wu <= '0';
                counter_weights_next <= counter_weights + 1;
                addr_weights_n <= '0'&counter_weights(14 downto 2);
                bitstream_weights_next <= bitstream_weights(47 downto 0)&data_in;
                if counter_weights = 16384 then
                    counter_weights_next <= (others => '0');
                    addr_weights_n  <= (others => '0');
                    input_write_en_gru2_wr <= '1';
                    next_state <= initial_gru2_wr;
                else 
                    next_state <= initial_gru2_wu;
                end if;
            when initial_gru2_wr =>
                input_write_en_gru2_wr <= '1';
                wen_wr <= '0';
                counter_weights_next <= counter_weights + 1;
                addr_weights_n <= '0'&counter_weights(14 downto 2); 
                bitstream_weights_next <= bitstream_weights(47 downto 0)&data_in;
                if counter_weights = 16384 then 
                    input_write_en_gru2_wc <= '1';
                    counter_weights_next <= (others => '0');
                    addr_weights_n  <= (others => '0'); 
                    next_state <= initial_gru2_wc;    
                else 
                    next_state <= initial_gru2_wr;
                end if;
            when initial_gru2_wc=>
                input_write_en_gru2_wc <= '1';
                wen_wc <= '0';
                counter_weights_next <= counter_weights + 1;
                addr_weights_n <= '0'&counter_weights(14 downto 2);  
                bitstream_weights_next <= bitstream_weights(47 downto 0)&data_in;
                if counter_weights = 16384 then               
                    next_state <= initial_gru2_bubr;
                    counter_bias_next <= (others => '0');
                    bitstream_bias_next <= data_in&bitstream_bias(15 downto 0);
                    input_write_en_gru2_bubr <= '1';
                else 
                    next_state <= initial_gru2_wc;
                end if;
            when initial_gru2_bubr=>
                input_write_en_gru2_bubr <= '1';
                wen_bubr <= '0';
                bitstream_bias_next <= data_in&bitstream_bias(15 downto 0);
                counter_bias_next <= counter_bias + 1;
                addr_bias_n <= counter_bias;
                if addr_bias = 128 then
                    next_state <= initial_gru2_bc;
                    counter_bias_next <= (others => '0');
                    input_write_en_gru2_bc <= '1';
                else
                    next_state <= initial_gru2_bubr;
                end if;
            when initial_gru2_bc=>
                input_write_en_gru2_bc <= '1';
                wen_bc <= '0';
                bitstream_bias_next <= data_in&bitstream_bias(15 downto 0);
                counter_bias_next <= counter_bias + 1;
                addr_bias_n <= counter_bias; 
                if addr_bias = 128 then
                    next_state <= initial_gru2_hprev1;
                    bitstream_hprev_next <= bitstream_hprev(47 downto 0)&data_in; 
                    input_write_en_gru2_hprev <= '1';
                else 
                    next_state <= initial_gru2_bc;
                end if;
            when initial_gru2_hprev1=>
                input_write_en_gru2_hprev <= '1';
                wen_hprev1 <= '0';
                counter_hprev_next <= counter_hprev + 1; 
                counter_change_next <= '0'&counter_hprev;
                addr_hprev_n <= addr_hprev;
                bitstream_hprev_next <= bitstream_hprev(47 downto 0)&data_in;             
                if counter_change(1 downto 0)=3 then
                    next_state <= initial_gru2_hprev2;  
                else
                    next_state <= initial_gru2_hprev1;  
                end if;  
            when initial_gru2_hprev2=>
                wen_hprev2 <= '0';
                input_write_en_gru2_hprev <= '1';
                if counter_hprev = 127 then
                    counter_hprev_next <= counter_hprev;        
                else
                    counter_hprev_next <= counter_hprev + 1;
                end if;
                counter_change_next <= '0'&counter_hprev;
                if counter_change = 127 then
                    bitstream_hprev_next <= bitstream_hprev;
                    addr_hprev_n <= addr_hprev;
                    input_write_en_fc_weights <= '1';
                    next_state <= wait_1_cc;                   
                elsif counter_change(1 downto 0) = 3 then
                    bitstream_hprev_next <= bitstream_hprev(47 downto 0)&data_in;
                    next_state <= initial_gru2_hprev1;
                    addr_hprev_n <= addr_hprev + 1;
                else
                    addr_hprev_n <=addr_hprev;
                    bitstream_hprev_next <= bitstream_hprev(47 downto 0)&data_in; 
                    next_state <= initial_gru2_hprev2;  
                end if; 
            when wait_1_cc =>
		next_state <= initial_fc_weights;
            when initial_fc_weights =>
                input_write_en_fc_weights <= '1';
                wen_fc <= '0';
                bitstream_fc_next <= bitstream_fc(15 downto 0)&data_in;
                counter_fc_next <= counter_fc + 1;
                addr_fc_n <= '0'&counter_fc(6 downto 1); 
                if addr_fc = 31 then
                    next_state <= wait_for_load_gru2;
                else 
                    next_state <= initial_fc_weights;
                end if;    
            when wait_for_load_gru2 =>
                start_gru2 <= '1';
                next_state <= load_gru2;
            when load_gru2 =>
                loading_gru2 <= '1';
                if addr_w_u_in_gru2 < 4096 then
                    next_state <= load_gru2;
                else
                    next_state <= idle;
                end if;                
            end case;        
end process;
ht_mem_controll:process(c_state,r_u_valid,counter_ht,bitstream_ht,ht_in)
begin
    n_state <= c_state;
    counter_ht_next <= (others => '0');
    bitstream_ht_next <= (others => '0');
    addr_ht_n <= (others => '0');
    wen_ht1 <= '1';
    wen_ht2 <= '1';
    case c_state is
        when idle_ht =>
            if r_u_valid = '1' then
                counter_ht_next <= counter_ht + 1;
                bitstream_ht_next <= bitstream_ht(47 downto 0)&ht_in;
                addr_ht_n    <= "00"&counter_ht(6 downto 3);
                n_state <= initial_ht;
            else
                n_state <= idle_ht;
            end if;
        when initial_ht =>
            bitstream_ht_next <= bitstream_ht;
            addr_ht_n <= "00"&counter_ht(6 downto 3);
            if counter_ht(2 downto 0)<4 then
                wen_ht1 <= '0';
            else
                wen_ht1 <= '1';
            end if;
            if counter_ht(2 downto 0)>3 then
                wen_ht2 <= '0';
            else
                wen_ht2 <= '1';
            end if;    
            if counter_ht = 127 and r_u_valid = '1' then
                bitstream_ht_next <= bitstream_ht(47 downto 0)&ht_in;
                counter_ht_next <= counter_ht;
                n_state <= wait_for_load;
            elsif r_u_valid = '1' then
                bitstream_ht_next <= bitstream_ht(47 downto 0)&ht_in;
                counter_ht_next <= counter_ht + 1;
                n_state <= initial_ht;
            else
                counter_ht_next <= counter_ht;
            end if;
        when wait_for_load =>
            bitstream_ht_next <= bitstream_ht;
            wen_ht1 <= '1';
            wen_ht2 <= '1';
            n_state <= wait_for_load;
        end case;
end process;              
--            counter_ht_next <=  counter_ht when counter_ht = 127 else
--                                counter_ht + 1 when r_u_valid = '1' else 
--                                counter_ht;
--            bitstream_ht_next <= bitstream_ht(47 downto 0)&ht_in when r_u_valid = '1' else bitstream_ht;
--            addr_ht_mem  <= addr_ht;
--            addr_ht_n    <= "00"&counter_ht(6 downto 3);
--            wen_ht1 <= '0' when counter_ht(2 downto 0) < 4 else '1';
--            wen_ht2 <= '0' when counter_ht(2 downto 0) > 3 else '1';
--            wen_ht1_n(0) <= wen_ht1;
--            wen_ht2_n(0) <= wen_ht2;

-------------port map-------------------------------------------------------
addr_weights_ff : FF
    generic map(N =>14)
    port map(
          D  => addr_weights_n,       
          Q  => addr_weights,
          clk => clk,
          reset => reset
          );              
addr_bias_ff : FF
    generic map(N => 8)
    port map(
          D  => addr_bias_n,       
          Q  => addr_bias,
          clk => clk,
          reset => reset
          );
addr_xt_FF : FF
    generic map(N => 6)
    port map(
          D  => addr_xt_n,       
          Q  => addr_xt,
          clk => clk,
          reset => reset
          ); 
addr_hprev_FF : FF
    generic map(N => 6)
    port map(
          D  => addr_hprev_n,       
          Q  => addr_hprev,
          clk => clk,
          reset => reset
          );   
addr_ht_FF : FF
    generic map(N => 6)
    port map(
          D  => addr_ht_n,       
          Q  => addr_ht,
          clk => clk,
          reset => reset
          );   
addr_fc_FF : FF
    generic map(N => 7)
    port map(
          D  => addr_fc_n,       
          Q  => addr_fc,
          clk => clk,
          reset => reset
          );      
counter_weights_ff : FF
    generic map(N => 15)
    port map(
          D  => counter_weights_next,       
          Q  => counter_weights,
          clk => clk,
          reset => reset
          );         
counter_bias_ff : FF
    generic map(N => 8)
    port map(
          D  => counter_bias_next,       
          Q  => counter_bias,
          clk => clk,
          reset => reset
          ); 
counter_xt_ff : FF
    generic map(N => 8)
    port map(
          D  => counter_xt_next,       
          Q  => counter_xt,
          clk => clk,
          reset => reset
          ); 
counter_hprev_ff : FF
    generic map(N => 7)
    port map(
          D  => counter_hprev_next,       
          Q  => counter_hprev,
          clk => clk,
          reset => reset
          ); 
counter_ht_ff : FF
    generic map(N => 7)
    port map(
          D  => counter_ht_next,       
          Q  => counter_ht,
          clk => clk,
          reset => reset
          ); 
counter_change_ff : FF
    generic map(N => 8)
    port map(
          D  => counter_change_next,       
          Q  => counter_change,
          clk => clk,
          reset => reset
          ); 
counter_fc_ff : FF
    generic map(N => 7)
    port map(
          D  => counter_fc_next,       
          Q  => counter_fc,
          clk => clk,
          reset => reset
          ); 
bitstream_weights_ff : FF
    generic map(N => 64)
    port map(
          D  => bitstream_weights_next,       
          Q  => bitstream_weights,
          clk => clk,
          reset => reset
          );
bitstream_bias_ff : FF
    generic map(N => 32)
    port map(
          D  => bitstream_bias_next,       
          Q  => bitstream_bias,
          clk => clk,
          reset => reset
          );
bitstream_xt_ff : FF
    generic map(N => 64)
    port map(
          D  => bitstream_xt_next,       
          Q  => bitstream_xt,
          clk => clk,
          reset => reset
          );
bitstream_hprev_ff : FF
    generic map(N => 64)
    port map(
          D  => bitstream_hprev_next,       
          Q  => bitstream_hprev,
          clk => clk,
          reset => reset
          );  
bitstream_ht_ff : FF
    generic map(N => 64)
    port map(
          D  => bitstream_ht_next,       
          Q  => bitstream_ht,
          clk => clk,
          reset => reset
          );
bitstream_fc_ff : FF
    generic map(N => 32)
    port map(
          D  => bitstream_fc_next,       
          Q  => bitstream_fc,
          clk => clk,
          reset => reset
          );          
wen_ht1_ff : FF
    generic map(N => 1)
    port map(
          D  => wen_ht1_n,       
          Q  => wen_ht1_c,
          clk => clk,
          reset => reset
          );  
wen_ht2_ff : FF
    generic map(N => 1)
    port map(
          D  => wen_ht2_n,       
          Q  => wen_ht2_c,
          clk => clk,
          reset => reset
          ); 
wen_fc_ff : FF
    generic map(N => 1)
    port map(
          D  => wen_fc_n,       
          Q  => wen_fc_c,
          clk => clk,
          reset => reset
          );  
wu: ram 
  generic map(
    d_width => 64,    --width of each data word
    size    => 6145)  --number of data words the memory can store
  port map(
    clk      => clk,                             --system clock
    wrn_ena  => wen_wu,                           --write enable negative
    addr     => addr_weights_mem_int,           --address to write/read
    data_in  => bitstream_weights,  --input data to write
    data_out => weight_1u
    );
wr: ram 
  generic map(
    d_width => 64,    --width of each data word
    size    => 6145)  --number of data words the memory can store
  port map(
    clk      => clk,                             --system clock
    wrn_ena  => wen_wr,                           --write enable negative
    addr     => addr_weights_mem_int,           --address to write/read
    data_in  => bitstream_weights,  --input data to write
    data_out => weight_1r
    );
wc: ram 
  generic map(
    d_width => 64,    --width of each data word
    size    => 6145)  --number of data words the memory can store
  port map(
    clk      => clk,                             --system clock
    wrn_ena  => wen_wc,                           --write enable negative
    addr     => addr_weights_mem_int,           --address to write/read
    data_in  => bitstream_weights,  --input data to write
    data_out => weight_1c
    );
bubr: ram 
  generic map(
    d_width => 32,    --width of each data word
    size    => 256)  --number of data words the memory can store
  port map(
    clk      => clk,                             --system clock
    wrn_ena  => wen_bubr,                           --write enable negative
    addr     => addr_bias_mem_int,           --address to write/read
    data_in  => bitstream_bias,  --input data to write
    data_out => bias_bubr
    );
bc_ff: ram 
  generic map(
    d_width => 32,    --width of each data word
    size    => 256)  --number of data words the memory can store
  port map(
    clk      => clk,                             --system clock
    wrn_ena  => wen_bc,                           --write enable negative
    addr     => addr_bias_mem_int,           --address to write/read
    data_in  => bitstream_bias,  --input data to write
    data_out => bias_bc
    );
xt1_ff: ram 
  generic map(
    d_width => 64,    --width of each data word
    size    => 32)  --number of data words the memory can store
  port map(
    clk      => clk,                             --system clock
    wrn_ena  => wen_xt1,                           --write enable negative
    addr     => addr_xt_mem_int,           --address to write/read
    data_in  => bitstream_xt,  --input data to write
    data_out => xt1
    );
xt2_ff: ram 
  generic map(
    d_width => 64,    --width of each data word
    size    => 32)  --number of data words the memory can store
  port map(
    clk      => clk,                             --system clock
    wrn_ena  => wen_xt2,                           --write enable negative
    addr     => addr_xt_mem_int,           --address to write/read
    data_in  => bitstream_xt,  --input data to write
    data_out => xt2
    );
hprev1_ff: ram 
  generic map(
    d_width => 64,    --width of each data word
    size    => 32)  --number of data words the memory can store
  port map(
    clk      => clk,                             --system clock
    wrn_ena  => wen_hprev1,                           --write enable negative
    addr     => addr_hprev_mem_int,           --address to write/read
    data_in  => bitstream_hprev,  --input data to write
    data_out => hprev1
    );
hprev2_ff: ram 
  generic map(
    d_width => 64,    --width of each data word
    size    => 32)  --number of data words the memory can store
  port map(
    clk      => clk,                             --system clock
    wrn_ena  => wen_hprev2,                           --write enable negative
    addr     => addr_hprev_mem_int,           --address to write/read
    data_in  => bitstream_hprev,  --input data to write
    data_out => hprev2
    );

ht1_ff: ram 
  generic map(
    d_width => 64,    --width of each data word
    size    => 32)  --number of data words the memory can store
  port map(
    clk      => clk,                             --system clock
    wrn_ena  => wen_ht1_c(0),                           --write enable negative
    addr     => addr_ht_mem_int,           --address to write/read
    data_in  => bitstream_ht,  --input data to write
    data_out => ht1
    );
ht2_ff: ram 
  generic map(
    d_width => 64,    --width of each data word
    size    => 32)  --number of data words the memory can store
  port map(
    clk      => clk,                             --system clock
    wrn_ena  => wen_ht2_c(0),                           --write enable negative
    addr     => addr_ht_mem_int,           --address to write/read
    data_in  => bitstream_ht,  --input data to write
    data_out => ht2
    );
fc_weights_ff: ram 
  generic map(
    d_width => 32,    --width of each data word
    size    => 129)  --number of data words the memory can store
  port map(
    clk      => clk,                             --system clock
    wrn_ena  => wen_fc_c(0),                           --write enable negative
    addr     => addr_fc_mem_int,           --address to write/read
    data_in  => bitstream_fc,  --input data to write
    data_out => fc_weights
    );

end Behavioral;

