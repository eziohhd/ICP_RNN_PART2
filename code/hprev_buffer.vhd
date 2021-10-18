----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/05/19 23:51:32
-- Design Name: 
-- Module Name: h_prev_buffer - Behavioral
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



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity h_prev_buffer is
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
end h_prev_buffer;

architecture Behavioral of h_prev_buffer is
alias count8 is  count_ver_g(2 downto 0) ;
signal h_prev_reg, h_prev_next:  std_logic_vector(15 downto 0);
component FF 
  generic(N:integer:=1);
  port(   D  :  in std_logic_vector(N-1 downto 0);
          Q  : out std_logic_vector(N-1 downto 0);
        clk  :  in std_logic;
        reset:  in std_logic
      );
end component;
constant period1         : time := 5ns;
begin

h_prev_ff : FF
  generic map(N => 16)
  port map(
          D  => h_prev_next,       
          Q  => h_prev_reg,
          clk => clk,
          reset => reset
          ); 
          
h_prev_next<=   input1(31 downto 16) when unsigned(count_ver_g(6 downto 3))=unsigned(count_hor_g) - to_unsigned((INPUT_SIZE)/8,6) and count8="000" else
                input1(15 downto 0)  when unsigned(count_ver_g(6 downto 3))=unsigned(count_hor_g) - to_unsigned((INPUT_SIZE)/8,6) and count8="001" else
                input2(31 downto 16) when unsigned(count_ver_g(6 downto 3))=unsigned(count_hor_g) - to_unsigned((INPUT_SIZE)/8,6) and count8="010" else
                input2(15 downto 0)  when unsigned(count_ver_g(6 downto 3))=unsigned(count_hor_g) - to_unsigned((INPUT_SIZE)/8,6) and count8="011" else
                input3(31 downto 16) when unsigned(count_ver_g(6 downto 3))=unsigned(count_hor_g) - to_unsigned((INPUT_SIZE)/8,6) and count8="100" else
                input3(15 downto 0)  when unsigned(count_ver_g(6 downto 3))=unsigned(count_hor_g) - to_unsigned((INPUT_SIZE)/8,6) and count8="101" else
                input4(31 downto 16) when unsigned(count_ver_g(6 downto 3))=unsigned(count_hor_g) - to_unsigned((INPUT_SIZE)/8,6) and count8="110" else
                input4(15 downto 0)  when unsigned(count_ver_g(6 downto 3))=unsigned(count_hor_g) - to_unsigned((INPUT_SIZE)/8,6) and count8="111" else
                h_prev_reg;  

h_prev<=h_prev_reg;
end Behavioral;

