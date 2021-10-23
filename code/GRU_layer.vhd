----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/05/20 12:38:06
-- Design Name: 
-- Module Name: GRU_layer - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity GRU_layer is
  generic(MED_WL:integer:=24;
          MED_FL:integer:=13
          );
  Port (clk           : in std_logic;                            
        reset          : in std_logic;                            
        GRU_en        : in std_logic;                           
        input_done_g  : in std_logic;                   
        h_prev_done_g : in std_logic;                   
        op_done_g     : in std_logic;
        h_prev      : in std_logic_vector(15 downto 0);                  
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
        r_u_valid_o : out std_logic; 
        h_t         : out std_logic_vector(15 downto 0)       
       );
end GRU_layer;

architecture Behavioral of GRU_layer is
component r_u_controller is  
  generic(MED_WL:integer:=24;
          MED_FL:integer:=13
          );
  Port (
        clk           : in std_logic;                            
        reset          : in std_logic;                            
        GRU_en        : in std_logic;                           
        input_done_g  : in std_logic;                   
        h_prev_done_g : in std_logic;                   
        op_done_g     : in std_logic;                   
        input1      : in std_logic_vector(31 downto 0); 
        input2      : in std_logic_vector(31 downto 0); 
        input3      : in std_logic_vector(31 downto 0); 
        input4      : in std_logic_vector(31 downto 0); 
        weight_u1   : in std_logic_vector(31 downto 0); 
        weight_u2   : in std_logic_vector(31 downto 0); 
        weight_r1   : in std_logic_vector(31 downto 0); 
        weight_r2   : in std_logic_vector(31 downto 0); 
        bias        : in std_logic_vector(31 downto 0); 
        output_u    : out std_logic_vector(15 downto 0);
        output_r    : out std_logic_vector(15 downto 0)   --10-bit for integer, 6-bit for fractional
        );
end component;
component  memory_cell_controller is
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
end component;

component sigmoid is
    port(
         clk         : in std_logic; 
         reset       : in std_logic;
         h_prev_done_g : in std_logic;
         u_in        : in std_logic_vector(15 downto 0);
         r_in        : in std_logic_vector(15 downto 0);
         r_u_valid   : out std_logic;       
         u_t         : out std_logic_vector(15 downto 0);
         r_t         : out std_logic_vector(15 downto 0)
         );
end component;
component tanh_h_t is
  generic(MED_WL:integer:=24;
          MED_FL:integer:=13
          );
  Port (
        clk  : in std_logic; 
        reset: in std_logic;
        r_u_valid: in std_logic;
        cx_in: in std_logic_vector (MED_WL-1 downto 0); 
        ch_in: in std_logic_vector (MED_WL-1 downto 0); 
        r_t  : in std_logic_vector (15 downto 0); 
        h_can: out std_logic_vector(15 downto 0)     
   );
end component;
component output_stage is
--  generic(INPUT_SIZE:integer:=256;
--          SIZE_HOR  :integer:=384 
----          SIG_WL:integer:=1;
----          SIG_FL:integer:=7;
----          RES_WL:integer:=11;
----          RES_FL:integer:=13;
----          TANH_WL:integer:=1;
----          TANH_FL:integer:=7
--          );
  Port (  r_u_valid: in std_logic;
--        u_t         : in std_logic_vector(SIG_WL-1 downto 0);
--        r_t         : in std_logic_vector(SIG_WL-1 downto 0);
--        h_can       : in std_logic_vector(SIG_WL-1 downto 0);
--        h_t         : out std_logic_vector(RES_WL-1 downto 0)
        u_t         : in std_logic_vector(15 downto 0);
        r_t         : in std_logic_vector(15 downto 0);
        h_can       : in std_logic_vector(15 downto 0);
        h_prev       : in std_logic_vector(15 downto 0);
        h_t         : out std_logic_vector(15 downto 0)         
        );
end component;

component write_file is
    generic (
        FILE_NAME: string ;
        INPUT_WIDTH: positive
        ); 
    Port (
        clk: in std_logic;
        reset: in std_logic;
        write_file_en: in std_logic;
	end_sim      : in std_logic;
        input_sample: in std_logic_vector(INPUT_WIDTH-1 downto 0)
        );
        end component;



signal input_done        : std_logic;                   
signal h_prev_done       : std_logic;                   
signal op_done           : std_logic; 
signal r_u_valid         : std_logic; 
signal output_u          : std_logic_vector(15 downto 0);
signal output_r          : std_logic_vector(15 downto 0);
signal u_t               : std_logic_vector(15 downto 0);
signal r_t               : std_logic_vector(15 downto 0);
signal output_cx         : std_logic_vector(MED_WL-1 downto 0);
signal output_ch         : std_logic_vector(MED_WL-1 downto 0);
signal h_can         : std_logic_vector(15 downto 0); 
signal end_sim : std_logic:='0';
begin
dut66:r_u_controller
    generic map(MED_WL=>MED_WL,MED_FL=>MED_FL)
    port map(
         clk          =>  clk         ,       
         reset        =>  reset       ,    
         GRU_en       =>  GRU_en      ,    
         input_done_g =>  input_done_g,    
         h_prev_done_g => h_prev_done_g,    
         op_done_g    =>  op_done_g   ,    
         input1       =>  input1      ,    
         input2       =>  input2      ,    
         input3       =>  input3      ,
         input4       =>  input4      ,
         weight_u1    =>  weight_u1   ,
         weight_u2    =>  weight_u2   ,
         weight_r1    =>  weight_r1   ,    
         weight_r2    =>  weight_r2   ,    
         bias         =>  bias        ,    
         output_u     =>  output_u    ,    
         output_r     =>  output_r        
            );
  dut77:  memory_cell_controller 
  generic map(MED_WL=>MED_WL,
          MED_FL=>MED_FL
          )
  Port map(
        clk          => clk          ,
        reset        => reset        ,
        GRU_en       => GRU_en       ,
        input_done_g => input_done_g ,
        h_prev_done_g=> h_prev_done_g,
        op_done_g    => op_done_g    ,
        input1       => input1       ,
        input2       => input2       ,
        input3       => input3       ,
        input4       => input4       ,
        weight_c1    => weight_c1    ,
        weight_c2    => weight_c2    ,
        bias         => bias        ,
        output_cx    => output_cx    ,
        output_ch    => output_ch    
        );

    dut88:sigmoid
    port map(
        clk         => clk        ,    
        reset       => reset      ,
        h_prev_done_g => h_prev_done_g,
        u_in        => output_u       ,
        r_in        => output_r       ,
        r_u_valid   => r_u_valid  ,
        u_t         => u_t        ,    
        r_t         => r_t                       
            );   
   dut99: tanh_h_t
  generic map(MED_WL=>MED_WL,
          MED_FL=>MED_FL
          )
  Port map(
        clk        => clk      ,
        reset      => reset    ,
        r_u_valid  => r_u_valid,
        cx_in      => output_cx     ,
        ch_in      => output_ch    ,
        r_t        => r_t      ,
        h_can      => h_can    
   );

  dut100: output_stage 
  Port map (
        r_u_valid   =>  r_u_valid,
        u_t         =>  u_t      ,
        r_t         =>  r_t      ,
        h_can       =>  h_can    ,
        h_prev      =>  h_prev   ,
        h_t         =>  h_t      
        );

dut101:write_file
 generic map(
        FILE_NAME => "C:\Users\Nitro 5\Desktop\ICP_RNN_PART2\ICP_RNN_PART2\binary_files\u_t.txt",
        INPUT_WIDTH=> 16
        )
    Port map(
        clk =>clk,
        reset  => reset,
        write_file_en=>r_u_valid,
         end_sim =>end_sim,
        input_sample=>u_t
        );

dut102:write_file
 generic map(
        FILE_NAME => "C:\Users\Nitro 5\Desktop\ICP_RNN_PART2\ICP_RNN_PART2\binary_files\r_t.txt",
        INPUT_WIDTH=> 16
        )
    Port map(
        clk =>clk,
        reset  => reset,
        write_file_en=>r_u_valid,
         end_sim =>end_sim,
        input_sample=>r_t
        );
r_u_valid_o<=r_u_valid;
end Behavioral;
