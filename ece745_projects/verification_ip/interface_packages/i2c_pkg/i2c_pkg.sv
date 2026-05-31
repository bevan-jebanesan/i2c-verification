package i2c_pkg;
  import ncsu_pkg::*;

typedef enum bit {write = 1'b0, read = 1'b1} i2c_op_t;

  `include "ncsu_macros.svh"

   
  `include "src/i2c_configuration.svh"
  `include "src/i2c_transaction.svh"
  `include "src/i2c_driver.svh"
  `include "src/i2c_monitor.svh"
  `include "src/i2c_agent.svh"
endpackage
