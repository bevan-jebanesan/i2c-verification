class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));
  `ncsu_register_object(i2cmb_predictor)

  i2cmb_scoreboard  scoreboard;
  i2cmb_env_configuration configuration;

  i2c_transaction predicted_trans;
  bit [7:0] last_dpr;
  bit       addr_sent;

  bit [1:0] reg_addr;
  bit [7:0] reg_data;
  bit       reg_we;
  bit [2:0] last_cmd;

  covergroup csr_write_cg;
    option.per_instance = 1;
    option.name         = "csr_write_cg";

    cp_enable: coverpoint reg_data[7] iff (reg_addr == 2'h0 && reg_we) {
      bins enabled  = {1'b1};
      bins disabled = {1'b0};
    }

    cp_irq_en: coverpoint reg_data[6] iff (reg_addr == 2'h0 && reg_we) {
      bins irq_enabled  = {1'b1};
      bins irq_disabled = {1'b0};
    }
  endgroup

  covergroup dpr_access_cg;
    option.per_instance = 1;
    option.name         = "dpr_access_cg";

    cp_dpr_op: coverpoint reg_we iff (reg_addr == 2'h1) {
      bins dpr_write = {1'b1};
      bins dpr_read  = {1'b0};
    }

    cp_dpr_data: coverpoint reg_data iff (reg_addr == 2'h1 && reg_we) {
      bins dpr_zero    = {8'h00};
      bins dpr_low     = {[8'h01 : 8'h7F]};
      bins dpr_high    = {[8'h80 : 8'hFE]};
      bins dpr_max     = {8'hFF};
    }
  endgroup

  covergroup cmdr_cmd_cg;
    option.per_instance = 1;
    option.name         = "cmdr_cmd_cg";

    cp_cmd: coverpoint reg_data[2:0] iff (reg_addr == 2'h2 && reg_we) {
      bins cmd_wait    = {3'b000};   
      bins cmd_write   = {3'b001};   
      bins cmd_read_ak = {3'b010};   
      bins cmd_read_nk = {3'b011};   
      bins cmd_start   = {3'b100};   
      bins cmd_stop    = {3'b101};  
      bins cmd_set_bus = {3'b110}; 
    }
  endgroup

  covergroup cmdr_status_cg;
    option.per_instance = 1;
    option.name         = "cmdr_status_cg";

    cp_don: coverpoint reg_data[7] iff (reg_addr == 2'h2 && !reg_we) {
      bins done_set   = {1'b1};
      bins done_clear = {1'b0};
    }
  endgroup


  covergroup cmdr_read_cg;
    option.per_instance = 1;
    option.name         = "cmdr_read_cg";

    cp_cmdr_read: coverpoint reg_we iff (reg_addr == 2'h2) {
      bins cmdr_write = {1'b1};
      bins cmdr_read  = {1'b0};  
    }
  endgroup

  covergroup cmd_sequence_cg;
    option.per_instance = 1;
    option.name         = "cmd_sequence_cg";

    cp_cmd_trans: coverpoint last_cmd iff (reg_addr == 2'h2 && reg_we) {
      bins set_bus_then_start = (3'b110 => 3'b100);
      bins start_then_write   = (3'b100 => 3'b001);
      bins write_then_write   = (3'b001 => 3'b001);
      bins write_then_stop    = (3'b001 => 3'b101);
      bins start_then_read    = (3'b100 => 3'b011);
      bins read_then_stop     = (3'b011 => 3'b101);
    }
  endgroup

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
    addr_sent    = 0;
    last_cmd     = 3'b000;
    csr_write_cg   = new;
    dpr_access_cg  = new;
    cmdr_cmd_cg    = new;
    cmdr_status_cg = new;
    cmdr_read_cg   = new;
    cmd_sequence_cg = new;
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void set_scoreboard(i2cmb_scoreboard sb);
    this.scoreboard = sb;
  endfunction

  virtual function void nb_put(T trans);
    reg_addr = trans.addr;
    reg_data = trans.data;
    reg_we   = trans.we;

    csr_write_cg.sample();
    dpr_access_cg.sample();
    cmdr_cmd_cg.sample();
    cmdr_status_cg.sample();
    cmdr_read_cg.sample();

    if (trans.addr == 2'h2 && trans.we) begin
      cmd_sequence_cg.sample();
      last_cmd = trans.data[2:0];
    end

    if (!trans.we) return;

    case (trans.addr)
      2'h1: begin
        last_dpr = trans.data;
      end

      2'h2: begin
        case (trans.data)
          8'h04: begin
            predicted_trans      = new("predicted_trans");
            predicted_trans.addr = last_dpr[7:1];
            predicted_trans.op   = i2c_op_t'(last_dpr[0]);
            predicted_trans.data = {};
            addr_sent            = 0;
          end

          8'h01: begin
            if (!addr_sent) begin
              addr_sent = 1;
            end else begin
              if (predicted_trans != null) begin
                bit [7:0] tmp[];
                tmp = new[predicted_trans.data.size()+1](predicted_trans.data);
                tmp[predicted_trans.data.size()] = last_dpr;
                predicted_trans.data = tmp;
              end
            end
          end

          8'h03: begin
          end

          8'h05: begin
            if (predicted_trans != null && scoreboard != null)
              scoreboard.predict(predicted_trans);
            predicted_trans = null;
            addr_sent       = 0;
          end

          default: ;
        endcase
      end

      default: ;
    endcase
  endfunction

endclass
