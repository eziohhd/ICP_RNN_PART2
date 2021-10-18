----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/05/20 11:02:41
-- Design Name: 
-- Module Name: GRU_sel - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity GRU_select is
  Port (clk   : in std_logic; 
        reset : in std_logic;
        start : in std_logic;
        start_gru2 : in std_logic;
        GRU_sel:  out std_logic
         );
end GRU_select;

architecture Behavioral of GRU_select is
signal GRU_sel_reg,GRU_sel_next : std_logic_vector(0 downto 0);

component FF 
  generic(N:integer:=1);
  port(   D  :  in std_logic_vector(N-1 downto 0);
          Q  : out std_logic_vector(N-1 downto 0);
        clk  :  in std_logic;
        reset:  in std_logic
      );
end component;
begin

GRU_sel_ff : FF
    generic map(N => 1)
    port map(
          D  => GRU_sel_next,       
          Q  => GRU_sel_reg,
          clk => clk,
          reset => reset
          ); 
GRU_sel_next<="0" when start='1' else
              "1" when start_gru2='1' else
              GRU_sel_reg;
GRU_sel<='0' when GRU_sel_next="0" else
         '1';                                 
end Behavioral;
