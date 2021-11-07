----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2021 04:19:55 PM
-- Design Name: 
-- Module Name: edge_detector - Behavioral
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
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity edge_detector is
    port (
      clk : in std_logic;
      reset : in std_logic;
      button : in std_logic;
      edge_found : out std_logic
  );
end edge_detector;


architecture edge_detector_arch of edge_detector is
    signal button_reg, edge_found_next : std_logic;
begin
    --registers
    process (clk, reset)
    begin
        if (reset = '1') then
            button_reg <= '0';
            edge_found <= '0';
        elsif rising_edge(clk) then
            button_reg <= button;
            edge_found <= edge_found_next;
        end if;
    end process;  
    --next state logic
    edge_found_next <= button when (button_reg = '0') else
                       '0'; 
end edge_detector_arch;
