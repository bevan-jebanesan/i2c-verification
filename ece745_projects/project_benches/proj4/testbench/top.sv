`timescale 1ns / 10ps
import ncsu_pkg::*;
import wb_pkg::*;
import i2c_pkg::*;
import i2cmb_env_pkg::*;

module top();

  parameter int WB_ADDR_WIDTH = 2;
  parameter int WB_DATA_WIDTH = 8;
  parameter int NUM_I2C_BUSSES = 1;

  bit  clk;
  bit  rst = 1'b1;
  wire cyc, stb, we;
  tri1 ack;
  wire [WB_ADDR_WIDTH-1:0] adr;
  wire [WB_DATA_WIDTH-1:0] dat_wr_o;
  wire [WB_DATA_WIDTH-1:0] dat_rd_i;
  wire irq;
  tri1 [NUM_I2C_BUSSES-1:0] scl;
  tri1 [NUM_I2C_BUSSES-1:0] sda;

  initial begin : clk_gen
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin : rst_gen
    rst = 1'b1;
    #113;
    rst = 1'b0;
  end

  wb_if #(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)) wb_bus (
    .clk_i(clk), .rst_i(rst), .irq_i(irq),
    .cyc_o(cyc), .stb_o(stb), .ack_i(ack),
    .adr_o(adr), .we_o(we),
    .cyc_i(cyc), .stb_i(stb), .ack_o(), .adr_i(adr), .we_i(we),
    .dat_o(dat_wr_o), .dat_i(dat_rd_i)
  );

  i2c_if #(.I2C_ADDR_WIDTH(7), .I2C_DATA_WIDTH(8)) i2c_bus (
    .clk_i(clk), .scl(scl), .sda(sda)
  );

  wire [NUM_I2C_BUSSES-1:0] scl_o_dut, sda_o_dut;
  assign scl[0] = (scl_o_dut[0] == 1'b0) ? 1'b0 : 1'bz;
  assign sda[0] = (sda_o_dut[0] == 1'b0) ? 1'b0 : 1'bz;

  \work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT (
    .clk_i(clk), .rst_i(rst),
    .cyc_i(cyc), .stb_i(stb), .ack_o(ack),
    .adr_i(adr), .we_i(we),
    .dat_i(dat_wr_o), .dat_o(dat_rd_i),
    .irq(irq),
    .scl_i(scl), .sda_i(sda),
    .scl_o(scl_o_dut), .sda_o(sda_o_dut)
  );

  i2cmb_test test;

  initial begin
    ncsu_config_db#(virtual wb_if)::set("test.env.wb_agent_inst", wb_bus);
    ncsu_config_db#(virtual i2c_if)::set("test.env.i2c_agent_inst", i2c_bus);

    test = new("test", null);
    test.build();
    wb_bus.wait_for_reset();
    fork
      test.env.run();
    join_none
    test.gen.run();
    test.env.report();
    $finish;
  end

endmodule
