module apb_master(

    apb_bus.master apb_bus_0,
    apb_bus.master apb_bus_1,
    apb_bus.master apb_bus_2,
    apb_bus.master apb_bus_3,

    input  logic empty,
    input  logic full,

    input  logic [31:0] rdata,          // wfifo read data
    output logic rdata_en,              // wfifo read enable

    output logic [31:0] wdata,          // to encrypt write data
    output logic wdata_vld              // to encrypt write data valid

);

    logic clk;
    logic rst_n;

    logic pack_valid;
    logic pack_flag;
    logic pack_write;
    logic [5:0] pack_sel;
    logic [23:0] pack_addr;
    logic [31:0] pack_data;

    logic pack_write_reg;
    logic [5:0] pack_sel_reg;       // hold the pack_sel
    logic [23:0] pack_addr_reg;
    logic [31:0] pack_wdata_reg;

    logic apb_setup;
    logic apb_access;
    logic apb_pready;

    assign clk = apb_bus_0.clk;
    assign rst_n = apb_bus_0.rst_n;

//  fsm
//  apb_write : idle -> read fifo (ctrl) -> read fifo (data) -> drive_apb -> idle
//  apb_read : idle -> read fifo (ctrl) -> drive_apb -> write fifo -> idle

    typedef enum logic [2:0] {
        IDLE,
        READ_CTRL_PACK,
        DECODE_CTRL_PACK,       // apb_write : wait for fifo not empty | apb_read : drive apb
        READ_DATA_PACK,
        DECODE_DATA_PACK,       // 1 cycle : 由于fifo数据延后一周期到达  因此需要停顿一周期
        DRIVE_APB_SETUP,
        DRIVE_APB_ACCESS,
        WRITE_FIFO              
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if ( !rst_n ) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        case ( state )
            IDLE: begin
                if ( !empty ) begin
                    next_state = READ_CTRL_PACK;
                end else begin
                    next_state = IDLE;
                end
            end
            READ_CTRL_PACK: begin
                next_state = DECODE_CTRL_PACK;
            end
            DECODE_CTRL_PACK: begin
                if ( pack_write ) begin               // apb_write
                    if ( !empty ) begin
                        next_state = READ_DATA_PACK;      // wait for fifo not empty
                    end else begin
                        next_state = DECODE_CTRL_PACK;      
                    end
                end else begin                      // apb_read
                    next_state = DRIVE_APB_SETUP;
                end
            end
            READ_DATA_PACK: begin
                next_state = DECODE_DATA_PACK;
            end
            DECODE_DATA_PACK: begin
                next_state = DRIVE_APB_SETUP;
            end
            DRIVE_APB_SETUP: begin
                next_state = DRIVE_APB_ACCESS;
            end
            DRIVE_APB_ACCESS: begin
                if (apb_pready) begin
                    if ( pack_write_reg ) begin          // apb_write
                        next_state = IDLE;
                    end else begin
                        next_state = WRITE_FIFO;   // apb_read
                    end
                end else begin
                    next_state = DRIVE_APB_ACCESS;
                end
            end
            WRITE_FIFO: begin
                if ( !full ) begin
                    next_state = IDLE;
                end else begin
                    next_state = WRITE_FIFO;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

//  read fifo
    assign rdata_en = (state == READ_CTRL_PACK ) || (state == READ_DATA_PACK) ;

//  decode pack
    assign pack_flag = rdata[0];
    assign pack_write = rdata[1];
    assign pack_sel = rdata[7:2];
    assign pack_addr = rdata[31:8];
    assign pack_data = {1'b0,rdata[31:1]};

    always_ff @(posedge clk or negedge rst_n) begin         // 数据同周期有效
        if ( !rst_n ) begin
            pack_valid <= 1'b0;
        end
        else begin
            pack_valid <= rdata_en;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if ( !rst_n ) begin
            pack_sel_reg <= 6'b0;
            pack_addr_reg <= 24'b0;
            pack_write_reg <= 1'b0;
        end
        else begin
            if ( pack_valid & ( pack_flag == 0 ) ) begin    // ctrl pack
                pack_sel_reg <= pack_sel;
                pack_addr_reg <= pack_addr;
                pack_write_reg <= pack_write;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if ( !rst_n ) begin
            pack_wdata_reg <= 32'b0;
        end
        else begin
            if ( pack_valid & ( pack_flag == 1 ) ) begin    // data pack
                pack_wdata_reg <= pack_data;
            end
        end
    end

//  drive apb
    assign apb_setup = (state == DRIVE_APB_SETUP) || (state == DRIVE_APB_ACCESS); // apb setup and access 
    assign apb_access = (state == DRIVE_APB_ACCESS);
    assign apb_pready = apb_bus_0.pready || apb_bus_1.pready || apb_bus_2.pready || apb_bus_3.pready;
   
    // setup apb
    always_comb begin
        if ( apb_setup && (pack_sel_reg == 6'b000001) ) begin
            apb_bus_0.pwrite = pack_write_reg;
            apb_bus_0.psel = 1'b1;
            apb_bus_0.paddr = pack_addr_reg;
            apb_bus_0.pwdata = pack_wdata_reg;
        end
        else begin
            apb_bus_0.pwrite = 1'b0;
            apb_bus_0.psel = 1'b0;
            apb_bus_0.paddr = 32'b0;
            apb_bus_0.pwdata = 32'b0;
        end
    end

    always_comb begin
        if ( apb_setup && (pack_sel_reg == 6'b000010) ) begin
            apb_bus_1.pwrite = pack_write_reg;
            apb_bus_1.psel = 1'b1;
            apb_bus_1.paddr = pack_addr_reg;
            apb_bus_1.pwdata = pack_wdata_reg;
        end
        else begin
            apb_bus_1.pwrite = 1'b0;
            apb_bus_1.psel = 1'b0;
            apb_bus_1.paddr = 32'b0;
            apb_bus_1.pwdata = 32'b0;
        end
    end

    always_comb begin
        if ( apb_setup && (pack_sel_reg == 6'b000100) ) begin
            apb_bus_2.pwrite = pack_write_reg;
            apb_bus_2.psel = 1'b1;
            apb_bus_2.paddr = pack_addr_reg;
            apb_bus_2.pwdata = pack_wdata_reg;
        end
        else begin
            apb_bus_2.pwrite = 1'b0;
            apb_bus_2.psel = 1'b0;
            apb_bus_2.paddr = 32'b0;
            apb_bus_2.pwdata = 32'b0;
        end
    end

    always_comb begin
        if ( apb_setup && (pack_sel_reg == 6'b001000) ) begin
            apb_bus_3.pwrite = pack_write_reg;
            apb_bus_3.psel = 1'b1;
            apb_bus_3.paddr = pack_addr_reg;
            apb_bus_3.pwdata = pack_wdata_reg;
        end
        else begin
            apb_bus_3.pwrite = 1'b0;
            apb_bus_3.psel = 1'b0;
            apb_bus_3.paddr = 32'b0;
            apb_bus_3.pwdata = 32'b0;
        end
    end

    // access apb
    always_comb begin
        if ( apb_access && (pack_sel_reg == 6'b000001) ) begin
            apb_bus_0.penable = 1'b1;
        end
        else begin
            apb_bus_0.penable = 1'b0;
        end
    end

    always_comb begin
        if ( apb_access && (pack_sel_reg == 6'b000010) ) begin
            apb_bus_1.penable = 1'b1;
        end
        else begin
            apb_bus_1.penable = 1'b0;
        end
    end

    always_comb begin
        if ( apb_access && (pack_sel_reg == 6'b000100) ) begin
            apb_bus_2.penable = 1'b1;
        end
        else begin
            apb_bus_2.penable = 1'b0;
        end
    end

    always_comb begin
        if ( apb_access && (pack_sel_reg == 6'b001000) ) begin
            apb_bus_3.penable = 1'b1;
        end
        else begin
            apb_bus_3.penable = 1'b0;
        end
    end

//  write fifo
    always_ff @(posedge clk or negedge rst_n) begin
        if ( !rst_n ) begin
            wdata <= 32'b0;
        end else if ( apb_bus_0.pready ) begin
            wdata <= apb_bus_0.prdata;
        end else if ( apb_bus_1.pready ) begin
            wdata <= apb_bus_1.prdata;
        end else if ( apb_bus_2.pready ) begin
            wdata <= apb_bus_2.prdata;
        end else if ( apb_bus_3.pready ) begin
            wdata <= apb_bus_3.prdata;
        end else begin
            wdata <= wdata;
        end
    end

    assign wdata_vld = (state == WRITE_FIFO) && !full ;

endmodule