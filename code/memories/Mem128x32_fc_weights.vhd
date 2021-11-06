library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-- -- ST_SPHDL_128x32_mem2010
--words = 128
--bits  = 32

entity Mem128x32_fc_weights is
  port (
    ClkxCI  : in  std_logic;
    CSxSI   : in  std_logic;            -- Active Low
    WExSI   : in  std_logic;            --Active Low
    AddrxDI : in  std_logic_vector (6 downto 0);
    RYxSO   : out std_logic;
    DataxDI : in  std_logic_vector (31 downto 0);
    DataxDO : out std_logic_vector (31 downto 0)
    );
end Mem128x32_fc_weights;


architecture rtl of Mem128x32_fc_weights is
  
--  component ST_SPHDL_128x32m8_L
--    port (
--      Q       : out std_logic_vector (31 downto 0);
--      RY      : out std_logic;
--      CK      : in  std_logic;
--      CSN     : in  std_logic;
--      TBYPASS : in  std_logic;
--      WEN     : in  std_logic;
--      A       : in  std_logic_vector (6 downto 0);
--      D       : in  std_logic_vector (31 downto 0)
--      );
--  end component;
--  component blk_mem_gen_1 is
--  PORT (
--    clka : IN STD_LOGIC;
--    ena : IN STD_LOGIC;
--    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
--    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
--    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
--  );
--end component;
component dist_mem_gen_11 is
  PORT (
    a : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end component;

  signal LOW  : std_logic;
  signal HIGH : std_logic;
  signal csn  : std_logic;
  signal wen  : std_logic;

begin

  LOW  <= '0';
  HIGH <= '1';
  csn <= not CSxSI;
  wen <= not WExSI;

-- mem2011
--  DUT_ST_SPHDL_128x32_mem2010 : blk_mem_gen_1
--    port map(
--        clka => ClkxCI,
--        ena  => csn,
--        wea  => wen,
--        addra => AddrxDI,
--        dina  => DataxDI,
--        douta => DataxDO  
--        );
    DUT_ST_SPHDL_128x32_mem2010 : dist_mem_gen_11
    port map(  
        a   => AddrxDI,
        d   => DataxDI,
        clk => ClkxCI,
        we  => wen,
        spo => DataxDO   
    );

end rtl;


