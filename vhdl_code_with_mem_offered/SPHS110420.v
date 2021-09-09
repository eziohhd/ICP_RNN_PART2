//  
//  
//  ------------------------------------------------------------
//    STMicroelectronics N.V. 2011
//   All rights reserved. Reproduction in whole or part is prohibited  without the written consent of the copyright holder.                                                                                                                                                                                                                                                                                                                           
//    STMicroelectronics RESERVES THE RIGHTS TO MAKE CHANGES WITHOUT  NOTICE AT ANY TIME.
//  STMicroelectronics MAKES NO WARRANTY,  EXPRESSED, IMPLIED OR STATUTORY, INCLUDING BUT NOT LIMITED TO ANY IMPLIED  WARRANTY OR MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE,  OR THAT THE USE WILL NOT INFRINGE ANY THIRD PARTY PATENT,  COPYRIGHT OR TRADEMARK.
//  STMicroelectronics SHALL NOT BE LIABLE  FOR ANY LOSS OR DAMAGE ARISING FROM THE USE OF ITS LIBRARIES OR  SOFTWARE.
//    STMicroelectronics
//   850, Rue Jean Monnet
//   BP 16 - 38921 Crolles Cedex - France
//   Central R&D / DAIS.
//                                                                                                                                                                                                                                                                                                                                                                             
//    
//  
//  ------------------------------------------------------------
//  
//  
//    User           : sophie dumont           
//    Project        : CMP_LUND_110420         
//    Division       : Not known               
//    Creation date  : 20 April 2011           
//    Generator mode : MemConfMAT10/distributed
//    
//    WebGen configuration             : C65LP_ST_SPHS:303,29:MemConfMAT10/distributed:3.1-00
//  
//    HDL C65_ST_SPHS Compiler version : 5.3.a@20090417.0 (UPT date)                          
//    
//  
//  For more information about the cuts or the generation environment, please
//  refer to files uk.env and ugnGuiSetupDB in directory DESIGN_DATA.
//   
//  
//  





/****************************************************************
--  Description         : Verilog Model for SPHSLP cmos65
--  Last modified in    : 5.3.a
--  Date                : April, 2009
--  Last modified by    : SK 
--
****************************************************************/
 

/******************** START OF HEADER****************************
   This Header Gives Information about the parameters & options present in the Model

   words = 16
   bits  = 64
   mux   = 4 
   
   
   
   

**********************END OF HEADER ******************************/
   


`ifdef slm
        `define functional
`endif
`celldefine
`suppress_faults
`enable_portfaults
`ifdef functional
   `timescale 1ns / 1ns
   `delay_mode_unit
`endif

`ifdef functional

module ST_SPHS_16x64m4_L (Q, RY,CK, CSN, TBYPASS, WEN, A, D    );

    
    
    parameter 
        Corruption_Read_Violation = 1,
        Fault_file_name = "ST_SPHS_16x64m4_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20;
   
   // Parameters for Memory Initialization at 0 ns
    parameter 
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHS_16x64m4_L.cde",
        InstancePath = "ST_SPHS_16x64m4_L",
        Debug_mode = "all_warning_mode";
    
    parameter
        Words = 16,
        Bits = 64,
        Addr = 4,
        mux = 4;




   
    parameter
        Rows = Words/mux,
        WordX = 64'bx,
        AddrX = 4'bx,
        Word0 = 64'b0,
        X = 1'bx;


         
      
        //  INPUT OUTPUT PORTS
        // ========================
      
	output [Bits-1 : 0] Q;
        
        output RY;   
        
        input [Bits-1 : 0] D;
	input [Addr-1 : 0] A;
	        
        input CK, CSN, TBYPASS, WEN;

        
        
        

           
        
        
	reg [Bits-1 : 0] Qint; 

    
        //  WIRE DECLARATION
        //  =====================
        
        
	wire [Bits-1 : 0] Dint,Mint;
        
        assign Mint=64'b0;
        
	wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;

        
        
        wire TBYPASSint;
        
 
        

        
        wire RYint;
        
        
        assign RY =   RYint; 
        reg RY_outreg, RY_out;
        assign RYint = RY_out;
        
        

        
        
        //  REG DECLARATION
        //  ====================
        
	//Output Register for tbypass
        reg [Bits-1 : 0] tbydata;
        //delayed Output Register
        reg [Bits-1 : 0] delOutReg_data;
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] tempMem;
	reg lastCK;
        reg CSNreg;	

        `ifdef slm
        `else
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
        `endif
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;

        
        
        reg WENreg;
        
        
        /* This register is used to force all warning messages 
        ** OFF during run time.
        ** It is a 2 bit register.
        ** USAGE :
        ** debug_level_off = 2'b00 -> ALL WARNING MESSAGES will be DISPLAYED 
        ** debug_level = 2'b10 -> ALL WARNING MESSAGES will NOT be DISPLAYED.
        ** It will override the value of debug_mode, i.e
        ** if debug_mode = "all_warning_mode", then also
        ** no warning messages will be displayed.     
        ** debug_level = 2'b01 OR 2'b11 -> UNUSED , FOR FUTURE SCALABILITY.
        ** ult, debug_mode will prevail.               
        */ 
         reg [1:0] debug_level;
         reg [8*10: 0] operating_mode;
         reg [8*44: 0] message_status;

        integer d, a, p, i, k, j, l;
        `ifdef slm
           integer MemAddr;
        `endif


        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;

        `ifdef slm
        reg [Bits -1 : 0] slm_temp_data;
        `endif
        

        integer flag_error;
        
        //BUFFER INSTANTIATION
        //=========================
        
        
        assign Q =  Qint; 
        buf bufdata [Bits-1:0] (Dint,D);
        buf bufaddr [Addr-1:0] (Aint,A);
        
	buf (TBYPASSint, TBYPASS);
	buf (CKint, CK);
        
        or (CSNint, CSN,TBYPASSint ); 
	buf (WENint, WEN);
        
        
        
        

           

        

// BEHAVIOURAL MODULE DESCRIPTION
// ================================



task task_insert_faults_in_memory;
begin
   if (ConfigFault)
   begin   
     Fault_in_memory = 1;
     for(i = 0;i< fcnt;i = i+ 1) begin
       if (fault_repair_flag[i] !== 1) begin
         Fault_in_memory = 0;
         if (array_stuck_at[i] === "sa0") begin
         `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data & stuck_at_0fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
         `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
         `endif
         end //if(array_stuck_at)
                                        
         if(array_stuck_at[i] === "sa1") begin
         `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data | stuck_at_1fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
         `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
         `endif
         end //if(array_stuck_at)
       end   // if(fault_repair_flag
     end    // end of for
   end  
end
endtask


      
task WriteMemX;
begin
   `ifdef slm
   $slm_ResetMemory(MemAddr, WordX);
   `else
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
   `endif        
   task_insert_faults_in_memory;
end
endtask

task WriteOutX;                
begin
   OutReg_data = WordX;
end
endtask


task WriteCycle;                  
input [Addr-1 : 0] Address;
reg [Bits-1:0] tempReg1,tempReg2;
integer po,i;
begin
   
   tempReg1 = WordX;
   if (^Address !== X)
   begin
      if (ValidAddress)
      begin
         
         
            `ifdef slm
               $slm_ReadMemoryS(MemAddr, Address, tempReg1);
            `else
               tempReg1 = Mem[Address];
            `endif
                   
            for (po=0;po<Bits;po=po+1)
            begin
               if (Mint[po] === 1'b0)
                  tempReg1[po] = Dint[po];
               else if (Mint[po] === 1'bX)
                  tempReg1[po] = 1'bx;
            end                
         
            `ifdef slm
                $slm_WriteMemory(MemAddr, Address, tempReg1);
            `else
                Mem[Address] = tempReg1;
            `endif
            
      end//if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. ",$realtime); 
      task_insert_faults_in_memory;
   end //if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
      
   end
  
end
endtask

task ReadCycle;
input [Addr-1 : 0] Address;
reg [Bits-1:0] MemData;
integer a;
begin
   if (ValidAddress)
   begin        
      `ifdef slm
         $slm_ReadMemory(MemAddr, Address, MemData);
      `else
         MemData = Mem[Address];
      `endif
   end //if (ValidAddress)  
                
   if(ValidAddress === X)
   begin
      if (Corruption_Read_Violation === 1)
      begin   
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
         WriteMemX;
      end
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Output Corrupted ",$realtime);
      MemData = WordX;
      
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. Output Corrupted ",$realtime); 
      MemData = WordX;
   end
   
   OutReg_data = MemData;
end
endtask



initial
begin
   // Define format for timing value
  $timeformat (-9, 2, " ns", 0);
  `ifdef slm
  $slm_RegisterMemory(MemAddr, Words, Bits);
  `endif   
  
   debug_level= 2'b0;
   message_status = "All Messages are Switched ON";
  
   
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
     message_status = "All Warning Messages are Switched OFF";
  `endif  
  `ifdef slm
     operating_mode = "SLM";
  `else
     operating_mode = "FUNCTIONAL";
  `endif
if(debug_level !== 2'b10) begin
  $display ("%mINFORMATION ");
  $display ("***************************************");
  $display ("The Model is Operating in %s MODE", operating_mode);
  $display ("%s", message_status);
  if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF");   
  
  $display ("***************************************");
end     
  if (MEM_INITIALIZE === 1'b1)
  begin   
     `ifdef slm
        if (BinaryInit)
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_BIN");
        else
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_HEX");

     `else
        if (BinaryInit)
           $readmemb(InitFileName, Mem, 0, Words-1);
        else
           $readmemh(InitFileName, Mem, 0, Words-1);
     `endif
  end   
   
  

  
  RY_out = 1'b1;


        
/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
      file_ptr = $fopen(Fault_file_name , "r");
      if(file_ptr == 0)
      begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
      end        
      else                
      begin : read_fault_file
        t = 0;
        for (i = 0; i< max_faults; i= i + 1)
        begin
         
           stuck0 = {Bits{1'b1}};
           stuck1 = {Bits{1'b0}};
           fault_char1 = $fgetc (file_ptr);
           if (fault_char1 == 8'b11111111)
              disable read_fault_file;
           ret_val = $ungetc (fault_char1, file_ptr);
           ret_val = $fgets(tempStr, file_ptr);
           ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
           flag_error = 0; 
           if(ret_val !== 0)
           begin         
              if(ret_val == 2 || ret_val == 3)
              begin
                if(ret_val == 2)
                   stuck_at = "sa0";

                if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                begin
                   if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                   flag_error = 1;
                end    
                      
                if(fault_word > Words-1)
                begin
                   if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                   flag_error = 1;
                end    

                if(fault_bit > Bits-1)
                begin  
                   if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                   flag_error = 1;
                end    

                if(flag_error == 0)
                //Correct Inputs
                begin
                   if(stuck_at === "none")
                   begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                   end
                   else
                   //Adding the faults
                   begin
                      FailureLocn[t] = fault_word;
                      std_fault_word = fault_word;
                      
                      fault_repair_flag[t] = 1'b0;
                      if (stuck_at === "sa0" )
                      begin
                         stuck0[fault_bit] = 1'b0;         
                         stuck_at_0fault[t] = stuck0;
                      end     
                      if (stuck_at === "sa1" )
                      begin
                         stuck1[fault_bit] = 1'b1;
                         stuck_at_1fault[t] = stuck1; 
                      end

                      array_stuck_at[t] = stuck_at;
                      t = t + 1;
                   end //if(stuck_at === "none")  
                end //if(flag_error == 0)
              end //if(ret_val == 2 || ret_val == 3 
              else
              //wrong number of arguments
              begin
                if(debug_level < 2)
                   $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                flag_error = 1;
              end
           end //if(ret_val !== 0)
           else
           begin
              if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
           end    
        end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);

      fcnt = t;

      
      //fault injection at time 0.
      task_insert_faults_in_memory;
   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//
        
always @(CKint)
begin
  
      // Unknown Clock Behaviour
      if (CKint=== X && CSNint !==1)
      begin
         WriteOutX;
         WriteMemX;
          
         RY_out = 1'bX;
      end
      if(CKint === 1'b1 && lastCK === 1'b0)
      begin
         CSNreg = CSNint;
         WENreg = WENint;
         if (CSNint !== 1)
         begin
            if (^Aint === X)
               ValidAddress = X;
            else if (Aint < Words)
               ValidAddress = 1;
            else    
               ValidAddress = 0;

            if (ValidAddress)
	       `ifdef slm
               $slm_ReadMemoryS(MemAddr, Aint, Mem_temp);
               `else        
               Mem_temp = Mem[Aint];
               `endif       
            else
	       Mem_temp = WordX; 
               
            
         end// CSNint !==1...
      end // if(CKint === 1'b1...)
        
   /*---------------------- Normal Read and Write -----------------*/

      if (CSNint !== 1 && CKint === 1'b1 && lastCK === 1'b0 )
      begin
            if (CSNint === 0)
            begin        
               
               if (ValidAddress !== 1'bX )   
                  RY_outreg = ~CKint;
               else
                  RY_outreg = 1'bX;
               if (WENint === 1)
               begin
                  ReadCycle(Aint);
               end
               else if (WENint === 0)
               begin
                  
                   WriteCycle(Aint);
                   
               end
               else if (WENint === X)
               begin
                  // Uncertain write cycle
                  WriteOutX;
                  WriteMemX;
                  
                  RY_outreg = 1'bX;
                  if(debug_level < 2) $display("%m - %t (MSG_ID 002) WARNING: Illegal Value on Write Enable. Memory and Output Corrupted ",$realtime);
                  
               end // if (WENint === X...)
            end //if (CSNint === 0
            else if (CSNint === X)
            begin
                
                RY_outreg = 1'bX;
                if(debug_level < 2) $display("%m - %t (MSG_ID 001) WARNING: Illegal Value on Chip Select. Memory and Output Corrupted ",$realtime);
                WriteOutX;
                WriteMemX;
            end //else if (CSNint === X)
         
       
       
      end // if (CSNint !==1..          

   
   lastCK = CKint;
end // always @(CKint)
        
always @(CSNint)
begin
     // Unknown Clock & CSN signal
     if (CSNint !== 1 && CKint === 1'bx)
     begin
       if(debug_level < 2) $display("%m - %t (MSG_ID 004) WARNING: Chip Select going low while Clock is Invalid. Memory Corrupted ",$realtime);
       WriteMemX;
       WriteOutX;
       
       RY_out = 1'bX;
     end
end



//TBYPASS functionality
 always @(TBYPASSint)
 begin
     
             
      
        OutReg_data = WordX;
        if(TBYPASSint === 1'b1) 
          tbydata = Dint;
        else
          tbydata = WordX;
          
    
    
    
 end //end of always TBYPASSint

 always @(Dint)
 begin
    
     
       
      if(TBYPASSint === 1'b1)
        tbydata = Dint;
      
    
    
    
 end //end of always Dint

//assign output data
always @(OutReg_data)
   #1 delOutReg_data = OutReg_data;

always @(delOutReg_data or tbydata or TBYPASSint)
   if(TBYPASSint === 1'b0)
      Qint = delOutReg_data;
   else if(TBYPASSint === 1'bX)
      Qint = WordX;
   else
      Qint = tbydata;      

 
 always @(TBYPASSint)
 begin
    
     
      
      if(TBYPASSint !== 1'b0)
        RY_outreg = 1'bx;
        
    
    
    
 end

 always @(negedge CKint)
 begin
    
     
      
      if(TBYPASSint === 1'b1)
        RY_outreg = 1'b1;
      else if (TBYPASSint === 1'b0) 
         if(CSNreg === 1'b0 && WENreg !== 1'bX && ValidAddress !== 1'bX  && RY_outreg !== 1'bX)
            RY_outreg = ~CKint;
            
    
    
    
 end

always @(RY_outreg)
begin
  #1 RY_out = RY_outreg;
end





endmodule


`else

`timescale 1ns / 1ps
`delay_mode_path
 
module ST_SPHS_16x64m4_L_main (Q_glitch,  Q_data, Q_gCK , RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main, CK,  CSN, TBYPASS, WEN,  A, D, M,debug_level , TimingViol_addr, TimingViol_data, TimingViol_csn, TimingViol_wen, TimingViol_tckh, TimingViol_tckl, TimingViol_tcycle, TimingViol_tbypass, TimingViol_mask     );

    
       
    parameter 
        Corruption_Read_Violation = 1,
        Fault_file_name = "ST_SPHS_16x64m4_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20;
   
    // Parameters for Memory Initialization at 0 ns
    parameter 
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHS_16x64m4_L.cde",
        InstancePath = "ST_SPHS_16x64m4_L",
        Debug_mode = "all_warning_mode";
    
    parameter
        Words = 16,
        Bits = 64,
        Addr = 4,
        mux = 4,
        Rows = Words/mux;




   
    parameter
        WordX = 64'bx,
        AddrX = 4'bx,
        Word0 = 64'b0,
        X = 1'bx;
         
      
        //  INPUT OUTPUT PORTS
        // ========================
	output [Bits-1 : 0] Q_glitch;
	output [Bits-1 : 0] Q_data;
	output [Bits-1 : 0] Q_gCK;
        
        output ICRY;
        output RY_rfCK;
	output RY_rrCK;
	output RY_frCK;   
	output [Bits-1 : 0] delTBYPASS; 
	output TBYPASS_main; 
        output [Bits-1 : 0] TBYPASS_D_Q;
        
        input [Bits-1 : 0] D,M;
	input [Addr-1 : 0] A;
	input CK, CSN, TBYPASS, WEN;
        input [1 : 0] debug_level;

	input [Bits-1 : 0] TimingViol_data, TimingViol_mask;
	input TimingViol_addr, TimingViol_csn, TimingViol_wen, TimingViol_tckh, TimingViol_tckl, TimingViol_tcycle, TimingViol_tbypass;

        
        
 



        
        wire [Bits-1 : 0] Dint,Mint; 
	wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;
        
        


        
        
        
	wire  Mreg_0;
	wire  Mreg_1;
	wire  Mreg_2;
	wire  Mreg_3;
	wire  Mreg_4;
	wire  Mreg_5;
	wire  Mreg_6;
	wire  Mreg_7;
	wire  Mreg_8;
	wire  Mreg_9;
	wire  Mreg_10;
	wire  Mreg_11;
	wire  Mreg_12;
	wire  Mreg_13;
	wire  Mreg_14;
	wire  Mreg_15;
	wire  Mreg_16;
	wire  Mreg_17;
	wire  Mreg_18;
	wire  Mreg_19;
	wire  Mreg_20;
	wire  Mreg_21;
	wire  Mreg_22;
	wire  Mreg_23;
	wire  Mreg_24;
	wire  Mreg_25;
	wire  Mreg_26;
	wire  Mreg_27;
	wire  Mreg_28;
	wire  Mreg_29;
	wire  Mreg_30;
	wire  Mreg_31;
	wire  Mreg_32;
	wire  Mreg_33;
	wire  Mreg_34;
	wire  Mreg_35;
	wire  Mreg_36;
	wire  Mreg_37;
	wire  Mreg_38;
	wire  Mreg_39;
	wire  Mreg_40;
	wire  Mreg_41;
	wire  Mreg_42;
	wire  Mreg_43;
	wire  Mreg_44;
	wire  Mreg_45;
	wire  Mreg_46;
	wire  Mreg_47;
	wire  Mreg_48;
	wire  Mreg_49;
	wire  Mreg_50;
	wire  Mreg_51;
	wire  Mreg_52;
	wire  Mreg_53;
	wire  Mreg_54;
	wire  Mreg_55;
	wire  Mreg_56;
	wire  Mreg_57;
	wire  Mreg_58;
	wire  Mreg_59;
	wire  Mreg_60;
	wire  Mreg_61;
	wire  Mreg_62;
	wire  Mreg_63;
	
	reg [Bits-1 : 0] OutReg_glitch; // Glitch Output register
	reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] Dreg,Mreg;
	reg [Bits-1 : 0] Mreg_temp;
	reg [Bits-1 : 0] tempMem;
	reg [Bits-1 : 0] prevMem;
	reg [Addr-1 : 0] Areg;
	reg [Bits-1 : 0] Q_gCKreg; 
	reg [Bits-1 : 0] lastQ_gCK;
	reg [Bits-1 : 0] last_Qdata;
	reg lastCK, CKreg;
	reg CSNreg;
	reg WENreg;
	
        reg [Bits-1 : 0] TimingViol_data_last;
        reg [Bits-1 : 0] TimingViol_mask_last;
	
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;
	reg ICGFlag;
        



        
       
        
        
        

        integer d, a, p, i, k, j, l;

        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;

        integer flag_error;


	assign Mreg_0 = Mreg[0];
	assign Mreg_1 = Mreg[1];
	assign Mreg_2 = Mreg[2];
	assign Mreg_3 = Mreg[3];
	assign Mreg_4 = Mreg[4];
	assign Mreg_5 = Mreg[5];
	assign Mreg_6 = Mreg[6];
	assign Mreg_7 = Mreg[7];
	assign Mreg_8 = Mreg[8];
	assign Mreg_9 = Mreg[9];
	assign Mreg_10 = Mreg[10];
	assign Mreg_11 = Mreg[11];
	assign Mreg_12 = Mreg[12];
	assign Mreg_13 = Mreg[13];
	assign Mreg_14 = Mreg[14];
	assign Mreg_15 = Mreg[15];
	assign Mreg_16 = Mreg[16];
	assign Mreg_17 = Mreg[17];
	assign Mreg_18 = Mreg[18];
	assign Mreg_19 = Mreg[19];
	assign Mreg_20 = Mreg[20];
	assign Mreg_21 = Mreg[21];
	assign Mreg_22 = Mreg[22];
	assign Mreg_23 = Mreg[23];
	assign Mreg_24 = Mreg[24];
	assign Mreg_25 = Mreg[25];
	assign Mreg_26 = Mreg[26];
	assign Mreg_27 = Mreg[27];
	assign Mreg_28 = Mreg[28];
	assign Mreg_29 = Mreg[29];
	assign Mreg_30 = Mreg[30];
	assign Mreg_31 = Mreg[31];
	assign Mreg_32 = Mreg[32];
	assign Mreg_33 = Mreg[33];
	assign Mreg_34 = Mreg[34];
	assign Mreg_35 = Mreg[35];
	assign Mreg_36 = Mreg[36];
	assign Mreg_37 = Mreg[37];
	assign Mreg_38 = Mreg[38];
	assign Mreg_39 = Mreg[39];
	assign Mreg_40 = Mreg[40];
	assign Mreg_41 = Mreg[41];
	assign Mreg_42 = Mreg[42];
	assign Mreg_43 = Mreg[43];
	assign Mreg_44 = Mreg[44];
	assign Mreg_45 = Mreg[45];
	assign Mreg_46 = Mreg[46];
	assign Mreg_47 = Mreg[47];
	assign Mreg_48 = Mreg[48];
	assign Mreg_49 = Mreg[49];
	assign Mreg_50 = Mreg[50];
	assign Mreg_51 = Mreg[51];
	assign Mreg_52 = Mreg[52];
	assign Mreg_53 = Mreg[53];
	assign Mreg_54 = Mreg[54];
	assign Mreg_55 = Mreg[55];
	assign Mreg_56 = Mreg[56];
	assign Mreg_57 = Mreg[57];
	assign Mreg_58 = Mreg[58];
	assign Mreg_59 = Mreg[59];
	assign Mreg_60 = Mreg[60];
	assign Mreg_61 = Mreg[61];
	assign Mreg_62 = Mreg[62];
	assign Mreg_63 = Mreg[63];

        //BUFFER INSTANTIATION
        //=========================
        
        buf bufdint [Bits-1:0] (Dint, D);

        buf bufmint [Bits-1:0] (Mint, M);
        
        buf bufaint [Addr-1:0] (Aint, A);
	
	buf (TBYPASS_main, TBYPASS);
	buf (CKint, CK);
        
        buf (CSNint, CSN); 
	buf (WENint, WEN);

        //TBYPASS functionality
        buf bufdeltb [Bits-1:0] (delTBYPASS, TBYPASS);
        
           
        buf bugtbdq [Bits-1:0] (TBYPASS_D_Q, D);

        
        


        
        
        

        wire RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYFlagint;
        reg RY_rfCKreg, RY_rrCKreg, RY_frCKreg; 
	reg InitialRYFlag, ICRYFlag;
        
        buf (RY_rfCK, RY_rfCKint);
	buf (RY_rrCK, RY_rrCKint);
	buf (RY_frCK, RY_frCKint); 
        
        buf (ICRY, ICRYFlagint);
        assign ICRYFlagint = ICRYFlag;
        
        
    specify
        specparam

            tdq = 0.01,
            ttmq = 0.01,
            
            taa_ry = 1.0,
            th_ry = 0.9,
            tck_ry = 1.0,
            taa = 1.0,
            th = 0.9;
        /*-------------------- Propagation Delays ------------------*/
	if (WENreg && !ICGFlag) (CK *> (Q_data[0] : D[0])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[1] : D[1])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[2] : D[2])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[3] : D[3])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[4] : D[4])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[5] : D[5])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[6] : D[6])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[7] : D[7])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[8] : D[8])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[9] : D[9])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[10] : D[10])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[11] : D[11])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[12] : D[12])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[13] : D[13])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[14] : D[14])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[15] : D[15])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[16] : D[16])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[17] : D[17])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[18] : D[18])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[19] : D[19])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[20] : D[20])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[21] : D[21])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[22] : D[22])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[23] : D[23])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[24] : D[24])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[25] : D[25])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[26] : D[26])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[27] : D[27])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[28] : D[28])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[29] : D[29])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[30] : D[30])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[31] : D[31])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[32] : D[32])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[33] : D[33])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[34] : D[34])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[35] : D[35])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[36] : D[36])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[37] : D[37])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[38] : D[38])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[39] : D[39])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[40] : D[40])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[41] : D[41])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[42] : D[42])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[43] : D[43])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[44] : D[44])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[45] : D[45])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[46] : D[46])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[47] : D[47])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[48] : D[48])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[49] : D[49])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[50] : D[50])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[51] : D[51])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[52] : D[52])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[53] : D[53])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[54] : D[54])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[55] : D[55])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[56] : D[56])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[57] : D[57])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[58] : D[58])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[59] : D[59])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[60] : D[60])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[61] : D[61])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[62] : D[62])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[63] : D[63])) = (taa, taa);

	if (!ICGFlag) (CK *> (Q_glitch[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[31] : D[31])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[32] : D[32])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[33] : D[33])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[34] : D[34])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[35] : D[35])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[36] : D[36])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[37] : D[37])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[38] : D[38])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[39] : D[39])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[40] : D[40])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[41] : D[41])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[42] : D[42])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[43] : D[43])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[44] : D[44])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[45] : D[45])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[46] : D[46])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[47] : D[47])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[48] : D[48])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[49] : D[49])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[50] : D[50])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[51] : D[51])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[52] : D[52])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[53] : D[53])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[54] : D[54])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[55] : D[55])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[56] : D[56])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[57] : D[57])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[58] : D[58])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[59] : D[59])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[60] : D[60])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[61] : D[61])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[62] : D[62])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[63] : D[63])) = (th, th);

	if (!ICGFlag) (CK *> (Q_gCK[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[31] : D[31])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[32] : D[32])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[33] : D[33])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[34] : D[34])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[35] : D[35])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[36] : D[36])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[37] : D[37])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[38] : D[38])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[39] : D[39])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[40] : D[40])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[41] : D[41])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[42] : D[42])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[43] : D[43])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[44] : D[44])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[45] : D[45])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[46] : D[46])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[47] : D[47])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[48] : D[48])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[49] : D[49])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[50] : D[50])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[51] : D[51])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[52] : D[52])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[53] : D[53])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[54] : D[54])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[55] : D[55])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[56] : D[56])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[57] : D[57])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[58] : D[58])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[59] : D[59])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[60] : D[60])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[61] : D[61])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[62] : D[62])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[63] : D[63])) = (th, th);

	if (!TBYPASS) (TBYPASS *> delTBYPASS[0]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[1]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[2]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[3]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[4]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[5]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[6]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[7]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[8]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[9]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[10]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[11]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[12]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[13]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[14]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[15]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[16]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[17]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[18]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[19]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[20]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[21]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[22]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[23]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[24]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[25]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[26]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[27]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[28]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[29]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[30]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[31]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[32]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[33]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[34]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[35]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[36]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[37]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[38]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[39]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[40]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[41]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[42]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[43]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[44]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[45]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[46]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[47]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[48]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[49]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[50]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[51]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[52]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[53]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[54]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[55]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[56]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[57]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[58]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[59]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[60]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[61]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[62]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[63]) = (0);
	if (TBYPASS) (TBYPASS *> delTBYPASS[0]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[1]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[2]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[3]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[4]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[5]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[6]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[7]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[8]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[9]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[10]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[11]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[12]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[13]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[14]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[15]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[16]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[17]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[18]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[19]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[20]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[21]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[22]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[23]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[24]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[25]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[26]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[27]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[28]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[29]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[30]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[31]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[32]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[33]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[34]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[35]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[36]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[37]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[38]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[39]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[40]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[41]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[42]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[43]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[44]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[45]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[46]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[47]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[48]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[49]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[50]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[51]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[52]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[53]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[54]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[55]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[56]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[57]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[58]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[59]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[60]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[61]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[62]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[63]) = (ttmq);
      (D[0] *> TBYPASS_D_Q[0]) = (tdq, tdq);
      (D[1] *> TBYPASS_D_Q[1]) = (tdq, tdq);
      (D[2] *> TBYPASS_D_Q[2]) = (tdq, tdq);
      (D[3] *> TBYPASS_D_Q[3]) = (tdq, tdq);
      (D[4] *> TBYPASS_D_Q[4]) = (tdq, tdq);
      (D[5] *> TBYPASS_D_Q[5]) = (tdq, tdq);
      (D[6] *> TBYPASS_D_Q[6]) = (tdq, tdq);
      (D[7] *> TBYPASS_D_Q[7]) = (tdq, tdq);
      (D[8] *> TBYPASS_D_Q[8]) = (tdq, tdq);
      (D[9] *> TBYPASS_D_Q[9]) = (tdq, tdq);
      (D[10] *> TBYPASS_D_Q[10]) = (tdq, tdq);
      (D[11] *> TBYPASS_D_Q[11]) = (tdq, tdq);
      (D[12] *> TBYPASS_D_Q[12]) = (tdq, tdq);
      (D[13] *> TBYPASS_D_Q[13]) = (tdq, tdq);
      (D[14] *> TBYPASS_D_Q[14]) = (tdq, tdq);
      (D[15] *> TBYPASS_D_Q[15]) = (tdq, tdq);
      (D[16] *> TBYPASS_D_Q[16]) = (tdq, tdq);
      (D[17] *> TBYPASS_D_Q[17]) = (tdq, tdq);
      (D[18] *> TBYPASS_D_Q[18]) = (tdq, tdq);
      (D[19] *> TBYPASS_D_Q[19]) = (tdq, tdq);
      (D[20] *> TBYPASS_D_Q[20]) = (tdq, tdq);
      (D[21] *> TBYPASS_D_Q[21]) = (tdq, tdq);
      (D[22] *> TBYPASS_D_Q[22]) = (tdq, tdq);
      (D[23] *> TBYPASS_D_Q[23]) = (tdq, tdq);
      (D[24] *> TBYPASS_D_Q[24]) = (tdq, tdq);
      (D[25] *> TBYPASS_D_Q[25]) = (tdq, tdq);
      (D[26] *> TBYPASS_D_Q[26]) = (tdq, tdq);
      (D[27] *> TBYPASS_D_Q[27]) = (tdq, tdq);
      (D[28] *> TBYPASS_D_Q[28]) = (tdq, tdq);
      (D[29] *> TBYPASS_D_Q[29]) = (tdq, tdq);
      (D[30] *> TBYPASS_D_Q[30]) = (tdq, tdq);
      (D[31] *> TBYPASS_D_Q[31]) = (tdq, tdq);
      (D[32] *> TBYPASS_D_Q[32]) = (tdq, tdq);
      (D[33] *> TBYPASS_D_Q[33]) = (tdq, tdq);
      (D[34] *> TBYPASS_D_Q[34]) = (tdq, tdq);
      (D[35] *> TBYPASS_D_Q[35]) = (tdq, tdq);
      (D[36] *> TBYPASS_D_Q[36]) = (tdq, tdq);
      (D[37] *> TBYPASS_D_Q[37]) = (tdq, tdq);
      (D[38] *> TBYPASS_D_Q[38]) = (tdq, tdq);
      (D[39] *> TBYPASS_D_Q[39]) = (tdq, tdq);
      (D[40] *> TBYPASS_D_Q[40]) = (tdq, tdq);
      (D[41] *> TBYPASS_D_Q[41]) = (tdq, tdq);
      (D[42] *> TBYPASS_D_Q[42]) = (tdq, tdq);
      (D[43] *> TBYPASS_D_Q[43]) = (tdq, tdq);
      (D[44] *> TBYPASS_D_Q[44]) = (tdq, tdq);
      (D[45] *> TBYPASS_D_Q[45]) = (tdq, tdq);
      (D[46] *> TBYPASS_D_Q[46]) = (tdq, tdq);
      (D[47] *> TBYPASS_D_Q[47]) = (tdq, tdq);
      (D[48] *> TBYPASS_D_Q[48]) = (tdq, tdq);
      (D[49] *> TBYPASS_D_Q[49]) = (tdq, tdq);
      (D[50] *> TBYPASS_D_Q[50]) = (tdq, tdq);
      (D[51] *> TBYPASS_D_Q[51]) = (tdq, tdq);
      (D[52] *> TBYPASS_D_Q[52]) = (tdq, tdq);
      (D[53] *> TBYPASS_D_Q[53]) = (tdq, tdq);
      (D[54] *> TBYPASS_D_Q[54]) = (tdq, tdq);
      (D[55] *> TBYPASS_D_Q[55]) = (tdq, tdq);
      (D[56] *> TBYPASS_D_Q[56]) = (tdq, tdq);
      (D[57] *> TBYPASS_D_Q[57]) = (tdq, tdq);
      (D[58] *> TBYPASS_D_Q[58]) = (tdq, tdq);
      (D[59] *> TBYPASS_D_Q[59]) = (tdq, tdq);
      (D[60] *> TBYPASS_D_Q[60]) = (tdq, tdq);
      (D[61] *> TBYPASS_D_Q[61]) = (tdq, tdq);
      (D[62] *> TBYPASS_D_Q[62]) = (tdq, tdq);
      (D[63] *> TBYPASS_D_Q[63]) = (tdq, tdq);


        // RY functionality
	if (!ICRY && InitialRYFlag) (CK *> RY_rfCK) = (th_ry, th_ry);
	if (!ICRY && InitialRYFlag) (CK *> RY_rrCK) = (taa_ry, taa_ry);
	if (!ICRY && InitialRYFlag) (CK *> RY_frCK) = (tck_ry, tck_ry);   

	endspecify


assign #0 Q_data = OutReg_data;
assign Q_glitch = OutReg_glitch; 
assign Q_gCK = Q_gCKreg;

    // BEHAVIOURAL MODULE DESCRIPTION



task task_insert_faults_in_memory;
begin
   if (ConfigFault)
   begin   
     Fault_in_memory = 1;
     for(i = 0;i< fcnt;i = i+ 1) begin
       if (fault_repair_flag[i] !== 1) begin
         Fault_in_memory = 0;
         if (array_stuck_at[i] === "sa0") begin
         `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data & stuck_at_0fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
         `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
         `endif
         end //if(array_stuck_at)
                                        
         if(array_stuck_at[i] === "sa1") begin
         `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data | stuck_at_1fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
         `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
         `endif
         end //if(array_stuck_at)
       end   // if(fault_repair_flag
     end    // end of for
   end  
end
endtask



task chstate;
   input [Bits-1 : 0] clkin;
   output [Bits-1 : 0] clkout;
   integer d;
begin
   if ( $realtime != 0 )
      for (d = 0; d < Bits; d = d + 1)
      begin
         if (clkin[d] === 1'b0)
            clkout[d] = 1'b1;
         else if (clkin[d] === 1'b1)
            clkout[d] = 1'bx;
         else
            clkout[d] = 1'b0;
      end
end
endtask


task WriteMemX;
begin
   for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
   task_insert_faults_in_memory;
end
endtask

task WriteLocMskX_bwise;
   input [Addr-1 : 0] Address;
   input [Bits-1 : 0] Mask;
begin
   if (^Address !== X)
   begin
      tempMem = Mem[Address];
             
      for (j = 0;j< Bits; j=j+1)
         if (Mask[j] === 1'bx)
            tempMem[j] = 1'bx;
                    
      Mem[Address] = tempMem;
      task_insert_faults_in_memory;
   end//if (^Address !== X
   else
      WriteMemX;
end
endtask
    
task WriteOutX;                
begin
   OutReg_data= WordX;
   OutReg_glitch= WordX;
end
endtask

task WriteCycle;                  
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] tempReg1,tempReg2;
   integer po,i;
begin
  
   tempReg1 = WordX;
   if (^Address !== X)
   begin
      if (ValidAddress)
      begin
         
             tempReg1 = Mem[Address];
             for (po=0;po<Bits;po=po+1)
                if (Mreg[po] === 1'b0)
                   tempReg1[po] = Dreg[po];
                else if (Mreg[po] === 1'bX)
                    tempReg1[po] = 1'bx;
                        
                Mem[Address] = tempReg1;
                     
      end //if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Write Port:  Address Out Of Range. ",$realtime);
      task_insert_faults_in_memory;
   end//if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Write Port:  Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
      
   end
   
end
endtask

task ReadCycle;
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] MemData;
   integer a;
begin

   if (ValidAddress)
      MemData = Mem[Address];

   if(ValidAddress === X)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Read Port:  Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
      MemData = WordX;
      WriteMemX;
      
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Read Port:  Address Out Of Range. Output Corrupted ",$realtime);
      MemData = WordX;
   end

   for (a = 0; a < Bits; a = a + 1)
   begin
      if (MemData[a] !== OutReg_data[a])
         OutReg_glitch[a] = WordX[a];
      else
         OutReg_glitch[a] = MemData[a];
   end//for (a = 0; a <

   OutReg_data = MemData;
   last_Qdata = Q_data;

end
endtask




assign RY_rfCKint = RY_rfCKreg;
assign RY_frCKint = RY_frCKreg;
assign RY_rrCKint = RY_rrCKreg;

// Define format for timing value
initial
begin
   $timeformat (-9, 2, " ns", 0);
   ICGFlag = 0;

   //Initialize Memory
   if (MEM_INITIALIZE === 1'b1)
   begin   
      if (BinaryInit)
         $readmemb(InitFileName, Mem, 0, Words-1);
      else
         $readmemh(InitFileName, Mem, 0, Words-1);
   end

   
   ICRYFlag = 1;
   InitialRYFlag = 0;
   ICRYFlag <= 0;
   RY_rfCKreg = 1'b1;
   RY_rrCKreg = 1'b1;
   RY_frCKreg = 1'b1;

   
   

/*  -----------Implementation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
      file_ptr = $fopen(Fault_file_name , "r");
      if(file_ptr == 0)
      begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
      end        
      else                
      begin : read_fault_file
        t = 0;
        for (i = 0; i< max_faults; i= i + 1)
        begin
         
           stuck0 = {Bits{1'b1}};
           stuck1 = {Bits{1'b0}};
           fault_char1 = $fgetc (file_ptr);
           if (fault_char1 == 8'b11111111)
              disable read_fault_file;
           ret_val = $ungetc (fault_char1, file_ptr);
           ret_val = $fgets(tempStr, file_ptr);
           ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
           flag_error = 0; 
           if(ret_val !== 0)
           begin         
              if(ret_val == 2 || ret_val == 3)
              begin
                if(ret_val == 2)
                   stuck_at = "sa0";

                if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                begin
                   if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                   flag_error = 1;
                end    
                      
                if(fault_word > Words-1)
                begin
                   if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                   flag_error = 1;
                end    

                if(fault_bit > Bits-1)
                begin  
                   if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                   flag_error = 1;
                end    

                if(flag_error == 0)
                //Correct Inputs
                begin
                   if(stuck_at === "none")
                   begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                   end
                   else
                   //Adding the faults
                   begin
                      FailureLocn[t] = fault_word;
                      std_fault_word = fault_word;
                      
                      fault_repair_flag[t] = 1'b0;
                      if (stuck_at === "sa0" )
                      begin
                         stuck0[fault_bit] = 1'b0;         
                         stuck_at_0fault[t] = stuck0;
                      end     
                      if (stuck_at === "sa1" )
                      begin
                         stuck1[fault_bit] = 1'b1;
                         stuck_at_1fault[t] = stuck1; 
                      end

                      array_stuck_at[t] = stuck_at;
                      t = t + 1;
                   end //if(stuck_at === "none")  
                end //if(flag_error == 0)
              end //if(ret_val == 2 || ret_val == 3 
              else
              //wrong number of arguments
              begin
                if(debug_level < 2)
                   $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                flag_error = 1;
              end
           end //if(ret_val !== 0)
           else
           begin
              if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
           end    
        end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);

      fcnt = t;
      
      task_insert_faults_in_memory;
   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//

always @(CKint)
begin
   lastCK = CKreg;
   CKreg = CKint;
   
   if (CKint !== 0 && CSNint !== 1)
   begin
     InitialRYFlag = 1;
   end
   
      // Unknown Clock Behaviour
      if (((CKint=== X && CSNint !==1) || (CKint=== X && CSNreg !==1 && lastCK ===1)))
      begin
         
         ICRYFlag = 1;   
         chstate(Q_gCKreg, Q_gCKreg);
	 WriteOutX;
         WriteMemX;
      end//if (((CKint===
                
   
   if (CKint===1 && lastCK ===0 && CSNint === X  )
       ICRYFlag = 1;
   else if (CKint === 1 && lastCK === 0 && CSNint === 0 )
       ICRYFlag = 0;
   

   /*---------------------- Latching signals ----------------------*/
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
      if (CSNint !== 1)
      begin
         ICGFlag = 0;
         Dreg = Dint;
         Mreg = Mint;
         WENreg = WENint;
         Areg = Aint;
         if (^Areg === X)
            ValidAddress = X;
         else if (Areg < Words)
            ValidAddress = 1;
         else
            ValidAddress = 0;

         if (ValidAddress)
            Mem_temp = Mem[Aint];
         else
            Mem_temp = WordX; 

         
      end//if (CSNint !== 1)
         
      CSNreg = CSNint;
      last_Qdata = Q_data;
      
      
   end//if(CKreg === 1'b1 && lastCK =   
     
   /*---------------------- Normal Read and Write -----------------*/

   if ((CSNreg !== 1) && (CKreg === 1 && lastCK === 0))
   begin
      if (WENreg === 1'b1 && CSNreg === 1'b0)
      begin
         ReadCycle(Areg);
         chstate(Q_gCKreg, Q_gCKreg);
      end//if (WENreg === 1 && C
      else if (WENreg === 0 && CSNreg === 0)
      begin
          
           WriteCycle(Areg);
           
      end
      /*---------- Corruption due to faulty values on signals --------*/
      else if (CSNreg === 1'bX)
      begin
         // Uncertain cycle
         if(debug_level < 2) $display("%m - %t (MSG_ID 001) WARNING: Illegal Value on Chip Select. Memory and Output Corrupted ",$realtime);
         WriteMemX;
         WriteOutX;
         chstate(Q_gCKreg, Q_gCKreg);
      end//else if (CSN === 1'bX
      else if (WENreg === X)
      begin
         // Uncertain write cycle
         if(debug_level < 2) $display("%m - %t (MSG_ID 002) WARNING: Illegal Value on Write Enable. Memory and Output Corrupted ",$realtime);
         WriteMemX;
         WriteOutX;
         chstate(Q_gCKreg, Q_gCKreg);
         
         ICRYFlag = 1;
         
      end//else if (WENreg ===
      
      

   end //if ((CSNreg !== 1) && (CKreg    
   
end // always @(CKint)

always @(CSNint)
begin   
     // Unknown Clock & CSN signal
     if (CSNint !== 1 && CKint === X )
     begin
       if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
       chstate(Q_gCKreg, Q_gCKreg);
       WriteMemX;
       WriteOutX;
       
       ICRYFlag = 1;
     end//if (CSNint !== 1
end      


 always @(TBYPASS_main)
 begin
 
      if (TBYPASS_main !== 0)
        
        ICRYFlag = 1;
      OutReg_data = WordX;
      OutReg_glitch = WordX;
    
 end


  

        /*---------------RY Functionality-----------------*/
always @(posedge CKreg)
begin

     
     if ((CSNreg === 0) && (CKreg === 1 && lastCK === 0) && TBYPASS_main === 1'b0)
     begin
       if (WENreg !== 1'bX && ValidAddress !== 1'bX)
       begin
         RY_rfCKreg = ~RY_rfCKreg;
         RY_rrCKreg = ~RY_rrCKreg;
       end
       else
         ICRYFlag = 1'b1; 
     end
     
     
end

 always @(negedge CKreg)
 begin
 
      
      if (TBYPASS_main === 1'b1)
      begin
        RY_frCKreg = ~RY_frCKreg;
        ICRYFlag = 1'b0;
      end  
      else if (TBYPASS_main === 1'b0 && (CSNreg === 0) && (CKreg === 0 && lastCK === 1))
      begin
        if (WENreg !== 1'bX && ValidAddress !== 1'bX)
           RY_frCKreg = ~RY_frCKreg;
      end
      
     
     
   
 end

always @ (TimingViol_tckl or TimingViol_tcycle or TimingViol_csn or TimingViol_tckh or TimingViol_tbypass or TimingViol_wen or TimingViol_addr  )
ICRYFlag = 1;
        /*---------------------------------*/





/*---------------TBYPASS  Functionality in functional model -----------------*/

always @(TimingViol_data)
// tds or tdh violation
begin
#0
   for (l = 0; l < Bits; l = l + 1)
   begin   
      if((TimingViol_data[l] !== TimingViol_data_last[l]))
         Mreg[l] = 1'bx;
   end   
   WriteLocMskX_bwise(Areg,Mreg);
   TimingViol_data_last = TimingViol_data;
end


        
/*---------- Corruption due to Timing Violations ---------------*/

always @(TimingViol_tckl or TimingViol_tcycle)
// tckl -  tcycle
begin
#0
   WriteOutX;
   #0.00 WriteMemX;
end

always @(TimingViol_csn)
// tps or tph
begin
#0
   CSNreg = 1'bX;
   WriteOutX;
   WriteMemX;  
   if (CSNreg === 1)
   begin
      chstate(Q_gCKreg, Q_gCKreg);
   end
end

always @(TimingViol_tckh)
// tckh
begin
#0
   ICGFlag = 1;
   chstate(Q_gCKreg, Q_gCKreg);
   WriteOutX;
   WriteMemX;
end

always @(TimingViol_addr)
// tas or tah
begin
#0
   if (WENreg !== 0)
      WriteOutX;
   WriteMemX;
   
end


always @(TimingViol_wen)
//tws or twh
begin
#0
   WriteMemX; 
   WriteOutX;
end


always @(TimingViol_tbypass)
//ttmck
begin
#0
   WriteOutX;
   WriteMemX;  
end







endmodule

module ST_SPHS_16x64m4_L_OPschlr (QINT,  RYINT, Q_gCK, Q_glitch,  Q_data, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main);

    parameter
        Words = 16,
        Bits = 64,
        Addr = 4;
        

    parameter
        WordX = 64'bx,
        AddrX = 4'bx,
        X = 1'bx;

	output [Bits-1 : 0] QINT;
	input [Bits-1 : 0] Q_glitch;
	input [Bits-1 : 0] Q_data;
	input [Bits-1 : 0] Q_gCK;
        input [Bits-1 : 0] TBYPASS_D_Q;
        input [Bits-1 : 0] delTBYPASS;
        input TBYPASS_main;
	
	integer m,a, d, n, o, p;
	wire [Bits-1 : 0] QINTint;
	wire [Bits-1 : 0] QINTERNAL;

        reg [Bits-1 : 0] OutReg;
	reg [Bits-1 : 0] lastQ_gCK, Q_gCKreg;
	reg [Bits-1 : 0] lastQ_data, Q_datareg;
	reg [Bits-1 : 0] QINTERNALreg;
	reg [Bits-1 : 0] lastQINTERNAL;

buf bufqint [Bits-1:0] (QINT, QINTint);

	assign QINTint[0] = (TBYPASS_main===0 && delTBYPASS[0]===0)?OutReg[0] : (TBYPASS_main===1 && delTBYPASS[0]===1)?TBYPASS_D_Q[0] : WordX;
	assign QINTint[1] = (TBYPASS_main===0 && delTBYPASS[1]===0)?OutReg[1] : (TBYPASS_main===1 && delTBYPASS[1]===1)?TBYPASS_D_Q[1] : WordX;
	assign QINTint[2] = (TBYPASS_main===0 && delTBYPASS[2]===0)?OutReg[2] : (TBYPASS_main===1 && delTBYPASS[2]===1)?TBYPASS_D_Q[2] : WordX;
	assign QINTint[3] = (TBYPASS_main===0 && delTBYPASS[3]===0)?OutReg[3] : (TBYPASS_main===1 && delTBYPASS[3]===1)?TBYPASS_D_Q[3] : WordX;
	assign QINTint[4] = (TBYPASS_main===0 && delTBYPASS[4]===0)?OutReg[4] : (TBYPASS_main===1 && delTBYPASS[4]===1)?TBYPASS_D_Q[4] : WordX;
	assign QINTint[5] = (TBYPASS_main===0 && delTBYPASS[5]===0)?OutReg[5] : (TBYPASS_main===1 && delTBYPASS[5]===1)?TBYPASS_D_Q[5] : WordX;
	assign QINTint[6] = (TBYPASS_main===0 && delTBYPASS[6]===0)?OutReg[6] : (TBYPASS_main===1 && delTBYPASS[6]===1)?TBYPASS_D_Q[6] : WordX;
	assign QINTint[7] = (TBYPASS_main===0 && delTBYPASS[7]===0)?OutReg[7] : (TBYPASS_main===1 && delTBYPASS[7]===1)?TBYPASS_D_Q[7] : WordX;
	assign QINTint[8] = (TBYPASS_main===0 && delTBYPASS[8]===0)?OutReg[8] : (TBYPASS_main===1 && delTBYPASS[8]===1)?TBYPASS_D_Q[8] : WordX;
	assign QINTint[9] = (TBYPASS_main===0 && delTBYPASS[9]===0)?OutReg[9] : (TBYPASS_main===1 && delTBYPASS[9]===1)?TBYPASS_D_Q[9] : WordX;
	assign QINTint[10] = (TBYPASS_main===0 && delTBYPASS[10]===0)?OutReg[10] : (TBYPASS_main===1 && delTBYPASS[10]===1)?TBYPASS_D_Q[10] : WordX;
	assign QINTint[11] = (TBYPASS_main===0 && delTBYPASS[11]===0)?OutReg[11] : (TBYPASS_main===1 && delTBYPASS[11]===1)?TBYPASS_D_Q[11] : WordX;
	assign QINTint[12] = (TBYPASS_main===0 && delTBYPASS[12]===0)?OutReg[12] : (TBYPASS_main===1 && delTBYPASS[12]===1)?TBYPASS_D_Q[12] : WordX;
	assign QINTint[13] = (TBYPASS_main===0 && delTBYPASS[13]===0)?OutReg[13] : (TBYPASS_main===1 && delTBYPASS[13]===1)?TBYPASS_D_Q[13] : WordX;
	assign QINTint[14] = (TBYPASS_main===0 && delTBYPASS[14]===0)?OutReg[14] : (TBYPASS_main===1 && delTBYPASS[14]===1)?TBYPASS_D_Q[14] : WordX;
	assign QINTint[15] = (TBYPASS_main===0 && delTBYPASS[15]===0)?OutReg[15] : (TBYPASS_main===1 && delTBYPASS[15]===1)?TBYPASS_D_Q[15] : WordX;
	assign QINTint[16] = (TBYPASS_main===0 && delTBYPASS[16]===0)?OutReg[16] : (TBYPASS_main===1 && delTBYPASS[16]===1)?TBYPASS_D_Q[16] : WordX;
	assign QINTint[17] = (TBYPASS_main===0 && delTBYPASS[17]===0)?OutReg[17] : (TBYPASS_main===1 && delTBYPASS[17]===1)?TBYPASS_D_Q[17] : WordX;
	assign QINTint[18] = (TBYPASS_main===0 && delTBYPASS[18]===0)?OutReg[18] : (TBYPASS_main===1 && delTBYPASS[18]===1)?TBYPASS_D_Q[18] : WordX;
	assign QINTint[19] = (TBYPASS_main===0 && delTBYPASS[19]===0)?OutReg[19] : (TBYPASS_main===1 && delTBYPASS[19]===1)?TBYPASS_D_Q[19] : WordX;
	assign QINTint[20] = (TBYPASS_main===0 && delTBYPASS[20]===0)?OutReg[20] : (TBYPASS_main===1 && delTBYPASS[20]===1)?TBYPASS_D_Q[20] : WordX;
	assign QINTint[21] = (TBYPASS_main===0 && delTBYPASS[21]===0)?OutReg[21] : (TBYPASS_main===1 && delTBYPASS[21]===1)?TBYPASS_D_Q[21] : WordX;
	assign QINTint[22] = (TBYPASS_main===0 && delTBYPASS[22]===0)?OutReg[22] : (TBYPASS_main===1 && delTBYPASS[22]===1)?TBYPASS_D_Q[22] : WordX;
	assign QINTint[23] = (TBYPASS_main===0 && delTBYPASS[23]===0)?OutReg[23] : (TBYPASS_main===1 && delTBYPASS[23]===1)?TBYPASS_D_Q[23] : WordX;
	assign QINTint[24] = (TBYPASS_main===0 && delTBYPASS[24]===0)?OutReg[24] : (TBYPASS_main===1 && delTBYPASS[24]===1)?TBYPASS_D_Q[24] : WordX;
	assign QINTint[25] = (TBYPASS_main===0 && delTBYPASS[25]===0)?OutReg[25] : (TBYPASS_main===1 && delTBYPASS[25]===1)?TBYPASS_D_Q[25] : WordX;
	assign QINTint[26] = (TBYPASS_main===0 && delTBYPASS[26]===0)?OutReg[26] : (TBYPASS_main===1 && delTBYPASS[26]===1)?TBYPASS_D_Q[26] : WordX;
	assign QINTint[27] = (TBYPASS_main===0 && delTBYPASS[27]===0)?OutReg[27] : (TBYPASS_main===1 && delTBYPASS[27]===1)?TBYPASS_D_Q[27] : WordX;
	assign QINTint[28] = (TBYPASS_main===0 && delTBYPASS[28]===0)?OutReg[28] : (TBYPASS_main===1 && delTBYPASS[28]===1)?TBYPASS_D_Q[28] : WordX;
	assign QINTint[29] = (TBYPASS_main===0 && delTBYPASS[29]===0)?OutReg[29] : (TBYPASS_main===1 && delTBYPASS[29]===1)?TBYPASS_D_Q[29] : WordX;
	assign QINTint[30] = (TBYPASS_main===0 && delTBYPASS[30]===0)?OutReg[30] : (TBYPASS_main===1 && delTBYPASS[30]===1)?TBYPASS_D_Q[30] : WordX;
	assign QINTint[31] = (TBYPASS_main===0 && delTBYPASS[31]===0)?OutReg[31] : (TBYPASS_main===1 && delTBYPASS[31]===1)?TBYPASS_D_Q[31] : WordX;
	assign QINTint[32] = (TBYPASS_main===0 && delTBYPASS[32]===0)?OutReg[32] : (TBYPASS_main===1 && delTBYPASS[32]===1)?TBYPASS_D_Q[32] : WordX;
	assign QINTint[33] = (TBYPASS_main===0 && delTBYPASS[33]===0)?OutReg[33] : (TBYPASS_main===1 && delTBYPASS[33]===1)?TBYPASS_D_Q[33] : WordX;
	assign QINTint[34] = (TBYPASS_main===0 && delTBYPASS[34]===0)?OutReg[34] : (TBYPASS_main===1 && delTBYPASS[34]===1)?TBYPASS_D_Q[34] : WordX;
	assign QINTint[35] = (TBYPASS_main===0 && delTBYPASS[35]===0)?OutReg[35] : (TBYPASS_main===1 && delTBYPASS[35]===1)?TBYPASS_D_Q[35] : WordX;
	assign QINTint[36] = (TBYPASS_main===0 && delTBYPASS[36]===0)?OutReg[36] : (TBYPASS_main===1 && delTBYPASS[36]===1)?TBYPASS_D_Q[36] : WordX;
	assign QINTint[37] = (TBYPASS_main===0 && delTBYPASS[37]===0)?OutReg[37] : (TBYPASS_main===1 && delTBYPASS[37]===1)?TBYPASS_D_Q[37] : WordX;
	assign QINTint[38] = (TBYPASS_main===0 && delTBYPASS[38]===0)?OutReg[38] : (TBYPASS_main===1 && delTBYPASS[38]===1)?TBYPASS_D_Q[38] : WordX;
	assign QINTint[39] = (TBYPASS_main===0 && delTBYPASS[39]===0)?OutReg[39] : (TBYPASS_main===1 && delTBYPASS[39]===1)?TBYPASS_D_Q[39] : WordX;
	assign QINTint[40] = (TBYPASS_main===0 && delTBYPASS[40]===0)?OutReg[40] : (TBYPASS_main===1 && delTBYPASS[40]===1)?TBYPASS_D_Q[40] : WordX;
	assign QINTint[41] = (TBYPASS_main===0 && delTBYPASS[41]===0)?OutReg[41] : (TBYPASS_main===1 && delTBYPASS[41]===1)?TBYPASS_D_Q[41] : WordX;
	assign QINTint[42] = (TBYPASS_main===0 && delTBYPASS[42]===0)?OutReg[42] : (TBYPASS_main===1 && delTBYPASS[42]===1)?TBYPASS_D_Q[42] : WordX;
	assign QINTint[43] = (TBYPASS_main===0 && delTBYPASS[43]===0)?OutReg[43] : (TBYPASS_main===1 && delTBYPASS[43]===1)?TBYPASS_D_Q[43] : WordX;
	assign QINTint[44] = (TBYPASS_main===0 && delTBYPASS[44]===0)?OutReg[44] : (TBYPASS_main===1 && delTBYPASS[44]===1)?TBYPASS_D_Q[44] : WordX;
	assign QINTint[45] = (TBYPASS_main===0 && delTBYPASS[45]===0)?OutReg[45] : (TBYPASS_main===1 && delTBYPASS[45]===1)?TBYPASS_D_Q[45] : WordX;
	assign QINTint[46] = (TBYPASS_main===0 && delTBYPASS[46]===0)?OutReg[46] : (TBYPASS_main===1 && delTBYPASS[46]===1)?TBYPASS_D_Q[46] : WordX;
	assign QINTint[47] = (TBYPASS_main===0 && delTBYPASS[47]===0)?OutReg[47] : (TBYPASS_main===1 && delTBYPASS[47]===1)?TBYPASS_D_Q[47] : WordX;
	assign QINTint[48] = (TBYPASS_main===0 && delTBYPASS[48]===0)?OutReg[48] : (TBYPASS_main===1 && delTBYPASS[48]===1)?TBYPASS_D_Q[48] : WordX;
	assign QINTint[49] = (TBYPASS_main===0 && delTBYPASS[49]===0)?OutReg[49] : (TBYPASS_main===1 && delTBYPASS[49]===1)?TBYPASS_D_Q[49] : WordX;
	assign QINTint[50] = (TBYPASS_main===0 && delTBYPASS[50]===0)?OutReg[50] : (TBYPASS_main===1 && delTBYPASS[50]===1)?TBYPASS_D_Q[50] : WordX;
	assign QINTint[51] = (TBYPASS_main===0 && delTBYPASS[51]===0)?OutReg[51] : (TBYPASS_main===1 && delTBYPASS[51]===1)?TBYPASS_D_Q[51] : WordX;
	assign QINTint[52] = (TBYPASS_main===0 && delTBYPASS[52]===0)?OutReg[52] : (TBYPASS_main===1 && delTBYPASS[52]===1)?TBYPASS_D_Q[52] : WordX;
	assign QINTint[53] = (TBYPASS_main===0 && delTBYPASS[53]===0)?OutReg[53] : (TBYPASS_main===1 && delTBYPASS[53]===1)?TBYPASS_D_Q[53] : WordX;
	assign QINTint[54] = (TBYPASS_main===0 && delTBYPASS[54]===0)?OutReg[54] : (TBYPASS_main===1 && delTBYPASS[54]===1)?TBYPASS_D_Q[54] : WordX;
	assign QINTint[55] = (TBYPASS_main===0 && delTBYPASS[55]===0)?OutReg[55] : (TBYPASS_main===1 && delTBYPASS[55]===1)?TBYPASS_D_Q[55] : WordX;
	assign QINTint[56] = (TBYPASS_main===0 && delTBYPASS[56]===0)?OutReg[56] : (TBYPASS_main===1 && delTBYPASS[56]===1)?TBYPASS_D_Q[56] : WordX;
	assign QINTint[57] = (TBYPASS_main===0 && delTBYPASS[57]===0)?OutReg[57] : (TBYPASS_main===1 && delTBYPASS[57]===1)?TBYPASS_D_Q[57] : WordX;
	assign QINTint[58] = (TBYPASS_main===0 && delTBYPASS[58]===0)?OutReg[58] : (TBYPASS_main===1 && delTBYPASS[58]===1)?TBYPASS_D_Q[58] : WordX;
	assign QINTint[59] = (TBYPASS_main===0 && delTBYPASS[59]===0)?OutReg[59] : (TBYPASS_main===1 && delTBYPASS[59]===1)?TBYPASS_D_Q[59] : WordX;
	assign QINTint[60] = (TBYPASS_main===0 && delTBYPASS[60]===0)?OutReg[60] : (TBYPASS_main===1 && delTBYPASS[60]===1)?TBYPASS_D_Q[60] : WordX;
	assign QINTint[61] = (TBYPASS_main===0 && delTBYPASS[61]===0)?OutReg[61] : (TBYPASS_main===1 && delTBYPASS[61]===1)?TBYPASS_D_Q[61] : WordX;
	assign QINTint[62] = (TBYPASS_main===0 && delTBYPASS[62]===0)?OutReg[62] : (TBYPASS_main===1 && delTBYPASS[62]===1)?TBYPASS_D_Q[62] : WordX;
	assign QINTint[63] = (TBYPASS_main===0 && delTBYPASS[63]===0)?OutReg[63] : (TBYPASS_main===1 && delTBYPASS[63]===1)?TBYPASS_D_Q[63] : WordX;
assign QINTERNAL = QINTERNALreg;

always @ (TBYPASS_main)
begin
if (TBYPASS_main === 0 || TBYPASS_main === X) 
     QINTERNALreg = WordX;
end


        
/*------------------ RY functionality -----------------*/
       output RYINT;
        input RY_rfCK, RY_rrCK, RY_frCK, ICRY;
        wire RYINTint;
        reg RYINTreg, RYRiseFlag;

        buf (RYINT, RYINTint);

assign RYINTint = RYINTreg;
        
initial
begin
   RYRiseFlag = 1'b0;
   RYINTreg = 1'b1;
end

always @(ICRY)
begin
   if($realtime == 0)
      RYINTreg = 1'b1;
   else
      RYINTreg = 1'bx;
end

always @(RY_rfCK)
   if (ICRY !== 1)
   begin
      if ($realtime != 0)
      begin   
         RYINTreg = 0;
         RYRiseFlag=0;
      end   
   end


always @(RY_rrCK) 
#0 
   if (ICRY !== 1 && $realtime != 0)
   begin
      if (RYRiseFlag === 0)
      begin
         RYRiseFlag=1;
      end
      else
      begin
         RYINTreg = 1'b1;
         RYRiseFlag=0;
      end
   end


always @(RY_frCK)         
   if (ICRY !== 1 && $realtime != 0)
   begin
      if (RYRiseFlag === 0)
      begin
         RYRiseFlag=1;
      end
      else
      begin
         RYINTreg = 1'b1;
         RYRiseFlag=0;
      end
   end   

/*------------------------------------------------ */

always @(Q_gCK)
begin
#0  //This has been used for removing races during hold time vilations in MODELSIM simulator.
   lastQ_gCK = Q_gCKreg;
   Q_gCKreg <= Q_gCK;
   for (m = 0; m < Bits; m = m + 1)
   begin
      if (lastQ_gCK[m] !== Q_gCK[m])
      begin
        lastQINTERNAL[m] = QINTERNALreg[m];
        QINTERNALreg[m] = Q_glitch[m];
      end
   end
end

always @(Q_data)
begin
#0  //This has been used for removing races during hold time vilations in MODELSIM simulator.
    lastQ_data = Q_datareg;
    Q_datareg <= Q_data;
    for (n = 0; n < Bits; n = n + 1)
    begin
      if (lastQ_data[n] !== Q_data[n])
      begin
       	lastQINTERNAL[n] = QINTERNALreg[n];
        QINTERNALreg[n] = Q_data[n];
      end
    end
end

always @(QINTERNAL)
begin
   for (d = 0; d < Bits; d = d + 1)
   begin
      if (OutReg[d] !== QINTERNAL[d])
         OutReg[d] = QINTERNAL[d];
   end
end



endmodule



module ST_SPHS_16x64m4_L (Q, RY, CK, CSN, TBYPASS, WEN,  A,  D   );


    parameter 
        Corruption_Read_Violation = 1,
        Fault_file_name = "ST_SPHS_16x64m4_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20;
   
    // Parameters for Memory Initialization at 0 ns
    parameter 
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHS_16x64m4_L.cde",
        InstancePath = "ST_SPHS_16x64m4_L",
        Debug_mode = "all_warning_mode";
    
    parameter
        Words = 16,
        Bits = 64,
        Addr = 4,
        mux = 4;




   
    parameter
        Rows = Words/mux,
        WordX = 64'bx,
        AddrX = 4'bx,
        Word0 = 64'b0,
        X = 1'bx;

        
         
    // INPUT OUTPUT PORTS
    //  ======================

    output [Bits-1 : 0] Q;
    
    output RY;   
    input CK;
    input CSN;
    input WEN;
    input TBYPASS;
    input [Addr-1 : 0] A;
    input [Bits-1 : 0] D;
    
    


   

     

   // WIRE DECLARATIONS
   //======================
   
   wire [Bits-1 : 0] Q_glitchint;
   wire [Bits-1 : 0] Q_dataint;
   wire [Bits-1 : 0] Dint,Mint;
   wire [Addr-1 : 0] Aint;
   wire [Bits-1 : 0] Q_gCKint;
   wire CKint;
   wire CSNint;
   wire WENint;
   wire TBYPASSint;
   wire TBYPASS_mainint;
   wire [Bits-1 : 0]  TBYPASS_D_Qint;
   wire [Bits-1 : 0]  delTBYPASSint;




   wire [Bits-1 : 0] Qint, Q_out;
   
   
   

   //REG DECLARATIONS
   //======================

   reg [Bits-1 : 0] Dreg,Mreg;
   reg [Addr-1 : 0] Areg;
   reg CKreg;
   reg CSNreg;
   reg WENreg;
	
   reg [Bits-1 : 0] TimingViol_data, TimingViol_mask;
   reg [Bits-1 : 0] TimingViol_data_last, TimingViol_mask_last;
	reg TimingViol_data_0, TimingViol_mask_0;
	reg TimingViol_data_1, TimingViol_mask_1;
	reg TimingViol_data_2, TimingViol_mask_2;
	reg TimingViol_data_3, TimingViol_mask_3;
	reg TimingViol_data_4, TimingViol_mask_4;
	reg TimingViol_data_5, TimingViol_mask_5;
	reg TimingViol_data_6, TimingViol_mask_6;
	reg TimingViol_data_7, TimingViol_mask_7;
	reg TimingViol_data_8, TimingViol_mask_8;
	reg TimingViol_data_9, TimingViol_mask_9;
	reg TimingViol_data_10, TimingViol_mask_10;
	reg TimingViol_data_11, TimingViol_mask_11;
	reg TimingViol_data_12, TimingViol_mask_12;
	reg TimingViol_data_13, TimingViol_mask_13;
	reg TimingViol_data_14, TimingViol_mask_14;
	reg TimingViol_data_15, TimingViol_mask_15;
	reg TimingViol_data_16, TimingViol_mask_16;
	reg TimingViol_data_17, TimingViol_mask_17;
	reg TimingViol_data_18, TimingViol_mask_18;
	reg TimingViol_data_19, TimingViol_mask_19;
	reg TimingViol_data_20, TimingViol_mask_20;
	reg TimingViol_data_21, TimingViol_mask_21;
	reg TimingViol_data_22, TimingViol_mask_22;
	reg TimingViol_data_23, TimingViol_mask_23;
	reg TimingViol_data_24, TimingViol_mask_24;
	reg TimingViol_data_25, TimingViol_mask_25;
	reg TimingViol_data_26, TimingViol_mask_26;
	reg TimingViol_data_27, TimingViol_mask_27;
	reg TimingViol_data_28, TimingViol_mask_28;
	reg TimingViol_data_29, TimingViol_mask_29;
	reg TimingViol_data_30, TimingViol_mask_30;
	reg TimingViol_data_31, TimingViol_mask_31;
	reg TimingViol_data_32, TimingViol_mask_32;
	reg TimingViol_data_33, TimingViol_mask_33;
	reg TimingViol_data_34, TimingViol_mask_34;
	reg TimingViol_data_35, TimingViol_mask_35;
	reg TimingViol_data_36, TimingViol_mask_36;
	reg TimingViol_data_37, TimingViol_mask_37;
	reg TimingViol_data_38, TimingViol_mask_38;
	reg TimingViol_data_39, TimingViol_mask_39;
	reg TimingViol_data_40, TimingViol_mask_40;
	reg TimingViol_data_41, TimingViol_mask_41;
	reg TimingViol_data_42, TimingViol_mask_42;
	reg TimingViol_data_43, TimingViol_mask_43;
	reg TimingViol_data_44, TimingViol_mask_44;
	reg TimingViol_data_45, TimingViol_mask_45;
	reg TimingViol_data_46, TimingViol_mask_46;
	reg TimingViol_data_47, TimingViol_mask_47;
	reg TimingViol_data_48, TimingViol_mask_48;
	reg TimingViol_data_49, TimingViol_mask_49;
	reg TimingViol_data_50, TimingViol_mask_50;
	reg TimingViol_data_51, TimingViol_mask_51;
	reg TimingViol_data_52, TimingViol_mask_52;
	reg TimingViol_data_53, TimingViol_mask_53;
	reg TimingViol_data_54, TimingViol_mask_54;
	reg TimingViol_data_55, TimingViol_mask_55;
	reg TimingViol_data_56, TimingViol_mask_56;
	reg TimingViol_data_57, TimingViol_mask_57;
	reg TimingViol_data_58, TimingViol_mask_58;
	reg TimingViol_data_59, TimingViol_mask_59;
	reg TimingViol_data_60, TimingViol_mask_60;
	reg TimingViol_data_61, TimingViol_mask_61;
	reg TimingViol_data_62, TimingViol_mask_62;
	reg TimingViol_data_63, TimingViol_mask_63;
   reg TimingViol_addr;
   reg TimingViol_csn, TimingViol_wen, TimingViol_tbypass;
   reg TimingViol_tckh, TimingViol_tckl, TimingViol_tcycle;
   




   wire [Bits-1 : 0] MEN,CSWEMTBYPASS;
   wire CSTBYPASSN, CSWETBYPASSN,CS;

   /* This register is used to force all warning messages 
   ** OFF during run time.
   ** 
   */ 
   reg [1:0] debug_level;
   reg [8*10: 0] operating_mode;
   reg [8*44: 0] message_status;


initial
begin
  debug_level = 2'b0;
  message_status = "All Messages are Switched ON";
    
  
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
     message_status = "All Messages are Switched OFF"; 
  `endif 
if(debug_level !== 2'b10) begin
   $display ("%m  INFORMATION");
   $display ("***************************************");
   $display ("The Model is Operating in TIMING MODE");
   $display ("Please make sure that SDF is properly annotated otherwise dummy values will be used");
   $display ("%s", message_status);
   if(ConfigFault)
   $display ("Configurable Fault Functionality is ON");   
   else
   $display ("Configurable Fault Functionality is OFF");
   
   $display ("***************************************");
end     
end     

   
   // BUF DECLARATIONS
   //=====================
   
   buf (CKint, CK);
   or (CSNint, CSN, TBYPASSint);
   buf (TBYPASSint, TBYPASS);
   buf (WENint, WEN);
   buf bufDint [Bits-1:0] (Dint, D);
   
   assign Mint = 64'b0;
   
   buf bufAint [Addr-1:0] (Aint, A);


   assign Q =  Qint;




   


    wire  RYint, RY_rfCKint, RY_rrCKint, RY_frCKint, RY_out;
    reg RY_outreg; 
    assign RY_out = RY_outreg;
    assign RY =   RY_out;
    always @ (RYint)
    begin
       RY_outreg = RYint;
    end

        
    // Only include timing checks during behavioural modelling


    
    assign CS =  CSN;
    or (CSWETBYPASSN, WENint, CSNint);
    or (CSNTBY, CSN, TBYPASSint);  


        
 or (CSWEMTBYPASS[0], Mint[0], CSWETBYPASSN);
 or (CSWEMTBYPASS[1], Mint[1], CSWETBYPASSN);
 or (CSWEMTBYPASS[2], Mint[2], CSWETBYPASSN);
 or (CSWEMTBYPASS[3], Mint[3], CSWETBYPASSN);
 or (CSWEMTBYPASS[4], Mint[4], CSWETBYPASSN);
 or (CSWEMTBYPASS[5], Mint[5], CSWETBYPASSN);
 or (CSWEMTBYPASS[6], Mint[6], CSWETBYPASSN);
 or (CSWEMTBYPASS[7], Mint[7], CSWETBYPASSN);
 or (CSWEMTBYPASS[8], Mint[8], CSWETBYPASSN);
 or (CSWEMTBYPASS[9], Mint[9], CSWETBYPASSN);
 or (CSWEMTBYPASS[10], Mint[10], CSWETBYPASSN);
 or (CSWEMTBYPASS[11], Mint[11], CSWETBYPASSN);
 or (CSWEMTBYPASS[12], Mint[12], CSWETBYPASSN);
 or (CSWEMTBYPASS[13], Mint[13], CSWETBYPASSN);
 or (CSWEMTBYPASS[14], Mint[14], CSWETBYPASSN);
 or (CSWEMTBYPASS[15], Mint[15], CSWETBYPASSN);
 or (CSWEMTBYPASS[16], Mint[16], CSWETBYPASSN);
 or (CSWEMTBYPASS[17], Mint[17], CSWETBYPASSN);
 or (CSWEMTBYPASS[18], Mint[18], CSWETBYPASSN);
 or (CSWEMTBYPASS[19], Mint[19], CSWETBYPASSN);
 or (CSWEMTBYPASS[20], Mint[20], CSWETBYPASSN);
 or (CSWEMTBYPASS[21], Mint[21], CSWETBYPASSN);
 or (CSWEMTBYPASS[22], Mint[22], CSWETBYPASSN);
 or (CSWEMTBYPASS[23], Mint[23], CSWETBYPASSN);
 or (CSWEMTBYPASS[24], Mint[24], CSWETBYPASSN);
 or (CSWEMTBYPASS[25], Mint[25], CSWETBYPASSN);
 or (CSWEMTBYPASS[26], Mint[26], CSWETBYPASSN);
 or (CSWEMTBYPASS[27], Mint[27], CSWETBYPASSN);
 or (CSWEMTBYPASS[28], Mint[28], CSWETBYPASSN);
 or (CSWEMTBYPASS[29], Mint[29], CSWETBYPASSN);
 or (CSWEMTBYPASS[30], Mint[30], CSWETBYPASSN);
 or (CSWEMTBYPASS[31], Mint[31], CSWETBYPASSN);
 or (CSWEMTBYPASS[32], Mint[32], CSWETBYPASSN);
 or (CSWEMTBYPASS[33], Mint[33], CSWETBYPASSN);
 or (CSWEMTBYPASS[34], Mint[34], CSWETBYPASSN);
 or (CSWEMTBYPASS[35], Mint[35], CSWETBYPASSN);
 or (CSWEMTBYPASS[36], Mint[36], CSWETBYPASSN);
 or (CSWEMTBYPASS[37], Mint[37], CSWETBYPASSN);
 or (CSWEMTBYPASS[38], Mint[38], CSWETBYPASSN);
 or (CSWEMTBYPASS[39], Mint[39], CSWETBYPASSN);
 or (CSWEMTBYPASS[40], Mint[40], CSWETBYPASSN);
 or (CSWEMTBYPASS[41], Mint[41], CSWETBYPASSN);
 or (CSWEMTBYPASS[42], Mint[42], CSWETBYPASSN);
 or (CSWEMTBYPASS[43], Mint[43], CSWETBYPASSN);
 or (CSWEMTBYPASS[44], Mint[44], CSWETBYPASSN);
 or (CSWEMTBYPASS[45], Mint[45], CSWETBYPASSN);
 or (CSWEMTBYPASS[46], Mint[46], CSWETBYPASSN);
 or (CSWEMTBYPASS[47], Mint[47], CSWETBYPASSN);
 or (CSWEMTBYPASS[48], Mint[48], CSWETBYPASSN);
 or (CSWEMTBYPASS[49], Mint[49], CSWETBYPASSN);
 or (CSWEMTBYPASS[50], Mint[50], CSWETBYPASSN);
 or (CSWEMTBYPASS[51], Mint[51], CSWETBYPASSN);
 or (CSWEMTBYPASS[52], Mint[52], CSWETBYPASSN);
 or (CSWEMTBYPASS[53], Mint[53], CSWETBYPASSN);
 or (CSWEMTBYPASS[54], Mint[54], CSWETBYPASSN);
 or (CSWEMTBYPASS[55], Mint[55], CSWETBYPASSN);
 or (CSWEMTBYPASS[56], Mint[56], CSWETBYPASSN);
 or (CSWEMTBYPASS[57], Mint[57], CSWETBYPASSN);
 or (CSWEMTBYPASS[58], Mint[58], CSWETBYPASSN);
 or (CSWEMTBYPASS[59], Mint[59], CSWETBYPASSN);
 or (CSWEMTBYPASS[60], Mint[60], CSWETBYPASSN);
 or (CSWEMTBYPASS[61], Mint[61], CSWETBYPASSN);
 or (CSWEMTBYPASS[62], Mint[62], CSWETBYPASSN);
 or (CSWEMTBYPASS[63], Mint[63], CSWETBYPASSN);

    specify
    specparam


         tckl_tck_ry = 0.00,
         tcycle_taa_ry = 0.00,

         
         
	 tms = 0.0,
         tmh = 0.0,
         tcycle = 0.0,
         tckh = 0.0,
         tckl = 0.0,
         ttms = 0.0,
         ttmh = 0.0,
         tps = 0.0,
         tph = 0.0,
         tws = 0.0,
         twh = 0.0,
         tas = 0.0,
         tah = 0.0,
         tds = 0.0,
         tdh = 0.0;
        /*---------------------- Timing Checks ---------------------*/

	$setup(posedge A[0], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[1], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[2], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[3], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[0], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[1], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[2], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[3], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[0], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[1], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[2], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[3], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[0], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[1], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[2], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[3], tah, TimingViol_addr);
	$setup(posedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 1), tds, TimingViol_data_0);
	$setup(posedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 1), tds, TimingViol_data_1);
	$setup(posedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 1), tds, TimingViol_data_2);
	$setup(posedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 1), tds, TimingViol_data_3);
	$setup(posedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 1), tds, TimingViol_data_4);
	$setup(posedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 1), tds, TimingViol_data_5);
	$setup(posedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 1), tds, TimingViol_data_6);
	$setup(posedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 1), tds, TimingViol_data_7);
	$setup(posedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 1), tds, TimingViol_data_8);
	$setup(posedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 1), tds, TimingViol_data_9);
	$setup(posedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 1), tds, TimingViol_data_10);
	$setup(posedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 1), tds, TimingViol_data_11);
	$setup(posedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 1), tds, TimingViol_data_12);
	$setup(posedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 1), tds, TimingViol_data_13);
	$setup(posedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 1), tds, TimingViol_data_14);
	$setup(posedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 1), tds, TimingViol_data_15);
	$setup(posedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 1), tds, TimingViol_data_16);
	$setup(posedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 1), tds, TimingViol_data_17);
	$setup(posedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 1), tds, TimingViol_data_18);
	$setup(posedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 1), tds, TimingViol_data_19);
	$setup(posedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 1), tds, TimingViol_data_20);
	$setup(posedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 1), tds, TimingViol_data_21);
	$setup(posedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 1), tds, TimingViol_data_22);
	$setup(posedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 1), tds, TimingViol_data_23);
	$setup(posedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 1), tds, TimingViol_data_24);
	$setup(posedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 1), tds, TimingViol_data_25);
	$setup(posedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 1), tds, TimingViol_data_26);
	$setup(posedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 1), tds, TimingViol_data_27);
	$setup(posedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 1), tds, TimingViol_data_28);
	$setup(posedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 1), tds, TimingViol_data_29);
	$setup(posedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 1), tds, TimingViol_data_30);
	$setup(posedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 1), tds, TimingViol_data_31);
	$setup(posedge D[32], posedge CK &&& (CSWEMTBYPASS[32] != 1), tds, TimingViol_data_32);
	$setup(posedge D[33], posedge CK &&& (CSWEMTBYPASS[33] != 1), tds, TimingViol_data_33);
	$setup(posedge D[34], posedge CK &&& (CSWEMTBYPASS[34] != 1), tds, TimingViol_data_34);
	$setup(posedge D[35], posedge CK &&& (CSWEMTBYPASS[35] != 1), tds, TimingViol_data_35);
	$setup(posedge D[36], posedge CK &&& (CSWEMTBYPASS[36] != 1), tds, TimingViol_data_36);
	$setup(posedge D[37], posedge CK &&& (CSWEMTBYPASS[37] != 1), tds, TimingViol_data_37);
	$setup(posedge D[38], posedge CK &&& (CSWEMTBYPASS[38] != 1), tds, TimingViol_data_38);
	$setup(posedge D[39], posedge CK &&& (CSWEMTBYPASS[39] != 1), tds, TimingViol_data_39);
	$setup(posedge D[40], posedge CK &&& (CSWEMTBYPASS[40] != 1), tds, TimingViol_data_40);
	$setup(posedge D[41], posedge CK &&& (CSWEMTBYPASS[41] != 1), tds, TimingViol_data_41);
	$setup(posedge D[42], posedge CK &&& (CSWEMTBYPASS[42] != 1), tds, TimingViol_data_42);
	$setup(posedge D[43], posedge CK &&& (CSWEMTBYPASS[43] != 1), tds, TimingViol_data_43);
	$setup(posedge D[44], posedge CK &&& (CSWEMTBYPASS[44] != 1), tds, TimingViol_data_44);
	$setup(posedge D[45], posedge CK &&& (CSWEMTBYPASS[45] != 1), tds, TimingViol_data_45);
	$setup(posedge D[46], posedge CK &&& (CSWEMTBYPASS[46] != 1), tds, TimingViol_data_46);
	$setup(posedge D[47], posedge CK &&& (CSWEMTBYPASS[47] != 1), tds, TimingViol_data_47);
	$setup(posedge D[48], posedge CK &&& (CSWEMTBYPASS[48] != 1), tds, TimingViol_data_48);
	$setup(posedge D[49], posedge CK &&& (CSWEMTBYPASS[49] != 1), tds, TimingViol_data_49);
	$setup(posedge D[50], posedge CK &&& (CSWEMTBYPASS[50] != 1), tds, TimingViol_data_50);
	$setup(posedge D[51], posedge CK &&& (CSWEMTBYPASS[51] != 1), tds, TimingViol_data_51);
	$setup(posedge D[52], posedge CK &&& (CSWEMTBYPASS[52] != 1), tds, TimingViol_data_52);
	$setup(posedge D[53], posedge CK &&& (CSWEMTBYPASS[53] != 1), tds, TimingViol_data_53);
	$setup(posedge D[54], posedge CK &&& (CSWEMTBYPASS[54] != 1), tds, TimingViol_data_54);
	$setup(posedge D[55], posedge CK &&& (CSWEMTBYPASS[55] != 1), tds, TimingViol_data_55);
	$setup(posedge D[56], posedge CK &&& (CSWEMTBYPASS[56] != 1), tds, TimingViol_data_56);
	$setup(posedge D[57], posedge CK &&& (CSWEMTBYPASS[57] != 1), tds, TimingViol_data_57);
	$setup(posedge D[58], posedge CK &&& (CSWEMTBYPASS[58] != 1), tds, TimingViol_data_58);
	$setup(posedge D[59], posedge CK &&& (CSWEMTBYPASS[59] != 1), tds, TimingViol_data_59);
	$setup(posedge D[60], posedge CK &&& (CSWEMTBYPASS[60] != 1), tds, TimingViol_data_60);
	$setup(posedge D[61], posedge CK &&& (CSWEMTBYPASS[61] != 1), tds, TimingViol_data_61);
	$setup(posedge D[62], posedge CK &&& (CSWEMTBYPASS[62] != 1), tds, TimingViol_data_62);
	$setup(posedge D[63], posedge CK &&& (CSWEMTBYPASS[63] != 1), tds, TimingViol_data_63);
	$setup(negedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 1), tds, TimingViol_data_0);
	$setup(negedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 1), tds, TimingViol_data_1);
	$setup(negedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 1), tds, TimingViol_data_2);
	$setup(negedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 1), tds, TimingViol_data_3);
	$setup(negedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 1), tds, TimingViol_data_4);
	$setup(negedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 1), tds, TimingViol_data_5);
	$setup(negedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 1), tds, TimingViol_data_6);
	$setup(negedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 1), tds, TimingViol_data_7);
	$setup(negedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 1), tds, TimingViol_data_8);
	$setup(negedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 1), tds, TimingViol_data_9);
	$setup(negedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 1), tds, TimingViol_data_10);
	$setup(negedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 1), tds, TimingViol_data_11);
	$setup(negedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 1), tds, TimingViol_data_12);
	$setup(negedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 1), tds, TimingViol_data_13);
	$setup(negedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 1), tds, TimingViol_data_14);
	$setup(negedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 1), tds, TimingViol_data_15);
	$setup(negedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 1), tds, TimingViol_data_16);
	$setup(negedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 1), tds, TimingViol_data_17);
	$setup(negedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 1), tds, TimingViol_data_18);
	$setup(negedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 1), tds, TimingViol_data_19);
	$setup(negedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 1), tds, TimingViol_data_20);
	$setup(negedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 1), tds, TimingViol_data_21);
	$setup(negedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 1), tds, TimingViol_data_22);
	$setup(negedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 1), tds, TimingViol_data_23);
	$setup(negedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 1), tds, TimingViol_data_24);
	$setup(negedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 1), tds, TimingViol_data_25);
	$setup(negedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 1), tds, TimingViol_data_26);
	$setup(negedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 1), tds, TimingViol_data_27);
	$setup(negedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 1), tds, TimingViol_data_28);
	$setup(negedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 1), tds, TimingViol_data_29);
	$setup(negedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 1), tds, TimingViol_data_30);
	$setup(negedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 1), tds, TimingViol_data_31);
	$setup(negedge D[32], posedge CK &&& (CSWEMTBYPASS[32] != 1), tds, TimingViol_data_32);
	$setup(negedge D[33], posedge CK &&& (CSWEMTBYPASS[33] != 1), tds, TimingViol_data_33);
	$setup(negedge D[34], posedge CK &&& (CSWEMTBYPASS[34] != 1), tds, TimingViol_data_34);
	$setup(negedge D[35], posedge CK &&& (CSWEMTBYPASS[35] != 1), tds, TimingViol_data_35);
	$setup(negedge D[36], posedge CK &&& (CSWEMTBYPASS[36] != 1), tds, TimingViol_data_36);
	$setup(negedge D[37], posedge CK &&& (CSWEMTBYPASS[37] != 1), tds, TimingViol_data_37);
	$setup(negedge D[38], posedge CK &&& (CSWEMTBYPASS[38] != 1), tds, TimingViol_data_38);
	$setup(negedge D[39], posedge CK &&& (CSWEMTBYPASS[39] != 1), tds, TimingViol_data_39);
	$setup(negedge D[40], posedge CK &&& (CSWEMTBYPASS[40] != 1), tds, TimingViol_data_40);
	$setup(negedge D[41], posedge CK &&& (CSWEMTBYPASS[41] != 1), tds, TimingViol_data_41);
	$setup(negedge D[42], posedge CK &&& (CSWEMTBYPASS[42] != 1), tds, TimingViol_data_42);
	$setup(negedge D[43], posedge CK &&& (CSWEMTBYPASS[43] != 1), tds, TimingViol_data_43);
	$setup(negedge D[44], posedge CK &&& (CSWEMTBYPASS[44] != 1), tds, TimingViol_data_44);
	$setup(negedge D[45], posedge CK &&& (CSWEMTBYPASS[45] != 1), tds, TimingViol_data_45);
	$setup(negedge D[46], posedge CK &&& (CSWEMTBYPASS[46] != 1), tds, TimingViol_data_46);
	$setup(negedge D[47], posedge CK &&& (CSWEMTBYPASS[47] != 1), tds, TimingViol_data_47);
	$setup(negedge D[48], posedge CK &&& (CSWEMTBYPASS[48] != 1), tds, TimingViol_data_48);
	$setup(negedge D[49], posedge CK &&& (CSWEMTBYPASS[49] != 1), tds, TimingViol_data_49);
	$setup(negedge D[50], posedge CK &&& (CSWEMTBYPASS[50] != 1), tds, TimingViol_data_50);
	$setup(negedge D[51], posedge CK &&& (CSWEMTBYPASS[51] != 1), tds, TimingViol_data_51);
	$setup(negedge D[52], posedge CK &&& (CSWEMTBYPASS[52] != 1), tds, TimingViol_data_52);
	$setup(negedge D[53], posedge CK &&& (CSWEMTBYPASS[53] != 1), tds, TimingViol_data_53);
	$setup(negedge D[54], posedge CK &&& (CSWEMTBYPASS[54] != 1), tds, TimingViol_data_54);
	$setup(negedge D[55], posedge CK &&& (CSWEMTBYPASS[55] != 1), tds, TimingViol_data_55);
	$setup(negedge D[56], posedge CK &&& (CSWEMTBYPASS[56] != 1), tds, TimingViol_data_56);
	$setup(negedge D[57], posedge CK &&& (CSWEMTBYPASS[57] != 1), tds, TimingViol_data_57);
	$setup(negedge D[58], posedge CK &&& (CSWEMTBYPASS[58] != 1), tds, TimingViol_data_58);
	$setup(negedge D[59], posedge CK &&& (CSWEMTBYPASS[59] != 1), tds, TimingViol_data_59);
	$setup(negedge D[60], posedge CK &&& (CSWEMTBYPASS[60] != 1), tds, TimingViol_data_60);
	$setup(negedge D[61], posedge CK &&& (CSWEMTBYPASS[61] != 1), tds, TimingViol_data_61);
	$setup(negedge D[62], posedge CK &&& (CSWEMTBYPASS[62] != 1), tds, TimingViol_data_62);
	$setup(negedge D[63], posedge CK &&& (CSWEMTBYPASS[63] != 1), tds, TimingViol_data_63);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 1), posedge D[0], tdh, TimingViol_data_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 1), posedge D[1], tdh, TimingViol_data_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 1), posedge D[2], tdh, TimingViol_data_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 1), posedge D[3], tdh, TimingViol_data_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 1), posedge D[4], tdh, TimingViol_data_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 1), posedge D[5], tdh, TimingViol_data_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 1), posedge D[6], tdh, TimingViol_data_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 1), posedge D[7], tdh, TimingViol_data_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 1), posedge D[8], tdh, TimingViol_data_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 1), posedge D[9], tdh, TimingViol_data_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 1), posedge D[10], tdh, TimingViol_data_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 1), posedge D[11], tdh, TimingViol_data_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 1), posedge D[12], tdh, TimingViol_data_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 1), posedge D[13], tdh, TimingViol_data_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 1), posedge D[14], tdh, TimingViol_data_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 1), posedge D[15], tdh, TimingViol_data_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 1), posedge D[16], tdh, TimingViol_data_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 1), posedge D[17], tdh, TimingViol_data_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 1), posedge D[18], tdh, TimingViol_data_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 1), posedge D[19], tdh, TimingViol_data_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 1), posedge D[20], tdh, TimingViol_data_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 1), posedge D[21], tdh, TimingViol_data_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 1), posedge D[22], tdh, TimingViol_data_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 1), posedge D[23], tdh, TimingViol_data_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 1), posedge D[24], tdh, TimingViol_data_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 1), posedge D[25], tdh, TimingViol_data_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 1), posedge D[26], tdh, TimingViol_data_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 1), posedge D[27], tdh, TimingViol_data_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 1), posedge D[28], tdh, TimingViol_data_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 1), posedge D[29], tdh, TimingViol_data_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 1), posedge D[30], tdh, TimingViol_data_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 1), posedge D[31], tdh, TimingViol_data_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[32] != 1), posedge D[32], tdh, TimingViol_data_32);
	$hold(posedge CK &&& (CSWEMTBYPASS[33] != 1), posedge D[33], tdh, TimingViol_data_33);
	$hold(posedge CK &&& (CSWEMTBYPASS[34] != 1), posedge D[34], tdh, TimingViol_data_34);
	$hold(posedge CK &&& (CSWEMTBYPASS[35] != 1), posedge D[35], tdh, TimingViol_data_35);
	$hold(posedge CK &&& (CSWEMTBYPASS[36] != 1), posedge D[36], tdh, TimingViol_data_36);
	$hold(posedge CK &&& (CSWEMTBYPASS[37] != 1), posedge D[37], tdh, TimingViol_data_37);
	$hold(posedge CK &&& (CSWEMTBYPASS[38] != 1), posedge D[38], tdh, TimingViol_data_38);
	$hold(posedge CK &&& (CSWEMTBYPASS[39] != 1), posedge D[39], tdh, TimingViol_data_39);
	$hold(posedge CK &&& (CSWEMTBYPASS[40] != 1), posedge D[40], tdh, TimingViol_data_40);
	$hold(posedge CK &&& (CSWEMTBYPASS[41] != 1), posedge D[41], tdh, TimingViol_data_41);
	$hold(posedge CK &&& (CSWEMTBYPASS[42] != 1), posedge D[42], tdh, TimingViol_data_42);
	$hold(posedge CK &&& (CSWEMTBYPASS[43] != 1), posedge D[43], tdh, TimingViol_data_43);
	$hold(posedge CK &&& (CSWEMTBYPASS[44] != 1), posedge D[44], tdh, TimingViol_data_44);
	$hold(posedge CK &&& (CSWEMTBYPASS[45] != 1), posedge D[45], tdh, TimingViol_data_45);
	$hold(posedge CK &&& (CSWEMTBYPASS[46] != 1), posedge D[46], tdh, TimingViol_data_46);
	$hold(posedge CK &&& (CSWEMTBYPASS[47] != 1), posedge D[47], tdh, TimingViol_data_47);
	$hold(posedge CK &&& (CSWEMTBYPASS[48] != 1), posedge D[48], tdh, TimingViol_data_48);
	$hold(posedge CK &&& (CSWEMTBYPASS[49] != 1), posedge D[49], tdh, TimingViol_data_49);
	$hold(posedge CK &&& (CSWEMTBYPASS[50] != 1), posedge D[50], tdh, TimingViol_data_50);
	$hold(posedge CK &&& (CSWEMTBYPASS[51] != 1), posedge D[51], tdh, TimingViol_data_51);
	$hold(posedge CK &&& (CSWEMTBYPASS[52] != 1), posedge D[52], tdh, TimingViol_data_52);
	$hold(posedge CK &&& (CSWEMTBYPASS[53] != 1), posedge D[53], tdh, TimingViol_data_53);
	$hold(posedge CK &&& (CSWEMTBYPASS[54] != 1), posedge D[54], tdh, TimingViol_data_54);
	$hold(posedge CK &&& (CSWEMTBYPASS[55] != 1), posedge D[55], tdh, TimingViol_data_55);
	$hold(posedge CK &&& (CSWEMTBYPASS[56] != 1), posedge D[56], tdh, TimingViol_data_56);
	$hold(posedge CK &&& (CSWEMTBYPASS[57] != 1), posedge D[57], tdh, TimingViol_data_57);
	$hold(posedge CK &&& (CSWEMTBYPASS[58] != 1), posedge D[58], tdh, TimingViol_data_58);
	$hold(posedge CK &&& (CSWEMTBYPASS[59] != 1), posedge D[59], tdh, TimingViol_data_59);
	$hold(posedge CK &&& (CSWEMTBYPASS[60] != 1), posedge D[60], tdh, TimingViol_data_60);
	$hold(posedge CK &&& (CSWEMTBYPASS[61] != 1), posedge D[61], tdh, TimingViol_data_61);
	$hold(posedge CK &&& (CSWEMTBYPASS[62] != 1), posedge D[62], tdh, TimingViol_data_62);
	$hold(posedge CK &&& (CSWEMTBYPASS[63] != 1), posedge D[63], tdh, TimingViol_data_63);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 1), negedge D[0], tdh, TimingViol_data_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 1), negedge D[1], tdh, TimingViol_data_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 1), negedge D[2], tdh, TimingViol_data_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 1), negedge D[3], tdh, TimingViol_data_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 1), negedge D[4], tdh, TimingViol_data_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 1), negedge D[5], tdh, TimingViol_data_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 1), negedge D[6], tdh, TimingViol_data_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 1), negedge D[7], tdh, TimingViol_data_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 1), negedge D[8], tdh, TimingViol_data_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 1), negedge D[9], tdh, TimingViol_data_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 1), negedge D[10], tdh, TimingViol_data_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 1), negedge D[11], tdh, TimingViol_data_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 1), negedge D[12], tdh, TimingViol_data_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 1), negedge D[13], tdh, TimingViol_data_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 1), negedge D[14], tdh, TimingViol_data_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 1), negedge D[15], tdh, TimingViol_data_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 1), negedge D[16], tdh, TimingViol_data_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 1), negedge D[17], tdh, TimingViol_data_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 1), negedge D[18], tdh, TimingViol_data_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 1), negedge D[19], tdh, TimingViol_data_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 1), negedge D[20], tdh, TimingViol_data_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 1), negedge D[21], tdh, TimingViol_data_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 1), negedge D[22], tdh, TimingViol_data_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 1), negedge D[23], tdh, TimingViol_data_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 1), negedge D[24], tdh, TimingViol_data_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 1), negedge D[25], tdh, TimingViol_data_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 1), negedge D[26], tdh, TimingViol_data_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 1), negedge D[27], tdh, TimingViol_data_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 1), negedge D[28], tdh, TimingViol_data_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 1), negedge D[29], tdh, TimingViol_data_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 1), negedge D[30], tdh, TimingViol_data_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 1), negedge D[31], tdh, TimingViol_data_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[32] != 1), negedge D[32], tdh, TimingViol_data_32);
	$hold(posedge CK &&& (CSWEMTBYPASS[33] != 1), negedge D[33], tdh, TimingViol_data_33);
	$hold(posedge CK &&& (CSWEMTBYPASS[34] != 1), negedge D[34], tdh, TimingViol_data_34);
	$hold(posedge CK &&& (CSWEMTBYPASS[35] != 1), negedge D[35], tdh, TimingViol_data_35);
	$hold(posedge CK &&& (CSWEMTBYPASS[36] != 1), negedge D[36], tdh, TimingViol_data_36);
	$hold(posedge CK &&& (CSWEMTBYPASS[37] != 1), negedge D[37], tdh, TimingViol_data_37);
	$hold(posedge CK &&& (CSWEMTBYPASS[38] != 1), negedge D[38], tdh, TimingViol_data_38);
	$hold(posedge CK &&& (CSWEMTBYPASS[39] != 1), negedge D[39], tdh, TimingViol_data_39);
	$hold(posedge CK &&& (CSWEMTBYPASS[40] != 1), negedge D[40], tdh, TimingViol_data_40);
	$hold(posedge CK &&& (CSWEMTBYPASS[41] != 1), negedge D[41], tdh, TimingViol_data_41);
	$hold(posedge CK &&& (CSWEMTBYPASS[42] != 1), negedge D[42], tdh, TimingViol_data_42);
	$hold(posedge CK &&& (CSWEMTBYPASS[43] != 1), negedge D[43], tdh, TimingViol_data_43);
	$hold(posedge CK &&& (CSWEMTBYPASS[44] != 1), negedge D[44], tdh, TimingViol_data_44);
	$hold(posedge CK &&& (CSWEMTBYPASS[45] != 1), negedge D[45], tdh, TimingViol_data_45);
	$hold(posedge CK &&& (CSWEMTBYPASS[46] != 1), negedge D[46], tdh, TimingViol_data_46);
	$hold(posedge CK &&& (CSWEMTBYPASS[47] != 1), negedge D[47], tdh, TimingViol_data_47);
	$hold(posedge CK &&& (CSWEMTBYPASS[48] != 1), negedge D[48], tdh, TimingViol_data_48);
	$hold(posedge CK &&& (CSWEMTBYPASS[49] != 1), negedge D[49], tdh, TimingViol_data_49);
	$hold(posedge CK &&& (CSWEMTBYPASS[50] != 1), negedge D[50], tdh, TimingViol_data_50);
	$hold(posedge CK &&& (CSWEMTBYPASS[51] != 1), negedge D[51], tdh, TimingViol_data_51);
	$hold(posedge CK &&& (CSWEMTBYPASS[52] != 1), negedge D[52], tdh, TimingViol_data_52);
	$hold(posedge CK &&& (CSWEMTBYPASS[53] != 1), negedge D[53], tdh, TimingViol_data_53);
	$hold(posedge CK &&& (CSWEMTBYPASS[54] != 1), negedge D[54], tdh, TimingViol_data_54);
	$hold(posedge CK &&& (CSWEMTBYPASS[55] != 1), negedge D[55], tdh, TimingViol_data_55);
	$hold(posedge CK &&& (CSWEMTBYPASS[56] != 1), negedge D[56], tdh, TimingViol_data_56);
	$hold(posedge CK &&& (CSWEMTBYPASS[57] != 1), negedge D[57], tdh, TimingViol_data_57);
	$hold(posedge CK &&& (CSWEMTBYPASS[58] != 1), negedge D[58], tdh, TimingViol_data_58);
	$hold(posedge CK &&& (CSWEMTBYPASS[59] != 1), negedge D[59], tdh, TimingViol_data_59);
	$hold(posedge CK &&& (CSWEMTBYPASS[60] != 1), negedge D[60], tdh, TimingViol_data_60);
	$hold(posedge CK &&& (CSWEMTBYPASS[61] != 1), negedge D[61], tdh, TimingViol_data_61);
	$hold(posedge CK &&& (CSWEMTBYPASS[62] != 1), negedge D[62], tdh, TimingViol_data_62);
	$hold(posedge CK &&& (CSWEMTBYPASS[63] != 1), negedge D[63], tdh, TimingViol_data_63);

	
        $setup(posedge CSN, edge[01,0x,x1,1x] CK &&& (TBYPASSint != 1), tps, TimingViol_csn);
	$setup(negedge CSN, edge[01,0x,x1,1x] CK &&& (TBYPASSint != 1), tps, TimingViol_csn);
	$hold(edge[01,0x,x1,x0] CK &&& (TBYPASSint != 1), posedge CSN, tph, TimingViol_csn);
	$hold(edge[01,0x,x1,x0] CK &&& (TBYPASSint != 1), negedge CSN, tph, TimingViol_csn);
        $setup(posedge WEN, edge[01,0x,x1,1x] CK &&& (CSNint != 1), tws, TimingViol_wen);
        $setup(negedge WEN, edge[01,0x,x1,1x] CK &&& (CSNint != 1), tws, TimingViol_wen);
        $hold(edge[01,0x,x1,x0] CK &&& (CSNint != 1), posedge WEN, twh, TimingViol_wen);
        $hold(edge[01,0x,x1,x0] CK &&& (CSNint != 1), negedge WEN, twh, TimingViol_wen);
        $period(posedge CK &&& (CSNint != 1), tcycle, TimingViol_tcycle);
        $width(posedge CK &&& (CSNint != 1'b1), tckh, 0, TimingViol_tckh);
        $width(negedge CK &&& (CSNint != 1'b1), tckl, 0, TimingViol_tckl);
        $setup(posedge TBYPASS, posedge CK &&& (CS != 1),ttms, TimingViol_tbypass);
        $setup(negedge TBYPASS, posedge CK &&& (CS != 1),ttms, TimingViol_tbypass);
        $hold(posedge CK &&& (CS != 1), posedge TBYPASS, ttmh, TimingViol_tbypass); 
        $hold(posedge CK &&& (CS != 1), negedge TBYPASS, ttmh, TimingViol_tbypass); 




	endspecify

always @(CKint)
begin
   CKreg <= CKint;
end

//latch input signals
always @(posedge CKint)
begin
   if (CSNint !== 1)
   begin
      Dreg = Dint;
      Mreg = Mint;
      WENreg = WENint;
      Areg = Aint;
   end
   CSNreg = CSNint;
end
     


// conversion from registers to array elements for data setup violation notifiers

always @(TimingViol_data_0)
begin
   TimingViol_data[0] = TimingViol_data_0;
end


always @(TimingViol_data_1)
begin
   TimingViol_data[1] = TimingViol_data_1;
end


always @(TimingViol_data_2)
begin
   TimingViol_data[2] = TimingViol_data_2;
end


always @(TimingViol_data_3)
begin
   TimingViol_data[3] = TimingViol_data_3;
end


always @(TimingViol_data_4)
begin
   TimingViol_data[4] = TimingViol_data_4;
end


always @(TimingViol_data_5)
begin
   TimingViol_data[5] = TimingViol_data_5;
end


always @(TimingViol_data_6)
begin
   TimingViol_data[6] = TimingViol_data_6;
end


always @(TimingViol_data_7)
begin
   TimingViol_data[7] = TimingViol_data_7;
end


always @(TimingViol_data_8)
begin
   TimingViol_data[8] = TimingViol_data_8;
end


always @(TimingViol_data_9)
begin
   TimingViol_data[9] = TimingViol_data_9;
end


always @(TimingViol_data_10)
begin
   TimingViol_data[10] = TimingViol_data_10;
end


always @(TimingViol_data_11)
begin
   TimingViol_data[11] = TimingViol_data_11;
end


always @(TimingViol_data_12)
begin
   TimingViol_data[12] = TimingViol_data_12;
end


always @(TimingViol_data_13)
begin
   TimingViol_data[13] = TimingViol_data_13;
end


always @(TimingViol_data_14)
begin
   TimingViol_data[14] = TimingViol_data_14;
end


always @(TimingViol_data_15)
begin
   TimingViol_data[15] = TimingViol_data_15;
end


always @(TimingViol_data_16)
begin
   TimingViol_data[16] = TimingViol_data_16;
end


always @(TimingViol_data_17)
begin
   TimingViol_data[17] = TimingViol_data_17;
end


always @(TimingViol_data_18)
begin
   TimingViol_data[18] = TimingViol_data_18;
end


always @(TimingViol_data_19)
begin
   TimingViol_data[19] = TimingViol_data_19;
end


always @(TimingViol_data_20)
begin
   TimingViol_data[20] = TimingViol_data_20;
end


always @(TimingViol_data_21)
begin
   TimingViol_data[21] = TimingViol_data_21;
end


always @(TimingViol_data_22)
begin
   TimingViol_data[22] = TimingViol_data_22;
end


always @(TimingViol_data_23)
begin
   TimingViol_data[23] = TimingViol_data_23;
end


always @(TimingViol_data_24)
begin
   TimingViol_data[24] = TimingViol_data_24;
end


always @(TimingViol_data_25)
begin
   TimingViol_data[25] = TimingViol_data_25;
end


always @(TimingViol_data_26)
begin
   TimingViol_data[26] = TimingViol_data_26;
end


always @(TimingViol_data_27)
begin
   TimingViol_data[27] = TimingViol_data_27;
end


always @(TimingViol_data_28)
begin
   TimingViol_data[28] = TimingViol_data_28;
end


always @(TimingViol_data_29)
begin
   TimingViol_data[29] = TimingViol_data_29;
end


always @(TimingViol_data_30)
begin
   TimingViol_data[30] = TimingViol_data_30;
end


always @(TimingViol_data_31)
begin
   TimingViol_data[31] = TimingViol_data_31;
end


always @(TimingViol_data_32)
begin
   TimingViol_data[32] = TimingViol_data_32;
end


always @(TimingViol_data_33)
begin
   TimingViol_data[33] = TimingViol_data_33;
end


always @(TimingViol_data_34)
begin
   TimingViol_data[34] = TimingViol_data_34;
end


always @(TimingViol_data_35)
begin
   TimingViol_data[35] = TimingViol_data_35;
end


always @(TimingViol_data_36)
begin
   TimingViol_data[36] = TimingViol_data_36;
end


always @(TimingViol_data_37)
begin
   TimingViol_data[37] = TimingViol_data_37;
end


always @(TimingViol_data_38)
begin
   TimingViol_data[38] = TimingViol_data_38;
end


always @(TimingViol_data_39)
begin
   TimingViol_data[39] = TimingViol_data_39;
end


always @(TimingViol_data_40)
begin
   TimingViol_data[40] = TimingViol_data_40;
end


always @(TimingViol_data_41)
begin
   TimingViol_data[41] = TimingViol_data_41;
end


always @(TimingViol_data_42)
begin
   TimingViol_data[42] = TimingViol_data_42;
end


always @(TimingViol_data_43)
begin
   TimingViol_data[43] = TimingViol_data_43;
end


always @(TimingViol_data_44)
begin
   TimingViol_data[44] = TimingViol_data_44;
end


always @(TimingViol_data_45)
begin
   TimingViol_data[45] = TimingViol_data_45;
end


always @(TimingViol_data_46)
begin
   TimingViol_data[46] = TimingViol_data_46;
end


always @(TimingViol_data_47)
begin
   TimingViol_data[47] = TimingViol_data_47;
end


always @(TimingViol_data_48)
begin
   TimingViol_data[48] = TimingViol_data_48;
end


always @(TimingViol_data_49)
begin
   TimingViol_data[49] = TimingViol_data_49;
end


always @(TimingViol_data_50)
begin
   TimingViol_data[50] = TimingViol_data_50;
end


always @(TimingViol_data_51)
begin
   TimingViol_data[51] = TimingViol_data_51;
end


always @(TimingViol_data_52)
begin
   TimingViol_data[52] = TimingViol_data_52;
end


always @(TimingViol_data_53)
begin
   TimingViol_data[53] = TimingViol_data_53;
end


always @(TimingViol_data_54)
begin
   TimingViol_data[54] = TimingViol_data_54;
end


always @(TimingViol_data_55)
begin
   TimingViol_data[55] = TimingViol_data_55;
end


always @(TimingViol_data_56)
begin
   TimingViol_data[56] = TimingViol_data_56;
end


always @(TimingViol_data_57)
begin
   TimingViol_data[57] = TimingViol_data_57;
end


always @(TimingViol_data_58)
begin
   TimingViol_data[58] = TimingViol_data_58;
end


always @(TimingViol_data_59)
begin
   TimingViol_data[59] = TimingViol_data_59;
end


always @(TimingViol_data_60)
begin
   TimingViol_data[60] = TimingViol_data_60;
end


always @(TimingViol_data_61)
begin
   TimingViol_data[61] = TimingViol_data_61;
end


always @(TimingViol_data_62)
begin
   TimingViol_data[62] = TimingViol_data_62;
end


always @(TimingViol_data_63)
begin
   TimingViol_data[63] = TimingViol_data_63;
end




ST_SPHS_16x64m4_L_main ST_SPHS_16x64m4_L_maininst (Q_glitchint,  Q_dataint, Q_gCKint , RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint, CKint,  CSNint , TBYPASSint, WENint,  Aint, Dint, Mint, debug_level  , TimingViol_addr, TimingViol_data, TimingViol_csn, TimingViol_wen, TimingViol_tckh, TimingViol_tckl, TimingViol_tcycle, TimingViol_tbypass, TimingViol_mask    );


ST_SPHS_16x64m4_L_OPschlr ST_SPHS_16x64m4_L_OPschlrinst (Qint, RYint,  Q_gCKint, Q_glitchint,  Q_dataint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint);

defparam ST_SPHS_16x64m4_L_maininst.Fault_file_name = Fault_file_name;
defparam ST_SPHS_16x64m4_L_maininst.ConfigFault = ConfigFault;
defparam ST_SPHS_16x64m4_L_maininst.max_faults = max_faults;
defparam ST_SPHS_16x64m4_L_maininst.MEM_INITIALIZE = MEM_INITIALIZE;
defparam ST_SPHS_16x64m4_L_maininst.BinaryInit = BinaryInit;
defparam ST_SPHS_16x64m4_L_maininst.InitFileName = InitFileName;

endmodule
`endif

`delay_mode_path
`endcelldefine
`disable_portfaults
`nosuppress_faults









/****************************************************************
--  Description         : Verilog Model for SPHSLP cmos65
--  Last modified in    : 5.3.a
--  Date                : April, 2009
--  Last modified by    : SK 
--
****************************************************************/
 

/******************** START OF HEADER****************************
   This Header Gives Information about the parameters & options present in the Model

   words = 48
   bits  = 64
   mux   = 4 
   
   
   
   

**********************END OF HEADER ******************************/
   


`ifdef slm
        `define functional
`endif
`celldefine
`suppress_faults
`enable_portfaults
`ifdef functional
   `timescale 1ns / 1ns
   `delay_mode_unit
`endif

`ifdef functional

module ST_SPHS_48x64m4_L (Q, RY,CK, CSN, TBYPASS, WEN, A, D    );

    
    
    parameter 
        Corruption_Read_Violation = 1,
        Fault_file_name = "ST_SPHS_48x64m4_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20;
   
   // Parameters for Memory Initialization at 0 ns
    parameter 
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHS_48x64m4_L.cde",
        InstancePath = "ST_SPHS_48x64m4_L",
        Debug_mode = "all_warning_mode";
    
    parameter
        Words = 48,
        Bits = 64,
        Addr = 6,
        mux = 4;




   
    parameter
        Rows = Words/mux,
        WordX = 64'bx,
        AddrX = 6'bx,
        Word0 = 64'b0,
        X = 1'bx;


         
      
        //  INPUT OUTPUT PORTS
        // ========================
      
	output [Bits-1 : 0] Q;
        
        output RY;   
        
        input [Bits-1 : 0] D;
	input [Addr-1 : 0] A;
	        
        input CK, CSN, TBYPASS, WEN;

        
        
        

           
        
        
	reg [Bits-1 : 0] Qint; 

    
        //  WIRE DECLARATION
        //  =====================
        
        
	wire [Bits-1 : 0] Dint,Mint;
        
        assign Mint=64'b0;
        
	wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;

        
        
        wire TBYPASSint;
        
 
        

        
        wire RYint;
        
        
        assign RY =   RYint; 
        reg RY_outreg, RY_out;
        assign RYint = RY_out;
        
        

        
        
        //  REG DECLARATION
        //  ====================
        
	//Output Register for tbypass
        reg [Bits-1 : 0] tbydata;
        //delayed Output Register
        reg [Bits-1 : 0] delOutReg_data;
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] tempMem;
	reg lastCK;
        reg CSNreg;	

        `ifdef slm
        `else
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
        `endif
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;

        
        
        reg WENreg;
        
        
        /* This register is used to force all warning messages 
        ** OFF during run time.
        ** It is a 2 bit register.
        ** USAGE :
        ** debug_level_off = 2'b00 -> ALL WARNING MESSAGES will be DISPLAYED 
        ** debug_level = 2'b10 -> ALL WARNING MESSAGES will NOT be DISPLAYED.
        ** It will override the value of debug_mode, i.e
        ** if debug_mode = "all_warning_mode", then also
        ** no warning messages will be displayed.     
        ** debug_level = 2'b01 OR 2'b11 -> UNUSED , FOR FUTURE SCALABILITY.
        ** ult, debug_mode will prevail.               
        */ 
         reg [1:0] debug_level;
         reg [8*10: 0] operating_mode;
         reg [8*44: 0] message_status;

        integer d, a, p, i, k, j, l;
        `ifdef slm
           integer MemAddr;
        `endif


        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;

        `ifdef slm
        reg [Bits -1 : 0] slm_temp_data;
        `endif
        

        integer flag_error;
        
        //BUFFER INSTANTIATION
        //=========================
        
        
        assign Q =  Qint; 
        buf bufdata [Bits-1:0] (Dint,D);
        buf bufaddr [Addr-1:0] (Aint,A);
        
	buf (TBYPASSint, TBYPASS);
	buf (CKint, CK);
        
        or (CSNint, CSN,TBYPASSint ); 
	buf (WENint, WEN);
        
        
        
        

           

        

// BEHAVIOURAL MODULE DESCRIPTION
// ================================



task task_insert_faults_in_memory;
begin
   if (ConfigFault)
   begin   
     Fault_in_memory = 1;
     for(i = 0;i< fcnt;i = i+ 1) begin
       if (fault_repair_flag[i] !== 1) begin
         Fault_in_memory = 0;
         if (array_stuck_at[i] === "sa0") begin
         `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data & stuck_at_0fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
         `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
         `endif
         end //if(array_stuck_at)
                                        
         if(array_stuck_at[i] === "sa1") begin
         `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data | stuck_at_1fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
         `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
         `endif
         end //if(array_stuck_at)
       end   // if(fault_repair_flag
     end    // end of for
   end  
end
endtask


      
task WriteMemX;
begin
   `ifdef slm
   $slm_ResetMemory(MemAddr, WordX);
   `else
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
   `endif        
   task_insert_faults_in_memory;
end
endtask

task WriteOutX;                
begin
   OutReg_data = WordX;
end
endtask


task WriteCycle;                  
input [Addr-1 : 0] Address;
reg [Bits-1:0] tempReg1,tempReg2;
integer po,i;
begin
   
   tempReg1 = WordX;
   if (^Address !== X)
   begin
      if (ValidAddress)
      begin
         
         
            `ifdef slm
               $slm_ReadMemoryS(MemAddr, Address, tempReg1);
            `else
               tempReg1 = Mem[Address];
            `endif
                   
            for (po=0;po<Bits;po=po+1)
            begin
               if (Mint[po] === 1'b0)
                  tempReg1[po] = Dint[po];
               else if (Mint[po] === 1'bX)
                  tempReg1[po] = 1'bx;
            end                
         
            `ifdef slm
                $slm_WriteMemory(MemAddr, Address, tempReg1);
            `else
                Mem[Address] = tempReg1;
            `endif
            
      end//if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. ",$realtime); 
      task_insert_faults_in_memory;
   end //if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
      
   end
  
end
endtask

task ReadCycle;
input [Addr-1 : 0] Address;
reg [Bits-1:0] MemData;
integer a;
begin
   if (ValidAddress)
   begin        
      `ifdef slm
         $slm_ReadMemory(MemAddr, Address, MemData);
      `else
         MemData = Mem[Address];
      `endif
   end //if (ValidAddress)  
                
   if(ValidAddress === X)
   begin
      if (Corruption_Read_Violation === 1)
      begin   
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
         WriteMemX;
      end
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Output Corrupted ",$realtime);
      MemData = WordX;
      
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. Output Corrupted ",$realtime); 
      MemData = WordX;
   end
   
   OutReg_data = MemData;
end
endtask



initial
begin
   // Define format for timing value
  $timeformat (-9, 2, " ns", 0);
  `ifdef slm
  $slm_RegisterMemory(MemAddr, Words, Bits);
  `endif   
  
   debug_level= 2'b0;
   message_status = "All Messages are Switched ON";
  
   
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
     message_status = "All Warning Messages are Switched OFF";
  `endif  
  `ifdef slm
     operating_mode = "SLM";
  `else
     operating_mode = "FUNCTIONAL";
  `endif
if(debug_level !== 2'b10) begin
  $display ("%mINFORMATION ");
  $display ("***************************************");
  $display ("The Model is Operating in %s MODE", operating_mode);
  $display ("%s", message_status);
  if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF");   
  
  $display ("***************************************");
end     
  if (MEM_INITIALIZE === 1'b1)
  begin   
     `ifdef slm
        if (BinaryInit)
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_BIN");
        else
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_HEX");

     `else
        if (BinaryInit)
           $readmemb(InitFileName, Mem, 0, Words-1);
        else
           $readmemh(InitFileName, Mem, 0, Words-1);
     `endif
  end   
   
  

  
  RY_out = 1'b1;


        
/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
      file_ptr = $fopen(Fault_file_name , "r");
      if(file_ptr == 0)
      begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
      end        
      else                
      begin : read_fault_file
        t = 0;
        for (i = 0; i< max_faults; i= i + 1)
        begin
         
           stuck0 = {Bits{1'b1}};
           stuck1 = {Bits{1'b0}};
           fault_char1 = $fgetc (file_ptr);
           if (fault_char1 == 8'b11111111)
              disable read_fault_file;
           ret_val = $ungetc (fault_char1, file_ptr);
           ret_val = $fgets(tempStr, file_ptr);
           ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
           flag_error = 0; 
           if(ret_val !== 0)
           begin         
              if(ret_val == 2 || ret_val == 3)
              begin
                if(ret_val == 2)
                   stuck_at = "sa0";

                if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                begin
                   if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                   flag_error = 1;
                end    
                      
                if(fault_word > Words-1)
                begin
                   if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                   flag_error = 1;
                end    

                if(fault_bit > Bits-1)
                begin  
                   if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                   flag_error = 1;
                end    

                if(flag_error == 0)
                //Correct Inputs
                begin
                   if(stuck_at === "none")
                   begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                   end
                   else
                   //Adding the faults
                   begin
                      FailureLocn[t] = fault_word;
                      std_fault_word = fault_word;
                      
                      fault_repair_flag[t] = 1'b0;
                      if (stuck_at === "sa0" )
                      begin
                         stuck0[fault_bit] = 1'b0;         
                         stuck_at_0fault[t] = stuck0;
                      end     
                      if (stuck_at === "sa1" )
                      begin
                         stuck1[fault_bit] = 1'b1;
                         stuck_at_1fault[t] = stuck1; 
                      end

                      array_stuck_at[t] = stuck_at;
                      t = t + 1;
                   end //if(stuck_at === "none")  
                end //if(flag_error == 0)
              end //if(ret_val == 2 || ret_val == 3 
              else
              //wrong number of arguments
              begin
                if(debug_level < 2)
                   $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                flag_error = 1;
              end
           end //if(ret_val !== 0)
           else
           begin
              if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
           end    
        end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);

      fcnt = t;

      
      //fault injection at time 0.
      task_insert_faults_in_memory;
   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//
        
always @(CKint)
begin
  
      // Unknown Clock Behaviour
      if (CKint=== X && CSNint !==1)
      begin
         WriteOutX;
         WriteMemX;
          
         RY_out = 1'bX;
      end
      if(CKint === 1'b1 && lastCK === 1'b0)
      begin
         CSNreg = CSNint;
         WENreg = WENint;
         if (CSNint !== 1)
         begin
            if (^Aint === X)
               ValidAddress = X;
            else if (Aint < Words)
               ValidAddress = 1;
            else    
               ValidAddress = 0;

            if (ValidAddress)
	       `ifdef slm
               $slm_ReadMemoryS(MemAddr, Aint, Mem_temp);
               `else        
               Mem_temp = Mem[Aint];
               `endif       
            else
	       Mem_temp = WordX; 
               
            
         end// CSNint !==1...
      end // if(CKint === 1'b1...)
        
   /*---------------------- Normal Read and Write -----------------*/

      if (CSNint !== 1 && CKint === 1'b1 && lastCK === 1'b0 )
      begin
            if (CSNint === 0)
            begin        
               
               if (ValidAddress !== 1'bX )   
                  RY_outreg = ~CKint;
               else
                  RY_outreg = 1'bX;
               if (WENint === 1)
               begin
                  ReadCycle(Aint);
               end
               else if (WENint === 0)
               begin
                  
                   WriteCycle(Aint);
                   
               end
               else if (WENint === X)
               begin
                  // Uncertain write cycle
                  WriteOutX;
                  WriteMemX;
                  
                  RY_outreg = 1'bX;
                  if(debug_level < 2) $display("%m - %t (MSG_ID 002) WARNING: Illegal Value on Write Enable. Memory and Output Corrupted ",$realtime);
                  
               end // if (WENint === X...)
            end //if (CSNint === 0
            else if (CSNint === X)
            begin
                
                RY_outreg = 1'bX;
                if(debug_level < 2) $display("%m - %t (MSG_ID 001) WARNING: Illegal Value on Chip Select. Memory and Output Corrupted ",$realtime);
                WriteOutX;
                WriteMemX;
            end //else if (CSNint === X)
         
       
       
      end // if (CSNint !==1..          

   
   lastCK = CKint;
end // always @(CKint)
        
always @(CSNint)
begin
     // Unknown Clock & CSN signal
     if (CSNint !== 1 && CKint === 1'bx)
     begin
       if(debug_level < 2) $display("%m - %t (MSG_ID 004) WARNING: Chip Select going low while Clock is Invalid. Memory Corrupted ",$realtime);
       WriteMemX;
       WriteOutX;
       
       RY_out = 1'bX;
     end
end



//TBYPASS functionality
 always @(TBYPASSint)
 begin
     
             
      
        OutReg_data = WordX;
        if(TBYPASSint === 1'b1) 
          tbydata = Dint;
        else
          tbydata = WordX;
          
    
    
    
 end //end of always TBYPASSint

 always @(Dint)
 begin
    
     
       
      if(TBYPASSint === 1'b1)
        tbydata = Dint;
      
    
    
    
 end //end of always Dint

//assign output data
always @(OutReg_data)
   #1 delOutReg_data = OutReg_data;

always @(delOutReg_data or tbydata or TBYPASSint)
   if(TBYPASSint === 1'b0)
      Qint = delOutReg_data;
   else if(TBYPASSint === 1'bX)
      Qint = WordX;
   else
      Qint = tbydata;      

 
 always @(TBYPASSint)
 begin
    
     
      
      if(TBYPASSint !== 1'b0)
        RY_outreg = 1'bx;
        
    
    
    
 end

 always @(negedge CKint)
 begin
    
     
      
      if(TBYPASSint === 1'b1)
        RY_outreg = 1'b1;
      else if (TBYPASSint === 1'b0) 
         if(CSNreg === 1'b0 && WENreg !== 1'bX && ValidAddress !== 1'bX  && RY_outreg !== 1'bX)
            RY_outreg = ~CKint;
            
    
    
    
 end

always @(RY_outreg)
begin
  #1 RY_out = RY_outreg;
end





endmodule


`else

`timescale 1ns / 1ps
`delay_mode_path
 
module ST_SPHS_48x64m4_L_main (Q_glitch,  Q_data, Q_gCK , RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main, CK,  CSN, TBYPASS, WEN,  A, D, M,debug_level , TimingViol_addr, TimingViol_data, TimingViol_csn, TimingViol_wen, TimingViol_tckh, TimingViol_tckl, TimingViol_tcycle, TimingViol_tbypass, TimingViol_mask     );

    
       
    parameter 
        Corruption_Read_Violation = 1,
        Fault_file_name = "ST_SPHS_48x64m4_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20;
   
    // Parameters for Memory Initialization at 0 ns
    parameter 
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHS_48x64m4_L.cde",
        InstancePath = "ST_SPHS_48x64m4_L",
        Debug_mode = "all_warning_mode";
    
    parameter
        Words = 48,
        Bits = 64,
        Addr = 6,
        mux = 4,
        Rows = Words/mux;




   
    parameter
        WordX = 64'bx,
        AddrX = 6'bx,
        Word0 = 64'b0,
        X = 1'bx;
         
      
        //  INPUT OUTPUT PORTS
        // ========================
	output [Bits-1 : 0] Q_glitch;
	output [Bits-1 : 0] Q_data;
	output [Bits-1 : 0] Q_gCK;
        
        output ICRY;
        output RY_rfCK;
	output RY_rrCK;
	output RY_frCK;   
	output [Bits-1 : 0] delTBYPASS; 
	output TBYPASS_main; 
        output [Bits-1 : 0] TBYPASS_D_Q;
        
        input [Bits-1 : 0] D,M;
	input [Addr-1 : 0] A;
	input CK, CSN, TBYPASS, WEN;
        input [1 : 0] debug_level;

	input [Bits-1 : 0] TimingViol_data, TimingViol_mask;
	input TimingViol_addr, TimingViol_csn, TimingViol_wen, TimingViol_tckh, TimingViol_tckl, TimingViol_tcycle, TimingViol_tbypass;

        
        
 



        
        wire [Bits-1 : 0] Dint,Mint; 
	wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;
        
        


        
        
        
	wire  Mreg_0;
	wire  Mreg_1;
	wire  Mreg_2;
	wire  Mreg_3;
	wire  Mreg_4;
	wire  Mreg_5;
	wire  Mreg_6;
	wire  Mreg_7;
	wire  Mreg_8;
	wire  Mreg_9;
	wire  Mreg_10;
	wire  Mreg_11;
	wire  Mreg_12;
	wire  Mreg_13;
	wire  Mreg_14;
	wire  Mreg_15;
	wire  Mreg_16;
	wire  Mreg_17;
	wire  Mreg_18;
	wire  Mreg_19;
	wire  Mreg_20;
	wire  Mreg_21;
	wire  Mreg_22;
	wire  Mreg_23;
	wire  Mreg_24;
	wire  Mreg_25;
	wire  Mreg_26;
	wire  Mreg_27;
	wire  Mreg_28;
	wire  Mreg_29;
	wire  Mreg_30;
	wire  Mreg_31;
	wire  Mreg_32;
	wire  Mreg_33;
	wire  Mreg_34;
	wire  Mreg_35;
	wire  Mreg_36;
	wire  Mreg_37;
	wire  Mreg_38;
	wire  Mreg_39;
	wire  Mreg_40;
	wire  Mreg_41;
	wire  Mreg_42;
	wire  Mreg_43;
	wire  Mreg_44;
	wire  Mreg_45;
	wire  Mreg_46;
	wire  Mreg_47;
	wire  Mreg_48;
	wire  Mreg_49;
	wire  Mreg_50;
	wire  Mreg_51;
	wire  Mreg_52;
	wire  Mreg_53;
	wire  Mreg_54;
	wire  Mreg_55;
	wire  Mreg_56;
	wire  Mreg_57;
	wire  Mreg_58;
	wire  Mreg_59;
	wire  Mreg_60;
	wire  Mreg_61;
	wire  Mreg_62;
	wire  Mreg_63;
	
	reg [Bits-1 : 0] OutReg_glitch; // Glitch Output register
	reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] Dreg,Mreg;
	reg [Bits-1 : 0] Mreg_temp;
	reg [Bits-1 : 0] tempMem;
	reg [Bits-1 : 0] prevMem;
	reg [Addr-1 : 0] Areg;
	reg [Bits-1 : 0] Q_gCKreg; 
	reg [Bits-1 : 0] lastQ_gCK;
	reg [Bits-1 : 0] last_Qdata;
	reg lastCK, CKreg;
	reg CSNreg;
	reg WENreg;
	
        reg [Bits-1 : 0] TimingViol_data_last;
        reg [Bits-1 : 0] TimingViol_mask_last;
	
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;
	reg ICGFlag;
        



        
       
        
        
        

        integer d, a, p, i, k, j, l;

        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;

        integer flag_error;


	assign Mreg_0 = Mreg[0];
	assign Mreg_1 = Mreg[1];
	assign Mreg_2 = Mreg[2];
	assign Mreg_3 = Mreg[3];
	assign Mreg_4 = Mreg[4];
	assign Mreg_5 = Mreg[5];
	assign Mreg_6 = Mreg[6];
	assign Mreg_7 = Mreg[7];
	assign Mreg_8 = Mreg[8];
	assign Mreg_9 = Mreg[9];
	assign Mreg_10 = Mreg[10];
	assign Mreg_11 = Mreg[11];
	assign Mreg_12 = Mreg[12];
	assign Mreg_13 = Mreg[13];
	assign Mreg_14 = Mreg[14];
	assign Mreg_15 = Mreg[15];
	assign Mreg_16 = Mreg[16];
	assign Mreg_17 = Mreg[17];
	assign Mreg_18 = Mreg[18];
	assign Mreg_19 = Mreg[19];
	assign Mreg_20 = Mreg[20];
	assign Mreg_21 = Mreg[21];
	assign Mreg_22 = Mreg[22];
	assign Mreg_23 = Mreg[23];
	assign Mreg_24 = Mreg[24];
	assign Mreg_25 = Mreg[25];
	assign Mreg_26 = Mreg[26];
	assign Mreg_27 = Mreg[27];
	assign Mreg_28 = Mreg[28];
	assign Mreg_29 = Mreg[29];
	assign Mreg_30 = Mreg[30];
	assign Mreg_31 = Mreg[31];
	assign Mreg_32 = Mreg[32];
	assign Mreg_33 = Mreg[33];
	assign Mreg_34 = Mreg[34];
	assign Mreg_35 = Mreg[35];
	assign Mreg_36 = Mreg[36];
	assign Mreg_37 = Mreg[37];
	assign Mreg_38 = Mreg[38];
	assign Mreg_39 = Mreg[39];
	assign Mreg_40 = Mreg[40];
	assign Mreg_41 = Mreg[41];
	assign Mreg_42 = Mreg[42];
	assign Mreg_43 = Mreg[43];
	assign Mreg_44 = Mreg[44];
	assign Mreg_45 = Mreg[45];
	assign Mreg_46 = Mreg[46];
	assign Mreg_47 = Mreg[47];
	assign Mreg_48 = Mreg[48];
	assign Mreg_49 = Mreg[49];
	assign Mreg_50 = Mreg[50];
	assign Mreg_51 = Mreg[51];
	assign Mreg_52 = Mreg[52];
	assign Mreg_53 = Mreg[53];
	assign Mreg_54 = Mreg[54];
	assign Mreg_55 = Mreg[55];
	assign Mreg_56 = Mreg[56];
	assign Mreg_57 = Mreg[57];
	assign Mreg_58 = Mreg[58];
	assign Mreg_59 = Mreg[59];
	assign Mreg_60 = Mreg[60];
	assign Mreg_61 = Mreg[61];
	assign Mreg_62 = Mreg[62];
	assign Mreg_63 = Mreg[63];

        //BUFFER INSTANTIATION
        //=========================
        
        buf bufdint [Bits-1:0] (Dint, D);

        buf bufmint [Bits-1:0] (Mint, M);
        
        buf bufaint [Addr-1:0] (Aint, A);
	
	buf (TBYPASS_main, TBYPASS);
	buf (CKint, CK);
        
        buf (CSNint, CSN); 
	buf (WENint, WEN);

        //TBYPASS functionality
        buf bufdeltb [Bits-1:0] (delTBYPASS, TBYPASS);
        
           
        buf bugtbdq [Bits-1:0] (TBYPASS_D_Q, D);

        
        


        
        
        

        wire RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYFlagint;
        reg RY_rfCKreg, RY_rrCKreg, RY_frCKreg; 
	reg InitialRYFlag, ICRYFlag;
        
        buf (RY_rfCK, RY_rfCKint);
	buf (RY_rrCK, RY_rrCKint);
	buf (RY_frCK, RY_frCKint); 
        
        buf (ICRY, ICRYFlagint);
        assign ICRYFlagint = ICRYFlag;
        
        
    specify
        specparam

            tdq = 0.01,
            ttmq = 0.01,
            
            taa_ry = 1.0,
            th_ry = 0.9,
            tck_ry = 1.0,
            taa = 1.0,
            th = 0.9;
        /*-------------------- Propagation Delays ------------------*/
	if (WENreg && !ICGFlag) (CK *> (Q_data[0] : D[0])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[1] : D[1])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[2] : D[2])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[3] : D[3])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[4] : D[4])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[5] : D[5])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[6] : D[6])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[7] : D[7])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[8] : D[8])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[9] : D[9])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[10] : D[10])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[11] : D[11])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[12] : D[12])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[13] : D[13])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[14] : D[14])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[15] : D[15])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[16] : D[16])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[17] : D[17])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[18] : D[18])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[19] : D[19])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[20] : D[20])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[21] : D[21])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[22] : D[22])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[23] : D[23])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[24] : D[24])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[25] : D[25])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[26] : D[26])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[27] : D[27])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[28] : D[28])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[29] : D[29])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[30] : D[30])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[31] : D[31])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[32] : D[32])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[33] : D[33])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[34] : D[34])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[35] : D[35])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[36] : D[36])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[37] : D[37])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[38] : D[38])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[39] : D[39])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[40] : D[40])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[41] : D[41])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[42] : D[42])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[43] : D[43])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[44] : D[44])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[45] : D[45])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[46] : D[46])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[47] : D[47])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[48] : D[48])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[49] : D[49])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[50] : D[50])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[51] : D[51])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[52] : D[52])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[53] : D[53])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[54] : D[54])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[55] : D[55])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[56] : D[56])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[57] : D[57])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[58] : D[58])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[59] : D[59])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[60] : D[60])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[61] : D[61])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[62] : D[62])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[63] : D[63])) = (taa, taa);

	if (!ICGFlag) (CK *> (Q_glitch[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[31] : D[31])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[32] : D[32])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[33] : D[33])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[34] : D[34])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[35] : D[35])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[36] : D[36])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[37] : D[37])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[38] : D[38])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[39] : D[39])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[40] : D[40])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[41] : D[41])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[42] : D[42])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[43] : D[43])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[44] : D[44])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[45] : D[45])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[46] : D[46])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[47] : D[47])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[48] : D[48])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[49] : D[49])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[50] : D[50])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[51] : D[51])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[52] : D[52])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[53] : D[53])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[54] : D[54])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[55] : D[55])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[56] : D[56])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[57] : D[57])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[58] : D[58])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[59] : D[59])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[60] : D[60])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[61] : D[61])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[62] : D[62])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[63] : D[63])) = (th, th);

	if (!ICGFlag) (CK *> (Q_gCK[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[31] : D[31])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[32] : D[32])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[33] : D[33])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[34] : D[34])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[35] : D[35])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[36] : D[36])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[37] : D[37])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[38] : D[38])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[39] : D[39])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[40] : D[40])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[41] : D[41])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[42] : D[42])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[43] : D[43])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[44] : D[44])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[45] : D[45])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[46] : D[46])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[47] : D[47])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[48] : D[48])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[49] : D[49])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[50] : D[50])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[51] : D[51])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[52] : D[52])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[53] : D[53])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[54] : D[54])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[55] : D[55])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[56] : D[56])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[57] : D[57])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[58] : D[58])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[59] : D[59])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[60] : D[60])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[61] : D[61])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[62] : D[62])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[63] : D[63])) = (th, th);

	if (!TBYPASS) (TBYPASS *> delTBYPASS[0]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[1]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[2]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[3]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[4]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[5]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[6]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[7]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[8]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[9]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[10]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[11]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[12]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[13]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[14]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[15]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[16]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[17]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[18]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[19]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[20]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[21]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[22]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[23]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[24]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[25]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[26]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[27]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[28]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[29]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[30]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[31]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[32]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[33]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[34]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[35]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[36]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[37]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[38]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[39]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[40]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[41]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[42]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[43]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[44]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[45]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[46]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[47]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[48]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[49]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[50]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[51]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[52]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[53]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[54]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[55]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[56]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[57]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[58]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[59]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[60]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[61]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[62]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[63]) = (0);
	if (TBYPASS) (TBYPASS *> delTBYPASS[0]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[1]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[2]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[3]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[4]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[5]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[6]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[7]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[8]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[9]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[10]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[11]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[12]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[13]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[14]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[15]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[16]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[17]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[18]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[19]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[20]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[21]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[22]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[23]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[24]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[25]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[26]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[27]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[28]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[29]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[30]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[31]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[32]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[33]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[34]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[35]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[36]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[37]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[38]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[39]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[40]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[41]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[42]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[43]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[44]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[45]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[46]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[47]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[48]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[49]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[50]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[51]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[52]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[53]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[54]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[55]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[56]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[57]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[58]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[59]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[60]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[61]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[62]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[63]) = (ttmq);
      (D[0] *> TBYPASS_D_Q[0]) = (tdq, tdq);
      (D[1] *> TBYPASS_D_Q[1]) = (tdq, tdq);
      (D[2] *> TBYPASS_D_Q[2]) = (tdq, tdq);
      (D[3] *> TBYPASS_D_Q[3]) = (tdq, tdq);
      (D[4] *> TBYPASS_D_Q[4]) = (tdq, tdq);
      (D[5] *> TBYPASS_D_Q[5]) = (tdq, tdq);
      (D[6] *> TBYPASS_D_Q[6]) = (tdq, tdq);
      (D[7] *> TBYPASS_D_Q[7]) = (tdq, tdq);
      (D[8] *> TBYPASS_D_Q[8]) = (tdq, tdq);
      (D[9] *> TBYPASS_D_Q[9]) = (tdq, tdq);
      (D[10] *> TBYPASS_D_Q[10]) = (tdq, tdq);
      (D[11] *> TBYPASS_D_Q[11]) = (tdq, tdq);
      (D[12] *> TBYPASS_D_Q[12]) = (tdq, tdq);
      (D[13] *> TBYPASS_D_Q[13]) = (tdq, tdq);
      (D[14] *> TBYPASS_D_Q[14]) = (tdq, tdq);
      (D[15] *> TBYPASS_D_Q[15]) = (tdq, tdq);
      (D[16] *> TBYPASS_D_Q[16]) = (tdq, tdq);
      (D[17] *> TBYPASS_D_Q[17]) = (tdq, tdq);
      (D[18] *> TBYPASS_D_Q[18]) = (tdq, tdq);
      (D[19] *> TBYPASS_D_Q[19]) = (tdq, tdq);
      (D[20] *> TBYPASS_D_Q[20]) = (tdq, tdq);
      (D[21] *> TBYPASS_D_Q[21]) = (tdq, tdq);
      (D[22] *> TBYPASS_D_Q[22]) = (tdq, tdq);
      (D[23] *> TBYPASS_D_Q[23]) = (tdq, tdq);
      (D[24] *> TBYPASS_D_Q[24]) = (tdq, tdq);
      (D[25] *> TBYPASS_D_Q[25]) = (tdq, tdq);
      (D[26] *> TBYPASS_D_Q[26]) = (tdq, tdq);
      (D[27] *> TBYPASS_D_Q[27]) = (tdq, tdq);
      (D[28] *> TBYPASS_D_Q[28]) = (tdq, tdq);
      (D[29] *> TBYPASS_D_Q[29]) = (tdq, tdq);
      (D[30] *> TBYPASS_D_Q[30]) = (tdq, tdq);
      (D[31] *> TBYPASS_D_Q[31]) = (tdq, tdq);
      (D[32] *> TBYPASS_D_Q[32]) = (tdq, tdq);
      (D[33] *> TBYPASS_D_Q[33]) = (tdq, tdq);
      (D[34] *> TBYPASS_D_Q[34]) = (tdq, tdq);
      (D[35] *> TBYPASS_D_Q[35]) = (tdq, tdq);
      (D[36] *> TBYPASS_D_Q[36]) = (tdq, tdq);
      (D[37] *> TBYPASS_D_Q[37]) = (tdq, tdq);
      (D[38] *> TBYPASS_D_Q[38]) = (tdq, tdq);
      (D[39] *> TBYPASS_D_Q[39]) = (tdq, tdq);
      (D[40] *> TBYPASS_D_Q[40]) = (tdq, tdq);
      (D[41] *> TBYPASS_D_Q[41]) = (tdq, tdq);
      (D[42] *> TBYPASS_D_Q[42]) = (tdq, tdq);
      (D[43] *> TBYPASS_D_Q[43]) = (tdq, tdq);
      (D[44] *> TBYPASS_D_Q[44]) = (tdq, tdq);
      (D[45] *> TBYPASS_D_Q[45]) = (tdq, tdq);
      (D[46] *> TBYPASS_D_Q[46]) = (tdq, tdq);
      (D[47] *> TBYPASS_D_Q[47]) = (tdq, tdq);
      (D[48] *> TBYPASS_D_Q[48]) = (tdq, tdq);
      (D[49] *> TBYPASS_D_Q[49]) = (tdq, tdq);
      (D[50] *> TBYPASS_D_Q[50]) = (tdq, tdq);
      (D[51] *> TBYPASS_D_Q[51]) = (tdq, tdq);
      (D[52] *> TBYPASS_D_Q[52]) = (tdq, tdq);
      (D[53] *> TBYPASS_D_Q[53]) = (tdq, tdq);
      (D[54] *> TBYPASS_D_Q[54]) = (tdq, tdq);
      (D[55] *> TBYPASS_D_Q[55]) = (tdq, tdq);
      (D[56] *> TBYPASS_D_Q[56]) = (tdq, tdq);
      (D[57] *> TBYPASS_D_Q[57]) = (tdq, tdq);
      (D[58] *> TBYPASS_D_Q[58]) = (tdq, tdq);
      (D[59] *> TBYPASS_D_Q[59]) = (tdq, tdq);
      (D[60] *> TBYPASS_D_Q[60]) = (tdq, tdq);
      (D[61] *> TBYPASS_D_Q[61]) = (tdq, tdq);
      (D[62] *> TBYPASS_D_Q[62]) = (tdq, tdq);
      (D[63] *> TBYPASS_D_Q[63]) = (tdq, tdq);


        // RY functionality
	if (!ICRY && InitialRYFlag) (CK *> RY_rfCK) = (th_ry, th_ry);
	if (!ICRY && InitialRYFlag) (CK *> RY_rrCK) = (taa_ry, taa_ry);
	if (!ICRY && InitialRYFlag) (CK *> RY_frCK) = (tck_ry, tck_ry);   

	endspecify


assign #0 Q_data = OutReg_data;
assign Q_glitch = OutReg_glitch; 
assign Q_gCK = Q_gCKreg;

    // BEHAVIOURAL MODULE DESCRIPTION



task task_insert_faults_in_memory;
begin
   if (ConfigFault)
   begin   
     Fault_in_memory = 1;
     for(i = 0;i< fcnt;i = i+ 1) begin
       if (fault_repair_flag[i] !== 1) begin
         Fault_in_memory = 0;
         if (array_stuck_at[i] === "sa0") begin
         `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data & stuck_at_0fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
         `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
         `endif
         end //if(array_stuck_at)
                                        
         if(array_stuck_at[i] === "sa1") begin
         `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data | stuck_at_1fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
         `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
         `endif
         end //if(array_stuck_at)
       end   // if(fault_repair_flag
     end    // end of for
   end  
end
endtask



task chstate;
   input [Bits-1 : 0] clkin;
   output [Bits-1 : 0] clkout;
   integer d;
begin
   if ( $realtime != 0 )
      for (d = 0; d < Bits; d = d + 1)
      begin
         if (clkin[d] === 1'b0)
            clkout[d] = 1'b1;
         else if (clkin[d] === 1'b1)
            clkout[d] = 1'bx;
         else
            clkout[d] = 1'b0;
      end
end
endtask


task WriteMemX;
begin
   for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
   task_insert_faults_in_memory;
end
endtask

task WriteLocMskX_bwise;
   input [Addr-1 : 0] Address;
   input [Bits-1 : 0] Mask;
begin
   if (^Address !== X)
   begin
      tempMem = Mem[Address];
             
      for (j = 0;j< Bits; j=j+1)
         if (Mask[j] === 1'bx)
            tempMem[j] = 1'bx;
                    
      Mem[Address] = tempMem;
      task_insert_faults_in_memory;
   end//if (^Address !== X
   else
      WriteMemX;
end
endtask
    
task WriteOutX;                
begin
   OutReg_data= WordX;
   OutReg_glitch= WordX;
end
endtask

task WriteCycle;                  
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] tempReg1,tempReg2;
   integer po,i;
begin
  
   tempReg1 = WordX;
   if (^Address !== X)
   begin
      if (ValidAddress)
      begin
         
             tempReg1 = Mem[Address];
             for (po=0;po<Bits;po=po+1)
                if (Mreg[po] === 1'b0)
                   tempReg1[po] = Dreg[po];
                else if (Mreg[po] === 1'bX)
                    tempReg1[po] = 1'bx;
                        
                Mem[Address] = tempReg1;
                     
      end //if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Write Port:  Address Out Of Range. ",$realtime);
      task_insert_faults_in_memory;
   end//if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Write Port:  Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
      
   end
   
end
endtask

task ReadCycle;
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] MemData;
   integer a;
begin

   if (ValidAddress)
      MemData = Mem[Address];

   if(ValidAddress === X)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Read Port:  Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
      MemData = WordX;
      WriteMemX;
      
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Read Port:  Address Out Of Range. Output Corrupted ",$realtime);
      MemData = WordX;
   end

   for (a = 0; a < Bits; a = a + 1)
   begin
      if (MemData[a] !== OutReg_data[a])
         OutReg_glitch[a] = WordX[a];
      else
         OutReg_glitch[a] = MemData[a];
   end//for (a = 0; a <

   OutReg_data = MemData;
   last_Qdata = Q_data;

end
endtask




assign RY_rfCKint = RY_rfCKreg;
assign RY_frCKint = RY_frCKreg;
assign RY_rrCKint = RY_rrCKreg;

// Define format for timing value
initial
begin
   $timeformat (-9, 2, " ns", 0);
   ICGFlag = 0;

   //Initialize Memory
   if (MEM_INITIALIZE === 1'b1)
   begin   
      if (BinaryInit)
         $readmemb(InitFileName, Mem, 0, Words-1);
      else
         $readmemh(InitFileName, Mem, 0, Words-1);
   end

   
   ICRYFlag = 1;
   InitialRYFlag = 0;
   ICRYFlag <= 0;
   RY_rfCKreg = 1'b1;
   RY_rrCKreg = 1'b1;
   RY_frCKreg = 1'b1;

   
   

/*  -----------Implementation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
      file_ptr = $fopen(Fault_file_name , "r");
      if(file_ptr == 0)
      begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
      end        
      else                
      begin : read_fault_file
        t = 0;
        for (i = 0; i< max_faults; i= i + 1)
        begin
         
           stuck0 = {Bits{1'b1}};
           stuck1 = {Bits{1'b0}};
           fault_char1 = $fgetc (file_ptr);
           if (fault_char1 == 8'b11111111)
              disable read_fault_file;
           ret_val = $ungetc (fault_char1, file_ptr);
           ret_val = $fgets(tempStr, file_ptr);
           ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
           flag_error = 0; 
           if(ret_val !== 0)
           begin         
              if(ret_val == 2 || ret_val == 3)
              begin
                if(ret_val == 2)
                   stuck_at = "sa0";

                if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                begin
                   if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                   flag_error = 1;
                end    
                      
                if(fault_word > Words-1)
                begin
                   if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                   flag_error = 1;
                end    

                if(fault_bit > Bits-1)
                begin  
                   if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                   flag_error = 1;
                end    

                if(flag_error == 0)
                //Correct Inputs
                begin
                   if(stuck_at === "none")
                   begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                   end
                   else
                   //Adding the faults
                   begin
                      FailureLocn[t] = fault_word;
                      std_fault_word = fault_word;
                      
                      fault_repair_flag[t] = 1'b0;
                      if (stuck_at === "sa0" )
                      begin
                         stuck0[fault_bit] = 1'b0;         
                         stuck_at_0fault[t] = stuck0;
                      end     
                      if (stuck_at === "sa1" )
                      begin
                         stuck1[fault_bit] = 1'b1;
                         stuck_at_1fault[t] = stuck1; 
                      end

                      array_stuck_at[t] = stuck_at;
                      t = t + 1;
                   end //if(stuck_at === "none")  
                end //if(flag_error == 0)
              end //if(ret_val == 2 || ret_val == 3 
              else
              //wrong number of arguments
              begin
                if(debug_level < 2)
                   $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                flag_error = 1;
              end
           end //if(ret_val !== 0)
           else
           begin
              if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
           end    
        end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);

      fcnt = t;
      
      task_insert_faults_in_memory;
   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//

always @(CKint)
begin
   lastCK = CKreg;
   CKreg = CKint;
   
   if (CKint !== 0 && CSNint !== 1)
   begin
     InitialRYFlag = 1;
   end
   
      // Unknown Clock Behaviour
      if (((CKint=== X && CSNint !==1) || (CKint=== X && CSNreg !==1 && lastCK ===1)))
      begin
         
         ICRYFlag = 1;   
         chstate(Q_gCKreg, Q_gCKreg);
	 WriteOutX;
         WriteMemX;
      end//if (((CKint===
                
   
   if (CKint===1 && lastCK ===0 && CSNint === X  )
       ICRYFlag = 1;
   else if (CKint === 1 && lastCK === 0 && CSNint === 0 )
       ICRYFlag = 0;
   

   /*---------------------- Latching signals ----------------------*/
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
      if (CSNint !== 1)
      begin
         ICGFlag = 0;
         Dreg = Dint;
         Mreg = Mint;
         WENreg = WENint;
         Areg = Aint;
         if (^Areg === X)
            ValidAddress = X;
         else if (Areg < Words)
            ValidAddress = 1;
         else
            ValidAddress = 0;

         if (ValidAddress)
            Mem_temp = Mem[Aint];
         else
            Mem_temp = WordX; 

         
      end//if (CSNint !== 1)
         
      CSNreg = CSNint;
      last_Qdata = Q_data;
      
      
   end//if(CKreg === 1'b1 && lastCK =   
     
   /*---------------------- Normal Read and Write -----------------*/

   if ((CSNreg !== 1) && (CKreg === 1 && lastCK === 0))
   begin
      if (WENreg === 1'b1 && CSNreg === 1'b0)
      begin
         ReadCycle(Areg);
         chstate(Q_gCKreg, Q_gCKreg);
      end//if (WENreg === 1 && C
      else if (WENreg === 0 && CSNreg === 0)
      begin
          
           WriteCycle(Areg);
           
      end
      /*---------- Corruption due to faulty values on signals --------*/
      else if (CSNreg === 1'bX)
      begin
         // Uncertain cycle
         if(debug_level < 2) $display("%m - %t (MSG_ID 001) WARNING: Illegal Value on Chip Select. Memory and Output Corrupted ",$realtime);
         WriteMemX;
         WriteOutX;
         chstate(Q_gCKreg, Q_gCKreg);
      end//else if (CSN === 1'bX
      else if (WENreg === X)
      begin
         // Uncertain write cycle
         if(debug_level < 2) $display("%m - %t (MSG_ID 002) WARNING: Illegal Value on Write Enable. Memory and Output Corrupted ",$realtime);
         WriteMemX;
         WriteOutX;
         chstate(Q_gCKreg, Q_gCKreg);
         
         ICRYFlag = 1;
         
      end//else if (WENreg ===
      
      

   end //if ((CSNreg !== 1) && (CKreg    
   
end // always @(CKint)

always @(CSNint)
begin   
     // Unknown Clock & CSN signal
     if (CSNint !== 1 && CKint === X )
     begin
       if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
       chstate(Q_gCKreg, Q_gCKreg);
       WriteMemX;
       WriteOutX;
       
       ICRYFlag = 1;
     end//if (CSNint !== 1
end      


 always @(TBYPASS_main)
 begin
 
      if (TBYPASS_main !== 0)
        
        ICRYFlag = 1;
      OutReg_data = WordX;
      OutReg_glitch = WordX;
    
 end


  

        /*---------------RY Functionality-----------------*/
always @(posedge CKreg)
begin

     
     if ((CSNreg === 0) && (CKreg === 1 && lastCK === 0) && TBYPASS_main === 1'b0)
     begin
       if (WENreg !== 1'bX && ValidAddress !== 1'bX)
       begin
         RY_rfCKreg = ~RY_rfCKreg;
         RY_rrCKreg = ~RY_rrCKreg;
       end
       else
         ICRYFlag = 1'b1; 
     end
     
     
end

 always @(negedge CKreg)
 begin
 
      
      if (TBYPASS_main === 1'b1)
      begin
        RY_frCKreg = ~RY_frCKreg;
        ICRYFlag = 1'b0;
      end  
      else if (TBYPASS_main === 1'b0 && (CSNreg === 0) && (CKreg === 0 && lastCK === 1))
      begin
        if (WENreg !== 1'bX && ValidAddress !== 1'bX)
           RY_frCKreg = ~RY_frCKreg;
      end
      
     
     
   
 end

always @ (TimingViol_tckl or TimingViol_tcycle or TimingViol_csn or TimingViol_tckh or TimingViol_tbypass or TimingViol_wen or TimingViol_addr  )
ICRYFlag = 1;
        /*---------------------------------*/





/*---------------TBYPASS  Functionality in functional model -----------------*/

always @(TimingViol_data)
// tds or tdh violation
begin
#0
   for (l = 0; l < Bits; l = l + 1)
   begin   
      if((TimingViol_data[l] !== TimingViol_data_last[l]))
         Mreg[l] = 1'bx;
   end   
   WriteLocMskX_bwise(Areg,Mreg);
   TimingViol_data_last = TimingViol_data;
end


        
/*---------- Corruption due to Timing Violations ---------------*/

always @(TimingViol_tckl or TimingViol_tcycle)
// tckl -  tcycle
begin
#0
   WriteOutX;
   #0.00 WriteMemX;
end

always @(TimingViol_csn)
// tps or tph
begin
#0
   CSNreg = 1'bX;
   WriteOutX;
   WriteMemX;  
   if (CSNreg === 1)
   begin
      chstate(Q_gCKreg, Q_gCKreg);
   end
end

always @(TimingViol_tckh)
// tckh
begin
#0
   ICGFlag = 1;
   chstate(Q_gCKreg, Q_gCKreg);
   WriteOutX;
   WriteMemX;
end

always @(TimingViol_addr)
// tas or tah
begin
#0
   if (WENreg !== 0)
      WriteOutX;
   WriteMemX;
   
end


always @(TimingViol_wen)
//tws or twh
begin
#0
   WriteMemX; 
   WriteOutX;
end


always @(TimingViol_tbypass)
//ttmck
begin
#0
   WriteOutX;
   WriteMemX;  
end







endmodule

module ST_SPHS_48x64m4_L_OPschlr (QINT,  RYINT, Q_gCK, Q_glitch,  Q_data, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main);

    parameter
        Words = 48,
        Bits = 64,
        Addr = 6;
        

    parameter
        WordX = 64'bx,
        AddrX = 6'bx,
        X = 1'bx;

	output [Bits-1 : 0] QINT;
	input [Bits-1 : 0] Q_glitch;
	input [Bits-1 : 0] Q_data;
	input [Bits-1 : 0] Q_gCK;
        input [Bits-1 : 0] TBYPASS_D_Q;
        input [Bits-1 : 0] delTBYPASS;
        input TBYPASS_main;
	
	integer m,a, d, n, o, p;
	wire [Bits-1 : 0] QINTint;
	wire [Bits-1 : 0] QINTERNAL;

        reg [Bits-1 : 0] OutReg;
	reg [Bits-1 : 0] lastQ_gCK, Q_gCKreg;
	reg [Bits-1 : 0] lastQ_data, Q_datareg;
	reg [Bits-1 : 0] QINTERNALreg;
	reg [Bits-1 : 0] lastQINTERNAL;

buf bufqint [Bits-1:0] (QINT, QINTint);

	assign QINTint[0] = (TBYPASS_main===0 && delTBYPASS[0]===0)?OutReg[0] : (TBYPASS_main===1 && delTBYPASS[0]===1)?TBYPASS_D_Q[0] : WordX;
	assign QINTint[1] = (TBYPASS_main===0 && delTBYPASS[1]===0)?OutReg[1] : (TBYPASS_main===1 && delTBYPASS[1]===1)?TBYPASS_D_Q[1] : WordX;
	assign QINTint[2] = (TBYPASS_main===0 && delTBYPASS[2]===0)?OutReg[2] : (TBYPASS_main===1 && delTBYPASS[2]===1)?TBYPASS_D_Q[2] : WordX;
	assign QINTint[3] = (TBYPASS_main===0 && delTBYPASS[3]===0)?OutReg[3] : (TBYPASS_main===1 && delTBYPASS[3]===1)?TBYPASS_D_Q[3] : WordX;
	assign QINTint[4] = (TBYPASS_main===0 && delTBYPASS[4]===0)?OutReg[4] : (TBYPASS_main===1 && delTBYPASS[4]===1)?TBYPASS_D_Q[4] : WordX;
	assign QINTint[5] = (TBYPASS_main===0 && delTBYPASS[5]===0)?OutReg[5] : (TBYPASS_main===1 && delTBYPASS[5]===1)?TBYPASS_D_Q[5] : WordX;
	assign QINTint[6] = (TBYPASS_main===0 && delTBYPASS[6]===0)?OutReg[6] : (TBYPASS_main===1 && delTBYPASS[6]===1)?TBYPASS_D_Q[6] : WordX;
	assign QINTint[7] = (TBYPASS_main===0 && delTBYPASS[7]===0)?OutReg[7] : (TBYPASS_main===1 && delTBYPASS[7]===1)?TBYPASS_D_Q[7] : WordX;
	assign QINTint[8] = (TBYPASS_main===0 && delTBYPASS[8]===0)?OutReg[8] : (TBYPASS_main===1 && delTBYPASS[8]===1)?TBYPASS_D_Q[8] : WordX;
	assign QINTint[9] = (TBYPASS_main===0 && delTBYPASS[9]===0)?OutReg[9] : (TBYPASS_main===1 && delTBYPASS[9]===1)?TBYPASS_D_Q[9] : WordX;
	assign QINTint[10] = (TBYPASS_main===0 && delTBYPASS[10]===0)?OutReg[10] : (TBYPASS_main===1 && delTBYPASS[10]===1)?TBYPASS_D_Q[10] : WordX;
	assign QINTint[11] = (TBYPASS_main===0 && delTBYPASS[11]===0)?OutReg[11] : (TBYPASS_main===1 && delTBYPASS[11]===1)?TBYPASS_D_Q[11] : WordX;
	assign QINTint[12] = (TBYPASS_main===0 && delTBYPASS[12]===0)?OutReg[12] : (TBYPASS_main===1 && delTBYPASS[12]===1)?TBYPASS_D_Q[12] : WordX;
	assign QINTint[13] = (TBYPASS_main===0 && delTBYPASS[13]===0)?OutReg[13] : (TBYPASS_main===1 && delTBYPASS[13]===1)?TBYPASS_D_Q[13] : WordX;
	assign QINTint[14] = (TBYPASS_main===0 && delTBYPASS[14]===0)?OutReg[14] : (TBYPASS_main===1 && delTBYPASS[14]===1)?TBYPASS_D_Q[14] : WordX;
	assign QINTint[15] = (TBYPASS_main===0 && delTBYPASS[15]===0)?OutReg[15] : (TBYPASS_main===1 && delTBYPASS[15]===1)?TBYPASS_D_Q[15] : WordX;
	assign QINTint[16] = (TBYPASS_main===0 && delTBYPASS[16]===0)?OutReg[16] : (TBYPASS_main===1 && delTBYPASS[16]===1)?TBYPASS_D_Q[16] : WordX;
	assign QINTint[17] = (TBYPASS_main===0 && delTBYPASS[17]===0)?OutReg[17] : (TBYPASS_main===1 && delTBYPASS[17]===1)?TBYPASS_D_Q[17] : WordX;
	assign QINTint[18] = (TBYPASS_main===0 && delTBYPASS[18]===0)?OutReg[18] : (TBYPASS_main===1 && delTBYPASS[18]===1)?TBYPASS_D_Q[18] : WordX;
	assign QINTint[19] = (TBYPASS_main===0 && delTBYPASS[19]===0)?OutReg[19] : (TBYPASS_main===1 && delTBYPASS[19]===1)?TBYPASS_D_Q[19] : WordX;
	assign QINTint[20] = (TBYPASS_main===0 && delTBYPASS[20]===0)?OutReg[20] : (TBYPASS_main===1 && delTBYPASS[20]===1)?TBYPASS_D_Q[20] : WordX;
	assign QINTint[21] = (TBYPASS_main===0 && delTBYPASS[21]===0)?OutReg[21] : (TBYPASS_main===1 && delTBYPASS[21]===1)?TBYPASS_D_Q[21] : WordX;
	assign QINTint[22] = (TBYPASS_main===0 && delTBYPASS[22]===0)?OutReg[22] : (TBYPASS_main===1 && delTBYPASS[22]===1)?TBYPASS_D_Q[22] : WordX;
	assign QINTint[23] = (TBYPASS_main===0 && delTBYPASS[23]===0)?OutReg[23] : (TBYPASS_main===1 && delTBYPASS[23]===1)?TBYPASS_D_Q[23] : WordX;
	assign QINTint[24] = (TBYPASS_main===0 && delTBYPASS[24]===0)?OutReg[24] : (TBYPASS_main===1 && delTBYPASS[24]===1)?TBYPASS_D_Q[24] : WordX;
	assign QINTint[25] = (TBYPASS_main===0 && delTBYPASS[25]===0)?OutReg[25] : (TBYPASS_main===1 && delTBYPASS[25]===1)?TBYPASS_D_Q[25] : WordX;
	assign QINTint[26] = (TBYPASS_main===0 && delTBYPASS[26]===0)?OutReg[26] : (TBYPASS_main===1 && delTBYPASS[26]===1)?TBYPASS_D_Q[26] : WordX;
	assign QINTint[27] = (TBYPASS_main===0 && delTBYPASS[27]===0)?OutReg[27] : (TBYPASS_main===1 && delTBYPASS[27]===1)?TBYPASS_D_Q[27] : WordX;
	assign QINTint[28] = (TBYPASS_main===0 && delTBYPASS[28]===0)?OutReg[28] : (TBYPASS_main===1 && delTBYPASS[28]===1)?TBYPASS_D_Q[28] : WordX;
	assign QINTint[29] = (TBYPASS_main===0 && delTBYPASS[29]===0)?OutReg[29] : (TBYPASS_main===1 && delTBYPASS[29]===1)?TBYPASS_D_Q[29] : WordX;
	assign QINTint[30] = (TBYPASS_main===0 && delTBYPASS[30]===0)?OutReg[30] : (TBYPASS_main===1 && delTBYPASS[30]===1)?TBYPASS_D_Q[30] : WordX;
	assign QINTint[31] = (TBYPASS_main===0 && delTBYPASS[31]===0)?OutReg[31] : (TBYPASS_main===1 && delTBYPASS[31]===1)?TBYPASS_D_Q[31] : WordX;
	assign QINTint[32] = (TBYPASS_main===0 && delTBYPASS[32]===0)?OutReg[32] : (TBYPASS_main===1 && delTBYPASS[32]===1)?TBYPASS_D_Q[32] : WordX;
	assign QINTint[33] = (TBYPASS_main===0 && delTBYPASS[33]===0)?OutReg[33] : (TBYPASS_main===1 && delTBYPASS[33]===1)?TBYPASS_D_Q[33] : WordX;
	assign QINTint[34] = (TBYPASS_main===0 && delTBYPASS[34]===0)?OutReg[34] : (TBYPASS_main===1 && delTBYPASS[34]===1)?TBYPASS_D_Q[34] : WordX;
	assign QINTint[35] = (TBYPASS_main===0 && delTBYPASS[35]===0)?OutReg[35] : (TBYPASS_main===1 && delTBYPASS[35]===1)?TBYPASS_D_Q[35] : WordX;
	assign QINTint[36] = (TBYPASS_main===0 && delTBYPASS[36]===0)?OutReg[36] : (TBYPASS_main===1 && delTBYPASS[36]===1)?TBYPASS_D_Q[36] : WordX;
	assign QINTint[37] = (TBYPASS_main===0 && delTBYPASS[37]===0)?OutReg[37] : (TBYPASS_main===1 && delTBYPASS[37]===1)?TBYPASS_D_Q[37] : WordX;
	assign QINTint[38] = (TBYPASS_main===0 && delTBYPASS[38]===0)?OutReg[38] : (TBYPASS_main===1 && delTBYPASS[38]===1)?TBYPASS_D_Q[38] : WordX;
	assign QINTint[39] = (TBYPASS_main===0 && delTBYPASS[39]===0)?OutReg[39] : (TBYPASS_main===1 && delTBYPASS[39]===1)?TBYPASS_D_Q[39] : WordX;
	assign QINTint[40] = (TBYPASS_main===0 && delTBYPASS[40]===0)?OutReg[40] : (TBYPASS_main===1 && delTBYPASS[40]===1)?TBYPASS_D_Q[40] : WordX;
	assign QINTint[41] = (TBYPASS_main===0 && delTBYPASS[41]===0)?OutReg[41] : (TBYPASS_main===1 && delTBYPASS[41]===1)?TBYPASS_D_Q[41] : WordX;
	assign QINTint[42] = (TBYPASS_main===0 && delTBYPASS[42]===0)?OutReg[42] : (TBYPASS_main===1 && delTBYPASS[42]===1)?TBYPASS_D_Q[42] : WordX;
	assign QINTint[43] = (TBYPASS_main===0 && delTBYPASS[43]===0)?OutReg[43] : (TBYPASS_main===1 && delTBYPASS[43]===1)?TBYPASS_D_Q[43] : WordX;
	assign QINTint[44] = (TBYPASS_main===0 && delTBYPASS[44]===0)?OutReg[44] : (TBYPASS_main===1 && delTBYPASS[44]===1)?TBYPASS_D_Q[44] : WordX;
	assign QINTint[45] = (TBYPASS_main===0 && delTBYPASS[45]===0)?OutReg[45] : (TBYPASS_main===1 && delTBYPASS[45]===1)?TBYPASS_D_Q[45] : WordX;
	assign QINTint[46] = (TBYPASS_main===0 && delTBYPASS[46]===0)?OutReg[46] : (TBYPASS_main===1 && delTBYPASS[46]===1)?TBYPASS_D_Q[46] : WordX;
	assign QINTint[47] = (TBYPASS_main===0 && delTBYPASS[47]===0)?OutReg[47] : (TBYPASS_main===1 && delTBYPASS[47]===1)?TBYPASS_D_Q[47] : WordX;
	assign QINTint[48] = (TBYPASS_main===0 && delTBYPASS[48]===0)?OutReg[48] : (TBYPASS_main===1 && delTBYPASS[48]===1)?TBYPASS_D_Q[48] : WordX;
	assign QINTint[49] = (TBYPASS_main===0 && delTBYPASS[49]===0)?OutReg[49] : (TBYPASS_main===1 && delTBYPASS[49]===1)?TBYPASS_D_Q[49] : WordX;
	assign QINTint[50] = (TBYPASS_main===0 && delTBYPASS[50]===0)?OutReg[50] : (TBYPASS_main===1 && delTBYPASS[50]===1)?TBYPASS_D_Q[50] : WordX;
	assign QINTint[51] = (TBYPASS_main===0 && delTBYPASS[51]===0)?OutReg[51] : (TBYPASS_main===1 && delTBYPASS[51]===1)?TBYPASS_D_Q[51] : WordX;
	assign QINTint[52] = (TBYPASS_main===0 && delTBYPASS[52]===0)?OutReg[52] : (TBYPASS_main===1 && delTBYPASS[52]===1)?TBYPASS_D_Q[52] : WordX;
	assign QINTint[53] = (TBYPASS_main===0 && delTBYPASS[53]===0)?OutReg[53] : (TBYPASS_main===1 && delTBYPASS[53]===1)?TBYPASS_D_Q[53] : WordX;
	assign QINTint[54] = (TBYPASS_main===0 && delTBYPASS[54]===0)?OutReg[54] : (TBYPASS_main===1 && delTBYPASS[54]===1)?TBYPASS_D_Q[54] : WordX;
	assign QINTint[55] = (TBYPASS_main===0 && delTBYPASS[55]===0)?OutReg[55] : (TBYPASS_main===1 && delTBYPASS[55]===1)?TBYPASS_D_Q[55] : WordX;
	assign QINTint[56] = (TBYPASS_main===0 && delTBYPASS[56]===0)?OutReg[56] : (TBYPASS_main===1 && delTBYPASS[56]===1)?TBYPASS_D_Q[56] : WordX;
	assign QINTint[57] = (TBYPASS_main===0 && delTBYPASS[57]===0)?OutReg[57] : (TBYPASS_main===1 && delTBYPASS[57]===1)?TBYPASS_D_Q[57] : WordX;
	assign QINTint[58] = (TBYPASS_main===0 && delTBYPASS[58]===0)?OutReg[58] : (TBYPASS_main===1 && delTBYPASS[58]===1)?TBYPASS_D_Q[58] : WordX;
	assign QINTint[59] = (TBYPASS_main===0 && delTBYPASS[59]===0)?OutReg[59] : (TBYPASS_main===1 && delTBYPASS[59]===1)?TBYPASS_D_Q[59] : WordX;
	assign QINTint[60] = (TBYPASS_main===0 && delTBYPASS[60]===0)?OutReg[60] : (TBYPASS_main===1 && delTBYPASS[60]===1)?TBYPASS_D_Q[60] : WordX;
	assign QINTint[61] = (TBYPASS_main===0 && delTBYPASS[61]===0)?OutReg[61] : (TBYPASS_main===1 && delTBYPASS[61]===1)?TBYPASS_D_Q[61] : WordX;
	assign QINTint[62] = (TBYPASS_main===0 && delTBYPASS[62]===0)?OutReg[62] : (TBYPASS_main===1 && delTBYPASS[62]===1)?TBYPASS_D_Q[62] : WordX;
	assign QINTint[63] = (TBYPASS_main===0 && delTBYPASS[63]===0)?OutReg[63] : (TBYPASS_main===1 && delTBYPASS[63]===1)?TBYPASS_D_Q[63] : WordX;
assign QINTERNAL = QINTERNALreg;

always @ (TBYPASS_main)
begin
if (TBYPASS_main === 0 || TBYPASS_main === X) 
     QINTERNALreg = WordX;
end


        
/*------------------ RY functionality -----------------*/
       output RYINT;
        input RY_rfCK, RY_rrCK, RY_frCK, ICRY;
        wire RYINTint;
        reg RYINTreg, RYRiseFlag;

        buf (RYINT, RYINTint);

assign RYINTint = RYINTreg;
        
initial
begin
   RYRiseFlag = 1'b0;
   RYINTreg = 1'b1;
end

always @(ICRY)
begin
   if($realtime == 0)
      RYINTreg = 1'b1;
   else
      RYINTreg = 1'bx;
end

always @(RY_rfCK)
   if (ICRY !== 1)
   begin
      if ($realtime != 0)
      begin   
         RYINTreg = 0;
         RYRiseFlag=0;
      end   
   end


always @(RY_rrCK) 
#0 
   if (ICRY !== 1 && $realtime != 0)
   begin
      if (RYRiseFlag === 0)
      begin
         RYRiseFlag=1;
      end
      else
      begin
         RYINTreg = 1'b1;
         RYRiseFlag=0;
      end
   end


always @(RY_frCK)         
   if (ICRY !== 1 && $realtime != 0)
   begin
      if (RYRiseFlag === 0)
      begin
         RYRiseFlag=1;
      end
      else
      begin
         RYINTreg = 1'b1;
         RYRiseFlag=0;
      end
   end   

/*------------------------------------------------ */

always @(Q_gCK)
begin
#0  //This has been used for removing races during hold time vilations in MODELSIM simulator.
   lastQ_gCK = Q_gCKreg;
   Q_gCKreg <= Q_gCK;
   for (m = 0; m < Bits; m = m + 1)
   begin
      if (lastQ_gCK[m] !== Q_gCK[m])
      begin
        lastQINTERNAL[m] = QINTERNALreg[m];
        QINTERNALreg[m] = Q_glitch[m];
      end
   end
end

always @(Q_data)
begin
#0  //This has been used for removing races during hold time vilations in MODELSIM simulator.
    lastQ_data = Q_datareg;
    Q_datareg <= Q_data;
    for (n = 0; n < Bits; n = n + 1)
    begin
      if (lastQ_data[n] !== Q_data[n])
      begin
       	lastQINTERNAL[n] = QINTERNALreg[n];
        QINTERNALreg[n] = Q_data[n];
      end
    end
end

always @(QINTERNAL)
begin
   for (d = 0; d < Bits; d = d + 1)
   begin
      if (OutReg[d] !== QINTERNAL[d])
         OutReg[d] = QINTERNAL[d];
   end
end



endmodule



module ST_SPHS_48x64m4_L (Q, RY, CK, CSN, TBYPASS, WEN,  A,  D   );


    parameter 
        Corruption_Read_Violation = 1,
        Fault_file_name = "ST_SPHS_48x64m4_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20;
   
    // Parameters for Memory Initialization at 0 ns
    parameter 
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHS_48x64m4_L.cde",
        InstancePath = "ST_SPHS_48x64m4_L",
        Debug_mode = "all_warning_mode";
    
    parameter
        Words = 48,
        Bits = 64,
        Addr = 6,
        mux = 4;




   
    parameter
        Rows = Words/mux,
        WordX = 64'bx,
        AddrX = 6'bx,
        Word0 = 64'b0,
        X = 1'bx;

        
         
    // INPUT OUTPUT PORTS
    //  ======================

    output [Bits-1 : 0] Q;
    
    output RY;   
    input CK;
    input CSN;
    input WEN;
    input TBYPASS;
    input [Addr-1 : 0] A;
    input [Bits-1 : 0] D;
    
    


   

     

   // WIRE DECLARATIONS
   //======================
   
   wire [Bits-1 : 0] Q_glitchint;
   wire [Bits-1 : 0] Q_dataint;
   wire [Bits-1 : 0] Dint,Mint;
   wire [Addr-1 : 0] Aint;
   wire [Bits-1 : 0] Q_gCKint;
   wire CKint;
   wire CSNint;
   wire WENint;
   wire TBYPASSint;
   wire TBYPASS_mainint;
   wire [Bits-1 : 0]  TBYPASS_D_Qint;
   wire [Bits-1 : 0]  delTBYPASSint;




   wire [Bits-1 : 0] Qint, Q_out;
   
   
   

   //REG DECLARATIONS
   //======================

   reg [Bits-1 : 0] Dreg,Mreg;
   reg [Addr-1 : 0] Areg;
   reg CKreg;
   reg CSNreg;
   reg WENreg;
	
   reg [Bits-1 : 0] TimingViol_data, TimingViol_mask;
   reg [Bits-1 : 0] TimingViol_data_last, TimingViol_mask_last;
	reg TimingViol_data_0, TimingViol_mask_0;
	reg TimingViol_data_1, TimingViol_mask_1;
	reg TimingViol_data_2, TimingViol_mask_2;
	reg TimingViol_data_3, TimingViol_mask_3;
	reg TimingViol_data_4, TimingViol_mask_4;
	reg TimingViol_data_5, TimingViol_mask_5;
	reg TimingViol_data_6, TimingViol_mask_6;
	reg TimingViol_data_7, TimingViol_mask_7;
	reg TimingViol_data_8, TimingViol_mask_8;
	reg TimingViol_data_9, TimingViol_mask_9;
	reg TimingViol_data_10, TimingViol_mask_10;
	reg TimingViol_data_11, TimingViol_mask_11;
	reg TimingViol_data_12, TimingViol_mask_12;
	reg TimingViol_data_13, TimingViol_mask_13;
	reg TimingViol_data_14, TimingViol_mask_14;
	reg TimingViol_data_15, TimingViol_mask_15;
	reg TimingViol_data_16, TimingViol_mask_16;
	reg TimingViol_data_17, TimingViol_mask_17;
	reg TimingViol_data_18, TimingViol_mask_18;
	reg TimingViol_data_19, TimingViol_mask_19;
	reg TimingViol_data_20, TimingViol_mask_20;
	reg TimingViol_data_21, TimingViol_mask_21;
	reg TimingViol_data_22, TimingViol_mask_22;
	reg TimingViol_data_23, TimingViol_mask_23;
	reg TimingViol_data_24, TimingViol_mask_24;
	reg TimingViol_data_25, TimingViol_mask_25;
	reg TimingViol_data_26, TimingViol_mask_26;
	reg TimingViol_data_27, TimingViol_mask_27;
	reg TimingViol_data_28, TimingViol_mask_28;
	reg TimingViol_data_29, TimingViol_mask_29;
	reg TimingViol_data_30, TimingViol_mask_30;
	reg TimingViol_data_31, TimingViol_mask_31;
	reg TimingViol_data_32, TimingViol_mask_32;
	reg TimingViol_data_33, TimingViol_mask_33;
	reg TimingViol_data_34, TimingViol_mask_34;
	reg TimingViol_data_35, TimingViol_mask_35;
	reg TimingViol_data_36, TimingViol_mask_36;
	reg TimingViol_data_37, TimingViol_mask_37;
	reg TimingViol_data_38, TimingViol_mask_38;
	reg TimingViol_data_39, TimingViol_mask_39;
	reg TimingViol_data_40, TimingViol_mask_40;
	reg TimingViol_data_41, TimingViol_mask_41;
	reg TimingViol_data_42, TimingViol_mask_42;
	reg TimingViol_data_43, TimingViol_mask_43;
	reg TimingViol_data_44, TimingViol_mask_44;
	reg TimingViol_data_45, TimingViol_mask_45;
	reg TimingViol_data_46, TimingViol_mask_46;
	reg TimingViol_data_47, TimingViol_mask_47;
	reg TimingViol_data_48, TimingViol_mask_48;
	reg TimingViol_data_49, TimingViol_mask_49;
	reg TimingViol_data_50, TimingViol_mask_50;
	reg TimingViol_data_51, TimingViol_mask_51;
	reg TimingViol_data_52, TimingViol_mask_52;
	reg TimingViol_data_53, TimingViol_mask_53;
	reg TimingViol_data_54, TimingViol_mask_54;
	reg TimingViol_data_55, TimingViol_mask_55;
	reg TimingViol_data_56, TimingViol_mask_56;
	reg TimingViol_data_57, TimingViol_mask_57;
	reg TimingViol_data_58, TimingViol_mask_58;
	reg TimingViol_data_59, TimingViol_mask_59;
	reg TimingViol_data_60, TimingViol_mask_60;
	reg TimingViol_data_61, TimingViol_mask_61;
	reg TimingViol_data_62, TimingViol_mask_62;
	reg TimingViol_data_63, TimingViol_mask_63;
   reg TimingViol_addr;
   reg TimingViol_csn, TimingViol_wen, TimingViol_tbypass;
   reg TimingViol_tckh, TimingViol_tckl, TimingViol_tcycle;
   




   wire [Bits-1 : 0] MEN,CSWEMTBYPASS;
   wire CSTBYPASSN, CSWETBYPASSN,CS;

   /* This register is used to force all warning messages 
   ** OFF during run time.
   ** 
   */ 
   reg [1:0] debug_level;
   reg [8*10: 0] operating_mode;
   reg [8*44: 0] message_status;


initial
begin
  debug_level = 2'b0;
  message_status = "All Messages are Switched ON";
    
  
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
     message_status = "All Messages are Switched OFF"; 
  `endif 
if(debug_level !== 2'b10) begin
   $display ("%m  INFORMATION");
   $display ("***************************************");
   $display ("The Model is Operating in TIMING MODE");
   $display ("Please make sure that SDF is properly annotated otherwise dummy values will be used");
   $display ("%s", message_status);
   if(ConfigFault)
   $display ("Configurable Fault Functionality is ON");   
   else
   $display ("Configurable Fault Functionality is OFF");
   
   $display ("***************************************");
end     
end     

   
   // BUF DECLARATIONS
   //=====================
   
   buf (CKint, CK);
   or (CSNint, CSN, TBYPASSint);
   buf (TBYPASSint, TBYPASS);
   buf (WENint, WEN);
   buf bufDint [Bits-1:0] (Dint, D);
   
   assign Mint = 64'b0;
   
   buf bufAint [Addr-1:0] (Aint, A);


   assign Q =  Qint;




   


    wire  RYint, RY_rfCKint, RY_rrCKint, RY_frCKint, RY_out;
    reg RY_outreg; 
    assign RY_out = RY_outreg;
    assign RY =   RY_out;
    always @ (RYint)
    begin
       RY_outreg = RYint;
    end

        
    // Only include timing checks during behavioural modelling


    
    assign CS =  CSN;
    or (CSWETBYPASSN, WENint, CSNint);
    or (CSNTBY, CSN, TBYPASSint);  


        
 or (CSWEMTBYPASS[0], Mint[0], CSWETBYPASSN);
 or (CSWEMTBYPASS[1], Mint[1], CSWETBYPASSN);
 or (CSWEMTBYPASS[2], Mint[2], CSWETBYPASSN);
 or (CSWEMTBYPASS[3], Mint[3], CSWETBYPASSN);
 or (CSWEMTBYPASS[4], Mint[4], CSWETBYPASSN);
 or (CSWEMTBYPASS[5], Mint[5], CSWETBYPASSN);
 or (CSWEMTBYPASS[6], Mint[6], CSWETBYPASSN);
 or (CSWEMTBYPASS[7], Mint[7], CSWETBYPASSN);
 or (CSWEMTBYPASS[8], Mint[8], CSWETBYPASSN);
 or (CSWEMTBYPASS[9], Mint[9], CSWETBYPASSN);
 or (CSWEMTBYPASS[10], Mint[10], CSWETBYPASSN);
 or (CSWEMTBYPASS[11], Mint[11], CSWETBYPASSN);
 or (CSWEMTBYPASS[12], Mint[12], CSWETBYPASSN);
 or (CSWEMTBYPASS[13], Mint[13], CSWETBYPASSN);
 or (CSWEMTBYPASS[14], Mint[14], CSWETBYPASSN);
 or (CSWEMTBYPASS[15], Mint[15], CSWETBYPASSN);
 or (CSWEMTBYPASS[16], Mint[16], CSWETBYPASSN);
 or (CSWEMTBYPASS[17], Mint[17], CSWETBYPASSN);
 or (CSWEMTBYPASS[18], Mint[18], CSWETBYPASSN);
 or (CSWEMTBYPASS[19], Mint[19], CSWETBYPASSN);
 or (CSWEMTBYPASS[20], Mint[20], CSWETBYPASSN);
 or (CSWEMTBYPASS[21], Mint[21], CSWETBYPASSN);
 or (CSWEMTBYPASS[22], Mint[22], CSWETBYPASSN);
 or (CSWEMTBYPASS[23], Mint[23], CSWETBYPASSN);
 or (CSWEMTBYPASS[24], Mint[24], CSWETBYPASSN);
 or (CSWEMTBYPASS[25], Mint[25], CSWETBYPASSN);
 or (CSWEMTBYPASS[26], Mint[26], CSWETBYPASSN);
 or (CSWEMTBYPASS[27], Mint[27], CSWETBYPASSN);
 or (CSWEMTBYPASS[28], Mint[28], CSWETBYPASSN);
 or (CSWEMTBYPASS[29], Mint[29], CSWETBYPASSN);
 or (CSWEMTBYPASS[30], Mint[30], CSWETBYPASSN);
 or (CSWEMTBYPASS[31], Mint[31], CSWETBYPASSN);
 or (CSWEMTBYPASS[32], Mint[32], CSWETBYPASSN);
 or (CSWEMTBYPASS[33], Mint[33], CSWETBYPASSN);
 or (CSWEMTBYPASS[34], Mint[34], CSWETBYPASSN);
 or (CSWEMTBYPASS[35], Mint[35], CSWETBYPASSN);
 or (CSWEMTBYPASS[36], Mint[36], CSWETBYPASSN);
 or (CSWEMTBYPASS[37], Mint[37], CSWETBYPASSN);
 or (CSWEMTBYPASS[38], Mint[38], CSWETBYPASSN);
 or (CSWEMTBYPASS[39], Mint[39], CSWETBYPASSN);
 or (CSWEMTBYPASS[40], Mint[40], CSWETBYPASSN);
 or (CSWEMTBYPASS[41], Mint[41], CSWETBYPASSN);
 or (CSWEMTBYPASS[42], Mint[42], CSWETBYPASSN);
 or (CSWEMTBYPASS[43], Mint[43], CSWETBYPASSN);
 or (CSWEMTBYPASS[44], Mint[44], CSWETBYPASSN);
 or (CSWEMTBYPASS[45], Mint[45], CSWETBYPASSN);
 or (CSWEMTBYPASS[46], Mint[46], CSWETBYPASSN);
 or (CSWEMTBYPASS[47], Mint[47], CSWETBYPASSN);
 or (CSWEMTBYPASS[48], Mint[48], CSWETBYPASSN);
 or (CSWEMTBYPASS[49], Mint[49], CSWETBYPASSN);
 or (CSWEMTBYPASS[50], Mint[50], CSWETBYPASSN);
 or (CSWEMTBYPASS[51], Mint[51], CSWETBYPASSN);
 or (CSWEMTBYPASS[52], Mint[52], CSWETBYPASSN);
 or (CSWEMTBYPASS[53], Mint[53], CSWETBYPASSN);
 or (CSWEMTBYPASS[54], Mint[54], CSWETBYPASSN);
 or (CSWEMTBYPASS[55], Mint[55], CSWETBYPASSN);
 or (CSWEMTBYPASS[56], Mint[56], CSWETBYPASSN);
 or (CSWEMTBYPASS[57], Mint[57], CSWETBYPASSN);
 or (CSWEMTBYPASS[58], Mint[58], CSWETBYPASSN);
 or (CSWEMTBYPASS[59], Mint[59], CSWETBYPASSN);
 or (CSWEMTBYPASS[60], Mint[60], CSWETBYPASSN);
 or (CSWEMTBYPASS[61], Mint[61], CSWETBYPASSN);
 or (CSWEMTBYPASS[62], Mint[62], CSWETBYPASSN);
 or (CSWEMTBYPASS[63], Mint[63], CSWETBYPASSN);

    specify
    specparam


         tckl_tck_ry = 0.00,
         tcycle_taa_ry = 0.00,

         
         
	 tms = 0.0,
         tmh = 0.0,
         tcycle = 0.0,
         tckh = 0.0,
         tckl = 0.0,
         ttms = 0.0,
         ttmh = 0.0,
         tps = 0.0,
         tph = 0.0,
         tws = 0.0,
         twh = 0.0,
         tas = 0.0,
         tah = 0.0,
         tds = 0.0,
         tdh = 0.0;
        /*---------------------- Timing Checks ---------------------*/

	$setup(posedge A[0], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[1], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[2], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[3], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[4], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[5], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[0], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[1], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[2], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[3], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[4], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[5], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[0], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[1], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[2], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[3], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[4], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[5], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[0], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[1], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[2], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[3], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[4], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[5], tah, TimingViol_addr);
	$setup(posedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 1), tds, TimingViol_data_0);
	$setup(posedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 1), tds, TimingViol_data_1);
	$setup(posedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 1), tds, TimingViol_data_2);
	$setup(posedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 1), tds, TimingViol_data_3);
	$setup(posedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 1), tds, TimingViol_data_4);
	$setup(posedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 1), tds, TimingViol_data_5);
	$setup(posedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 1), tds, TimingViol_data_6);
	$setup(posedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 1), tds, TimingViol_data_7);
	$setup(posedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 1), tds, TimingViol_data_8);
	$setup(posedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 1), tds, TimingViol_data_9);
	$setup(posedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 1), tds, TimingViol_data_10);
	$setup(posedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 1), tds, TimingViol_data_11);
	$setup(posedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 1), tds, TimingViol_data_12);
	$setup(posedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 1), tds, TimingViol_data_13);
	$setup(posedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 1), tds, TimingViol_data_14);
	$setup(posedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 1), tds, TimingViol_data_15);
	$setup(posedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 1), tds, TimingViol_data_16);
	$setup(posedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 1), tds, TimingViol_data_17);
	$setup(posedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 1), tds, TimingViol_data_18);
	$setup(posedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 1), tds, TimingViol_data_19);
	$setup(posedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 1), tds, TimingViol_data_20);
	$setup(posedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 1), tds, TimingViol_data_21);
	$setup(posedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 1), tds, TimingViol_data_22);
	$setup(posedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 1), tds, TimingViol_data_23);
	$setup(posedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 1), tds, TimingViol_data_24);
	$setup(posedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 1), tds, TimingViol_data_25);
	$setup(posedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 1), tds, TimingViol_data_26);
	$setup(posedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 1), tds, TimingViol_data_27);
	$setup(posedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 1), tds, TimingViol_data_28);
	$setup(posedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 1), tds, TimingViol_data_29);
	$setup(posedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 1), tds, TimingViol_data_30);
	$setup(posedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 1), tds, TimingViol_data_31);
	$setup(posedge D[32], posedge CK &&& (CSWEMTBYPASS[32] != 1), tds, TimingViol_data_32);
	$setup(posedge D[33], posedge CK &&& (CSWEMTBYPASS[33] != 1), tds, TimingViol_data_33);
	$setup(posedge D[34], posedge CK &&& (CSWEMTBYPASS[34] != 1), tds, TimingViol_data_34);
	$setup(posedge D[35], posedge CK &&& (CSWEMTBYPASS[35] != 1), tds, TimingViol_data_35);
	$setup(posedge D[36], posedge CK &&& (CSWEMTBYPASS[36] != 1), tds, TimingViol_data_36);
	$setup(posedge D[37], posedge CK &&& (CSWEMTBYPASS[37] != 1), tds, TimingViol_data_37);
	$setup(posedge D[38], posedge CK &&& (CSWEMTBYPASS[38] != 1), tds, TimingViol_data_38);
	$setup(posedge D[39], posedge CK &&& (CSWEMTBYPASS[39] != 1), tds, TimingViol_data_39);
	$setup(posedge D[40], posedge CK &&& (CSWEMTBYPASS[40] != 1), tds, TimingViol_data_40);
	$setup(posedge D[41], posedge CK &&& (CSWEMTBYPASS[41] != 1), tds, TimingViol_data_41);
	$setup(posedge D[42], posedge CK &&& (CSWEMTBYPASS[42] != 1), tds, TimingViol_data_42);
	$setup(posedge D[43], posedge CK &&& (CSWEMTBYPASS[43] != 1), tds, TimingViol_data_43);
	$setup(posedge D[44], posedge CK &&& (CSWEMTBYPASS[44] != 1), tds, TimingViol_data_44);
	$setup(posedge D[45], posedge CK &&& (CSWEMTBYPASS[45] != 1), tds, TimingViol_data_45);
	$setup(posedge D[46], posedge CK &&& (CSWEMTBYPASS[46] != 1), tds, TimingViol_data_46);
	$setup(posedge D[47], posedge CK &&& (CSWEMTBYPASS[47] != 1), tds, TimingViol_data_47);
	$setup(posedge D[48], posedge CK &&& (CSWEMTBYPASS[48] != 1), tds, TimingViol_data_48);
	$setup(posedge D[49], posedge CK &&& (CSWEMTBYPASS[49] != 1), tds, TimingViol_data_49);
	$setup(posedge D[50], posedge CK &&& (CSWEMTBYPASS[50] != 1), tds, TimingViol_data_50);
	$setup(posedge D[51], posedge CK &&& (CSWEMTBYPASS[51] != 1), tds, TimingViol_data_51);
	$setup(posedge D[52], posedge CK &&& (CSWEMTBYPASS[52] != 1), tds, TimingViol_data_52);
	$setup(posedge D[53], posedge CK &&& (CSWEMTBYPASS[53] != 1), tds, TimingViol_data_53);
	$setup(posedge D[54], posedge CK &&& (CSWEMTBYPASS[54] != 1), tds, TimingViol_data_54);
	$setup(posedge D[55], posedge CK &&& (CSWEMTBYPASS[55] != 1), tds, TimingViol_data_55);
	$setup(posedge D[56], posedge CK &&& (CSWEMTBYPASS[56] != 1), tds, TimingViol_data_56);
	$setup(posedge D[57], posedge CK &&& (CSWEMTBYPASS[57] != 1), tds, TimingViol_data_57);
	$setup(posedge D[58], posedge CK &&& (CSWEMTBYPASS[58] != 1), tds, TimingViol_data_58);
	$setup(posedge D[59], posedge CK &&& (CSWEMTBYPASS[59] != 1), tds, TimingViol_data_59);
	$setup(posedge D[60], posedge CK &&& (CSWEMTBYPASS[60] != 1), tds, TimingViol_data_60);
	$setup(posedge D[61], posedge CK &&& (CSWEMTBYPASS[61] != 1), tds, TimingViol_data_61);
	$setup(posedge D[62], posedge CK &&& (CSWEMTBYPASS[62] != 1), tds, TimingViol_data_62);
	$setup(posedge D[63], posedge CK &&& (CSWEMTBYPASS[63] != 1), tds, TimingViol_data_63);
	$setup(negedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 1), tds, TimingViol_data_0);
	$setup(negedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 1), tds, TimingViol_data_1);
	$setup(negedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 1), tds, TimingViol_data_2);
	$setup(negedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 1), tds, TimingViol_data_3);
	$setup(negedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 1), tds, TimingViol_data_4);
	$setup(negedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 1), tds, TimingViol_data_5);
	$setup(negedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 1), tds, TimingViol_data_6);
	$setup(negedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 1), tds, TimingViol_data_7);
	$setup(negedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 1), tds, TimingViol_data_8);
	$setup(negedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 1), tds, TimingViol_data_9);
	$setup(negedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 1), tds, TimingViol_data_10);
	$setup(negedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 1), tds, TimingViol_data_11);
	$setup(negedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 1), tds, TimingViol_data_12);
	$setup(negedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 1), tds, TimingViol_data_13);
	$setup(negedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 1), tds, TimingViol_data_14);
	$setup(negedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 1), tds, TimingViol_data_15);
	$setup(negedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 1), tds, TimingViol_data_16);
	$setup(negedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 1), tds, TimingViol_data_17);
	$setup(negedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 1), tds, TimingViol_data_18);
	$setup(negedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 1), tds, TimingViol_data_19);
	$setup(negedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 1), tds, TimingViol_data_20);
	$setup(negedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 1), tds, TimingViol_data_21);
	$setup(negedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 1), tds, TimingViol_data_22);
	$setup(negedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 1), tds, TimingViol_data_23);
	$setup(negedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 1), tds, TimingViol_data_24);
	$setup(negedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 1), tds, TimingViol_data_25);
	$setup(negedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 1), tds, TimingViol_data_26);
	$setup(negedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 1), tds, TimingViol_data_27);
	$setup(negedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 1), tds, TimingViol_data_28);
	$setup(negedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 1), tds, TimingViol_data_29);
	$setup(negedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 1), tds, TimingViol_data_30);
	$setup(negedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 1), tds, TimingViol_data_31);
	$setup(negedge D[32], posedge CK &&& (CSWEMTBYPASS[32] != 1), tds, TimingViol_data_32);
	$setup(negedge D[33], posedge CK &&& (CSWEMTBYPASS[33] != 1), tds, TimingViol_data_33);
	$setup(negedge D[34], posedge CK &&& (CSWEMTBYPASS[34] != 1), tds, TimingViol_data_34);
	$setup(negedge D[35], posedge CK &&& (CSWEMTBYPASS[35] != 1), tds, TimingViol_data_35);
	$setup(negedge D[36], posedge CK &&& (CSWEMTBYPASS[36] != 1), tds, TimingViol_data_36);
	$setup(negedge D[37], posedge CK &&& (CSWEMTBYPASS[37] != 1), tds, TimingViol_data_37);
	$setup(negedge D[38], posedge CK &&& (CSWEMTBYPASS[38] != 1), tds, TimingViol_data_38);
	$setup(negedge D[39], posedge CK &&& (CSWEMTBYPASS[39] != 1), tds, TimingViol_data_39);
	$setup(negedge D[40], posedge CK &&& (CSWEMTBYPASS[40] != 1), tds, TimingViol_data_40);
	$setup(negedge D[41], posedge CK &&& (CSWEMTBYPASS[41] != 1), tds, TimingViol_data_41);
	$setup(negedge D[42], posedge CK &&& (CSWEMTBYPASS[42] != 1), tds, TimingViol_data_42);
	$setup(negedge D[43], posedge CK &&& (CSWEMTBYPASS[43] != 1), tds, TimingViol_data_43);
	$setup(negedge D[44], posedge CK &&& (CSWEMTBYPASS[44] != 1), tds, TimingViol_data_44);
	$setup(negedge D[45], posedge CK &&& (CSWEMTBYPASS[45] != 1), tds, TimingViol_data_45);
	$setup(negedge D[46], posedge CK &&& (CSWEMTBYPASS[46] != 1), tds, TimingViol_data_46);
	$setup(negedge D[47], posedge CK &&& (CSWEMTBYPASS[47] != 1), tds, TimingViol_data_47);
	$setup(negedge D[48], posedge CK &&& (CSWEMTBYPASS[48] != 1), tds, TimingViol_data_48);
	$setup(negedge D[49], posedge CK &&& (CSWEMTBYPASS[49] != 1), tds, TimingViol_data_49);
	$setup(negedge D[50], posedge CK &&& (CSWEMTBYPASS[50] != 1), tds, TimingViol_data_50);
	$setup(negedge D[51], posedge CK &&& (CSWEMTBYPASS[51] != 1), tds, TimingViol_data_51);
	$setup(negedge D[52], posedge CK &&& (CSWEMTBYPASS[52] != 1), tds, TimingViol_data_52);
	$setup(negedge D[53], posedge CK &&& (CSWEMTBYPASS[53] != 1), tds, TimingViol_data_53);
	$setup(negedge D[54], posedge CK &&& (CSWEMTBYPASS[54] != 1), tds, TimingViol_data_54);
	$setup(negedge D[55], posedge CK &&& (CSWEMTBYPASS[55] != 1), tds, TimingViol_data_55);
	$setup(negedge D[56], posedge CK &&& (CSWEMTBYPASS[56] != 1), tds, TimingViol_data_56);
	$setup(negedge D[57], posedge CK &&& (CSWEMTBYPASS[57] != 1), tds, TimingViol_data_57);
	$setup(negedge D[58], posedge CK &&& (CSWEMTBYPASS[58] != 1), tds, TimingViol_data_58);
	$setup(negedge D[59], posedge CK &&& (CSWEMTBYPASS[59] != 1), tds, TimingViol_data_59);
	$setup(negedge D[60], posedge CK &&& (CSWEMTBYPASS[60] != 1), tds, TimingViol_data_60);
	$setup(negedge D[61], posedge CK &&& (CSWEMTBYPASS[61] != 1), tds, TimingViol_data_61);
	$setup(negedge D[62], posedge CK &&& (CSWEMTBYPASS[62] != 1), tds, TimingViol_data_62);
	$setup(negedge D[63], posedge CK &&& (CSWEMTBYPASS[63] != 1), tds, TimingViol_data_63);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 1), posedge D[0], tdh, TimingViol_data_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 1), posedge D[1], tdh, TimingViol_data_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 1), posedge D[2], tdh, TimingViol_data_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 1), posedge D[3], tdh, TimingViol_data_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 1), posedge D[4], tdh, TimingViol_data_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 1), posedge D[5], tdh, TimingViol_data_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 1), posedge D[6], tdh, TimingViol_data_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 1), posedge D[7], tdh, TimingViol_data_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 1), posedge D[8], tdh, TimingViol_data_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 1), posedge D[9], tdh, TimingViol_data_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 1), posedge D[10], tdh, TimingViol_data_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 1), posedge D[11], tdh, TimingViol_data_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 1), posedge D[12], tdh, TimingViol_data_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 1), posedge D[13], tdh, TimingViol_data_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 1), posedge D[14], tdh, TimingViol_data_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 1), posedge D[15], tdh, TimingViol_data_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 1), posedge D[16], tdh, TimingViol_data_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 1), posedge D[17], tdh, TimingViol_data_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 1), posedge D[18], tdh, TimingViol_data_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 1), posedge D[19], tdh, TimingViol_data_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 1), posedge D[20], tdh, TimingViol_data_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 1), posedge D[21], tdh, TimingViol_data_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 1), posedge D[22], tdh, TimingViol_data_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 1), posedge D[23], tdh, TimingViol_data_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 1), posedge D[24], tdh, TimingViol_data_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 1), posedge D[25], tdh, TimingViol_data_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 1), posedge D[26], tdh, TimingViol_data_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 1), posedge D[27], tdh, TimingViol_data_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 1), posedge D[28], tdh, TimingViol_data_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 1), posedge D[29], tdh, TimingViol_data_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 1), posedge D[30], tdh, TimingViol_data_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 1), posedge D[31], tdh, TimingViol_data_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[32] != 1), posedge D[32], tdh, TimingViol_data_32);
	$hold(posedge CK &&& (CSWEMTBYPASS[33] != 1), posedge D[33], tdh, TimingViol_data_33);
	$hold(posedge CK &&& (CSWEMTBYPASS[34] != 1), posedge D[34], tdh, TimingViol_data_34);
	$hold(posedge CK &&& (CSWEMTBYPASS[35] != 1), posedge D[35], tdh, TimingViol_data_35);
	$hold(posedge CK &&& (CSWEMTBYPASS[36] != 1), posedge D[36], tdh, TimingViol_data_36);
	$hold(posedge CK &&& (CSWEMTBYPASS[37] != 1), posedge D[37], tdh, TimingViol_data_37);
	$hold(posedge CK &&& (CSWEMTBYPASS[38] != 1), posedge D[38], tdh, TimingViol_data_38);
	$hold(posedge CK &&& (CSWEMTBYPASS[39] != 1), posedge D[39], tdh, TimingViol_data_39);
	$hold(posedge CK &&& (CSWEMTBYPASS[40] != 1), posedge D[40], tdh, TimingViol_data_40);
	$hold(posedge CK &&& (CSWEMTBYPASS[41] != 1), posedge D[41], tdh, TimingViol_data_41);
	$hold(posedge CK &&& (CSWEMTBYPASS[42] != 1), posedge D[42], tdh, TimingViol_data_42);
	$hold(posedge CK &&& (CSWEMTBYPASS[43] != 1), posedge D[43], tdh, TimingViol_data_43);
	$hold(posedge CK &&& (CSWEMTBYPASS[44] != 1), posedge D[44], tdh, TimingViol_data_44);
	$hold(posedge CK &&& (CSWEMTBYPASS[45] != 1), posedge D[45], tdh, TimingViol_data_45);
	$hold(posedge CK &&& (CSWEMTBYPASS[46] != 1), posedge D[46], tdh, TimingViol_data_46);
	$hold(posedge CK &&& (CSWEMTBYPASS[47] != 1), posedge D[47], tdh, TimingViol_data_47);
	$hold(posedge CK &&& (CSWEMTBYPASS[48] != 1), posedge D[48], tdh, TimingViol_data_48);
	$hold(posedge CK &&& (CSWEMTBYPASS[49] != 1), posedge D[49], tdh, TimingViol_data_49);
	$hold(posedge CK &&& (CSWEMTBYPASS[50] != 1), posedge D[50], tdh, TimingViol_data_50);
	$hold(posedge CK &&& (CSWEMTBYPASS[51] != 1), posedge D[51], tdh, TimingViol_data_51);
	$hold(posedge CK &&& (CSWEMTBYPASS[52] != 1), posedge D[52], tdh, TimingViol_data_52);
	$hold(posedge CK &&& (CSWEMTBYPASS[53] != 1), posedge D[53], tdh, TimingViol_data_53);
	$hold(posedge CK &&& (CSWEMTBYPASS[54] != 1), posedge D[54], tdh, TimingViol_data_54);
	$hold(posedge CK &&& (CSWEMTBYPASS[55] != 1), posedge D[55], tdh, TimingViol_data_55);
	$hold(posedge CK &&& (CSWEMTBYPASS[56] != 1), posedge D[56], tdh, TimingViol_data_56);
	$hold(posedge CK &&& (CSWEMTBYPASS[57] != 1), posedge D[57], tdh, TimingViol_data_57);
	$hold(posedge CK &&& (CSWEMTBYPASS[58] != 1), posedge D[58], tdh, TimingViol_data_58);
	$hold(posedge CK &&& (CSWEMTBYPASS[59] != 1), posedge D[59], tdh, TimingViol_data_59);
	$hold(posedge CK &&& (CSWEMTBYPASS[60] != 1), posedge D[60], tdh, TimingViol_data_60);
	$hold(posedge CK &&& (CSWEMTBYPASS[61] != 1), posedge D[61], tdh, TimingViol_data_61);
	$hold(posedge CK &&& (CSWEMTBYPASS[62] != 1), posedge D[62], tdh, TimingViol_data_62);
	$hold(posedge CK &&& (CSWEMTBYPASS[63] != 1), posedge D[63], tdh, TimingViol_data_63);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 1), negedge D[0], tdh, TimingViol_data_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 1), negedge D[1], tdh, TimingViol_data_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 1), negedge D[2], tdh, TimingViol_data_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 1), negedge D[3], tdh, TimingViol_data_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 1), negedge D[4], tdh, TimingViol_data_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 1), negedge D[5], tdh, TimingViol_data_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 1), negedge D[6], tdh, TimingViol_data_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 1), negedge D[7], tdh, TimingViol_data_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 1), negedge D[8], tdh, TimingViol_data_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 1), negedge D[9], tdh, TimingViol_data_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 1), negedge D[10], tdh, TimingViol_data_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 1), negedge D[11], tdh, TimingViol_data_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 1), negedge D[12], tdh, TimingViol_data_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 1), negedge D[13], tdh, TimingViol_data_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 1), negedge D[14], tdh, TimingViol_data_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 1), negedge D[15], tdh, TimingViol_data_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 1), negedge D[16], tdh, TimingViol_data_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 1), negedge D[17], tdh, TimingViol_data_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 1), negedge D[18], tdh, TimingViol_data_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 1), negedge D[19], tdh, TimingViol_data_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 1), negedge D[20], tdh, TimingViol_data_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 1), negedge D[21], tdh, TimingViol_data_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 1), negedge D[22], tdh, TimingViol_data_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 1), negedge D[23], tdh, TimingViol_data_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 1), negedge D[24], tdh, TimingViol_data_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 1), negedge D[25], tdh, TimingViol_data_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 1), negedge D[26], tdh, TimingViol_data_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 1), negedge D[27], tdh, TimingViol_data_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 1), negedge D[28], tdh, TimingViol_data_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 1), negedge D[29], tdh, TimingViol_data_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 1), negedge D[30], tdh, TimingViol_data_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 1), negedge D[31], tdh, TimingViol_data_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[32] != 1), negedge D[32], tdh, TimingViol_data_32);
	$hold(posedge CK &&& (CSWEMTBYPASS[33] != 1), negedge D[33], tdh, TimingViol_data_33);
	$hold(posedge CK &&& (CSWEMTBYPASS[34] != 1), negedge D[34], tdh, TimingViol_data_34);
	$hold(posedge CK &&& (CSWEMTBYPASS[35] != 1), negedge D[35], tdh, TimingViol_data_35);
	$hold(posedge CK &&& (CSWEMTBYPASS[36] != 1), negedge D[36], tdh, TimingViol_data_36);
	$hold(posedge CK &&& (CSWEMTBYPASS[37] != 1), negedge D[37], tdh, TimingViol_data_37);
	$hold(posedge CK &&& (CSWEMTBYPASS[38] != 1), negedge D[38], tdh, TimingViol_data_38);
	$hold(posedge CK &&& (CSWEMTBYPASS[39] != 1), negedge D[39], tdh, TimingViol_data_39);
	$hold(posedge CK &&& (CSWEMTBYPASS[40] != 1), negedge D[40], tdh, TimingViol_data_40);
	$hold(posedge CK &&& (CSWEMTBYPASS[41] != 1), negedge D[41], tdh, TimingViol_data_41);
	$hold(posedge CK &&& (CSWEMTBYPASS[42] != 1), negedge D[42], tdh, TimingViol_data_42);
	$hold(posedge CK &&& (CSWEMTBYPASS[43] != 1), negedge D[43], tdh, TimingViol_data_43);
	$hold(posedge CK &&& (CSWEMTBYPASS[44] != 1), negedge D[44], tdh, TimingViol_data_44);
	$hold(posedge CK &&& (CSWEMTBYPASS[45] != 1), negedge D[45], tdh, TimingViol_data_45);
	$hold(posedge CK &&& (CSWEMTBYPASS[46] != 1), negedge D[46], tdh, TimingViol_data_46);
	$hold(posedge CK &&& (CSWEMTBYPASS[47] != 1), negedge D[47], tdh, TimingViol_data_47);
	$hold(posedge CK &&& (CSWEMTBYPASS[48] != 1), negedge D[48], tdh, TimingViol_data_48);
	$hold(posedge CK &&& (CSWEMTBYPASS[49] != 1), negedge D[49], tdh, TimingViol_data_49);
	$hold(posedge CK &&& (CSWEMTBYPASS[50] != 1), negedge D[50], tdh, TimingViol_data_50);
	$hold(posedge CK &&& (CSWEMTBYPASS[51] != 1), negedge D[51], tdh, TimingViol_data_51);
	$hold(posedge CK &&& (CSWEMTBYPASS[52] != 1), negedge D[52], tdh, TimingViol_data_52);
	$hold(posedge CK &&& (CSWEMTBYPASS[53] != 1), negedge D[53], tdh, TimingViol_data_53);
	$hold(posedge CK &&& (CSWEMTBYPASS[54] != 1), negedge D[54], tdh, TimingViol_data_54);
	$hold(posedge CK &&& (CSWEMTBYPASS[55] != 1), negedge D[55], tdh, TimingViol_data_55);
	$hold(posedge CK &&& (CSWEMTBYPASS[56] != 1), negedge D[56], tdh, TimingViol_data_56);
	$hold(posedge CK &&& (CSWEMTBYPASS[57] != 1), negedge D[57], tdh, TimingViol_data_57);
	$hold(posedge CK &&& (CSWEMTBYPASS[58] != 1), negedge D[58], tdh, TimingViol_data_58);
	$hold(posedge CK &&& (CSWEMTBYPASS[59] != 1), negedge D[59], tdh, TimingViol_data_59);
	$hold(posedge CK &&& (CSWEMTBYPASS[60] != 1), negedge D[60], tdh, TimingViol_data_60);
	$hold(posedge CK &&& (CSWEMTBYPASS[61] != 1), negedge D[61], tdh, TimingViol_data_61);
	$hold(posedge CK &&& (CSWEMTBYPASS[62] != 1), negedge D[62], tdh, TimingViol_data_62);
	$hold(posedge CK &&& (CSWEMTBYPASS[63] != 1), negedge D[63], tdh, TimingViol_data_63);

	
        $setup(posedge CSN, edge[01,0x,x1,1x] CK &&& (TBYPASSint != 1), tps, TimingViol_csn);
	$setup(negedge CSN, edge[01,0x,x1,1x] CK &&& (TBYPASSint != 1), tps, TimingViol_csn);
	$hold(edge[01,0x,x1,x0] CK &&& (TBYPASSint != 1), posedge CSN, tph, TimingViol_csn);
	$hold(edge[01,0x,x1,x0] CK &&& (TBYPASSint != 1), negedge CSN, tph, TimingViol_csn);
        $setup(posedge WEN, edge[01,0x,x1,1x] CK &&& (CSNint != 1), tws, TimingViol_wen);
        $setup(negedge WEN, edge[01,0x,x1,1x] CK &&& (CSNint != 1), tws, TimingViol_wen);
        $hold(edge[01,0x,x1,x0] CK &&& (CSNint != 1), posedge WEN, twh, TimingViol_wen);
        $hold(edge[01,0x,x1,x0] CK &&& (CSNint != 1), negedge WEN, twh, TimingViol_wen);
        $period(posedge CK &&& (CSNint != 1), tcycle, TimingViol_tcycle);
        $width(posedge CK &&& (CSNint != 1'b1), tckh, 0, TimingViol_tckh);
        $width(negedge CK &&& (CSNint != 1'b1), tckl, 0, TimingViol_tckl);
        $setup(posedge TBYPASS, posedge CK &&& (CS != 1),ttms, TimingViol_tbypass);
        $setup(negedge TBYPASS, posedge CK &&& (CS != 1),ttms, TimingViol_tbypass);
        $hold(posedge CK &&& (CS != 1), posedge TBYPASS, ttmh, TimingViol_tbypass); 
        $hold(posedge CK &&& (CS != 1), negedge TBYPASS, ttmh, TimingViol_tbypass); 




	endspecify

always @(CKint)
begin
   CKreg <= CKint;
end

//latch input signals
always @(posedge CKint)
begin
   if (CSNint !== 1)
   begin
      Dreg = Dint;
      Mreg = Mint;
      WENreg = WENint;
      Areg = Aint;
   end
   CSNreg = CSNint;
end
     


// conversion from registers to array elements for data setup violation notifiers

always @(TimingViol_data_0)
begin
   TimingViol_data[0] = TimingViol_data_0;
end


always @(TimingViol_data_1)
begin
   TimingViol_data[1] = TimingViol_data_1;
end


always @(TimingViol_data_2)
begin
   TimingViol_data[2] = TimingViol_data_2;
end


always @(TimingViol_data_3)
begin
   TimingViol_data[3] = TimingViol_data_3;
end


always @(TimingViol_data_4)
begin
   TimingViol_data[4] = TimingViol_data_4;
end


always @(TimingViol_data_5)
begin
   TimingViol_data[5] = TimingViol_data_5;
end


always @(TimingViol_data_6)
begin
   TimingViol_data[6] = TimingViol_data_6;
end


always @(TimingViol_data_7)
begin
   TimingViol_data[7] = TimingViol_data_7;
end


always @(TimingViol_data_8)
begin
   TimingViol_data[8] = TimingViol_data_8;
end


always @(TimingViol_data_9)
begin
   TimingViol_data[9] = TimingViol_data_9;
end


always @(TimingViol_data_10)
begin
   TimingViol_data[10] = TimingViol_data_10;
end


always @(TimingViol_data_11)
begin
   TimingViol_data[11] = TimingViol_data_11;
end


always @(TimingViol_data_12)
begin
   TimingViol_data[12] = TimingViol_data_12;
end


always @(TimingViol_data_13)
begin
   TimingViol_data[13] = TimingViol_data_13;
end


always @(TimingViol_data_14)
begin
   TimingViol_data[14] = TimingViol_data_14;
end


always @(TimingViol_data_15)
begin
   TimingViol_data[15] = TimingViol_data_15;
end


always @(TimingViol_data_16)
begin
   TimingViol_data[16] = TimingViol_data_16;
end


always @(TimingViol_data_17)
begin
   TimingViol_data[17] = TimingViol_data_17;
end


always @(TimingViol_data_18)
begin
   TimingViol_data[18] = TimingViol_data_18;
end


always @(TimingViol_data_19)
begin
   TimingViol_data[19] = TimingViol_data_19;
end


always @(TimingViol_data_20)
begin
   TimingViol_data[20] = TimingViol_data_20;
end


always @(TimingViol_data_21)
begin
   TimingViol_data[21] = TimingViol_data_21;
end


always @(TimingViol_data_22)
begin
   TimingViol_data[22] = TimingViol_data_22;
end


always @(TimingViol_data_23)
begin
   TimingViol_data[23] = TimingViol_data_23;
end


always @(TimingViol_data_24)
begin
   TimingViol_data[24] = TimingViol_data_24;
end


always @(TimingViol_data_25)
begin
   TimingViol_data[25] = TimingViol_data_25;
end


always @(TimingViol_data_26)
begin
   TimingViol_data[26] = TimingViol_data_26;
end


always @(TimingViol_data_27)
begin
   TimingViol_data[27] = TimingViol_data_27;
end


always @(TimingViol_data_28)
begin
   TimingViol_data[28] = TimingViol_data_28;
end


always @(TimingViol_data_29)
begin
   TimingViol_data[29] = TimingViol_data_29;
end


always @(TimingViol_data_30)
begin
   TimingViol_data[30] = TimingViol_data_30;
end


always @(TimingViol_data_31)
begin
   TimingViol_data[31] = TimingViol_data_31;
end


always @(TimingViol_data_32)
begin
   TimingViol_data[32] = TimingViol_data_32;
end


always @(TimingViol_data_33)
begin
   TimingViol_data[33] = TimingViol_data_33;
end


always @(TimingViol_data_34)
begin
   TimingViol_data[34] = TimingViol_data_34;
end


always @(TimingViol_data_35)
begin
   TimingViol_data[35] = TimingViol_data_35;
end


always @(TimingViol_data_36)
begin
   TimingViol_data[36] = TimingViol_data_36;
end


always @(TimingViol_data_37)
begin
   TimingViol_data[37] = TimingViol_data_37;
end


always @(TimingViol_data_38)
begin
   TimingViol_data[38] = TimingViol_data_38;
end


always @(TimingViol_data_39)
begin
   TimingViol_data[39] = TimingViol_data_39;
end


always @(TimingViol_data_40)
begin
   TimingViol_data[40] = TimingViol_data_40;
end


always @(TimingViol_data_41)
begin
   TimingViol_data[41] = TimingViol_data_41;
end


always @(TimingViol_data_42)
begin
   TimingViol_data[42] = TimingViol_data_42;
end


always @(TimingViol_data_43)
begin
   TimingViol_data[43] = TimingViol_data_43;
end


always @(TimingViol_data_44)
begin
   TimingViol_data[44] = TimingViol_data_44;
end


always @(TimingViol_data_45)
begin
   TimingViol_data[45] = TimingViol_data_45;
end


always @(TimingViol_data_46)
begin
   TimingViol_data[46] = TimingViol_data_46;
end


always @(TimingViol_data_47)
begin
   TimingViol_data[47] = TimingViol_data_47;
end


always @(TimingViol_data_48)
begin
   TimingViol_data[48] = TimingViol_data_48;
end


always @(TimingViol_data_49)
begin
   TimingViol_data[49] = TimingViol_data_49;
end


always @(TimingViol_data_50)
begin
   TimingViol_data[50] = TimingViol_data_50;
end


always @(TimingViol_data_51)
begin
   TimingViol_data[51] = TimingViol_data_51;
end


always @(TimingViol_data_52)
begin
   TimingViol_data[52] = TimingViol_data_52;
end


always @(TimingViol_data_53)
begin
   TimingViol_data[53] = TimingViol_data_53;
end


always @(TimingViol_data_54)
begin
   TimingViol_data[54] = TimingViol_data_54;
end


always @(TimingViol_data_55)
begin
   TimingViol_data[55] = TimingViol_data_55;
end


always @(TimingViol_data_56)
begin
   TimingViol_data[56] = TimingViol_data_56;
end


always @(TimingViol_data_57)
begin
   TimingViol_data[57] = TimingViol_data_57;
end


always @(TimingViol_data_58)
begin
   TimingViol_data[58] = TimingViol_data_58;
end


always @(TimingViol_data_59)
begin
   TimingViol_data[59] = TimingViol_data_59;
end


always @(TimingViol_data_60)
begin
   TimingViol_data[60] = TimingViol_data_60;
end


always @(TimingViol_data_61)
begin
   TimingViol_data[61] = TimingViol_data_61;
end


always @(TimingViol_data_62)
begin
   TimingViol_data[62] = TimingViol_data_62;
end


always @(TimingViol_data_63)
begin
   TimingViol_data[63] = TimingViol_data_63;
end




ST_SPHS_48x64m4_L_main ST_SPHS_48x64m4_L_maininst (Q_glitchint,  Q_dataint, Q_gCKint , RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint, CKint,  CSNint , TBYPASSint, WENint,  Aint, Dint, Mint, debug_level  , TimingViol_addr, TimingViol_data, TimingViol_csn, TimingViol_wen, TimingViol_tckh, TimingViol_tckl, TimingViol_tcycle, TimingViol_tbypass, TimingViol_mask    );


ST_SPHS_48x64m4_L_OPschlr ST_SPHS_48x64m4_L_OPschlrinst (Qint, RYint,  Q_gCKint, Q_glitchint,  Q_dataint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint);

defparam ST_SPHS_48x64m4_L_maininst.Fault_file_name = Fault_file_name;
defparam ST_SPHS_48x64m4_L_maininst.ConfigFault = ConfigFault;
defparam ST_SPHS_48x64m4_L_maininst.max_faults = max_faults;
defparam ST_SPHS_48x64m4_L_maininst.MEM_INITIALIZE = MEM_INITIALIZE;
defparam ST_SPHS_48x64m4_L_maininst.BinaryInit = BinaryInit;
defparam ST_SPHS_48x64m4_L_maininst.InitFileName = InitFileName;

endmodule
`endif

`delay_mode_path
`endcelldefine
`disable_portfaults
`nosuppress_faults









/****************************************************************
--  Description         : Verilog Model for SPHSLP cmos65
--  Last modified in    : 5.3.a
--  Date                : April, 2009
--  Last modified by    : SK 
--
****************************************************************/
 

/******************** START OF HEADER****************************
   This Header Gives Information about the parameters & options present in the Model

   words = 80
   bits  = 64
   mux   = 4 
   
   
   
   

**********************END OF HEADER ******************************/
   


`ifdef slm
        `define functional
`endif
`celldefine
`suppress_faults
`enable_portfaults
`ifdef functional
   `timescale 1ns / 1ns
   `delay_mode_unit
`endif

`ifdef functional

module ST_SPHS_80x64m4_L (Q, RY,CK, CSN, TBYPASS, WEN, A, D    );

    
    
    parameter 
        Corruption_Read_Violation = 1,
        Fault_file_name = "ST_SPHS_80x64m4_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20;
   
   // Parameters for Memory Initialization at 0 ns
    parameter 
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHS_80x64m4_L.cde",
        InstancePath = "ST_SPHS_80x64m4_L",
        Debug_mode = "all_warning_mode";
    
    parameter
        Words = 80,
        Bits = 64,
        Addr = 7,
        mux = 4;




   
    parameter
        Rows = Words/mux,
        WordX = 64'bx,
        AddrX = 7'bx,
        Word0 = 64'b0,
        X = 1'bx;


         
      
        //  INPUT OUTPUT PORTS
        // ========================
      
	output [Bits-1 : 0] Q;
        
        output RY;   
        
        input [Bits-1 : 0] D;
	input [Addr-1 : 0] A;
	        
        input CK, CSN, TBYPASS, WEN;

        
        
        

           
        
        
	reg [Bits-1 : 0] Qint; 

    
        //  WIRE DECLARATION
        //  =====================
        
        
	wire [Bits-1 : 0] Dint,Mint;
        
        assign Mint=64'b0;
        
	wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;

        
        
        wire TBYPASSint;
        
 
        

        
        wire RYint;
        
        
        assign RY =   RYint; 
        reg RY_outreg, RY_out;
        assign RYint = RY_out;
        
        

        
        
        //  REG DECLARATION
        //  ====================
        
	//Output Register for tbypass
        reg [Bits-1 : 0] tbydata;
        //delayed Output Register
        reg [Bits-1 : 0] delOutReg_data;
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] tempMem;
	reg lastCK;
        reg CSNreg;	

        `ifdef slm
        `else
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
        `endif
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;

        
        
        reg WENreg;
        
        
        /* This register is used to force all warning messages 
        ** OFF during run time.
        ** It is a 2 bit register.
        ** USAGE :
        ** debug_level_off = 2'b00 -> ALL WARNING MESSAGES will be DISPLAYED 
        ** debug_level = 2'b10 -> ALL WARNING MESSAGES will NOT be DISPLAYED.
        ** It will override the value of debug_mode, i.e
        ** if debug_mode = "all_warning_mode", then also
        ** no warning messages will be displayed.     
        ** debug_level = 2'b01 OR 2'b11 -> UNUSED , FOR FUTURE SCALABILITY.
        ** ult, debug_mode will prevail.               
        */ 
         reg [1:0] debug_level;
         reg [8*10: 0] operating_mode;
         reg [8*44: 0] message_status;

        integer d, a, p, i, k, j, l;
        `ifdef slm
           integer MemAddr;
        `endif


        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;

        `ifdef slm
        reg [Bits -1 : 0] slm_temp_data;
        `endif
        

        integer flag_error;
        
        //BUFFER INSTANTIATION
        //=========================
        
        
        assign Q =  Qint; 
        buf bufdata [Bits-1:0] (Dint,D);
        buf bufaddr [Addr-1:0] (Aint,A);
        
	buf (TBYPASSint, TBYPASS);
	buf (CKint, CK);
        
        or (CSNint, CSN,TBYPASSint ); 
	buf (WENint, WEN);
        
        
        
        

           

        

// BEHAVIOURAL MODULE DESCRIPTION
// ================================



task task_insert_faults_in_memory;
begin
   if (ConfigFault)
   begin   
     Fault_in_memory = 1;
     for(i = 0;i< fcnt;i = i+ 1) begin
       if (fault_repair_flag[i] !== 1) begin
         Fault_in_memory = 0;
         if (array_stuck_at[i] === "sa0") begin
         `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data & stuck_at_0fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
         `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
         `endif
         end //if(array_stuck_at)
                                        
         if(array_stuck_at[i] === "sa1") begin
         `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data | stuck_at_1fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
         `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
         `endif
         end //if(array_stuck_at)
       end   // if(fault_repair_flag
     end    // end of for
   end  
end
endtask


      
task WriteMemX;
begin
   `ifdef slm
   $slm_ResetMemory(MemAddr, WordX);
   `else
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
   `endif        
   task_insert_faults_in_memory;
end
endtask

task WriteOutX;                
begin
   OutReg_data = WordX;
end
endtask


task WriteCycle;                  
input [Addr-1 : 0] Address;
reg [Bits-1:0] tempReg1,tempReg2;
integer po,i;
begin
   
   tempReg1 = WordX;
   if (^Address !== X)
   begin
      if (ValidAddress)
      begin
         
         
            `ifdef slm
               $slm_ReadMemoryS(MemAddr, Address, tempReg1);
            `else
               tempReg1 = Mem[Address];
            `endif
                   
            for (po=0;po<Bits;po=po+1)
            begin
               if (Mint[po] === 1'b0)
                  tempReg1[po] = Dint[po];
               else if (Mint[po] === 1'bX)
                  tempReg1[po] = 1'bx;
            end                
         
            `ifdef slm
                $slm_WriteMemory(MemAddr, Address, tempReg1);
            `else
                Mem[Address] = tempReg1;
            `endif
            
      end//if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. ",$realtime); 
      task_insert_faults_in_memory;
   end //if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
      
   end
  
end
endtask

task ReadCycle;
input [Addr-1 : 0] Address;
reg [Bits-1:0] MemData;
integer a;
begin
   if (ValidAddress)
   begin        
      `ifdef slm
         $slm_ReadMemory(MemAddr, Address, MemData);
      `else
         MemData = Mem[Address];
      `endif
   end //if (ValidAddress)  
                
   if(ValidAddress === X)
   begin
      if (Corruption_Read_Violation === 1)
      begin   
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
         WriteMemX;
      end
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Output Corrupted ",$realtime);
      MemData = WordX;
      
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. Output Corrupted ",$realtime); 
      MemData = WordX;
   end
   
   OutReg_data = MemData;
end
endtask



initial
begin
   // Define format for timing value
  $timeformat (-9, 2, " ns", 0);
  `ifdef slm
  $slm_RegisterMemory(MemAddr, Words, Bits);
  `endif   
  
   debug_level= 2'b0;
   message_status = "All Messages are Switched ON";
  
   
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
     message_status = "All Warning Messages are Switched OFF";
  `endif  
  `ifdef slm
     operating_mode = "SLM";
  `else
     operating_mode = "FUNCTIONAL";
  `endif
if(debug_level !== 2'b10) begin
  $display ("%mINFORMATION ");
  $display ("***************************************");
  $display ("The Model is Operating in %s MODE", operating_mode);
  $display ("%s", message_status);
  if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF");   
  
  $display ("***************************************");
end     
  if (MEM_INITIALIZE === 1'b1)
  begin   
     `ifdef slm
        if (BinaryInit)
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_BIN");
        else
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_HEX");

     `else
        if (BinaryInit)
           $readmemb(InitFileName, Mem, 0, Words-1);
        else
           $readmemh(InitFileName, Mem, 0, Words-1);
     `endif
  end   
   
  

  
  RY_out = 1'b1;


        
/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
      file_ptr = $fopen(Fault_file_name , "r");
      if(file_ptr == 0)
      begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
      end        
      else                
      begin : read_fault_file
        t = 0;
        for (i = 0; i< max_faults; i= i + 1)
        begin
         
           stuck0 = {Bits{1'b1}};
           stuck1 = {Bits{1'b0}};
           fault_char1 = $fgetc (file_ptr);
           if (fault_char1 == 8'b11111111)
              disable read_fault_file;
           ret_val = $ungetc (fault_char1, file_ptr);
           ret_val = $fgets(tempStr, file_ptr);
           ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
           flag_error = 0; 
           if(ret_val !== 0)
           begin         
              if(ret_val == 2 || ret_val == 3)
              begin
                if(ret_val == 2)
                   stuck_at = "sa0";

                if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                begin
                   if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                   flag_error = 1;
                end    
                      
                if(fault_word > Words-1)
                begin
                   if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                   flag_error = 1;
                end    

                if(fault_bit > Bits-1)
                begin  
                   if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                   flag_error = 1;
                end    

                if(flag_error == 0)
                //Correct Inputs
                begin
                   if(stuck_at === "none")
                   begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                   end
                   else
                   //Adding the faults
                   begin
                      FailureLocn[t] = fault_word;
                      std_fault_word = fault_word;
                      
                      fault_repair_flag[t] = 1'b0;
                      if (stuck_at === "sa0" )
                      begin
                         stuck0[fault_bit] = 1'b0;         
                         stuck_at_0fault[t] = stuck0;
                      end     
                      if (stuck_at === "sa1" )
                      begin
                         stuck1[fault_bit] = 1'b1;
                         stuck_at_1fault[t] = stuck1; 
                      end

                      array_stuck_at[t] = stuck_at;
                      t = t + 1;
                   end //if(stuck_at === "none")  
                end //if(flag_error == 0)
              end //if(ret_val == 2 || ret_val == 3 
              else
              //wrong number of arguments
              begin
                if(debug_level < 2)
                   $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                flag_error = 1;
              end
           end //if(ret_val !== 0)
           else
           begin
              if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
           end    
        end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);

      fcnt = t;

      
      //fault injection at time 0.
      task_insert_faults_in_memory;
   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//
        
always @(CKint)
begin
  
      // Unknown Clock Behaviour
      if (CKint=== X && CSNint !==1)
      begin
         WriteOutX;
         WriteMemX;
          
         RY_out = 1'bX;
      end
      if(CKint === 1'b1 && lastCK === 1'b0)
      begin
         CSNreg = CSNint;
         WENreg = WENint;
         if (CSNint !== 1)
         begin
            if (^Aint === X)
               ValidAddress = X;
            else if (Aint < Words)
               ValidAddress = 1;
            else    
               ValidAddress = 0;

            if (ValidAddress)
	       `ifdef slm
               $slm_ReadMemoryS(MemAddr, Aint, Mem_temp);
               `else        
               Mem_temp = Mem[Aint];
               `endif       
            else
	       Mem_temp = WordX; 
               
            
         end// CSNint !==1...
      end // if(CKint === 1'b1...)
        
   /*---------------------- Normal Read and Write -----------------*/

      if (CSNint !== 1 && CKint === 1'b1 && lastCK === 1'b0 )
      begin
            if (CSNint === 0)
            begin        
               
               if (ValidAddress !== 1'bX )   
                  RY_outreg = ~CKint;
               else
                  RY_outreg = 1'bX;
               if (WENint === 1)
               begin
                  ReadCycle(Aint);
               end
               else if (WENint === 0)
               begin
                  
                   WriteCycle(Aint);
                   
               end
               else if (WENint === X)
               begin
                  // Uncertain write cycle
                  WriteOutX;
                  WriteMemX;
                  
                  RY_outreg = 1'bX;
                  if(debug_level < 2) $display("%m - %t (MSG_ID 002) WARNING: Illegal Value on Write Enable. Memory and Output Corrupted ",$realtime);
                  
               end // if (WENint === X...)
            end //if (CSNint === 0
            else if (CSNint === X)
            begin
                
                RY_outreg = 1'bX;
                if(debug_level < 2) $display("%m - %t (MSG_ID 001) WARNING: Illegal Value on Chip Select. Memory and Output Corrupted ",$realtime);
                WriteOutX;
                WriteMemX;
            end //else if (CSNint === X)
         
       
       
      end // if (CSNint !==1..          

   
   lastCK = CKint;
end // always @(CKint)
        
always @(CSNint)
begin
     // Unknown Clock & CSN signal
     if (CSNint !== 1 && CKint === 1'bx)
     begin
       if(debug_level < 2) $display("%m - %t (MSG_ID 004) WARNING: Chip Select going low while Clock is Invalid. Memory Corrupted ",$realtime);
       WriteMemX;
       WriteOutX;
       
       RY_out = 1'bX;
     end
end



//TBYPASS functionality
 always @(TBYPASSint)
 begin
     
             
      
        OutReg_data = WordX;
        if(TBYPASSint === 1'b1) 
          tbydata = Dint;
        else
          tbydata = WordX;
          
    
    
    
 end //end of always TBYPASSint

 always @(Dint)
 begin
    
     
       
      if(TBYPASSint === 1'b1)
        tbydata = Dint;
      
    
    
    
 end //end of always Dint

//assign output data
always @(OutReg_data)
   #1 delOutReg_data = OutReg_data;

always @(delOutReg_data or tbydata or TBYPASSint)
   if(TBYPASSint === 1'b0)
      Qint = delOutReg_data;
   else if(TBYPASSint === 1'bX)
      Qint = WordX;
   else
      Qint = tbydata;      

 
 always @(TBYPASSint)
 begin
    
     
      
      if(TBYPASSint !== 1'b0)
        RY_outreg = 1'bx;
        
    
    
    
 end

 always @(negedge CKint)
 begin
    
     
      
      if(TBYPASSint === 1'b1)
        RY_outreg = 1'b1;
      else if (TBYPASSint === 1'b0) 
         if(CSNreg === 1'b0 && WENreg !== 1'bX && ValidAddress !== 1'bX  && RY_outreg !== 1'bX)
            RY_outreg = ~CKint;
            
    
    
    
 end

always @(RY_outreg)
begin
  #1 RY_out = RY_outreg;
end





endmodule


`else

`timescale 1ns / 1ps
`delay_mode_path
 
module ST_SPHS_80x64m4_L_main (Q_glitch,  Q_data, Q_gCK , RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main, CK,  CSN, TBYPASS, WEN,  A, D, M,debug_level , TimingViol_addr, TimingViol_data, TimingViol_csn, TimingViol_wen, TimingViol_tckh, TimingViol_tckl, TimingViol_tcycle, TimingViol_tbypass, TimingViol_mask     );

    
       
    parameter 
        Corruption_Read_Violation = 1,
        Fault_file_name = "ST_SPHS_80x64m4_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20;
   
    // Parameters for Memory Initialization at 0 ns
    parameter 
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHS_80x64m4_L.cde",
        InstancePath = "ST_SPHS_80x64m4_L",
        Debug_mode = "all_warning_mode";
    
    parameter
        Words = 80,
        Bits = 64,
        Addr = 7,
        mux = 4,
        Rows = Words/mux;




   
    parameter
        WordX = 64'bx,
        AddrX = 7'bx,
        Word0 = 64'b0,
        X = 1'bx;
         
      
        //  INPUT OUTPUT PORTS
        // ========================
	output [Bits-1 : 0] Q_glitch;
	output [Bits-1 : 0] Q_data;
	output [Bits-1 : 0] Q_gCK;
        
        output ICRY;
        output RY_rfCK;
	output RY_rrCK;
	output RY_frCK;   
	output [Bits-1 : 0] delTBYPASS; 
	output TBYPASS_main; 
        output [Bits-1 : 0] TBYPASS_D_Q;
        
        input [Bits-1 : 0] D,M;
	input [Addr-1 : 0] A;
	input CK, CSN, TBYPASS, WEN;
        input [1 : 0] debug_level;

	input [Bits-1 : 0] TimingViol_data, TimingViol_mask;
	input TimingViol_addr, TimingViol_csn, TimingViol_wen, TimingViol_tckh, TimingViol_tckl, TimingViol_tcycle, TimingViol_tbypass;

        
        
 



        
        wire [Bits-1 : 0] Dint,Mint; 
	wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;
        
        


        
        
        
	wire  Mreg_0;
	wire  Mreg_1;
	wire  Mreg_2;
	wire  Mreg_3;
	wire  Mreg_4;
	wire  Mreg_5;
	wire  Mreg_6;
	wire  Mreg_7;
	wire  Mreg_8;
	wire  Mreg_9;
	wire  Mreg_10;
	wire  Mreg_11;
	wire  Mreg_12;
	wire  Mreg_13;
	wire  Mreg_14;
	wire  Mreg_15;
	wire  Mreg_16;
	wire  Mreg_17;
	wire  Mreg_18;
	wire  Mreg_19;
	wire  Mreg_20;
	wire  Mreg_21;
	wire  Mreg_22;
	wire  Mreg_23;
	wire  Mreg_24;
	wire  Mreg_25;
	wire  Mreg_26;
	wire  Mreg_27;
	wire  Mreg_28;
	wire  Mreg_29;
	wire  Mreg_30;
	wire  Mreg_31;
	wire  Mreg_32;
	wire  Mreg_33;
	wire  Mreg_34;
	wire  Mreg_35;
	wire  Mreg_36;
	wire  Mreg_37;
	wire  Mreg_38;
	wire  Mreg_39;
	wire  Mreg_40;
	wire  Mreg_41;
	wire  Mreg_42;
	wire  Mreg_43;
	wire  Mreg_44;
	wire  Mreg_45;
	wire  Mreg_46;
	wire  Mreg_47;
	wire  Mreg_48;
	wire  Mreg_49;
	wire  Mreg_50;
	wire  Mreg_51;
	wire  Mreg_52;
	wire  Mreg_53;
	wire  Mreg_54;
	wire  Mreg_55;
	wire  Mreg_56;
	wire  Mreg_57;
	wire  Mreg_58;
	wire  Mreg_59;
	wire  Mreg_60;
	wire  Mreg_61;
	wire  Mreg_62;
	wire  Mreg_63;
	
	reg [Bits-1 : 0] OutReg_glitch; // Glitch Output register
	reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] Dreg,Mreg;
	reg [Bits-1 : 0] Mreg_temp;
	reg [Bits-1 : 0] tempMem;
	reg [Bits-1 : 0] prevMem;
	reg [Addr-1 : 0] Areg;
	reg [Bits-1 : 0] Q_gCKreg; 
	reg [Bits-1 : 0] lastQ_gCK;
	reg [Bits-1 : 0] last_Qdata;
	reg lastCK, CKreg;
	reg CSNreg;
	reg WENreg;
	
        reg [Bits-1 : 0] TimingViol_data_last;
        reg [Bits-1 : 0] TimingViol_mask_last;
	
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;
	reg ICGFlag;
        



        
       
        
        
        

        integer d, a, p, i, k, j, l;

        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;

        integer flag_error;


	assign Mreg_0 = Mreg[0];
	assign Mreg_1 = Mreg[1];
	assign Mreg_2 = Mreg[2];
	assign Mreg_3 = Mreg[3];
	assign Mreg_4 = Mreg[4];
	assign Mreg_5 = Mreg[5];
	assign Mreg_6 = Mreg[6];
	assign Mreg_7 = Mreg[7];
	assign Mreg_8 = Mreg[8];
	assign Mreg_9 = Mreg[9];
	assign Mreg_10 = Mreg[10];
	assign Mreg_11 = Mreg[11];
	assign Mreg_12 = Mreg[12];
	assign Mreg_13 = Mreg[13];
	assign Mreg_14 = Mreg[14];
	assign Mreg_15 = Mreg[15];
	assign Mreg_16 = Mreg[16];
	assign Mreg_17 = Mreg[17];
	assign Mreg_18 = Mreg[18];
	assign Mreg_19 = Mreg[19];
	assign Mreg_20 = Mreg[20];
	assign Mreg_21 = Mreg[21];
	assign Mreg_22 = Mreg[22];
	assign Mreg_23 = Mreg[23];
	assign Mreg_24 = Mreg[24];
	assign Mreg_25 = Mreg[25];
	assign Mreg_26 = Mreg[26];
	assign Mreg_27 = Mreg[27];
	assign Mreg_28 = Mreg[28];
	assign Mreg_29 = Mreg[29];
	assign Mreg_30 = Mreg[30];
	assign Mreg_31 = Mreg[31];
	assign Mreg_32 = Mreg[32];
	assign Mreg_33 = Mreg[33];
	assign Mreg_34 = Mreg[34];
	assign Mreg_35 = Mreg[35];
	assign Mreg_36 = Mreg[36];
	assign Mreg_37 = Mreg[37];
	assign Mreg_38 = Mreg[38];
	assign Mreg_39 = Mreg[39];
	assign Mreg_40 = Mreg[40];
	assign Mreg_41 = Mreg[41];
	assign Mreg_42 = Mreg[42];
	assign Mreg_43 = Mreg[43];
	assign Mreg_44 = Mreg[44];
	assign Mreg_45 = Mreg[45];
	assign Mreg_46 = Mreg[46];
	assign Mreg_47 = Mreg[47];
	assign Mreg_48 = Mreg[48];
	assign Mreg_49 = Mreg[49];
	assign Mreg_50 = Mreg[50];
	assign Mreg_51 = Mreg[51];
	assign Mreg_52 = Mreg[52];
	assign Mreg_53 = Mreg[53];
	assign Mreg_54 = Mreg[54];
	assign Mreg_55 = Mreg[55];
	assign Mreg_56 = Mreg[56];
	assign Mreg_57 = Mreg[57];
	assign Mreg_58 = Mreg[58];
	assign Mreg_59 = Mreg[59];
	assign Mreg_60 = Mreg[60];
	assign Mreg_61 = Mreg[61];
	assign Mreg_62 = Mreg[62];
	assign Mreg_63 = Mreg[63];

        //BUFFER INSTANTIATION
        //=========================
        
        buf bufdint [Bits-1:0] (Dint, D);

        buf bufmint [Bits-1:0] (Mint, M);
        
        buf bufaint [Addr-1:0] (Aint, A);
	
	buf (TBYPASS_main, TBYPASS);
	buf (CKint, CK);
        
        buf (CSNint, CSN); 
	buf (WENint, WEN);

        //TBYPASS functionality
        buf bufdeltb [Bits-1:0] (delTBYPASS, TBYPASS);
        
           
        buf bugtbdq [Bits-1:0] (TBYPASS_D_Q, D);

        
        


        
        
        

        wire RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYFlagint;
        reg RY_rfCKreg, RY_rrCKreg, RY_frCKreg; 
	reg InitialRYFlag, ICRYFlag;
        
        buf (RY_rfCK, RY_rfCKint);
	buf (RY_rrCK, RY_rrCKint);
	buf (RY_frCK, RY_frCKint); 
        
        buf (ICRY, ICRYFlagint);
        assign ICRYFlagint = ICRYFlag;
        
        
    specify
        specparam

            tdq = 0.01,
            ttmq = 0.01,
            
            taa_ry = 1.0,
            th_ry = 0.9,
            tck_ry = 1.0,
            taa = 1.0,
            th = 0.9;
        /*-------------------- Propagation Delays ------------------*/
	if (WENreg && !ICGFlag) (CK *> (Q_data[0] : D[0])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[1] : D[1])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[2] : D[2])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[3] : D[3])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[4] : D[4])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[5] : D[5])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[6] : D[6])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[7] : D[7])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[8] : D[8])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[9] : D[9])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[10] : D[10])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[11] : D[11])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[12] : D[12])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[13] : D[13])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[14] : D[14])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[15] : D[15])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[16] : D[16])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[17] : D[17])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[18] : D[18])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[19] : D[19])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[20] : D[20])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[21] : D[21])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[22] : D[22])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[23] : D[23])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[24] : D[24])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[25] : D[25])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[26] : D[26])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[27] : D[27])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[28] : D[28])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[29] : D[29])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[30] : D[30])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[31] : D[31])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[32] : D[32])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[33] : D[33])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[34] : D[34])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[35] : D[35])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[36] : D[36])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[37] : D[37])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[38] : D[38])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[39] : D[39])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[40] : D[40])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[41] : D[41])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[42] : D[42])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[43] : D[43])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[44] : D[44])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[45] : D[45])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[46] : D[46])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[47] : D[47])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[48] : D[48])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[49] : D[49])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[50] : D[50])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[51] : D[51])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[52] : D[52])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[53] : D[53])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[54] : D[54])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[55] : D[55])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[56] : D[56])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[57] : D[57])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[58] : D[58])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[59] : D[59])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[60] : D[60])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[61] : D[61])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[62] : D[62])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[63] : D[63])) = (taa, taa);

	if (!ICGFlag) (CK *> (Q_glitch[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[31] : D[31])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[32] : D[32])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[33] : D[33])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[34] : D[34])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[35] : D[35])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[36] : D[36])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[37] : D[37])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[38] : D[38])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[39] : D[39])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[40] : D[40])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[41] : D[41])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[42] : D[42])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[43] : D[43])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[44] : D[44])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[45] : D[45])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[46] : D[46])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[47] : D[47])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[48] : D[48])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[49] : D[49])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[50] : D[50])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[51] : D[51])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[52] : D[52])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[53] : D[53])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[54] : D[54])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[55] : D[55])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[56] : D[56])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[57] : D[57])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[58] : D[58])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[59] : D[59])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[60] : D[60])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[61] : D[61])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[62] : D[62])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[63] : D[63])) = (th, th);

	if (!ICGFlag) (CK *> (Q_gCK[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[31] : D[31])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[32] : D[32])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[33] : D[33])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[34] : D[34])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[35] : D[35])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[36] : D[36])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[37] : D[37])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[38] : D[38])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[39] : D[39])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[40] : D[40])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[41] : D[41])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[42] : D[42])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[43] : D[43])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[44] : D[44])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[45] : D[45])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[46] : D[46])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[47] : D[47])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[48] : D[48])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[49] : D[49])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[50] : D[50])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[51] : D[51])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[52] : D[52])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[53] : D[53])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[54] : D[54])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[55] : D[55])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[56] : D[56])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[57] : D[57])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[58] : D[58])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[59] : D[59])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[60] : D[60])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[61] : D[61])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[62] : D[62])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[63] : D[63])) = (th, th);

	if (!TBYPASS) (TBYPASS *> delTBYPASS[0]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[1]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[2]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[3]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[4]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[5]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[6]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[7]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[8]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[9]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[10]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[11]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[12]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[13]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[14]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[15]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[16]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[17]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[18]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[19]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[20]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[21]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[22]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[23]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[24]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[25]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[26]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[27]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[28]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[29]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[30]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[31]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[32]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[33]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[34]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[35]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[36]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[37]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[38]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[39]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[40]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[41]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[42]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[43]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[44]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[45]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[46]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[47]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[48]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[49]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[50]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[51]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[52]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[53]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[54]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[55]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[56]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[57]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[58]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[59]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[60]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[61]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[62]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[63]) = (0);
	if (TBYPASS) (TBYPASS *> delTBYPASS[0]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[1]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[2]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[3]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[4]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[5]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[6]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[7]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[8]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[9]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[10]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[11]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[12]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[13]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[14]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[15]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[16]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[17]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[18]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[19]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[20]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[21]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[22]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[23]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[24]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[25]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[26]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[27]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[28]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[29]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[30]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[31]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[32]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[33]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[34]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[35]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[36]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[37]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[38]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[39]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[40]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[41]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[42]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[43]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[44]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[45]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[46]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[47]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[48]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[49]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[50]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[51]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[52]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[53]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[54]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[55]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[56]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[57]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[58]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[59]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[60]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[61]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[62]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[63]) = (ttmq);
      (D[0] *> TBYPASS_D_Q[0]) = (tdq, tdq);
      (D[1] *> TBYPASS_D_Q[1]) = (tdq, tdq);
      (D[2] *> TBYPASS_D_Q[2]) = (tdq, tdq);
      (D[3] *> TBYPASS_D_Q[3]) = (tdq, tdq);
      (D[4] *> TBYPASS_D_Q[4]) = (tdq, tdq);
      (D[5] *> TBYPASS_D_Q[5]) = (tdq, tdq);
      (D[6] *> TBYPASS_D_Q[6]) = (tdq, tdq);
      (D[7] *> TBYPASS_D_Q[7]) = (tdq, tdq);
      (D[8] *> TBYPASS_D_Q[8]) = (tdq, tdq);
      (D[9] *> TBYPASS_D_Q[9]) = (tdq, tdq);
      (D[10] *> TBYPASS_D_Q[10]) = (tdq, tdq);
      (D[11] *> TBYPASS_D_Q[11]) = (tdq, tdq);
      (D[12] *> TBYPASS_D_Q[12]) = (tdq, tdq);
      (D[13] *> TBYPASS_D_Q[13]) = (tdq, tdq);
      (D[14] *> TBYPASS_D_Q[14]) = (tdq, tdq);
      (D[15] *> TBYPASS_D_Q[15]) = (tdq, tdq);
      (D[16] *> TBYPASS_D_Q[16]) = (tdq, tdq);
      (D[17] *> TBYPASS_D_Q[17]) = (tdq, tdq);
      (D[18] *> TBYPASS_D_Q[18]) = (tdq, tdq);
      (D[19] *> TBYPASS_D_Q[19]) = (tdq, tdq);
      (D[20] *> TBYPASS_D_Q[20]) = (tdq, tdq);
      (D[21] *> TBYPASS_D_Q[21]) = (tdq, tdq);
      (D[22] *> TBYPASS_D_Q[22]) = (tdq, tdq);
      (D[23] *> TBYPASS_D_Q[23]) = (tdq, tdq);
      (D[24] *> TBYPASS_D_Q[24]) = (tdq, tdq);
      (D[25] *> TBYPASS_D_Q[25]) = (tdq, tdq);
      (D[26] *> TBYPASS_D_Q[26]) = (tdq, tdq);
      (D[27] *> TBYPASS_D_Q[27]) = (tdq, tdq);
      (D[28] *> TBYPASS_D_Q[28]) = (tdq, tdq);
      (D[29] *> TBYPASS_D_Q[29]) = (tdq, tdq);
      (D[30] *> TBYPASS_D_Q[30]) = (tdq, tdq);
      (D[31] *> TBYPASS_D_Q[31]) = (tdq, tdq);
      (D[32] *> TBYPASS_D_Q[32]) = (tdq, tdq);
      (D[33] *> TBYPASS_D_Q[33]) = (tdq, tdq);
      (D[34] *> TBYPASS_D_Q[34]) = (tdq, tdq);
      (D[35] *> TBYPASS_D_Q[35]) = (tdq, tdq);
      (D[36] *> TBYPASS_D_Q[36]) = (tdq, tdq);
      (D[37] *> TBYPASS_D_Q[37]) = (tdq, tdq);
      (D[38] *> TBYPASS_D_Q[38]) = (tdq, tdq);
      (D[39] *> TBYPASS_D_Q[39]) = (tdq, tdq);
      (D[40] *> TBYPASS_D_Q[40]) = (tdq, tdq);
      (D[41] *> TBYPASS_D_Q[41]) = (tdq, tdq);
      (D[42] *> TBYPASS_D_Q[42]) = (tdq, tdq);
      (D[43] *> TBYPASS_D_Q[43]) = (tdq, tdq);
      (D[44] *> TBYPASS_D_Q[44]) = (tdq, tdq);
      (D[45] *> TBYPASS_D_Q[45]) = (tdq, tdq);
      (D[46] *> TBYPASS_D_Q[46]) = (tdq, tdq);
      (D[47] *> TBYPASS_D_Q[47]) = (tdq, tdq);
      (D[48] *> TBYPASS_D_Q[48]) = (tdq, tdq);
      (D[49] *> TBYPASS_D_Q[49]) = (tdq, tdq);
      (D[50] *> TBYPASS_D_Q[50]) = (tdq, tdq);
      (D[51] *> TBYPASS_D_Q[51]) = (tdq, tdq);
      (D[52] *> TBYPASS_D_Q[52]) = (tdq, tdq);
      (D[53] *> TBYPASS_D_Q[53]) = (tdq, tdq);
      (D[54] *> TBYPASS_D_Q[54]) = (tdq, tdq);
      (D[55] *> TBYPASS_D_Q[55]) = (tdq, tdq);
      (D[56] *> TBYPASS_D_Q[56]) = (tdq, tdq);
      (D[57] *> TBYPASS_D_Q[57]) = (tdq, tdq);
      (D[58] *> TBYPASS_D_Q[58]) = (tdq, tdq);
      (D[59] *> TBYPASS_D_Q[59]) = (tdq, tdq);
      (D[60] *> TBYPASS_D_Q[60]) = (tdq, tdq);
      (D[61] *> TBYPASS_D_Q[61]) = (tdq, tdq);
      (D[62] *> TBYPASS_D_Q[62]) = (tdq, tdq);
      (D[63] *> TBYPASS_D_Q[63]) = (tdq, tdq);


        // RY functionality
	if (!ICRY && InitialRYFlag) (CK *> RY_rfCK) = (th_ry, th_ry);
	if (!ICRY && InitialRYFlag) (CK *> RY_rrCK) = (taa_ry, taa_ry);
	if (!ICRY && InitialRYFlag) (CK *> RY_frCK) = (tck_ry, tck_ry);   

	endspecify


assign #0 Q_data = OutReg_data;
assign Q_glitch = OutReg_glitch; 
assign Q_gCK = Q_gCKreg;

    // BEHAVIOURAL MODULE DESCRIPTION



task task_insert_faults_in_memory;
begin
   if (ConfigFault)
   begin   
     Fault_in_memory = 1;
     for(i = 0;i< fcnt;i = i+ 1) begin
       if (fault_repair_flag[i] !== 1) begin
         Fault_in_memory = 0;
         if (array_stuck_at[i] === "sa0") begin
         `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data & stuck_at_0fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
         `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
         `endif
         end //if(array_stuck_at)
                                        
         if(array_stuck_at[i] === "sa1") begin
         `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data | stuck_at_1fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
         `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
         `endif
         end //if(array_stuck_at)
       end   // if(fault_repair_flag
     end    // end of for
   end  
end
endtask



task chstate;
   input [Bits-1 : 0] clkin;
   output [Bits-1 : 0] clkout;
   integer d;
begin
   if ( $realtime != 0 )
      for (d = 0; d < Bits; d = d + 1)
      begin
         if (clkin[d] === 1'b0)
            clkout[d] = 1'b1;
         else if (clkin[d] === 1'b1)
            clkout[d] = 1'bx;
         else
            clkout[d] = 1'b0;
      end
end
endtask


task WriteMemX;
begin
   for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
   task_insert_faults_in_memory;
end
endtask

task WriteLocMskX_bwise;
   input [Addr-1 : 0] Address;
   input [Bits-1 : 0] Mask;
begin
   if (^Address !== X)
   begin
      tempMem = Mem[Address];
             
      for (j = 0;j< Bits; j=j+1)
         if (Mask[j] === 1'bx)
            tempMem[j] = 1'bx;
                    
      Mem[Address] = tempMem;
      task_insert_faults_in_memory;
   end//if (^Address !== X
   else
      WriteMemX;
end
endtask
    
task WriteOutX;                
begin
   OutReg_data= WordX;
   OutReg_glitch= WordX;
end
endtask

task WriteCycle;                  
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] tempReg1,tempReg2;
   integer po,i;
begin
  
   tempReg1 = WordX;
   if (^Address !== X)
   begin
      if (ValidAddress)
      begin
         
             tempReg1 = Mem[Address];
             for (po=0;po<Bits;po=po+1)
                if (Mreg[po] === 1'b0)
                   tempReg1[po] = Dreg[po];
                else if (Mreg[po] === 1'bX)
                    tempReg1[po] = 1'bx;
                        
                Mem[Address] = tempReg1;
                     
      end //if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Write Port:  Address Out Of Range. ",$realtime);
      task_insert_faults_in_memory;
   end//if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Write Port:  Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
      
   end
   
end
endtask

task ReadCycle;
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] MemData;
   integer a;
begin

   if (ValidAddress)
      MemData = Mem[Address];

   if(ValidAddress === X)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Read Port:  Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
      MemData = WordX;
      WriteMemX;
      
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Read Port:  Address Out Of Range. Output Corrupted ",$realtime);
      MemData = WordX;
   end

   for (a = 0; a < Bits; a = a + 1)
   begin
      if (MemData[a] !== OutReg_data[a])
         OutReg_glitch[a] = WordX[a];
      else
         OutReg_glitch[a] = MemData[a];
   end//for (a = 0; a <

   OutReg_data = MemData;
   last_Qdata = Q_data;

end
endtask




assign RY_rfCKint = RY_rfCKreg;
assign RY_frCKint = RY_frCKreg;
assign RY_rrCKint = RY_rrCKreg;

// Define format for timing value
initial
begin
   $timeformat (-9, 2, " ns", 0);
   ICGFlag = 0;

   //Initialize Memory
   if (MEM_INITIALIZE === 1'b1)
   begin   
      if (BinaryInit)
         $readmemb(InitFileName, Mem, 0, Words-1);
      else
         $readmemh(InitFileName, Mem, 0, Words-1);
   end

   
   ICRYFlag = 1;
   InitialRYFlag = 0;
   ICRYFlag <= 0;
   RY_rfCKreg = 1'b1;
   RY_rrCKreg = 1'b1;
   RY_frCKreg = 1'b1;

   
   

/*  -----------Implementation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
      file_ptr = $fopen(Fault_file_name , "r");
      if(file_ptr == 0)
      begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
      end        
      else                
      begin : read_fault_file
        t = 0;
        for (i = 0; i< max_faults; i= i + 1)
        begin
         
           stuck0 = {Bits{1'b1}};
           stuck1 = {Bits{1'b0}};
           fault_char1 = $fgetc (file_ptr);
           if (fault_char1 == 8'b11111111)
              disable read_fault_file;
           ret_val = $ungetc (fault_char1, file_ptr);
           ret_val = $fgets(tempStr, file_ptr);
           ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
           flag_error = 0; 
           if(ret_val !== 0)
           begin         
              if(ret_val == 2 || ret_val == 3)
              begin
                if(ret_val == 2)
                   stuck_at = "sa0";

                if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                begin
                   if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                   flag_error = 1;
                end    
                      
                if(fault_word > Words-1)
                begin
                   if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                   flag_error = 1;
                end    

                if(fault_bit > Bits-1)
                begin  
                   if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                   flag_error = 1;
                end    

                if(flag_error == 0)
                //Correct Inputs
                begin
                   if(stuck_at === "none")
                   begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                   end
                   else
                   //Adding the faults
                   begin
                      FailureLocn[t] = fault_word;
                      std_fault_word = fault_word;
                      
                      fault_repair_flag[t] = 1'b0;
                      if (stuck_at === "sa0" )
                      begin
                         stuck0[fault_bit] = 1'b0;         
                         stuck_at_0fault[t] = stuck0;
                      end     
                      if (stuck_at === "sa1" )
                      begin
                         stuck1[fault_bit] = 1'b1;
                         stuck_at_1fault[t] = stuck1; 
                      end

                      array_stuck_at[t] = stuck_at;
                      t = t + 1;
                   end //if(stuck_at === "none")  
                end //if(flag_error == 0)
              end //if(ret_val == 2 || ret_val == 3 
              else
              //wrong number of arguments
              begin
                if(debug_level < 2)
                   $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                flag_error = 1;
              end
           end //if(ret_val !== 0)
           else
           begin
              if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
           end    
        end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);

      fcnt = t;
      
      task_insert_faults_in_memory;
   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//

always @(CKint)
begin
   lastCK = CKreg;
   CKreg = CKint;
   
   if (CKint !== 0 && CSNint !== 1)
   begin
     InitialRYFlag = 1;
   end
   
      // Unknown Clock Behaviour
      if (((CKint=== X && CSNint !==1) || (CKint=== X && CSNreg !==1 && lastCK ===1)))
      begin
         
         ICRYFlag = 1;   
         chstate(Q_gCKreg, Q_gCKreg);
	 WriteOutX;
         WriteMemX;
      end//if (((CKint===
                
   
   if (CKint===1 && lastCK ===0 && CSNint === X  )
       ICRYFlag = 1;
   else if (CKint === 1 && lastCK === 0 && CSNint === 0 )
       ICRYFlag = 0;
   

   /*---------------------- Latching signals ----------------------*/
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
      if (CSNint !== 1)
      begin
         ICGFlag = 0;
         Dreg = Dint;
         Mreg = Mint;
         WENreg = WENint;
         Areg = Aint;
         if (^Areg === X)
            ValidAddress = X;
         else if (Areg < Words)
            ValidAddress = 1;
         else
            ValidAddress = 0;

         if (ValidAddress)
            Mem_temp = Mem[Aint];
         else
            Mem_temp = WordX; 

         
      end//if (CSNint !== 1)
         
      CSNreg = CSNint;
      last_Qdata = Q_data;
      
      
   end//if(CKreg === 1'b1 && lastCK =   
     
   /*---------------------- Normal Read and Write -----------------*/

   if ((CSNreg !== 1) && (CKreg === 1 && lastCK === 0))
   begin
      if (WENreg === 1'b1 && CSNreg === 1'b0)
      begin
         ReadCycle(Areg);
         chstate(Q_gCKreg, Q_gCKreg);
      end//if (WENreg === 1 && C
      else if (WENreg === 0 && CSNreg === 0)
      begin
          
           WriteCycle(Areg);
           
      end
      /*---------- Corruption due to faulty values on signals --------*/
      else if (CSNreg === 1'bX)
      begin
         // Uncertain cycle
         if(debug_level < 2) $display("%m - %t (MSG_ID 001) WARNING: Illegal Value on Chip Select. Memory and Output Corrupted ",$realtime);
         WriteMemX;
         WriteOutX;
         chstate(Q_gCKreg, Q_gCKreg);
      end//else if (CSN === 1'bX
      else if (WENreg === X)
      begin
         // Uncertain write cycle
         if(debug_level < 2) $display("%m - %t (MSG_ID 002) WARNING: Illegal Value on Write Enable. Memory and Output Corrupted ",$realtime);
         WriteMemX;
         WriteOutX;
         chstate(Q_gCKreg, Q_gCKreg);
         
         ICRYFlag = 1;
         
      end//else if (WENreg ===
      
      

   end //if ((CSNreg !== 1) && (CKreg    
   
end // always @(CKint)

always @(CSNint)
begin   
     // Unknown Clock & CSN signal
     if (CSNint !== 1 && CKint === X )
     begin
       if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
       chstate(Q_gCKreg, Q_gCKreg);
       WriteMemX;
       WriteOutX;
       
       ICRYFlag = 1;
     end//if (CSNint !== 1
end      


 always @(TBYPASS_main)
 begin
 
      if (TBYPASS_main !== 0)
        
        ICRYFlag = 1;
      OutReg_data = WordX;
      OutReg_glitch = WordX;
    
 end


  

        /*---------------RY Functionality-----------------*/
always @(posedge CKreg)
begin

     
     if ((CSNreg === 0) && (CKreg === 1 && lastCK === 0) && TBYPASS_main === 1'b0)
     begin
       if (WENreg !== 1'bX && ValidAddress !== 1'bX)
       begin
         RY_rfCKreg = ~RY_rfCKreg;
         RY_rrCKreg = ~RY_rrCKreg;
       end
       else
         ICRYFlag = 1'b1; 
     end
     
     
end

 always @(negedge CKreg)
 begin
 
      
      if (TBYPASS_main === 1'b1)
      begin
        RY_frCKreg = ~RY_frCKreg;
        ICRYFlag = 1'b0;
      end  
      else if (TBYPASS_main === 1'b0 && (CSNreg === 0) && (CKreg === 0 && lastCK === 1))
      begin
        if (WENreg !== 1'bX && ValidAddress !== 1'bX)
           RY_frCKreg = ~RY_frCKreg;
      end
      
     
     
   
 end

always @ (TimingViol_tckl or TimingViol_tcycle or TimingViol_csn or TimingViol_tckh or TimingViol_tbypass or TimingViol_wen or TimingViol_addr  )
ICRYFlag = 1;
        /*---------------------------------*/





/*---------------TBYPASS  Functionality in functional model -----------------*/

always @(TimingViol_data)
// tds or tdh violation
begin
#0
   for (l = 0; l < Bits; l = l + 1)
   begin   
      if((TimingViol_data[l] !== TimingViol_data_last[l]))
         Mreg[l] = 1'bx;
   end   
   WriteLocMskX_bwise(Areg,Mreg);
   TimingViol_data_last = TimingViol_data;
end


        
/*---------- Corruption due to Timing Violations ---------------*/

always @(TimingViol_tckl or TimingViol_tcycle)
// tckl -  tcycle
begin
#0
   WriteOutX;
   #0.00 WriteMemX;
end

always @(TimingViol_csn)
// tps or tph
begin
#0
   CSNreg = 1'bX;
   WriteOutX;
   WriteMemX;  
   if (CSNreg === 1)
   begin
      chstate(Q_gCKreg, Q_gCKreg);
   end
end

always @(TimingViol_tckh)
// tckh
begin
#0
   ICGFlag = 1;
   chstate(Q_gCKreg, Q_gCKreg);
   WriteOutX;
   WriteMemX;
end

always @(TimingViol_addr)
// tas or tah
begin
#0
   if (WENreg !== 0)
      WriteOutX;
   WriteMemX;
   
end


always @(TimingViol_wen)
//tws or twh
begin
#0
   WriteMemX; 
   WriteOutX;
end


always @(TimingViol_tbypass)
//ttmck
begin
#0
   WriteOutX;
   WriteMemX;  
end







endmodule

module ST_SPHS_80x64m4_L_OPschlr (QINT,  RYINT, Q_gCK, Q_glitch,  Q_data, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main);

    parameter
        Words = 80,
        Bits = 64,
        Addr = 7;
        

    parameter
        WordX = 64'bx,
        AddrX = 7'bx,
        X = 1'bx;

	output [Bits-1 : 0] QINT;
	input [Bits-1 : 0] Q_glitch;
	input [Bits-1 : 0] Q_data;
	input [Bits-1 : 0] Q_gCK;
        input [Bits-1 : 0] TBYPASS_D_Q;
        input [Bits-1 : 0] delTBYPASS;
        input TBYPASS_main;
	
	integer m,a, d, n, o, p;
	wire [Bits-1 : 0] QINTint;
	wire [Bits-1 : 0] QINTERNAL;

        reg [Bits-1 : 0] OutReg;
	reg [Bits-1 : 0] lastQ_gCK, Q_gCKreg;
	reg [Bits-1 : 0] lastQ_data, Q_datareg;
	reg [Bits-1 : 0] QINTERNALreg;
	reg [Bits-1 : 0] lastQINTERNAL;

buf bufqint [Bits-1:0] (QINT, QINTint);

	assign QINTint[0] = (TBYPASS_main===0 && delTBYPASS[0]===0)?OutReg[0] : (TBYPASS_main===1 && delTBYPASS[0]===1)?TBYPASS_D_Q[0] : WordX;
	assign QINTint[1] = (TBYPASS_main===0 && delTBYPASS[1]===0)?OutReg[1] : (TBYPASS_main===1 && delTBYPASS[1]===1)?TBYPASS_D_Q[1] : WordX;
	assign QINTint[2] = (TBYPASS_main===0 && delTBYPASS[2]===0)?OutReg[2] : (TBYPASS_main===1 && delTBYPASS[2]===1)?TBYPASS_D_Q[2] : WordX;
	assign QINTint[3] = (TBYPASS_main===0 && delTBYPASS[3]===0)?OutReg[3] : (TBYPASS_main===1 && delTBYPASS[3]===1)?TBYPASS_D_Q[3] : WordX;
	assign QINTint[4] = (TBYPASS_main===0 && delTBYPASS[4]===0)?OutReg[4] : (TBYPASS_main===1 && delTBYPASS[4]===1)?TBYPASS_D_Q[4] : WordX;
	assign QINTint[5] = (TBYPASS_main===0 && delTBYPASS[5]===0)?OutReg[5] : (TBYPASS_main===1 && delTBYPASS[5]===1)?TBYPASS_D_Q[5] : WordX;
	assign QINTint[6] = (TBYPASS_main===0 && delTBYPASS[6]===0)?OutReg[6] : (TBYPASS_main===1 && delTBYPASS[6]===1)?TBYPASS_D_Q[6] : WordX;
	assign QINTint[7] = (TBYPASS_main===0 && delTBYPASS[7]===0)?OutReg[7] : (TBYPASS_main===1 && delTBYPASS[7]===1)?TBYPASS_D_Q[7] : WordX;
	assign QINTint[8] = (TBYPASS_main===0 && delTBYPASS[8]===0)?OutReg[8] : (TBYPASS_main===1 && delTBYPASS[8]===1)?TBYPASS_D_Q[8] : WordX;
	assign QINTint[9] = (TBYPASS_main===0 && delTBYPASS[9]===0)?OutReg[9] : (TBYPASS_main===1 && delTBYPASS[9]===1)?TBYPASS_D_Q[9] : WordX;
	assign QINTint[10] = (TBYPASS_main===0 && delTBYPASS[10]===0)?OutReg[10] : (TBYPASS_main===1 && delTBYPASS[10]===1)?TBYPASS_D_Q[10] : WordX;
	assign QINTint[11] = (TBYPASS_main===0 && delTBYPASS[11]===0)?OutReg[11] : (TBYPASS_main===1 && delTBYPASS[11]===1)?TBYPASS_D_Q[11] : WordX;
	assign QINTint[12] = (TBYPASS_main===0 && delTBYPASS[12]===0)?OutReg[12] : (TBYPASS_main===1 && delTBYPASS[12]===1)?TBYPASS_D_Q[12] : WordX;
	assign QINTint[13] = (TBYPASS_main===0 && delTBYPASS[13]===0)?OutReg[13] : (TBYPASS_main===1 && delTBYPASS[13]===1)?TBYPASS_D_Q[13] : WordX;
	assign QINTint[14] = (TBYPASS_main===0 && delTBYPASS[14]===0)?OutReg[14] : (TBYPASS_main===1 && delTBYPASS[14]===1)?TBYPASS_D_Q[14] : WordX;
	assign QINTint[15] = (TBYPASS_main===0 && delTBYPASS[15]===0)?OutReg[15] : (TBYPASS_main===1 && delTBYPASS[15]===1)?TBYPASS_D_Q[15] : WordX;
	assign QINTint[16] = (TBYPASS_main===0 && delTBYPASS[16]===0)?OutReg[16] : (TBYPASS_main===1 && delTBYPASS[16]===1)?TBYPASS_D_Q[16] : WordX;
	assign QINTint[17] = (TBYPASS_main===0 && delTBYPASS[17]===0)?OutReg[17] : (TBYPASS_main===1 && delTBYPASS[17]===1)?TBYPASS_D_Q[17] : WordX;
	assign QINTint[18] = (TBYPASS_main===0 && delTBYPASS[18]===0)?OutReg[18] : (TBYPASS_main===1 && delTBYPASS[18]===1)?TBYPASS_D_Q[18] : WordX;
	assign QINTint[19] = (TBYPASS_main===0 && delTBYPASS[19]===0)?OutReg[19] : (TBYPASS_main===1 && delTBYPASS[19]===1)?TBYPASS_D_Q[19] : WordX;
	assign QINTint[20] = (TBYPASS_main===0 && delTBYPASS[20]===0)?OutReg[20] : (TBYPASS_main===1 && delTBYPASS[20]===1)?TBYPASS_D_Q[20] : WordX;
	assign QINTint[21] = (TBYPASS_main===0 && delTBYPASS[21]===0)?OutReg[21] : (TBYPASS_main===1 && delTBYPASS[21]===1)?TBYPASS_D_Q[21] : WordX;
	assign QINTint[22] = (TBYPASS_main===0 && delTBYPASS[22]===0)?OutReg[22] : (TBYPASS_main===1 && delTBYPASS[22]===1)?TBYPASS_D_Q[22] : WordX;
	assign QINTint[23] = (TBYPASS_main===0 && delTBYPASS[23]===0)?OutReg[23] : (TBYPASS_main===1 && delTBYPASS[23]===1)?TBYPASS_D_Q[23] : WordX;
	assign QINTint[24] = (TBYPASS_main===0 && delTBYPASS[24]===0)?OutReg[24] : (TBYPASS_main===1 && delTBYPASS[24]===1)?TBYPASS_D_Q[24] : WordX;
	assign QINTint[25] = (TBYPASS_main===0 && delTBYPASS[25]===0)?OutReg[25] : (TBYPASS_main===1 && delTBYPASS[25]===1)?TBYPASS_D_Q[25] : WordX;
	assign QINTint[26] = (TBYPASS_main===0 && delTBYPASS[26]===0)?OutReg[26] : (TBYPASS_main===1 && delTBYPASS[26]===1)?TBYPASS_D_Q[26] : WordX;
	assign QINTint[27] = (TBYPASS_main===0 && delTBYPASS[27]===0)?OutReg[27] : (TBYPASS_main===1 && delTBYPASS[27]===1)?TBYPASS_D_Q[27] : WordX;
	assign QINTint[28] = (TBYPASS_main===0 && delTBYPASS[28]===0)?OutReg[28] : (TBYPASS_main===1 && delTBYPASS[28]===1)?TBYPASS_D_Q[28] : WordX;
	assign QINTint[29] = (TBYPASS_main===0 && delTBYPASS[29]===0)?OutReg[29] : (TBYPASS_main===1 && delTBYPASS[29]===1)?TBYPASS_D_Q[29] : WordX;
	assign QINTint[30] = (TBYPASS_main===0 && delTBYPASS[30]===0)?OutReg[30] : (TBYPASS_main===1 && delTBYPASS[30]===1)?TBYPASS_D_Q[30] : WordX;
	assign QINTint[31] = (TBYPASS_main===0 && delTBYPASS[31]===0)?OutReg[31] : (TBYPASS_main===1 && delTBYPASS[31]===1)?TBYPASS_D_Q[31] : WordX;
	assign QINTint[32] = (TBYPASS_main===0 && delTBYPASS[32]===0)?OutReg[32] : (TBYPASS_main===1 && delTBYPASS[32]===1)?TBYPASS_D_Q[32] : WordX;
	assign QINTint[33] = (TBYPASS_main===0 && delTBYPASS[33]===0)?OutReg[33] : (TBYPASS_main===1 && delTBYPASS[33]===1)?TBYPASS_D_Q[33] : WordX;
	assign QINTint[34] = (TBYPASS_main===0 && delTBYPASS[34]===0)?OutReg[34] : (TBYPASS_main===1 && delTBYPASS[34]===1)?TBYPASS_D_Q[34] : WordX;
	assign QINTint[35] = (TBYPASS_main===0 && delTBYPASS[35]===0)?OutReg[35] : (TBYPASS_main===1 && delTBYPASS[35]===1)?TBYPASS_D_Q[35] : WordX;
	assign QINTint[36] = (TBYPASS_main===0 && delTBYPASS[36]===0)?OutReg[36] : (TBYPASS_main===1 && delTBYPASS[36]===1)?TBYPASS_D_Q[36] : WordX;
	assign QINTint[37] = (TBYPASS_main===0 && delTBYPASS[37]===0)?OutReg[37] : (TBYPASS_main===1 && delTBYPASS[37]===1)?TBYPASS_D_Q[37] : WordX;
	assign QINTint[38] = (TBYPASS_main===0 && delTBYPASS[38]===0)?OutReg[38] : (TBYPASS_main===1 && delTBYPASS[38]===1)?TBYPASS_D_Q[38] : WordX;
	assign QINTint[39] = (TBYPASS_main===0 && delTBYPASS[39]===0)?OutReg[39] : (TBYPASS_main===1 && delTBYPASS[39]===1)?TBYPASS_D_Q[39] : WordX;
	assign QINTint[40] = (TBYPASS_main===0 && delTBYPASS[40]===0)?OutReg[40] : (TBYPASS_main===1 && delTBYPASS[40]===1)?TBYPASS_D_Q[40] : WordX;
	assign QINTint[41] = (TBYPASS_main===0 && delTBYPASS[41]===0)?OutReg[41] : (TBYPASS_main===1 && delTBYPASS[41]===1)?TBYPASS_D_Q[41] : WordX;
	assign QINTint[42] = (TBYPASS_main===0 && delTBYPASS[42]===0)?OutReg[42] : (TBYPASS_main===1 && delTBYPASS[42]===1)?TBYPASS_D_Q[42] : WordX;
	assign QINTint[43] = (TBYPASS_main===0 && delTBYPASS[43]===0)?OutReg[43] : (TBYPASS_main===1 && delTBYPASS[43]===1)?TBYPASS_D_Q[43] : WordX;
	assign QINTint[44] = (TBYPASS_main===0 && delTBYPASS[44]===0)?OutReg[44] : (TBYPASS_main===1 && delTBYPASS[44]===1)?TBYPASS_D_Q[44] : WordX;
	assign QINTint[45] = (TBYPASS_main===0 && delTBYPASS[45]===0)?OutReg[45] : (TBYPASS_main===1 && delTBYPASS[45]===1)?TBYPASS_D_Q[45] : WordX;
	assign QINTint[46] = (TBYPASS_main===0 && delTBYPASS[46]===0)?OutReg[46] : (TBYPASS_main===1 && delTBYPASS[46]===1)?TBYPASS_D_Q[46] : WordX;
	assign QINTint[47] = (TBYPASS_main===0 && delTBYPASS[47]===0)?OutReg[47] : (TBYPASS_main===1 && delTBYPASS[47]===1)?TBYPASS_D_Q[47] : WordX;
	assign QINTint[48] = (TBYPASS_main===0 && delTBYPASS[48]===0)?OutReg[48] : (TBYPASS_main===1 && delTBYPASS[48]===1)?TBYPASS_D_Q[48] : WordX;
	assign QINTint[49] = (TBYPASS_main===0 && delTBYPASS[49]===0)?OutReg[49] : (TBYPASS_main===1 && delTBYPASS[49]===1)?TBYPASS_D_Q[49] : WordX;
	assign QINTint[50] = (TBYPASS_main===0 && delTBYPASS[50]===0)?OutReg[50] : (TBYPASS_main===1 && delTBYPASS[50]===1)?TBYPASS_D_Q[50] : WordX;
	assign QINTint[51] = (TBYPASS_main===0 && delTBYPASS[51]===0)?OutReg[51] : (TBYPASS_main===1 && delTBYPASS[51]===1)?TBYPASS_D_Q[51] : WordX;
	assign QINTint[52] = (TBYPASS_main===0 && delTBYPASS[52]===0)?OutReg[52] : (TBYPASS_main===1 && delTBYPASS[52]===1)?TBYPASS_D_Q[52] : WordX;
	assign QINTint[53] = (TBYPASS_main===0 && delTBYPASS[53]===0)?OutReg[53] : (TBYPASS_main===1 && delTBYPASS[53]===1)?TBYPASS_D_Q[53] : WordX;
	assign QINTint[54] = (TBYPASS_main===0 && delTBYPASS[54]===0)?OutReg[54] : (TBYPASS_main===1 && delTBYPASS[54]===1)?TBYPASS_D_Q[54] : WordX;
	assign QINTint[55] = (TBYPASS_main===0 && delTBYPASS[55]===0)?OutReg[55] : (TBYPASS_main===1 && delTBYPASS[55]===1)?TBYPASS_D_Q[55] : WordX;
	assign QINTint[56] = (TBYPASS_main===0 && delTBYPASS[56]===0)?OutReg[56] : (TBYPASS_main===1 && delTBYPASS[56]===1)?TBYPASS_D_Q[56] : WordX;
	assign QINTint[57] = (TBYPASS_main===0 && delTBYPASS[57]===0)?OutReg[57] : (TBYPASS_main===1 && delTBYPASS[57]===1)?TBYPASS_D_Q[57] : WordX;
	assign QINTint[58] = (TBYPASS_main===0 && delTBYPASS[58]===0)?OutReg[58] : (TBYPASS_main===1 && delTBYPASS[58]===1)?TBYPASS_D_Q[58] : WordX;
	assign QINTint[59] = (TBYPASS_main===0 && delTBYPASS[59]===0)?OutReg[59] : (TBYPASS_main===1 && delTBYPASS[59]===1)?TBYPASS_D_Q[59] : WordX;
	assign QINTint[60] = (TBYPASS_main===0 && delTBYPASS[60]===0)?OutReg[60] : (TBYPASS_main===1 && delTBYPASS[60]===1)?TBYPASS_D_Q[60] : WordX;
	assign QINTint[61] = (TBYPASS_main===0 && delTBYPASS[61]===0)?OutReg[61] : (TBYPASS_main===1 && delTBYPASS[61]===1)?TBYPASS_D_Q[61] : WordX;
	assign QINTint[62] = (TBYPASS_main===0 && delTBYPASS[62]===0)?OutReg[62] : (TBYPASS_main===1 && delTBYPASS[62]===1)?TBYPASS_D_Q[62] : WordX;
	assign QINTint[63] = (TBYPASS_main===0 && delTBYPASS[63]===0)?OutReg[63] : (TBYPASS_main===1 && delTBYPASS[63]===1)?TBYPASS_D_Q[63] : WordX;
assign QINTERNAL = QINTERNALreg;

always @ (TBYPASS_main)
begin
if (TBYPASS_main === 0 || TBYPASS_main === X) 
     QINTERNALreg = WordX;
end


        
/*------------------ RY functionality -----------------*/
       output RYINT;
        input RY_rfCK, RY_rrCK, RY_frCK, ICRY;
        wire RYINTint;
        reg RYINTreg, RYRiseFlag;

        buf (RYINT, RYINTint);

assign RYINTint = RYINTreg;
        
initial
begin
   RYRiseFlag = 1'b0;
   RYINTreg = 1'b1;
end

always @(ICRY)
begin
   if($realtime == 0)
      RYINTreg = 1'b1;
   else
      RYINTreg = 1'bx;
end

always @(RY_rfCK)
   if (ICRY !== 1)
   begin
      if ($realtime != 0)
      begin   
         RYINTreg = 0;
         RYRiseFlag=0;
      end   
   end


always @(RY_rrCK) 
#0 
   if (ICRY !== 1 && $realtime != 0)
   begin
      if (RYRiseFlag === 0)
      begin
         RYRiseFlag=1;
      end
      else
      begin
         RYINTreg = 1'b1;
         RYRiseFlag=0;
      end
   end


always @(RY_frCK)         
   if (ICRY !== 1 && $realtime != 0)
   begin
      if (RYRiseFlag === 0)
      begin
         RYRiseFlag=1;
      end
      else
      begin
         RYINTreg = 1'b1;
         RYRiseFlag=0;
      end
   end   

/*------------------------------------------------ */

always @(Q_gCK)
begin
#0  //This has been used for removing races during hold time vilations in MODELSIM simulator.
   lastQ_gCK = Q_gCKreg;
   Q_gCKreg <= Q_gCK;
   for (m = 0; m < Bits; m = m + 1)
   begin
      if (lastQ_gCK[m] !== Q_gCK[m])
      begin
        lastQINTERNAL[m] = QINTERNALreg[m];
        QINTERNALreg[m] = Q_glitch[m];
      end
   end
end

always @(Q_data)
begin
#0  //This has been used for removing races during hold time vilations in MODELSIM simulator.
    lastQ_data = Q_datareg;
    Q_datareg <= Q_data;
    for (n = 0; n < Bits; n = n + 1)
    begin
      if (lastQ_data[n] !== Q_data[n])
      begin
       	lastQINTERNAL[n] = QINTERNALreg[n];
        QINTERNALreg[n] = Q_data[n];
      end
    end
end

always @(QINTERNAL)
begin
   for (d = 0; d < Bits; d = d + 1)
   begin
      if (OutReg[d] !== QINTERNAL[d])
         OutReg[d] = QINTERNAL[d];
   end
end



endmodule



module ST_SPHS_80x64m4_L (Q, RY, CK, CSN, TBYPASS, WEN,  A,  D   );


    parameter 
        Corruption_Read_Violation = 1,
        Fault_file_name = "ST_SPHS_80x64m4_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20;
   
    // Parameters for Memory Initialization at 0 ns
    parameter 
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHS_80x64m4_L.cde",
        InstancePath = "ST_SPHS_80x64m4_L",
        Debug_mode = "all_warning_mode";
    
    parameter
        Words = 80,
        Bits = 64,
        Addr = 7,
        mux = 4;




   
    parameter
        Rows = Words/mux,
        WordX = 64'bx,
        AddrX = 7'bx,
        Word0 = 64'b0,
        X = 1'bx;

        
         
    // INPUT OUTPUT PORTS
    //  ======================

    output [Bits-1 : 0] Q;
    
    output RY;   
    input CK;
    input CSN;
    input WEN;
    input TBYPASS;
    input [Addr-1 : 0] A;
    input [Bits-1 : 0] D;
    
    


   

     

   // WIRE DECLARATIONS
   //======================
   
   wire [Bits-1 : 0] Q_glitchint;
   wire [Bits-1 : 0] Q_dataint;
   wire [Bits-1 : 0] Dint,Mint;
   wire [Addr-1 : 0] Aint;
   wire [Bits-1 : 0] Q_gCKint;
   wire CKint;
   wire CSNint;
   wire WENint;
   wire TBYPASSint;
   wire TBYPASS_mainint;
   wire [Bits-1 : 0]  TBYPASS_D_Qint;
   wire [Bits-1 : 0]  delTBYPASSint;




   wire [Bits-1 : 0] Qint, Q_out;
   
   
   

   //REG DECLARATIONS
   //======================

   reg [Bits-1 : 0] Dreg,Mreg;
   reg [Addr-1 : 0] Areg;
   reg CKreg;
   reg CSNreg;
   reg WENreg;
	
   reg [Bits-1 : 0] TimingViol_data, TimingViol_mask;
   reg [Bits-1 : 0] TimingViol_data_last, TimingViol_mask_last;
	reg TimingViol_data_0, TimingViol_mask_0;
	reg TimingViol_data_1, TimingViol_mask_1;
	reg TimingViol_data_2, TimingViol_mask_2;
	reg TimingViol_data_3, TimingViol_mask_3;
	reg TimingViol_data_4, TimingViol_mask_4;
	reg TimingViol_data_5, TimingViol_mask_5;
	reg TimingViol_data_6, TimingViol_mask_6;
	reg TimingViol_data_7, TimingViol_mask_7;
	reg TimingViol_data_8, TimingViol_mask_8;
	reg TimingViol_data_9, TimingViol_mask_9;
	reg TimingViol_data_10, TimingViol_mask_10;
	reg TimingViol_data_11, TimingViol_mask_11;
	reg TimingViol_data_12, TimingViol_mask_12;
	reg TimingViol_data_13, TimingViol_mask_13;
	reg TimingViol_data_14, TimingViol_mask_14;
	reg TimingViol_data_15, TimingViol_mask_15;
	reg TimingViol_data_16, TimingViol_mask_16;
	reg TimingViol_data_17, TimingViol_mask_17;
	reg TimingViol_data_18, TimingViol_mask_18;
	reg TimingViol_data_19, TimingViol_mask_19;
	reg TimingViol_data_20, TimingViol_mask_20;
	reg TimingViol_data_21, TimingViol_mask_21;
	reg TimingViol_data_22, TimingViol_mask_22;
	reg TimingViol_data_23, TimingViol_mask_23;
	reg TimingViol_data_24, TimingViol_mask_24;
	reg TimingViol_data_25, TimingViol_mask_25;
	reg TimingViol_data_26, TimingViol_mask_26;
	reg TimingViol_data_27, TimingViol_mask_27;
	reg TimingViol_data_28, TimingViol_mask_28;
	reg TimingViol_data_29, TimingViol_mask_29;
	reg TimingViol_data_30, TimingViol_mask_30;
	reg TimingViol_data_31, TimingViol_mask_31;
	reg TimingViol_data_32, TimingViol_mask_32;
	reg TimingViol_data_33, TimingViol_mask_33;
	reg TimingViol_data_34, TimingViol_mask_34;
	reg TimingViol_data_35, TimingViol_mask_35;
	reg TimingViol_data_36, TimingViol_mask_36;
	reg TimingViol_data_37, TimingViol_mask_37;
	reg TimingViol_data_38, TimingViol_mask_38;
	reg TimingViol_data_39, TimingViol_mask_39;
	reg TimingViol_data_40, TimingViol_mask_40;
	reg TimingViol_data_41, TimingViol_mask_41;
	reg TimingViol_data_42, TimingViol_mask_42;
	reg TimingViol_data_43, TimingViol_mask_43;
	reg TimingViol_data_44, TimingViol_mask_44;
	reg TimingViol_data_45, TimingViol_mask_45;
	reg TimingViol_data_46, TimingViol_mask_46;
	reg TimingViol_data_47, TimingViol_mask_47;
	reg TimingViol_data_48, TimingViol_mask_48;
	reg TimingViol_data_49, TimingViol_mask_49;
	reg TimingViol_data_50, TimingViol_mask_50;
	reg TimingViol_data_51, TimingViol_mask_51;
	reg TimingViol_data_52, TimingViol_mask_52;
	reg TimingViol_data_53, TimingViol_mask_53;
	reg TimingViol_data_54, TimingViol_mask_54;
	reg TimingViol_data_55, TimingViol_mask_55;
	reg TimingViol_data_56, TimingViol_mask_56;
	reg TimingViol_data_57, TimingViol_mask_57;
	reg TimingViol_data_58, TimingViol_mask_58;
	reg TimingViol_data_59, TimingViol_mask_59;
	reg TimingViol_data_60, TimingViol_mask_60;
	reg TimingViol_data_61, TimingViol_mask_61;
	reg TimingViol_data_62, TimingViol_mask_62;
	reg TimingViol_data_63, TimingViol_mask_63;
   reg TimingViol_addr;
   reg TimingViol_csn, TimingViol_wen, TimingViol_tbypass;
   reg TimingViol_tckh, TimingViol_tckl, TimingViol_tcycle;
   




   wire [Bits-1 : 0] MEN,CSWEMTBYPASS;
   wire CSTBYPASSN, CSWETBYPASSN,CS;

   /* This register is used to force all warning messages 
   ** OFF during run time.
   ** 
   */ 
   reg [1:0] debug_level;
   reg [8*10: 0] operating_mode;
   reg [8*44: 0] message_status;


initial
begin
  debug_level = 2'b0;
  message_status = "All Messages are Switched ON";
    
  
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
     message_status = "All Messages are Switched OFF"; 
  `endif 
if(debug_level !== 2'b10) begin
   $display ("%m  INFORMATION");
   $display ("***************************************");
   $display ("The Model is Operating in TIMING MODE");
   $display ("Please make sure that SDF is properly annotated otherwise dummy values will be used");
   $display ("%s", message_status);
   if(ConfigFault)
   $display ("Configurable Fault Functionality is ON");   
   else
   $display ("Configurable Fault Functionality is OFF");
   
   $display ("***************************************");
end     
end     

   
   // BUF DECLARATIONS
   //=====================
   
   buf (CKint, CK);
   or (CSNint, CSN, TBYPASSint);
   buf (TBYPASSint, TBYPASS);
   buf (WENint, WEN);
   buf bufDint [Bits-1:0] (Dint, D);
   
   assign Mint = 64'b0;
   
   buf bufAint [Addr-1:0] (Aint, A);


   assign Q =  Qint;




   


    wire  RYint, RY_rfCKint, RY_rrCKint, RY_frCKint, RY_out;
    reg RY_outreg; 
    assign RY_out = RY_outreg;
    assign RY =   RY_out;
    always @ (RYint)
    begin
       RY_outreg = RYint;
    end

        
    // Only include timing checks during behavioural modelling


    
    assign CS =  CSN;
    or (CSWETBYPASSN, WENint, CSNint);
    or (CSNTBY, CSN, TBYPASSint);  


        
 or (CSWEMTBYPASS[0], Mint[0], CSWETBYPASSN);
 or (CSWEMTBYPASS[1], Mint[1], CSWETBYPASSN);
 or (CSWEMTBYPASS[2], Mint[2], CSWETBYPASSN);
 or (CSWEMTBYPASS[3], Mint[3], CSWETBYPASSN);
 or (CSWEMTBYPASS[4], Mint[4], CSWETBYPASSN);
 or (CSWEMTBYPASS[5], Mint[5], CSWETBYPASSN);
 or (CSWEMTBYPASS[6], Mint[6], CSWETBYPASSN);
 or (CSWEMTBYPASS[7], Mint[7], CSWETBYPASSN);
 or (CSWEMTBYPASS[8], Mint[8], CSWETBYPASSN);
 or (CSWEMTBYPASS[9], Mint[9], CSWETBYPASSN);
 or (CSWEMTBYPASS[10], Mint[10], CSWETBYPASSN);
 or (CSWEMTBYPASS[11], Mint[11], CSWETBYPASSN);
 or (CSWEMTBYPASS[12], Mint[12], CSWETBYPASSN);
 or (CSWEMTBYPASS[13], Mint[13], CSWETBYPASSN);
 or (CSWEMTBYPASS[14], Mint[14], CSWETBYPASSN);
 or (CSWEMTBYPASS[15], Mint[15], CSWETBYPASSN);
 or (CSWEMTBYPASS[16], Mint[16], CSWETBYPASSN);
 or (CSWEMTBYPASS[17], Mint[17], CSWETBYPASSN);
 or (CSWEMTBYPASS[18], Mint[18], CSWETBYPASSN);
 or (CSWEMTBYPASS[19], Mint[19], CSWETBYPASSN);
 or (CSWEMTBYPASS[20], Mint[20], CSWETBYPASSN);
 or (CSWEMTBYPASS[21], Mint[21], CSWETBYPASSN);
 or (CSWEMTBYPASS[22], Mint[22], CSWETBYPASSN);
 or (CSWEMTBYPASS[23], Mint[23], CSWETBYPASSN);
 or (CSWEMTBYPASS[24], Mint[24], CSWETBYPASSN);
 or (CSWEMTBYPASS[25], Mint[25], CSWETBYPASSN);
 or (CSWEMTBYPASS[26], Mint[26], CSWETBYPASSN);
 or (CSWEMTBYPASS[27], Mint[27], CSWETBYPASSN);
 or (CSWEMTBYPASS[28], Mint[28], CSWETBYPASSN);
 or (CSWEMTBYPASS[29], Mint[29], CSWETBYPASSN);
 or (CSWEMTBYPASS[30], Mint[30], CSWETBYPASSN);
 or (CSWEMTBYPASS[31], Mint[31], CSWETBYPASSN);
 or (CSWEMTBYPASS[32], Mint[32], CSWETBYPASSN);
 or (CSWEMTBYPASS[33], Mint[33], CSWETBYPASSN);
 or (CSWEMTBYPASS[34], Mint[34], CSWETBYPASSN);
 or (CSWEMTBYPASS[35], Mint[35], CSWETBYPASSN);
 or (CSWEMTBYPASS[36], Mint[36], CSWETBYPASSN);
 or (CSWEMTBYPASS[37], Mint[37], CSWETBYPASSN);
 or (CSWEMTBYPASS[38], Mint[38], CSWETBYPASSN);
 or (CSWEMTBYPASS[39], Mint[39], CSWETBYPASSN);
 or (CSWEMTBYPASS[40], Mint[40], CSWETBYPASSN);
 or (CSWEMTBYPASS[41], Mint[41], CSWETBYPASSN);
 or (CSWEMTBYPASS[42], Mint[42], CSWETBYPASSN);
 or (CSWEMTBYPASS[43], Mint[43], CSWETBYPASSN);
 or (CSWEMTBYPASS[44], Mint[44], CSWETBYPASSN);
 or (CSWEMTBYPASS[45], Mint[45], CSWETBYPASSN);
 or (CSWEMTBYPASS[46], Mint[46], CSWETBYPASSN);
 or (CSWEMTBYPASS[47], Mint[47], CSWETBYPASSN);
 or (CSWEMTBYPASS[48], Mint[48], CSWETBYPASSN);
 or (CSWEMTBYPASS[49], Mint[49], CSWETBYPASSN);
 or (CSWEMTBYPASS[50], Mint[50], CSWETBYPASSN);
 or (CSWEMTBYPASS[51], Mint[51], CSWETBYPASSN);
 or (CSWEMTBYPASS[52], Mint[52], CSWETBYPASSN);
 or (CSWEMTBYPASS[53], Mint[53], CSWETBYPASSN);
 or (CSWEMTBYPASS[54], Mint[54], CSWETBYPASSN);
 or (CSWEMTBYPASS[55], Mint[55], CSWETBYPASSN);
 or (CSWEMTBYPASS[56], Mint[56], CSWETBYPASSN);
 or (CSWEMTBYPASS[57], Mint[57], CSWETBYPASSN);
 or (CSWEMTBYPASS[58], Mint[58], CSWETBYPASSN);
 or (CSWEMTBYPASS[59], Mint[59], CSWETBYPASSN);
 or (CSWEMTBYPASS[60], Mint[60], CSWETBYPASSN);
 or (CSWEMTBYPASS[61], Mint[61], CSWETBYPASSN);
 or (CSWEMTBYPASS[62], Mint[62], CSWETBYPASSN);
 or (CSWEMTBYPASS[63], Mint[63], CSWETBYPASSN);

    specify
    specparam


         tckl_tck_ry = 0.00,
         tcycle_taa_ry = 0.00,

         
         
	 tms = 0.0,
         tmh = 0.0,
         tcycle = 0.0,
         tckh = 0.0,
         tckl = 0.0,
         ttms = 0.0,
         ttmh = 0.0,
         tps = 0.0,
         tph = 0.0,
         tws = 0.0,
         twh = 0.0,
         tas = 0.0,
         tah = 0.0,
         tds = 0.0,
         tdh = 0.0;
        /*---------------------- Timing Checks ---------------------*/

	$setup(posedge A[0], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[1], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[2], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[3], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[4], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[5], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(posedge A[6], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[0], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[1], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[2], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[3], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[4], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[5], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$setup(negedge A[6], posedge CK &&& (CSNint != 1), tas, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[0], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[1], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[2], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[3], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[4], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[5], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), posedge A[6], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[0], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[1], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[2], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[3], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[4], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[5], tah, TimingViol_addr);
	$hold(posedge CK &&& (CSNint != 1), negedge A[6], tah, TimingViol_addr);
	$setup(posedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 1), tds, TimingViol_data_0);
	$setup(posedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 1), tds, TimingViol_data_1);
	$setup(posedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 1), tds, TimingViol_data_2);
	$setup(posedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 1), tds, TimingViol_data_3);
	$setup(posedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 1), tds, TimingViol_data_4);
	$setup(posedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 1), tds, TimingViol_data_5);
	$setup(posedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 1), tds, TimingViol_data_6);
	$setup(posedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 1), tds, TimingViol_data_7);
	$setup(posedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 1), tds, TimingViol_data_8);
	$setup(posedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 1), tds, TimingViol_data_9);
	$setup(posedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 1), tds, TimingViol_data_10);
	$setup(posedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 1), tds, TimingViol_data_11);
	$setup(posedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 1), tds, TimingViol_data_12);
	$setup(posedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 1), tds, TimingViol_data_13);
	$setup(posedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 1), tds, TimingViol_data_14);
	$setup(posedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 1), tds, TimingViol_data_15);
	$setup(posedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 1), tds, TimingViol_data_16);
	$setup(posedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 1), tds, TimingViol_data_17);
	$setup(posedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 1), tds, TimingViol_data_18);
	$setup(posedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 1), tds, TimingViol_data_19);
	$setup(posedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 1), tds, TimingViol_data_20);
	$setup(posedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 1), tds, TimingViol_data_21);
	$setup(posedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 1), tds, TimingViol_data_22);
	$setup(posedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 1), tds, TimingViol_data_23);
	$setup(posedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 1), tds, TimingViol_data_24);
	$setup(posedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 1), tds, TimingViol_data_25);
	$setup(posedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 1), tds, TimingViol_data_26);
	$setup(posedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 1), tds, TimingViol_data_27);
	$setup(posedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 1), tds, TimingViol_data_28);
	$setup(posedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 1), tds, TimingViol_data_29);
	$setup(posedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 1), tds, TimingViol_data_30);
	$setup(posedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 1), tds, TimingViol_data_31);
	$setup(posedge D[32], posedge CK &&& (CSWEMTBYPASS[32] != 1), tds, TimingViol_data_32);
	$setup(posedge D[33], posedge CK &&& (CSWEMTBYPASS[33] != 1), tds, TimingViol_data_33);
	$setup(posedge D[34], posedge CK &&& (CSWEMTBYPASS[34] != 1), tds, TimingViol_data_34);
	$setup(posedge D[35], posedge CK &&& (CSWEMTBYPASS[35] != 1), tds, TimingViol_data_35);
	$setup(posedge D[36], posedge CK &&& (CSWEMTBYPASS[36] != 1), tds, TimingViol_data_36);
	$setup(posedge D[37], posedge CK &&& (CSWEMTBYPASS[37] != 1), tds, TimingViol_data_37);
	$setup(posedge D[38], posedge CK &&& (CSWEMTBYPASS[38] != 1), tds, TimingViol_data_38);
	$setup(posedge D[39], posedge CK &&& (CSWEMTBYPASS[39] != 1), tds, TimingViol_data_39);
	$setup(posedge D[40], posedge CK &&& (CSWEMTBYPASS[40] != 1), tds, TimingViol_data_40);
	$setup(posedge D[41], posedge CK &&& (CSWEMTBYPASS[41] != 1), tds, TimingViol_data_41);
	$setup(posedge D[42], posedge CK &&& (CSWEMTBYPASS[42] != 1), tds, TimingViol_data_42);
	$setup(posedge D[43], posedge CK &&& (CSWEMTBYPASS[43] != 1), tds, TimingViol_data_43);
	$setup(posedge D[44], posedge CK &&& (CSWEMTBYPASS[44] != 1), tds, TimingViol_data_44);
	$setup(posedge D[45], posedge CK &&& (CSWEMTBYPASS[45] != 1), tds, TimingViol_data_45);
	$setup(posedge D[46], posedge CK &&& (CSWEMTBYPASS[46] != 1), tds, TimingViol_data_46);
	$setup(posedge D[47], posedge CK &&& (CSWEMTBYPASS[47] != 1), tds, TimingViol_data_47);
	$setup(posedge D[48], posedge CK &&& (CSWEMTBYPASS[48] != 1), tds, TimingViol_data_48);
	$setup(posedge D[49], posedge CK &&& (CSWEMTBYPASS[49] != 1), tds, TimingViol_data_49);
	$setup(posedge D[50], posedge CK &&& (CSWEMTBYPASS[50] != 1), tds, TimingViol_data_50);
	$setup(posedge D[51], posedge CK &&& (CSWEMTBYPASS[51] != 1), tds, TimingViol_data_51);
	$setup(posedge D[52], posedge CK &&& (CSWEMTBYPASS[52] != 1), tds, TimingViol_data_52);
	$setup(posedge D[53], posedge CK &&& (CSWEMTBYPASS[53] != 1), tds, TimingViol_data_53);
	$setup(posedge D[54], posedge CK &&& (CSWEMTBYPASS[54] != 1), tds, TimingViol_data_54);
	$setup(posedge D[55], posedge CK &&& (CSWEMTBYPASS[55] != 1), tds, TimingViol_data_55);
	$setup(posedge D[56], posedge CK &&& (CSWEMTBYPASS[56] != 1), tds, TimingViol_data_56);
	$setup(posedge D[57], posedge CK &&& (CSWEMTBYPASS[57] != 1), tds, TimingViol_data_57);
	$setup(posedge D[58], posedge CK &&& (CSWEMTBYPASS[58] != 1), tds, TimingViol_data_58);
	$setup(posedge D[59], posedge CK &&& (CSWEMTBYPASS[59] != 1), tds, TimingViol_data_59);
	$setup(posedge D[60], posedge CK &&& (CSWEMTBYPASS[60] != 1), tds, TimingViol_data_60);
	$setup(posedge D[61], posedge CK &&& (CSWEMTBYPASS[61] != 1), tds, TimingViol_data_61);
	$setup(posedge D[62], posedge CK &&& (CSWEMTBYPASS[62] != 1), tds, TimingViol_data_62);
	$setup(posedge D[63], posedge CK &&& (CSWEMTBYPASS[63] != 1), tds, TimingViol_data_63);
	$setup(negedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 1), tds, TimingViol_data_0);
	$setup(negedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 1), tds, TimingViol_data_1);
	$setup(negedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 1), tds, TimingViol_data_2);
	$setup(negedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 1), tds, TimingViol_data_3);
	$setup(negedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 1), tds, TimingViol_data_4);
	$setup(negedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 1), tds, TimingViol_data_5);
	$setup(negedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 1), tds, TimingViol_data_6);
	$setup(negedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 1), tds, TimingViol_data_7);
	$setup(negedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 1), tds, TimingViol_data_8);
	$setup(negedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 1), tds, TimingViol_data_9);
	$setup(negedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 1), tds, TimingViol_data_10);
	$setup(negedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 1), tds, TimingViol_data_11);
	$setup(negedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 1), tds, TimingViol_data_12);
	$setup(negedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 1), tds, TimingViol_data_13);
	$setup(negedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 1), tds, TimingViol_data_14);
	$setup(negedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 1), tds, TimingViol_data_15);
	$setup(negedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 1), tds, TimingViol_data_16);
	$setup(negedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 1), tds, TimingViol_data_17);
	$setup(negedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 1), tds, TimingViol_data_18);
	$setup(negedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 1), tds, TimingViol_data_19);
	$setup(negedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 1), tds, TimingViol_data_20);
	$setup(negedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 1), tds, TimingViol_data_21);
	$setup(negedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 1), tds, TimingViol_data_22);
	$setup(negedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 1), tds, TimingViol_data_23);
	$setup(negedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 1), tds, TimingViol_data_24);
	$setup(negedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 1), tds, TimingViol_data_25);
	$setup(negedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 1), tds, TimingViol_data_26);
	$setup(negedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 1), tds, TimingViol_data_27);
	$setup(negedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 1), tds, TimingViol_data_28);
	$setup(negedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 1), tds, TimingViol_data_29);
	$setup(negedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 1), tds, TimingViol_data_30);
	$setup(negedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 1), tds, TimingViol_data_31);
	$setup(negedge D[32], posedge CK &&& (CSWEMTBYPASS[32] != 1), tds, TimingViol_data_32);
	$setup(negedge D[33], posedge CK &&& (CSWEMTBYPASS[33] != 1), tds, TimingViol_data_33);
	$setup(negedge D[34], posedge CK &&& (CSWEMTBYPASS[34] != 1), tds, TimingViol_data_34);
	$setup(negedge D[35], posedge CK &&& (CSWEMTBYPASS[35] != 1), tds, TimingViol_data_35);
	$setup(negedge D[36], posedge CK &&& (CSWEMTBYPASS[36] != 1), tds, TimingViol_data_36);
	$setup(negedge D[37], posedge CK &&& (CSWEMTBYPASS[37] != 1), tds, TimingViol_data_37);
	$setup(negedge D[38], posedge CK &&& (CSWEMTBYPASS[38] != 1), tds, TimingViol_data_38);
	$setup(negedge D[39], posedge CK &&& (CSWEMTBYPASS[39] != 1), tds, TimingViol_data_39);
	$setup(negedge D[40], posedge CK &&& (CSWEMTBYPASS[40] != 1), tds, TimingViol_data_40);
	$setup(negedge D[41], posedge CK &&& (CSWEMTBYPASS[41] != 1), tds, TimingViol_data_41);
	$setup(negedge D[42], posedge CK &&& (CSWEMTBYPASS[42] != 1), tds, TimingViol_data_42);
	$setup(negedge D[43], posedge CK &&& (CSWEMTBYPASS[43] != 1), tds, TimingViol_data_43);
	$setup(negedge D[44], posedge CK &&& (CSWEMTBYPASS[44] != 1), tds, TimingViol_data_44);
	$setup(negedge D[45], posedge CK &&& (CSWEMTBYPASS[45] != 1), tds, TimingViol_data_45);
	$setup(negedge D[46], posedge CK &&& (CSWEMTBYPASS[46] != 1), tds, TimingViol_data_46);
	$setup(negedge D[47], posedge CK &&& (CSWEMTBYPASS[47] != 1), tds, TimingViol_data_47);
	$setup(negedge D[48], posedge CK &&& (CSWEMTBYPASS[48] != 1), tds, TimingViol_data_48);
	$setup(negedge D[49], posedge CK &&& (CSWEMTBYPASS[49] != 1), tds, TimingViol_data_49);
	$setup(negedge D[50], posedge CK &&& (CSWEMTBYPASS[50] != 1), tds, TimingViol_data_50);
	$setup(negedge D[51], posedge CK &&& (CSWEMTBYPASS[51] != 1), tds, TimingViol_data_51);
	$setup(negedge D[52], posedge CK &&& (CSWEMTBYPASS[52] != 1), tds, TimingViol_data_52);
	$setup(negedge D[53], posedge CK &&& (CSWEMTBYPASS[53] != 1), tds, TimingViol_data_53);
	$setup(negedge D[54], posedge CK &&& (CSWEMTBYPASS[54] != 1), tds, TimingViol_data_54);
	$setup(negedge D[55], posedge CK &&& (CSWEMTBYPASS[55] != 1), tds, TimingViol_data_55);
	$setup(negedge D[56], posedge CK &&& (CSWEMTBYPASS[56] != 1), tds, TimingViol_data_56);
	$setup(negedge D[57], posedge CK &&& (CSWEMTBYPASS[57] != 1), tds, TimingViol_data_57);
	$setup(negedge D[58], posedge CK &&& (CSWEMTBYPASS[58] != 1), tds, TimingViol_data_58);
	$setup(negedge D[59], posedge CK &&& (CSWEMTBYPASS[59] != 1), tds, TimingViol_data_59);
	$setup(negedge D[60], posedge CK &&& (CSWEMTBYPASS[60] != 1), tds, TimingViol_data_60);
	$setup(negedge D[61], posedge CK &&& (CSWEMTBYPASS[61] != 1), tds, TimingViol_data_61);
	$setup(negedge D[62], posedge CK &&& (CSWEMTBYPASS[62] != 1), tds, TimingViol_data_62);
	$setup(negedge D[63], posedge CK &&& (CSWEMTBYPASS[63] != 1), tds, TimingViol_data_63);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 1), posedge D[0], tdh, TimingViol_data_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 1), posedge D[1], tdh, TimingViol_data_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 1), posedge D[2], tdh, TimingViol_data_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 1), posedge D[3], tdh, TimingViol_data_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 1), posedge D[4], tdh, TimingViol_data_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 1), posedge D[5], tdh, TimingViol_data_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 1), posedge D[6], tdh, TimingViol_data_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 1), posedge D[7], tdh, TimingViol_data_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 1), posedge D[8], tdh, TimingViol_data_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 1), posedge D[9], tdh, TimingViol_data_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 1), posedge D[10], tdh, TimingViol_data_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 1), posedge D[11], tdh, TimingViol_data_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 1), posedge D[12], tdh, TimingViol_data_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 1), posedge D[13], tdh, TimingViol_data_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 1), posedge D[14], tdh, TimingViol_data_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 1), posedge D[15], tdh, TimingViol_data_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 1), posedge D[16], tdh, TimingViol_data_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 1), posedge D[17], tdh, TimingViol_data_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 1), posedge D[18], tdh, TimingViol_data_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 1), posedge D[19], tdh, TimingViol_data_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 1), posedge D[20], tdh, TimingViol_data_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 1), posedge D[21], tdh, TimingViol_data_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 1), posedge D[22], tdh, TimingViol_data_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 1), posedge D[23], tdh, TimingViol_data_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 1), posedge D[24], tdh, TimingViol_data_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 1), posedge D[25], tdh, TimingViol_data_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 1), posedge D[26], tdh, TimingViol_data_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 1), posedge D[27], tdh, TimingViol_data_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 1), posedge D[28], tdh, TimingViol_data_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 1), posedge D[29], tdh, TimingViol_data_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 1), posedge D[30], tdh, TimingViol_data_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 1), posedge D[31], tdh, TimingViol_data_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[32] != 1), posedge D[32], tdh, TimingViol_data_32);
	$hold(posedge CK &&& (CSWEMTBYPASS[33] != 1), posedge D[33], tdh, TimingViol_data_33);
	$hold(posedge CK &&& (CSWEMTBYPASS[34] != 1), posedge D[34], tdh, TimingViol_data_34);
	$hold(posedge CK &&& (CSWEMTBYPASS[35] != 1), posedge D[35], tdh, TimingViol_data_35);
	$hold(posedge CK &&& (CSWEMTBYPASS[36] != 1), posedge D[36], tdh, TimingViol_data_36);
	$hold(posedge CK &&& (CSWEMTBYPASS[37] != 1), posedge D[37], tdh, TimingViol_data_37);
	$hold(posedge CK &&& (CSWEMTBYPASS[38] != 1), posedge D[38], tdh, TimingViol_data_38);
	$hold(posedge CK &&& (CSWEMTBYPASS[39] != 1), posedge D[39], tdh, TimingViol_data_39);
	$hold(posedge CK &&& (CSWEMTBYPASS[40] != 1), posedge D[40], tdh, TimingViol_data_40);
	$hold(posedge CK &&& (CSWEMTBYPASS[41] != 1), posedge D[41], tdh, TimingViol_data_41);
	$hold(posedge CK &&& (CSWEMTBYPASS[42] != 1), posedge D[42], tdh, TimingViol_data_42);
	$hold(posedge CK &&& (CSWEMTBYPASS[43] != 1), posedge D[43], tdh, TimingViol_data_43);
	$hold(posedge CK &&& (CSWEMTBYPASS[44] != 1), posedge D[44], tdh, TimingViol_data_44);
	$hold(posedge CK &&& (CSWEMTBYPASS[45] != 1), posedge D[45], tdh, TimingViol_data_45);
	$hold(posedge CK &&& (CSWEMTBYPASS[46] != 1), posedge D[46], tdh, TimingViol_data_46);
	$hold(posedge CK &&& (CSWEMTBYPASS[47] != 1), posedge D[47], tdh, TimingViol_data_47);
	$hold(posedge CK &&& (CSWEMTBYPASS[48] != 1), posedge D[48], tdh, TimingViol_data_48);
	$hold(posedge CK &&& (CSWEMTBYPASS[49] != 1), posedge D[49], tdh, TimingViol_data_49);
	$hold(posedge CK &&& (CSWEMTBYPASS[50] != 1), posedge D[50], tdh, TimingViol_data_50);
	$hold(posedge CK &&& (CSWEMTBYPASS[51] != 1), posedge D[51], tdh, TimingViol_data_51);
	$hold(posedge CK &&& (CSWEMTBYPASS[52] != 1), posedge D[52], tdh, TimingViol_data_52);
	$hold(posedge CK &&& (CSWEMTBYPASS[53] != 1), posedge D[53], tdh, TimingViol_data_53);
	$hold(posedge CK &&& (CSWEMTBYPASS[54] != 1), posedge D[54], tdh, TimingViol_data_54);
	$hold(posedge CK &&& (CSWEMTBYPASS[55] != 1), posedge D[55], tdh, TimingViol_data_55);
	$hold(posedge CK &&& (CSWEMTBYPASS[56] != 1), posedge D[56], tdh, TimingViol_data_56);
	$hold(posedge CK &&& (CSWEMTBYPASS[57] != 1), posedge D[57], tdh, TimingViol_data_57);
	$hold(posedge CK &&& (CSWEMTBYPASS[58] != 1), posedge D[58], tdh, TimingViol_data_58);
	$hold(posedge CK &&& (CSWEMTBYPASS[59] != 1), posedge D[59], tdh, TimingViol_data_59);
	$hold(posedge CK &&& (CSWEMTBYPASS[60] != 1), posedge D[60], tdh, TimingViol_data_60);
	$hold(posedge CK &&& (CSWEMTBYPASS[61] != 1), posedge D[61], tdh, TimingViol_data_61);
	$hold(posedge CK &&& (CSWEMTBYPASS[62] != 1), posedge D[62], tdh, TimingViol_data_62);
	$hold(posedge CK &&& (CSWEMTBYPASS[63] != 1), posedge D[63], tdh, TimingViol_data_63);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 1), negedge D[0], tdh, TimingViol_data_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 1), negedge D[1], tdh, TimingViol_data_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 1), negedge D[2], tdh, TimingViol_data_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 1), negedge D[3], tdh, TimingViol_data_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 1), negedge D[4], tdh, TimingViol_data_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 1), negedge D[5], tdh, TimingViol_data_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 1), negedge D[6], tdh, TimingViol_data_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 1), negedge D[7], tdh, TimingViol_data_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 1), negedge D[8], tdh, TimingViol_data_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 1), negedge D[9], tdh, TimingViol_data_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 1), negedge D[10], tdh, TimingViol_data_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 1), negedge D[11], tdh, TimingViol_data_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 1), negedge D[12], tdh, TimingViol_data_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 1), negedge D[13], tdh, TimingViol_data_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 1), negedge D[14], tdh, TimingViol_data_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 1), negedge D[15], tdh, TimingViol_data_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 1), negedge D[16], tdh, TimingViol_data_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 1), negedge D[17], tdh, TimingViol_data_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 1), negedge D[18], tdh, TimingViol_data_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 1), negedge D[19], tdh, TimingViol_data_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 1), negedge D[20], tdh, TimingViol_data_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 1), negedge D[21], tdh, TimingViol_data_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 1), negedge D[22], tdh, TimingViol_data_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 1), negedge D[23], tdh, TimingViol_data_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 1), negedge D[24], tdh, TimingViol_data_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 1), negedge D[25], tdh, TimingViol_data_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 1), negedge D[26], tdh, TimingViol_data_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 1), negedge D[27], tdh, TimingViol_data_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 1), negedge D[28], tdh, TimingViol_data_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 1), negedge D[29], tdh, TimingViol_data_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 1), negedge D[30], tdh, TimingViol_data_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 1), negedge D[31], tdh, TimingViol_data_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[32] != 1), negedge D[32], tdh, TimingViol_data_32);
	$hold(posedge CK &&& (CSWEMTBYPASS[33] != 1), negedge D[33], tdh, TimingViol_data_33);
	$hold(posedge CK &&& (CSWEMTBYPASS[34] != 1), negedge D[34], tdh, TimingViol_data_34);
	$hold(posedge CK &&& (CSWEMTBYPASS[35] != 1), negedge D[35], tdh, TimingViol_data_35);
	$hold(posedge CK &&& (CSWEMTBYPASS[36] != 1), negedge D[36], tdh, TimingViol_data_36);
	$hold(posedge CK &&& (CSWEMTBYPASS[37] != 1), negedge D[37], tdh, TimingViol_data_37);
	$hold(posedge CK &&& (CSWEMTBYPASS[38] != 1), negedge D[38], tdh, TimingViol_data_38);
	$hold(posedge CK &&& (CSWEMTBYPASS[39] != 1), negedge D[39], tdh, TimingViol_data_39);
	$hold(posedge CK &&& (CSWEMTBYPASS[40] != 1), negedge D[40], tdh, TimingViol_data_40);
	$hold(posedge CK &&& (CSWEMTBYPASS[41] != 1), negedge D[41], tdh, TimingViol_data_41);
	$hold(posedge CK &&& (CSWEMTBYPASS[42] != 1), negedge D[42], tdh, TimingViol_data_42);
	$hold(posedge CK &&& (CSWEMTBYPASS[43] != 1), negedge D[43], tdh, TimingViol_data_43);
	$hold(posedge CK &&& (CSWEMTBYPASS[44] != 1), negedge D[44], tdh, TimingViol_data_44);
	$hold(posedge CK &&& (CSWEMTBYPASS[45] != 1), negedge D[45], tdh, TimingViol_data_45);
	$hold(posedge CK &&& (CSWEMTBYPASS[46] != 1), negedge D[46], tdh, TimingViol_data_46);
	$hold(posedge CK &&& (CSWEMTBYPASS[47] != 1), negedge D[47], tdh, TimingViol_data_47);
	$hold(posedge CK &&& (CSWEMTBYPASS[48] != 1), negedge D[48], tdh, TimingViol_data_48);
	$hold(posedge CK &&& (CSWEMTBYPASS[49] != 1), negedge D[49], tdh, TimingViol_data_49);
	$hold(posedge CK &&& (CSWEMTBYPASS[50] != 1), negedge D[50], tdh, TimingViol_data_50);
	$hold(posedge CK &&& (CSWEMTBYPASS[51] != 1), negedge D[51], tdh, TimingViol_data_51);
	$hold(posedge CK &&& (CSWEMTBYPASS[52] != 1), negedge D[52], tdh, TimingViol_data_52);
	$hold(posedge CK &&& (CSWEMTBYPASS[53] != 1), negedge D[53], tdh, TimingViol_data_53);
	$hold(posedge CK &&& (CSWEMTBYPASS[54] != 1), negedge D[54], tdh, TimingViol_data_54);
	$hold(posedge CK &&& (CSWEMTBYPASS[55] != 1), negedge D[55], tdh, TimingViol_data_55);
	$hold(posedge CK &&& (CSWEMTBYPASS[56] != 1), negedge D[56], tdh, TimingViol_data_56);
	$hold(posedge CK &&& (CSWEMTBYPASS[57] != 1), negedge D[57], tdh, TimingViol_data_57);
	$hold(posedge CK &&& (CSWEMTBYPASS[58] != 1), negedge D[58], tdh, TimingViol_data_58);
	$hold(posedge CK &&& (CSWEMTBYPASS[59] != 1), negedge D[59], tdh, TimingViol_data_59);
	$hold(posedge CK &&& (CSWEMTBYPASS[60] != 1), negedge D[60], tdh, TimingViol_data_60);
	$hold(posedge CK &&& (CSWEMTBYPASS[61] != 1), negedge D[61], tdh, TimingViol_data_61);
	$hold(posedge CK &&& (CSWEMTBYPASS[62] != 1), negedge D[62], tdh, TimingViol_data_62);
	$hold(posedge CK &&& (CSWEMTBYPASS[63] != 1), negedge D[63], tdh, TimingViol_data_63);

	
        $setup(posedge CSN, edge[01,0x,x1,1x] CK &&& (TBYPASSint != 1), tps, TimingViol_csn);
	$setup(negedge CSN, edge[01,0x,x1,1x] CK &&& (TBYPASSint != 1), tps, TimingViol_csn);
	$hold(edge[01,0x,x1,x0] CK &&& (TBYPASSint != 1), posedge CSN, tph, TimingViol_csn);
	$hold(edge[01,0x,x1,x0] CK &&& (TBYPASSint != 1), negedge CSN, tph, TimingViol_csn);
        $setup(posedge WEN, edge[01,0x,x1,1x] CK &&& (CSNint != 1), tws, TimingViol_wen);
        $setup(negedge WEN, edge[01,0x,x1,1x] CK &&& (CSNint != 1), tws, TimingViol_wen);
        $hold(edge[01,0x,x1,x0] CK &&& (CSNint != 1), posedge WEN, twh, TimingViol_wen);
        $hold(edge[01,0x,x1,x0] CK &&& (CSNint != 1), negedge WEN, twh, TimingViol_wen);
        $period(posedge CK &&& (CSNint != 1), tcycle, TimingViol_tcycle);
        $width(posedge CK &&& (CSNint != 1'b1), tckh, 0, TimingViol_tckh);
        $width(negedge CK &&& (CSNint != 1'b1), tckl, 0, TimingViol_tckl);
        $setup(posedge TBYPASS, posedge CK &&& (CS != 1),ttms, TimingViol_tbypass);
        $setup(negedge TBYPASS, posedge CK &&& (CS != 1),ttms, TimingViol_tbypass);
        $hold(posedge CK &&& (CS != 1), posedge TBYPASS, ttmh, TimingViol_tbypass); 
        $hold(posedge CK &&& (CS != 1), negedge TBYPASS, ttmh, TimingViol_tbypass); 




	endspecify

always @(CKint)
begin
   CKreg <= CKint;
end

//latch input signals
always @(posedge CKint)
begin
   if (CSNint !== 1)
   begin
      Dreg = Dint;
      Mreg = Mint;
      WENreg = WENint;
      Areg = Aint;
   end
   CSNreg = CSNint;
end
     


// conversion from registers to array elements for data setup violation notifiers

always @(TimingViol_data_0)
begin
   TimingViol_data[0] = TimingViol_data_0;
end


always @(TimingViol_data_1)
begin
   TimingViol_data[1] = TimingViol_data_1;
end


always @(TimingViol_data_2)
begin
   TimingViol_data[2] = TimingViol_data_2;
end


always @(TimingViol_data_3)
begin
   TimingViol_data[3] = TimingViol_data_3;
end


always @(TimingViol_data_4)
begin
   TimingViol_data[4] = TimingViol_data_4;
end


always @(TimingViol_data_5)
begin
   TimingViol_data[5] = TimingViol_data_5;
end


always @(TimingViol_data_6)
begin
   TimingViol_data[6] = TimingViol_data_6;
end


always @(TimingViol_data_7)
begin
   TimingViol_data[7] = TimingViol_data_7;
end


always @(TimingViol_data_8)
begin
   TimingViol_data[8] = TimingViol_data_8;
end


always @(TimingViol_data_9)
begin
   TimingViol_data[9] = TimingViol_data_9;
end


always @(TimingViol_data_10)
begin
   TimingViol_data[10] = TimingViol_data_10;
end


always @(TimingViol_data_11)
begin
   TimingViol_data[11] = TimingViol_data_11;
end


always @(TimingViol_data_12)
begin
   TimingViol_data[12] = TimingViol_data_12;
end


always @(TimingViol_data_13)
begin
   TimingViol_data[13] = TimingViol_data_13;
end


always @(TimingViol_data_14)
begin
   TimingViol_data[14] = TimingViol_data_14;
end


always @(TimingViol_data_15)
begin
   TimingViol_data[15] = TimingViol_data_15;
end


always @(TimingViol_data_16)
begin
   TimingViol_data[16] = TimingViol_data_16;
end


always @(TimingViol_data_17)
begin
   TimingViol_data[17] = TimingViol_data_17;
end


always @(TimingViol_data_18)
begin
   TimingViol_data[18] = TimingViol_data_18;
end


always @(TimingViol_data_19)
begin
   TimingViol_data[19] = TimingViol_data_19;
end


always @(TimingViol_data_20)
begin
   TimingViol_data[20] = TimingViol_data_20;
end


always @(TimingViol_data_21)
begin
   TimingViol_data[21] = TimingViol_data_21;
end


always @(TimingViol_data_22)
begin
   TimingViol_data[22] = TimingViol_data_22;
end


always @(TimingViol_data_23)
begin
   TimingViol_data[23] = TimingViol_data_23;
end


always @(TimingViol_data_24)
begin
   TimingViol_data[24] = TimingViol_data_24;
end


always @(TimingViol_data_25)
begin
   TimingViol_data[25] = TimingViol_data_25;
end


always @(TimingViol_data_26)
begin
   TimingViol_data[26] = TimingViol_data_26;
end


always @(TimingViol_data_27)
begin
   TimingViol_data[27] = TimingViol_data_27;
end


always @(TimingViol_data_28)
begin
   TimingViol_data[28] = TimingViol_data_28;
end


always @(TimingViol_data_29)
begin
   TimingViol_data[29] = TimingViol_data_29;
end


always @(TimingViol_data_30)
begin
   TimingViol_data[30] = TimingViol_data_30;
end


always @(TimingViol_data_31)
begin
   TimingViol_data[31] = TimingViol_data_31;
end


always @(TimingViol_data_32)
begin
   TimingViol_data[32] = TimingViol_data_32;
end


always @(TimingViol_data_33)
begin
   TimingViol_data[33] = TimingViol_data_33;
end


always @(TimingViol_data_34)
begin
   TimingViol_data[34] = TimingViol_data_34;
end


always @(TimingViol_data_35)
begin
   TimingViol_data[35] = TimingViol_data_35;
end


always @(TimingViol_data_36)
begin
   TimingViol_data[36] = TimingViol_data_36;
end


always @(TimingViol_data_37)
begin
   TimingViol_data[37] = TimingViol_data_37;
end


always @(TimingViol_data_38)
begin
   TimingViol_data[38] = TimingViol_data_38;
end


always @(TimingViol_data_39)
begin
   TimingViol_data[39] = TimingViol_data_39;
end


always @(TimingViol_data_40)
begin
   TimingViol_data[40] = TimingViol_data_40;
end


always @(TimingViol_data_41)
begin
   TimingViol_data[41] = TimingViol_data_41;
end


always @(TimingViol_data_42)
begin
   TimingViol_data[42] = TimingViol_data_42;
end


always @(TimingViol_data_43)
begin
   TimingViol_data[43] = TimingViol_data_43;
end


always @(TimingViol_data_44)
begin
   TimingViol_data[44] = TimingViol_data_44;
end


always @(TimingViol_data_45)
begin
   TimingViol_data[45] = TimingViol_data_45;
end


always @(TimingViol_data_46)
begin
   TimingViol_data[46] = TimingViol_data_46;
end


always @(TimingViol_data_47)
begin
   TimingViol_data[47] = TimingViol_data_47;
end


always @(TimingViol_data_48)
begin
   TimingViol_data[48] = TimingViol_data_48;
end


always @(TimingViol_data_49)
begin
   TimingViol_data[49] = TimingViol_data_49;
end


always @(TimingViol_data_50)
begin
   TimingViol_data[50] = TimingViol_data_50;
end


always @(TimingViol_data_51)
begin
   TimingViol_data[51] = TimingViol_data_51;
end


always @(TimingViol_data_52)
begin
   TimingViol_data[52] = TimingViol_data_52;
end


always @(TimingViol_data_53)
begin
   TimingViol_data[53] = TimingViol_data_53;
end


always @(TimingViol_data_54)
begin
   TimingViol_data[54] = TimingViol_data_54;
end


always @(TimingViol_data_55)
begin
   TimingViol_data[55] = TimingViol_data_55;
end


always @(TimingViol_data_56)
begin
   TimingViol_data[56] = TimingViol_data_56;
end


always @(TimingViol_data_57)
begin
   TimingViol_data[57] = TimingViol_data_57;
end


always @(TimingViol_data_58)
begin
   TimingViol_data[58] = TimingViol_data_58;
end


always @(TimingViol_data_59)
begin
   TimingViol_data[59] = TimingViol_data_59;
end


always @(TimingViol_data_60)
begin
   TimingViol_data[60] = TimingViol_data_60;
end


always @(TimingViol_data_61)
begin
   TimingViol_data[61] = TimingViol_data_61;
end


always @(TimingViol_data_62)
begin
   TimingViol_data[62] = TimingViol_data_62;
end


always @(TimingViol_data_63)
begin
   TimingViol_data[63] = TimingViol_data_63;
end




ST_SPHS_80x64m4_L_main ST_SPHS_80x64m4_L_maininst (Q_glitchint,  Q_dataint, Q_gCKint , RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint, CKint,  CSNint , TBYPASSint, WENint,  Aint, Dint, Mint, debug_level  , TimingViol_addr, TimingViol_data, TimingViol_csn, TimingViol_wen, TimingViol_tckh, TimingViol_tckl, TimingViol_tcycle, TimingViol_tbypass, TimingViol_mask    );


ST_SPHS_80x64m4_L_OPschlr ST_SPHS_80x64m4_L_OPschlrinst (Qint, RYint,  Q_gCKint, Q_glitchint,  Q_dataint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint);

defparam ST_SPHS_80x64m4_L_maininst.Fault_file_name = Fault_file_name;
defparam ST_SPHS_80x64m4_L_maininst.ConfigFault = ConfigFault;
defparam ST_SPHS_80x64m4_L_maininst.max_faults = max_faults;
defparam ST_SPHS_80x64m4_L_maininst.MEM_INITIALIZE = MEM_INITIALIZE;
defparam ST_SPHS_80x64m4_L_maininst.BinaryInit = BinaryInit;
defparam ST_SPHS_80x64m4_L_maininst.InitFileName = InitFileName;

endmodule
`endif

`delay_mode_path
`endcelldefine
`disable_portfaults
`nosuppress_faults




