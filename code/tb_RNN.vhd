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
      clk_in                      : in std_logic;--top pad
      reset                    : in std_logic;--top pad
      initial                  : in std_logic;--top pad
      start                    : in std_logic;--top pad
      data_in                  : in std_logic_vector(15 downto 0);--top pad
      input_write_en_wu        : out std_logic; --top pad
      input_write_en_wr        : out std_logic; --top pad
      input_write_en_wc        : out std_logic; --top pad
      input_write_en_bubr      : out std_logic; --top pad
      input_write_en_bc        : out std_logic; --top pad
      input_write_en_xt        : out std_logic; --top pad
      input_write_en_hprev     : out std_logic; --top pad    
      input_write_en_gru2_wu   : out std_logic; --top pad
      input_write_en_gru2_wr   : out std_logic; --top pad
      input_write_en_gru2_wc   : out std_logic; --top pad
      input_write_en_gru2_bubr : out std_logic; --top pad
      input_write_en_gru2_bc   : out std_logic; --top pad   
      input_write_en_gru2_hprev: out std_logic; --top pad     
      input_write_en_fc_weights: out std_logic;--top pad 
      data_out                : out std_logic_vector(15 downto 0)--top pad 
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
constant period1              : time := 5ns;
   
begin
----signals into chip-------------------------------------------------------------
     data_in <=  (others=>'0');
     reset <= '1' ,
               '0' after    4*period1;        
     clk <= not (clk) after 1*period1;
     initial <= '1',
                '0' after 50*period1*5;
     start <= '0',
               '1' after 200000*period1*5,
               '0' after 200002*period1*5;

-----duts------------------------------------------------------------------
   top: TOP_RNN
   port map(
        clk_in                   =>  clk                      ,
        reset                    =>  reset                    ,
        initial                  =>  initial                  ,
        start                    =>  start                    ,
        data_in                  =>  data_in                  ,
        input_write_en_wu        =>  input_write_en_wu        ,
        input_write_en_wr        =>  input_write_en_wr        ,
        input_write_en_wc        =>  input_write_en_wc        ,
        input_write_en_bubr      =>  input_write_en_bubr      ,
        input_write_en_bc        =>  input_write_en_bc        ,
        input_write_en_xt        =>  input_write_en_xt        ,
        input_write_en_hprev     =>  input_write_en_hprev     ,
        input_write_en_gru2_wu   =>  input_write_en_gru2_wu   ,
        input_write_en_gru2_wr   =>  input_write_en_gru2_wr   ,
        input_write_en_gru2_wc   =>  input_write_en_gru2_wc   ,
        input_write_en_gru2_bubr =>  input_write_en_gru2_bubr ,
        input_write_en_gru2_bc   =>  input_write_en_gru2_bc   , 
        input_write_en_gru2_hprev=>  input_write_en_gru2_hprev,
        input_write_en_fc_weights=>  input_write_en_fc_weights,
        data_out                 =>  data_out
            );
end Behavioral;
