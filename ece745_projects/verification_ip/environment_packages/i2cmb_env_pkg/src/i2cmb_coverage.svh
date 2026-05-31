class i2cmb_coverage extends ncsu_component#(.T(i2c_transaction));
  `ncsu_register_object(i2cmb_coverage)

  i2cmb_env_configuration configuration;

  i2c_op_t    op;
  bit [6:0]   addr;
  bit [7:0]   data;

  covergroup i2c_op_cg;
    option.per_instance = 1;
    option.name         = "i2c_op_cg";

    cp_op: coverpoint op {
      bins write_op = {i2c_pkg::write};
      bins read_op  = {i2c_pkg::read};
    }
  endgroup

  covergroup i2c_addr_cg;
    option.per_instance = 1;
    option.name         = "i2c_addr_cg";

    cp_addr: coverpoint addr {
      bins addr_low    = {[7'h00 : 7'h1F]}; 
      bins addr_mid    = {[7'h20 : 7'h3F]};  
      bins addr_high   = {[7'h40 : 7'h5F]};  
      bins addr_top    = {[7'h60 : 7'h7F]};  
    }
  endgroup

  covergroup i2c_data_cg;
    option.per_instance = 1;
    option.name         = "i2c_data_cg";

    cp_data: coverpoint data {
      bins data_zero      = {8'h00};           
      bins data_low       = {[8'h01 : 8'h3F]}; 
      bins data_mid_low   = {[8'h40 : 8'h7F]}; 
      bins data_mid_high  = {[8'h80 : 8'hBF]}; 
      bins data_high      = {[8'hC0 : 8'hFE]}; 
      bins data_max       = {8'hFF};            
    }
  endgroup


  covergroup i2c_op_data_cross_cg;
    option.per_instance = 1;
    option.name         = "i2c_op_data_cross_cg";

    cp_op_x: coverpoint op {
      bins write_op = {i2c_pkg::write};
      bins read_op  = {i2c_pkg::read};
    }

    cp_data_x: coverpoint data {
      bins data_zero     = {8'h00};
      bins data_low      = {[8'h01 : 8'h7F]};
      bins data_high     = {[8'h80 : 8'hFE]};
      bins data_max      = {8'hFF};
    }

    cx_op_data: cross cp_op_x, cp_data_x;
  endgroup

  covergroup i2c_op_transition_cg;
    option.per_instance = 1;
    option.name         = "i2c_op_transition_cg";

    cp_op_trans: coverpoint op {
      bins write_to_read  = (i2c_pkg::write => i2c_pkg::read);
      bins read_to_write  = (i2c_pkg::read  => i2c_pkg::write);
      bins write_to_write = (i2c_pkg::write => i2c_pkg::write);
      bins read_to_read   = (i2c_pkg::read  => i2c_pkg::read);
    }
  endgroup

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
    i2c_op_cg            = new;
    i2c_addr_cg          = new;
    i2c_data_cg          = new;
    i2c_op_data_cross_cg = new;
    i2c_op_transition_cg = new;
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void nb_put(T trans);
    op   = trans.op;
    addr = trans.addr;
    data = (trans.data.size() > 0) ? trans.data[0] : 8'h00;

    i2c_op_cg.sample();
    i2c_addr_cg.sample();
    i2c_data_cg.sample();
    i2c_op_data_cross_cg.sample();
    i2c_op_transition_cg.sample();
  endfunction

endclass
