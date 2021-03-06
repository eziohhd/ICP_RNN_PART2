library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_RNN is
end tb_RNN;

architecture Behavioral of tb_RNN is
--component------------------------------------------------------
component TOP_RNN is
port(
      clk_in                   : in std_logic;--top pad
      reset                    : in std_logic;--top pad
      initial_in               : in std_logic;--top pad
      start_in                 : in std_logic;--top pad
      final_result             : out std_logic
     -- data_out                : out std_logic_vector(15 downto 0)--top pad 
      );
end component;

------signals_gru1------------------------------------------------------------
constant MED_WL          :integer:=24;
constant MED_FL          :integer:=13;
constant FC_WL           :integer:=24;
signal reset,ready       : std_logic;
signal clk               : std_logic := '1';
signal initial           : std_logic;
signal start             : std_logic ;
signal data_out          : std_logic_vector(15 downto 0);
signal data_in           : std_logic_vector(15 downto 0);
signal data_wu           : std_logic_vector(15 downto 0);
signal data_wr           : std_logic_vector(15 downto 0);
signal data_wc           : std_logic_vector(15 downto 0);
signal data_xt           : std_logic_vector(15 downto 0);
signal data_hprev        : std_logic_vector(15 downto 0);
signal data_bubr         : std_logic_vector(15 downto 0);
signal data_bc           : std_logic_vector(15 downto 0);
signal input_write_en_wu       : std_logic; 
signal input_write_en_wr       : std_logic; 
signal input_write_en_wc       : std_logic; 
signal input_write_en_bubr     : std_logic; 
signal input_write_en_bc       : std_logic; 
signal input_write_en_xt       : std_logic; 
signal input_write_en_hprev    : std_logic;  
signal data_gru2_wu      : std_logic_vector(15 downto 0);
signal data_gru2_wr      : std_logic_vector(15 downto 0);
signal data_gru2_wc      : std_logic_vector(15 downto 0);
signal data_gru2_bubr    : std_logic_vector(15 downto 0);
signal data_gru2_bc      : std_logic_vector(15 downto 0);
signal data_gru2_hprev   : std_logic_vector(15 downto 0);
signal data_fc           : std_logic_vector(15 downto 0);
signal input_write_en_gru2_wu  : std_logic;
signal input_write_en_gru2_wr  : std_logic;
signal input_write_en_gru2_wc  : std_logic;
signal input_write_en_gru2_bubr: std_logic;
signal input_write_en_gru2_bc  : std_logic;
signal input_write_en_gru2_hprev : std_logic; 
signal input_write_en_fc_weights : std_logic;
signal result_valid_out         : std_logic;
constant period1              : time := 5ns;
   
begin
----signals into chip-------------------------------------------------------------
     data_in <=  (others=>'0');
     reset <= '0' ,
               '1' after    200*period1*4,
               '0' after    302*period1*4, 
               '1' after    2000000*period1,
               '0' after    2000010*period1;      
     clk <= not (clk) after 1*period1;
     initial <= '0',
                '1' after 500*period1,
                '0' after 202000*period1;
     start <= '0',
               '1' after 800000*period1,
               '0' after 1102000*period1;
               
          

-----duts------------------------------------------------------------------
   top: TOP_RNN
   port map(
        clk_in                   =>  clk                      ,
        reset                    =>  reset                    ,
        initial_in                  =>  initial                  ,
        start_in                    =>  start                    ,
        final_result         =>  result_valid_out
        --data_out                 =>  data_out
            );
end Behavioral;
