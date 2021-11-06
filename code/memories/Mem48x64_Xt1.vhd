library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-- -- ST_SPHS_48x64_mem2011
--words = 48
--bits  = 64

entity Mem48x64_Xt1 is
  port (
    ClkxCI  : in  std_logic;
    CSxSI   : in  std_logic;            -- Active Low
    WExSI   : in  std_logic;            --Active Low
    AddrxDI : in  std_logic_vector (5 downto 0);
    RYxSO   : out std_logic;
    DataxDI : in  std_logic_vector (63 downto 0);
    DataxDO : out std_logic_vector (63 downto 0)
    );
end Mem48x64_Xt1;


architecture rtl of Mem48x64_Xt1 is
  
--  component ST_SPHS_48x64m4_L
--    port (
--      Q       : out std_logic_vector (63 downto 0);
--      RY      : out std_logic;
--      CK      : in  std_logic;
--      CSN     : in  std_logic;
--      TBYPASS : in  std_logic;
--      WEN     : in  std_logic;
--      A       : in  std_logic_vector (5 downto 0);
--      D       : in  std_logic_vector (63 downto 0)
--      );
--  end component;
--component blk_mem_gen_2 is
--  PORT (
--    clka : IN STD_LOGIC;
--    ena : IN STD_LOGIC;
--    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addra : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
--    dina : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
--    douta : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
--  );

--end component;
component dist_mem_gen_5 is
  PORT (
    a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    d : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    spo : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
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
--  DUT_ST_SPHS_48x64_mem2011 :blk_mem_gen_5
--    port map(
--        clka => ClkxCI,
--        ena  => csn,
--        wea  => wen,
--        addra => AddrxDI,
--        dina  => DataxDI,
--        douta => DataxDO  
--        );
  DUT_ST_SPHS_48x64_mem2011 :dist_mem_gen_5
    port map(
        a   => AddrxDI,
        d   => DataxDI,
        clk => ClkxCI,
        we  => wen,
        spo => DataxDO 
        );
end rtl;

