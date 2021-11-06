----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2021 05:37:56 PM
-- Design Name: 
-- Module Name: input_controller - Behavioral
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity input_controller is
    generic(
            INPUT_NUMBER_WIDTH:integer:=8;--256 inputs
            HIDDEN_UNITS_NUMBER_WIDTH:integer:=7;--128 h(t-1) 
            HIDDEN_LAYERS_NUMBER_WIDTH:integer:=7;--128 layers    
            PARALLELISM_WIDTH: integer:= 3--8
            );
    Port (
        clk              : in std_logic; 
        reset            : in std_logic;
        start            : in std_logic;
        input_done       : in std_logic;
        h_prev_done      : in std_logic;
        op_done          : in std_logic;
--        initial          : out std_logic;
        xt_state         : out std_logic;
        hprev_state      : out std_logic;
        addr_input_out   : out std_logic_vector(INPUT_NUMBER_WIDTH-PARALLELISM_WIDTH-1 downto 0);--5 bit:32
        addr_w_u_out     : out std_logic_vector(INPUT_NUMBER_WIDTH+ 8 -PARALLELISM_WIDTH-1 downto 0);--13 bit:6144
        addr_bias_out    : out std_logic_vector(HIDDEN_LAYERS_NUMBER_WIDTH-1 downto 0);
        addr_hprev_out   : out std_logic_vector(HIDDEN_UNITS_NUMBER_WIDTH-PARALLELISM_WIDTH-1 downto 0)--4
         );
end input_controller;


architecture Behavioral of input_controller is
-------components------------------------------------------------
component FF 
  generic(N:integer:=1);
  port(   D  :  in std_logic_vector(N-1 downto 0);
          Q  : out std_logic_vector(N-1 downto 0);
        clk  :  in std_logic;
        reset:  in std_logic
      );
end component;
---signals------------------------------------------------------------
type state_type is (idle, first_input, input, h_prev);
signal current_state, next_state: state_type;
signal input1_c,input1_n,input2_c,input2_n,input3_c,input3_n,input4_c,input4_n:std_logic_vector(31 downto 0);
signal weight1_u_c,weight1_u_n,weight1_r_c,weight1_r_n,weight1_c_c,weight1_c_n:std_logic_vector(31 downto 0);
signal bias_c,bias_n:std_logic_vector(31 downto 0);
signal mem_input_en,mem_w_u_en,mem_b_en,mem_h_prev_en:std_logic;
signal xt_state_c,xt_state_n,hprev_state_c,hprev_state_n: std_logic_vector(0 downto 0);
signal addr_input,addr_input_next: std_logic_vector(INPUT_NUMBER_WIDTH-PARALLELISM_WIDTH-1 downto 0);
signal addr_h_prev,addr_h_prev_next: std_logic_vector(HIDDEN_UNITS_NUMBER_WIDTH-PARALLELISM_WIDTH-1 downto 0);
signal addr_w_u,addr_w_u_next: std_logic_vector(INPUT_NUMBER_WIDTH+ 8 -PARALLELISM_WIDTH-1 downto 0);
signal addr_bias,addr_bias_next: std_logic_vector(HIDDEN_LAYERS_NUMBER_WIDTH-1 downto 0);

begin
------combinational logic-------------------------------------------------
xt_state <= xt_state_c(0);
hprev_state<= hprev_state_c(0);
addr_w_u_out <= addr_w_u;
addr_input_out <= addr_input;
addr_bias_out <= addr_bias;
addr_hprev_out <= addr_h_prev;
------fsm----------------------------------------------------------------
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
    
process(current_state,start,input_done, h_prev_done,op_done,addr_input,addr_w_u,addr_bias,addr_h_prev)
    begin
--        initial <= '0';
        xt_state_n <= "0";
        hprev_state_n <= "0";
        addr_bias_next <= (others => '0');
        addr_input_next <= (others => '0');
        addr_w_u_next <= (others => '0');
        addr_h_prev_next <= (others => '0');
        next_state<=current_state;
        case current_state is 
            when idle=>
--                mem_input_en <= '0'; 
--                mem_w_u_en <= '0';   
--                mem_b_en <= '0';     
--                mem_h_prev_en <= '0';
--                initial <= '1';
                if start='1' then
                    next_state<=first_input;
                    addr_w_u_next <= addr_w_u + 1;
                    xt_state_n <= "1";
                else
                    next_state<=idle;
                end if;
            when first_input=>
--                mem_input_en <= '1';
--                mem_w_u_en <= '1';
--                mem_b_en <= '1';
--                mem_h_prev_en <= '0';
                xt_state_n <= "1";
                addr_input_next <= addr_input + 1;
                addr_w_u_next <= addr_w_u + 1;
                addr_bias_next <= addr_bias + 1;
                next_state<=input;
            when input=>
--                mem_input_en <= '1'; 
--                mem_w_u_en <= '1';   
--                mem_b_en <= '0';     
--                mem_h_prev_en <= '0';
                xt_state_n <= "1";
                addr_bias_next <= addr_bias;
                addr_input_next <= addr_input + 1;
                addr_w_u_next <= addr_w_u + 1;    
                if input_done='1' then
                    next_state<=h_prev;
                    addr_w_u_next <= addr_w_u + 1;
                else 
                    next_state<=input;
                    addr_w_u_next <= addr_w_u + 1;
                end if;
             when h_prev=>
--                mem_input_en <= '0'; 
--                mem_w_u_en <= '1';   
--                mem_b_en <= '0';     
--                mem_h_prev_en <= '1';
                hprev_state_n <= "1";
                addr_h_prev_next <= addr_h_prev + 1;
                addr_w_u_next <= addr_w_u + 1; 
                addr_bias_next <= addr_bias;
                if h_prev_done='1' then
                    if op_done = '1' then
                        next_state <= idle;
                    else
                        next_state <= first_input;
                        addr_w_u_next <= addr_w_u + 1;
                    end if;
                else
                    next_state<=h_prev;
                    addr_w_u_next <= addr_w_u + 1;
                end if;        
            end case;
end process;
addr_inputs : FF
    generic map(N =>INPUT_NUMBER_WIDTH-PARALLELISM_WIDTH)
    port map(
          D  => addr_input_next,       
          Q  => addr_input,
          clk => clk,
          reset => reset
          );    
          
addr_wu : FF
    generic map(N => INPUT_NUMBER_WIDTH+ 8 -PARALLELISM_WIDTH)
    port map(
          D  => addr_w_u_next,       
          Q  => addr_w_u,
          clk => clk,
          reset => reset
          );    
           
addr_hprev : FF
    generic map(N => HIDDEN_UNITS_NUMBER_WIDTH-PARALLELISM_WIDTH)
    port map(
          D  => addr_h_prev_next,       
          Q  => addr_h_prev,
          clk => clk,
          reset => reset
          );
addr_bias_ff : FF
    generic map(N => HIDDEN_LAYERS_NUMBER_WIDTH)
    port map(
          D  => addr_bias_next,       
          Q  => addr_bias,
          clk => clk,
          reset => reset
          );   
xt_state_ff : FF
    generic map(N => 1)
    port map(
          D  => xt_state_n,       
          Q  => xt_state_c,
          clk => clk,
          reset => reset
          ); 
hprev_state_ff : FF
    generic map(N => 1)
    port map(
          D  => hprev_state_n,       
          Q  => hprev_state_c,
          clk => clk,
          reset => reset
          );      
end Behavioral;
