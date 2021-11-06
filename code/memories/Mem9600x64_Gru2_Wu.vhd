library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-- -- ST_SPHS_9600x64_mem2014
--words = 9600
--bits  = 64

entity Mem9600x64_Gru2_Wu is
  port (
    ClkxCI  : in  std_logic;
    CSxSI   : in  std_logic;            -- Active Low
    WExSI   : in  std_logic;            --Active Low
    AddrxDI : in  std_logic_vector (13 downto 0);
    RYxSO   : out std_logic;
    DataxDI : in  std_logic_vector (63 downto 0);
    DataxDO : out std_logic_vector (63 downto 0)
    );
end Mem9600x64_Gru2_Wu;


architecture rtl of Mem9600x64_Gru2_Wu is
  
component dist_mem_gen_12 is
  PORT (
    a : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
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
  csn <= not CSxSI;
  wen <= not WExSI;

    DUT_ST_SPHS_9600x64_mem2014 :dist_mem_gen_12
    port map(
        a   => AddrxDI,
        d   => DataxDI,
        clk => ClkxCI,
        we  => wen,
        spo => DataxDO  
    );
end rtl;
