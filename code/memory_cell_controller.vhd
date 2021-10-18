----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/04/16 00:07:52
-- Design Name: 
-- Module Name: memory_cell_controller - Behavioral
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
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory_cell_controller is
  generic(MED_WL:integer:=24;
          MED_FL:integer:=13
          );

  Port (
        clk  : in std_logic; 
        reset: in std_logic;
        GRU_en: in std_logic;
        input_done_g  : in std_logic;
        h_prev_done_g : in std_logic;
        op_done_g     : in std_logic;
        input1      : in std_logic_vector(31 downto 0);
        input2      : in std_logic_vector(31 downto 0);
        input3      : in std_logic_vector(31 downto 0);
        input4      : in std_logic_vector(31 downto 0);
        weight_c1   : in std_logic_vector(31 downto 0);
        weight_c2   : in std_logic_vector(31 downto 0);
        bias        : in std_logic_vector(31 downto 0);
        output_cx   : out std_logic_vector(MED_WL-1 downto 0);
        output_ch   : out std_logic_vector(MED_WL-1 downto 0)
        );
end memory_cell_controller;

architecture Behavioral of memory_cell_controller is
------------------signals-------------------------------------------------
type state_type is (idle, first_op_input, op_input, first_op_h_prev, op_h_prev);
signal current_state, next_state: state_type;
signal temp: std_logic_vector(MED_WL-1 downto 0);
signal p_input, p_input_next: std_logic_vector(MED_WL-1 downto 0);
signal p_h, p_h_next: std_logic_vector(MED_WL-1 downto 0);
signal p, p_next: std_logic_vector(MED_WL-1 downto 0);
--signal weight_c1_c   : std_logic_vector(31 downto 0);
--signal weight_c2_c   : std_logic_vector(31 downto 0);
--signal input1_c      : std_logic_vector(31 downto 0);
--signal input2_c      : std_logic_vector(31 downto 0);
--signal input3_c      : std_logic_vector(31 downto 0);
--signal input4_c      : std_logic_vector(31 downto 0);
--signal bias_c        : std_logic_vector(31 downto 0);
------------------alias-------------------------------------------------
alias x1 is  input1(31 downto 16);
alias x2 is  input1(15 downto 0);
alias x3 is  input2(31 downto 16);
alias x4 is  input2(15 downto 0);
alias x5 is  input3(31 downto 16);
alias x6 is  input3(15 downto 0);
alias x7 is  input4(31 downto 16);
alias x8 is  input4(15 downto 0);
alias wc1 is weight_c1(31 downto 24);
alias wc2 is weight_c1(23 downto 16);
alias wc3 is weight_c1(15 downto 8);
alias wc4 is weight_c1(7 downto 0);
alias wc5 is weight_c2(31 downto 24);
alias wc6 is weight_c2(23 downto 16);
alias wc7 is weight_c2(15 downto 8);
alias wc8 is weight_c2(7 downto 0);
alias bc:std_logic_vector(7 downto 0) is bias(15 downto 8);
component FF 
  generic(N:integer:=1);
  port(   D  :  in std_logic_vector(N-1 downto 0);
          Q  : out std_logic_vector(N-1 downto 0);
        clk  :  in std_logic;
        reset:  in std_logic
      );
end component;

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
    
    process(current_state,GRU_en,input_done_g, h_prev_done_g,op_done_g, p, p_next, bc)
    begin
        temp<=(others=>'0');
        p_input_next<=p_input;
        p_h_next<=p_h;
        next_state<=current_state;
        case current_state is 
            when idle=>
                if GRU_en='1' then
                    next_state<=first_op_input;
                else
                    next_state<=idle;
                end if;

            when first_op_input=>
                if bc(7)='0' then 
                    temp<=std_logic_vector(to_signed(0,MED_WL-MED_FL-1)) & bc & std_logic_vector(to_unsigned(0,MED_FL-7));
                else
                    temp<=std_logic_vector(to_signed(-1,MED_WL-MED_FL-1)) & bc & std_logic_vector(to_unsigned(0,MED_FL-7));
                end if;
                p_input_next<=p_next;
                next_state<=op_input;
            when op_input=>
                temp<=p;
                p_input_next<=p_next;
                if input_done_g='1' then
                    next_state<=first_op_h_prev;
                else 
                    next_state<=op_input;
                end if;
             when first_op_h_prev=>
                temp<=(others=>'0');
                 p_h_next<=p_next;
                 next_state <= op_h_prev;
             when op_h_prev=>
                temp<=p;
                p_h_next<=p_next;
                if h_prev_done_g='1' then
                    if op_done_g='1' then
                        next_state<=idle;
                    else 
                        next_state<=first_op_input;
                    end if;
                    else
                        next_state<=op_h_prev;
                end if;                                        
            end case;
     end process;

input_result : FF
  generic map(N => MED_WL)
  port map(
          D  => p_input_next,       
          Q  => p_input,
          clk => clk,
          reset => reset
          );    
          
h_prev_result : FF
  generic map(N => MED_WL)
  port map(
          D  => p_h_next,       
          Q  => p_h,
          clk => clk,
          reset => reset
          );    
           
memory_cell_result : FF
  generic map(N => MED_WL)
  port map(
          D  => p_next,       
          Q  => p,
          clk => clk,
          reset => reset
          );

With current_state select
    p_next<=(others=>'0') when idle,
            std_logic_vector(resize(shift_right(signed(x1)*signed(wc1)+signed(x2)*signed(wc2)+signed(x3)*signed(wc3)+signed(x4)*signed(wc4)+signed(x5)*signed(wc5)+signed(x6)*signed(wc6)+signed(x7)*signed(wc7)+signed(x8)*signed(wc8),20-MED_FL)+signed(temp),MED_WL)) when others; 


output_cx<=p_input;
output_ch<=p_h;
end Behavioral;
