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
      clk                      : in std_logic;--top pad
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

component input_gen is
    generic (
        FILE_NAME: string ;
        INPUT_WIDTH: positive
        ); 
    Port (
        clk: in std_logic;
        reset: in std_logic;
        input_write_en: in std_logic;
        input_sample: out std_logic_vector(INPUT_WIDTH-1 downto 0)
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
     data_in <= data_wu when input_write_en_wu = '1' else
                data_wr when input_write_en_wr = '1' else
                data_wc when input_write_en_wc = '1' else
                data_bubr when input_write_en_bubr = '1' else
                data_bc when input_write_en_bc = '1' else
                data_xt when input_write_en_xt = '1' else
                data_hprev when input_write_en_hprev = '1' else
                data_gru2_wu when input_write_en_gru2_wu = '1' else
                data_gru2_wr when input_write_en_gru2_wr = '1' else
                data_gru2_wc when input_write_en_gru2_wc = '1' else
                data_gru2_bubr when input_write_en_gru2_bubr = '1' else
                data_gru2_bc when input_write_en_gru2_bc = '1' else 
                data_gru2_hprev when input_write_en_gru2_hprev = '1' else
                data_fc      when input_write_en_fc_weights = '1' else
                (others=>'0');
     reset <= '1' ,
               '0' after    4*period1;        
     clk <= not (clk) after 1*period1;
     initial <= '1',
                '0' after 6*period1;
     start <= '0',
               '1' after 200000*period1,
               '0' after 200002*period1;
--bitstream----------------------------------------------------------------
input_Wu: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/Wu_binary_new.txt" ,
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_wu,
    input_sample => data_wu
    );

input_Wr: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/Wr_binary_new.txt" ,
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_wr,
    input_sample =>data_wr
    );
input_Wc: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/Wc_binary_new.txt",
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_wc,
    input_sample => data_wc
    );       

input_xt: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/xt_binary_new.txt",
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_xt,
    input_sample => data_xt
    );
input_hprev: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/h175_binary_new.txt",
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_hprev,
    input_sample => data_hprev
    );
input_Bu_Br: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/BuBr_binary_new.txt",
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_bubr,
    input_sample => data_bubr
    );
input_Bc: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/Bc_binary_new.txt",
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_bc,
    input_sample => data_bc
    );
input_gru2_Wu: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/GRU2_Wu_binary_new.txt" ,
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_gru2_wu,
    input_sample => data_gru2_wu
    );

input_gru2_Wr: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/GRU2_Wr_binary_new.txt" ,
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_gru2_wr,
    input_sample =>data_gru2_wr
    );
input_gru2_Wc: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/GRU2_Wc_binary_new.txt",
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_gru2_wc,
    input_sample => data_gru2_wc
    );  
input_gru2_BuBr: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/GRU2_BuBr_binary_new.txt",
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_gru2_bubr,
    input_sample => data_gru2_bubr
    );
input_gru2_Bc: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/GRU2_Bc_binary_new.txt",
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_gru2_bc,
    input_sample => data_gru2_bc
    );
input_gru2_hprev: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/GRU2_h_prev_binary_new.txt",
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_gru2_hprev,
    input_sample => data_gru2_hprev
    );
input_fc_weights: input_gen 
generic map(
    FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/ICP_RNN/binary_files/fc_weights_new.txt",
    INPUT_WIDTH => 16
    )
Port map(
    clk     => clk,
    reset   => reset,
    input_write_en => input_write_en_fc_weights,
    input_sample => data_fc
    );
-----duts------------------------------------------------------------------
   top: TOP_RNN
   port map(
        clk                      =>  clk                      ,
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
