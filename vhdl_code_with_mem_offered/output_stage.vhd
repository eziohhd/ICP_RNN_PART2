----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/04/18 22:52:54
-- Design Name: 
-- Module Name: output_stage - Behavioral
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

entity output_stage is
--  generic(INPUT_SIZE:integer:=256;
--          SIZE_HOR  :integer:=384 
----          SIG_WL:integer:=1;
----          SIG_FL:integer:=7;
----          RES_WL:integer:=11;
----          RES_FL:integer:=13;
----          TANH_WL:integer:=1;
----          TANH_FL:integer:=7
--          );
  Port (
--        u_t         : in std_logic_vector(SIG_WL-1 downto 0);
--        r_t         : in std_logic_vector(SIG_WL-1 downto 0);
--        h_can       : in std_logic_vector(SIG_WL-1 downto 0);
--        h_t         : out std_logic_vector(RES_WL-1 downto 0)
        r_u_valid   : in std_logic;
        u_t         : in std_logic_vector(15 downto 0);
        r_t         : in std_logic_vector(15 downto 0);
        h_can       : in std_logic_vector(15 downto 0);
        h_prev       : in std_logic_vector(15 downto 0);
        h_t         : out std_logic_vector(15 downto 0)         
        );
end output_stage;

architecture Behavioral of output_stage is

begin
               
h_t<=std_logic_vector(resize(shift_right(signed(h_prev)*signed(u_t)+shift_left((shift_left(to_signed(1,16),6)- signed(u_t))*signed(h_can),7),13),16)) when r_u_valid='1' else
      (others=>'0');           
                                       
end Behavioral;
