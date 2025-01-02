module icb_slave(

    icb_bus.slave icb_bus,

    input  logic empty,
    input  logic full,
    output logic [63:0] key,

    input  logic [63:0] rdata,          // rfifo read data
    output logic rdata_en,              // rfifo read enable

    output logic [63:0] wdata,          // to decrypt write data
    output logic wdata_vld              // to decrypt write valid

);
    logic clk;
    logic rst_n;
    
    assign clk = icb_bus.clk;
    assign rst_n = icb_bus.rst_n;

    logic [63:0] icb_rsp_rdata_reg;
    logic rfifo_data_vld;
//  localparam 
    localparam ICB_SLAVE_BASE_ADDR  = 32'h20000000 ;
    localparam ICB_SLAVE_CONTROL    = ICB_SLAVE_BASE_ADDR | 32'h00 ;
    localparam ICB_SLAVE_STATE      = ICB_SLAVE_BASE_ADDR | 32'h08 ;
    localparam ICB_SLAVE_WDATA      = ICB_SLAVE_BASE_ADDR | 32'h10 ;
    localparam ICB_SLAVE_RDATA      = ICB_SLAVE_BASE_ADDR | 32'h18 ;
    localparam ICB_SLAVE_KEY        = ICB_SLAVE_BASE_ADDR | 32'h20 ;


//  visible_register
//  读写寄存器（ rdata / wdata ）被直接映射到fifo端口

    logic [7:0] control;
    logic [7:0] state;

//  icb_bus

    always_comb begin : icb_cmd_ready
        if  ( icb_bus.icb_cmd_valid ) begin
            if ( !icb_bus.icb_cmd_read && icb_bus.icb_cmd_addr == ICB_SLAVE_WDATA && full ) begin
                icb_bus.icb_cmd_ready = 1'b0;
            end
            else begin
                icb_bus.icb_cmd_ready = 1'b1;
            end
        end
        else begin
            icb_bus.icb_cmd_ready = 1'b0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : icb_rsp_valid
        if ( !rst_n ) begin
            icb_bus.icb_rsp_valid <= 1'b0;
        end
        else begin
            if( icb_bus.icb_cmd_ready ) begin
                icb_bus.icb_rsp_valid <= 1'b1;
            end else if( icb_bus.icb_rsp_ready ) begin
                icb_bus.icb_rsp_valid <= 1'b0;
            end else begin
                icb_bus.icb_rsp_valid <= icb_bus.icb_rsp_valid;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : icb_rsp_rdata
        if ( !rst_n ) begin
            icb_rsp_rdata_reg <= 64'b0;
        end
        else begin
            if( icb_bus.icb_cmd_ready && icb_bus.icb_cmd_read ) begin
                case( icb_bus.icb_cmd_addr )
                    ICB_SLAVE_CONTROL: icb_rsp_rdata_reg <= {56'b0, control};
                    ICB_SLAVE_STATE: icb_rsp_rdata_reg <= {56'b0, state};
                    ICB_SLAVE_KEY: icb_rsp_rdata_reg <= key; 
                    default : icb_rsp_rdata_reg <= 64'b0;
                endcase
            end else if( icb_bus.icb_rsp_ready ) begin
                icb_rsp_rdata_reg <= 64'b0;
            end else begin
                icb_rsp_rdata_reg <= icb_rsp_rdata_reg;
            end
        end
    end

    assign icb_bus.icb_rsp_rdata = rfifo_data_vld ? rdata : icb_rsp_rdata_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if ( !rst_n ) begin
            control <= 8'b0;
        end
        else begin
            if( icb_bus.icb_cmd_ready && !icb_bus.icb_cmd_read && icb_bus.icb_cmd_addr == ICB_SLAVE_CONTROL ) begin
                control <= icb_bus.icb_cmd_wdata[7:0];
            end else begin
                control <= control;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if ( !rst_n ) begin
            wdata <= 64'b0;
        end
        else begin
            if( icb_bus.icb_cmd_ready && !icb_bus.icb_cmd_read && icb_bus.icb_cmd_addr == ICB_SLAVE_WDATA ) begin
                if( ~icb_bus.icb_cmd_wmask[0] ) wdata[7:0] <= icb_bus.icb_cmd_wdata[7:0];
                if( ~icb_bus.icb_cmd_wmask[1] ) wdata[15:8] <= icb_bus.icb_cmd_wdata[15:8];
                if( ~icb_bus.icb_cmd_wmask[2] ) wdata[23:16] <= icb_bus.icb_cmd_wdata[23:16];
                if( ~icb_bus.icb_cmd_wmask[3] ) wdata[31:24] <= icb_bus.icb_cmd_wdata[31:24];
                if( ~icb_bus.icb_cmd_wmask[4] ) wdata[39:32] <= icb_bus.icb_cmd_wdata[39:32];
                if( ~icb_bus.icb_cmd_wmask[5] ) wdata[47:40] <= icb_bus.icb_cmd_wdata[47:40];
                if( ~icb_bus.icb_cmd_wmask[6] ) wdata[55:48] <= icb_bus.icb_cmd_wdata[55:48];
                if( ~icb_bus.icb_cmd_wmask[7] ) wdata[63:56] <= icb_bus.icb_cmd_wdata[63:56];
            end else begin
                wdata <= wdata;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if ( !rst_n ) begin
            key <= 64'b0;
        end
        else begin
            if( icb_bus.icb_cmd_ready && !icb_bus.icb_cmd_read && icb_bus.icb_cmd_addr == ICB_SLAVE_KEY ) begin
                if( ~icb_bus.icb_cmd_wmask[0] ) key[7:0] <= icb_bus.icb_cmd_wdata[7:0];
                if( ~icb_bus.icb_cmd_wmask[1] ) key[15:8] <= icb_bus.icb_cmd_wdata[15:8];
                if( ~icb_bus.icb_cmd_wmask[2] ) key[23:16] <= icb_bus.icb_cmd_wdata[23:16];
                if( ~icb_bus.icb_cmd_wmask[3] ) key[31:24] <= icb_bus.icb_cmd_wdata[31:24];
                if( ~icb_bus.icb_cmd_wmask[4] ) key[39:32] <= icb_bus.icb_cmd_wdata[39:32];
                if( ~icb_bus.icb_cmd_wmask[5] ) key[47:40] <= icb_bus.icb_cmd_wdata[47:40];
                if( ~icb_bus.icb_cmd_wmask[6] ) key[55:48] <= icb_bus.icb_cmd_wdata[55:48];
                if( ~icb_bus.icb_cmd_wmask[7] ) key[63:56] <= icb_bus.icb_cmd_wdata[63:56];
            end else begin
                key <= key;
            end
        end
    end

    assign icb_bus.icb_rsp_err = 1'b0;

//  Wfifo
    always_ff @(posedge clk or negedge rst_n) begin
        if ( !rst_n ) begin
            wdata_vld <= 1'b0;
        end
        else begin
            if( icb_bus.icb_cmd_ready && !icb_bus.icb_cmd_read && icb_bus.icb_cmd_addr == ICB_SLAVE_WDATA ) begin
                wdata_vld <= 1'b1;
            end else begin
                wdata_vld <= 1'b0;      // 1 cycle pulse
            end
        end
    end

//  rfifo
    assign rdata_en = icb_bus.icb_cmd_ready && icb_bus.icb_cmd_read && icb_bus.icb_cmd_addr == ICB_SLAVE_RDATA;
    always_ff @(posedge clk or negedge rst_n) begin
        if ( !rst_n ) begin
            rfifo_data_vld <= 1'b0;
        end
        else begin
            rfifo_data_vld <= rdata_en;
        end
    end

endmodule