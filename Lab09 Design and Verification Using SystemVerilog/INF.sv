//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2019 ICLAB Fall Course
//   Lab09      : CTS
//   Author     : Tzu-Yun Huang
//
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : INF.sv
//   Module Name : INF
//   Release version : v1.0 (Release Date: Nov -2019)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
//`include "Usertype_PKG.sv"

interface INF(input bit clk);
	import      usertype::*;
	logic rst_n ;
	DATA  D;
	logic   id_valid;
	logic   passwd_valid;
	logic   amnt_valid;
	logic   act_valid;
	logic   C_out_valid;


	logic   out_valid;
	Error_Msg err_msg;
	Balance out_balance;

	logic complete;
	logic [7:0]  C_addr;
	logic [31:0] C_data_w;
	logic [31:0] C_data_r;
	logic   C_in_valid;
	logic C_r_wb;

	logic   AR_READY, R_VALID, AW_READY, W_READY, B_VALID, B_RESP,
	      AR_VALID, R_READY, AW_VALID, W_VALID, B_READY;

    logic [31:0] R_DATA, W_DATA;
	logic [16:0] AW_ADDR, AR_ADDR;

    modport PATTERN(
		// port to Payment.sv
	     input err_msg,
		 input complete,
		 input out_valid,
		 input out_balance,
		 output id_valid,
		 output rst_n,
		 output passwd_valid,
		 output amnt_valid,
		 output  act_valid,
		 output D
    );

    modport DRAM(
		// port to bridge.sv
		output AR_READY,
		output R_VALID,
		output R_DATA,
		output AW_READY,
		output W_READY,
		output B_VALID,
		output B_RESP,
		input AR_VALID,
		input AR_ADDR,
		input R_READY,
		input AW_VALID,
		input AW_ADDR,
		input W_VALID,
		input W_DATA,
		input B_READY
    );

    modport payment_inf(
		// port to pattern.sv
	    input rst_n,
		input id_valid,
		input passwd_valid,
		input amnt_valid,
		input act_valid,
		input D,
		output out_valid,
		output err_msg,
		output complete,
		output out_balance,
		// port to bridge.sv
		input C_out_valid,
		input C_data_r,
		output C_addr,
		output C_data_w,
		output C_in_valid,
		output C_r_wb
	);

    modport bridge_inf(
		// port to Payment.sv
		input rst_n,
	    input C_addr,
		input C_r_wb,
		input C_in_valid,
		input C_data_w,
		output C_data_r,
		output C_out_valid,
		// port to DRAM
		input AR_READY,
		input R_VALID,
		input R_DATA,
		input AW_READY,
		input W_READY,
		input B_VALID,
		input B_RESP,
		output AR_VALID,
		output AR_ADDR,
		output R_READY,
		output AW_VALID,
		output AW_ADDR,
		output W_VALID,
		output W_DATA,
		output B_READY
    );


	modport PATTERN_bridge(
		// port to brige_inf.sv
		output rst_n,
		output C_addr,
	  	output C_r_wb,
	  	output C_in_valid,
	  	output C_data_w,
	  	input C_data_r,
	  	input C_out_valid,
		// port to dram
		output AR_READY,
		output R_VALID,
		output R_DATA,
		output AW_READY,
		output W_READY,
		output B_VALID,
		output B_RESP,
		input AR_VALID,
		input AR_ADDR,
		input R_READY,
		input AW_VALID,
		input AW_ADDR,
		input W_VALID,
		input W_DATA,
		input B_READY
    );

	modport PATTERN_payment(
		// port to pattern.sv
	    output rst_n,
		output id_valid,
		output passwd_valid,
		output amnt_valid,
		output act_valid,
		output D,
		input out_valid,
		input err_msg,
		input complete,
		input out_balance,
		// port to bridge.sv
		output C_out_valid,
		output C_data_r,
		input C_addr,
		input C_data_w,
		input C_in_valid,
		input C_r_wb
    );

endinterface
