----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/04/28 22:33:07
-- Design Name: 
-- Module Name: input_buffer - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity input_buffer is
  Port (clk  : in std_logic; 
        reset: in std_logic;
        start: in std_logic;
        input1      : in std_logic_vector(31 downto 0);
        input2      : in std_logic_vector(31 downto 0);
        input3      : in std_logic_vector(31 downto 0);
        input4      : in std_logic_vector(31 downto 0);
        weight_u1   : in std_logic_vector(31 downto 0);
        weight_u2   : in std_logic_vector(31 downto 0);
        weight_r1   : in std_logic_vector(31 downto 0);
        weight_r2   : in std_logic_vector(31 downto 0);
        weight_c1   : in std_logic_vector(31 downto 0);
        weight_c2   : in std_logic_vector(31 downto 0);
        bias        : in std_logic_vector(31 downto 0);
        GRU_en      : out std_logic;
        input1_o     : out std_logic_vector(31 downto 0);
        input2_o     : out std_logic_vector(31 downto 0);
        input3_o     : out std_logic_vector(31 downto 0);
        input4_o     : out std_logic_vector(31 downto 0);
        weight_u1_o  : out std_logic_vector(31 downto 0);
        weight_u2_o  : out std_logic_vector(31 downto 0);
        weight_r1_o  : out std_logic_vector(31 downto 0);
        weight_r2_o  : out std_logic_vector(31 downto 0);
        weight_c1_o  : out std_logic_vector(31 downto 0);
        weight_c2_o  : out std_logic_vector(31 downto 0);
        bias_o       : out std_logic_vector(31 downto 0)
         );
end input_buffer;

architecture Behavioral of input_buffer is
component FF 
  generic(N:integer:=1);
  port(   D  :  in std_logic_vector(N-1 downto 0);
          Q  : out std_logic_vector(N-1 downto 0);
        clk  :  in std_logic;
        reset:  in std_logic
      );
end component;
type state_type is (idle ,delay1, delay2);
signal current_state, next_state: state_type;

begin
--state machine
    process(clk,reset)
    begin
        if rising_edge(clk) then
            if reset='1' then
                current_state<=idle;
            else 
                current_state<=next_state;
            end if;
        end if;
    end process;
    
   process(current_state,start) 
       begin 
           GRU_en<='0';
           next_state<=current_state; 
           case current_state is 
               when idle=>
                   if start='1' then
                       next_state<=delay1;
                   else
                       next_state<=idle;
                   end if;
               when delay1=>   
                   next_state <= delay2;                                 
               when delay2=>
                   GRU_en<='1';  
                   next_state<=idle;                  
            end case;
     end process;

weight_u1_ff : FF
    generic map(N => 32)
    port map(
          D  => weight_u1,       
          Q  => weight_u1_o,
          clk => clk,
          reset => reset
          ); 
weight_u2_ff : FF
    generic map(N => 32)
    port map(
          D  => weight_u2,       
          Q  => weight_u2_o,
          clk => clk,
          reset => reset
          ); 
weight_r1_ff : FF
    generic map(N => 32)
    port map(
          D  => weight_r1,       
          Q  => weight_r1_o,
          clk => clk,
          reset => reset
          ); 
weight_r2_ff : FF
    generic map(N => 32)
    port map(
          D  => weight_r2,       
          Q  => weight_r2_o,
          clk => clk,
          reset => reset
          ); 
weight_c1_ff : FF
    generic map(N => 32)
    port map(
          D  => weight_c1,       
          Q  => weight_c1_o,
          clk => clk,
          reset => reset
          ); 
weight_c2_ff : FF
    generic map(N => 32)
    port map(
          D  => weight_c2,       
          Q  => weight_c2_o,
          clk => clk,
          reset => reset
          ); 
bias_ff: FF
    generic map(N => 32)    
    port map(               
          D  => bias,
          Q  => bias_o,  
          clk => clk,       
          reset => reset    
          );                   
input1_FF: FF
    generic map(N => 32)    
    port map(               
          D  => input1,
          Q  => input1_o,  
          clk => clk,       
          reset => reset    
          ); 
input2_FF: FF
    generic map(N => 32)    
    port map(               
          D  => input2,
          Q  => input2_o,  
          clk => clk,       
          reset => reset    
          ); 
input3_FF: FF
    generic map(N => 32)    
    port map(               
          D  => input3,
          Q  => input3_o,  
          clk => clk,       
          reset => reset    
          ); 
input4_FF: FF
    generic map(N => 32)    
    port map(               
          D  => input4,
          Q  => input4_o,  
          clk => clk,       
          reset => reset    
          );        
    
end Behavioral;  