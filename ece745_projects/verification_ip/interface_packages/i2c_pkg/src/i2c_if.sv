interface i2c_if #(
    int I2C_ADDR_WIDTH = 7,
    int I2C_DATA_WIDTH = 8
)(
    input wire clk_i,
    inout wire scl,
    inout wire sda
);


    typedef enum bit {write = 1'b0, read = 1'b1} i2c_op_t;
    logic sda_o = 1'b1;
    assign sda = (sda_o == 1'b0) ? 1'b0 : 1'bz;

    task wait_for_i2c_transfer(output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] write_data []);
        bit [I2C_ADDR_WIDTH-1:0] address;
        bit [I2C_DATA_WIDTH-1:0] eightbitdata;
        int count;
        write_data = {};

        @(negedge sda iff (scl == 1'b1));

        for (int i = 6; i >= 0; i--) begin
            @(posedge scl);
            address[i] = sda;
        end

        @(posedge scl);
        op = i2c_op_t'(sda);

        @(negedge scl); sda_o <= 1'b0;
        @(posedge scl);
        @(negedge scl); sda_o <= 1'b1;

        if (op == read) return;

        count = 0;
        forever begin
            for (int i = 7; i >= 0; i--) begin
                @(posedge scl);
                eightbitdata[i] = sda;
            end

            @(negedge scl); sda_o <= 1'b0;
            @(posedge scl);
            @(negedge scl); sda_o <= 1'b1;

            write_data = new[count+1](write_data);
            write_data[count] = eightbitdata;
            count++;

            begin
                automatic bit negative_edge = 0;
                @(posedge scl);
                for (int i = 0; i < 400; i++) begin
                    @(posedge clk_i);
                    if (scl == 1'b0) begin negative_edge = 1; break; end
                end
                if (!negative_edge) break;

                eightbitdata[7] = sda;
                for (int i = 6; i >= 0; i--) begin
                    @(posedge scl);
                    eightbitdata[i] = sda;
                end
                @(negedge scl); sda_o <= 1'b0;
                @(posedge scl);
                @(negedge scl); sda_o <= 1'b1;
                write_data = new[count+1](write_data);
                write_data[count] = eightbitdata;
                count++;
            end
        end
    endtask

    task provide_read_data(input  bit [I2C_DATA_WIDTH-1:0] read_data [], output bit transfer_complete);
        @(negedge sda iff (scl == 1'b1));  
        repeat(9) @(posedge scl);           
        @(negedge scl);

        transfer_complete = 1'b0;
        for (int i = 0; i < read_data.size(); i++) begin
            for (int j = 7; j >= 0; j--) begin
                sda_o <= read_data[i][j];
                @(negedge scl);
            end
            sda_o <= 1'b1;
            @(posedge scl);
            if (sda == 1'b1) begin
                transfer_complete = 1'b1;
                break;
            end
        end
    endtask

    task monitor( output bit [I2C_ADDR_WIDTH-1:0] addr, output bit op, output bit [I2C_DATA_WIDTH-1:0] data []);
        bit [I2C_DATA_WIDTH-1:0] eightbitdata;
        int count;
        data = {};

        @(negedge sda iff (scl == 1'b1));

        for (int i = 6; i >= 0; i--) begin
            @(posedge scl);
            addr[i] = sda;
        end


        @(posedge scl);
        op = i2c_op_t'(sda);

        @(negedge scl);
        @(posedge scl);
        @(negedge scl);

        count = 0;
        forever begin
            for (int i = 7; i >= 0; i--) begin
                @(posedge scl);
                eightbitdata[i] = sda;
            end
            @(negedge scl);
            @(posedge scl);

            data = new[count+1](data);
            data[count] = eightbitdata;
            count++;

            begin
                automatic bit negative_edge = 0;
                @(posedge scl);
                for (int i = 0; i < 400; i++) begin
                    @(posedge clk_i);
                    if (scl == 1'b0) begin negative_edge = 1; break; end
                end
                if (!negative_edge) break;
                eightbitdata[7] = sda;
                for (int i = 6; i >= 0; i--) begin
                    @(posedge scl);
                    eightbitdata[i] = sda;
                end
                @(negedge scl); @(posedge scl);
                data = new[count+1](data);
                data[count] = eightbitdata;
                count++;
            end
        end
    endtask

endinterface
