
`celldefine
`ifdef functional
  `timesclae 1ns / 1ns
  `delay_mode_zero
`else
  `timescale 1ns / 1ps
  `delay_mode_path
`endif

`define CPADS_S_74x50u_IN_PADIO_R_COREIO_R 0.1
`define CPADS_S_74x50u_IN_PADIO_F_COREIO_F 0.1

module CPAD_S_74x50u_IN (PADIO, COREIO);
        input PADIO;
        output COREIO;

        buf #1 U1 (COREIO, PADIO) ;

        specify

                (PADIO +=> COREIO) = (`CPADS_S_74x50u_IN_PADIO_R_COREIO_R, `CPADS_S_74x50u_IN_PADIO_F_COREIO_F);

        endspecify

endmodule


`celldefine
`ifdef functional
  `timesclae 1ns / 1ns
  `delay_mode_zero
`else
  `timescale 1ns / 1ps
  `delay_mode_path
`endif

`define CPADS_S_74x50u_OUT_COREIO_R_PADIO_R 0.1
`define CPADS_S_74x50u_OUT_COREIO_F_PADIO_F 0.1

module CPAD_S_74x50u_OUT (COREIO, PADIO);
        input COREIO;
        output PADIO;

        buf #1 U1 (PADIO, COREIO) ;

        specify

                (COREIO +=> PADIO) = (`CPADS_S_74x50u_OUT_COREIO_R_PADIO_R, `CPADS_S_74x50u_OUT_COREIO_F_PADIO_F);

        endspecify

endmodule


