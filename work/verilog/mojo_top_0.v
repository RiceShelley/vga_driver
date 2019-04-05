module mojo_top_0(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
    input cclk,
    // Outputs to the 8 onboard LEDs
    output[7:0]led,
    // AVR SPI connections
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    // AVR ADC channel select
    output [3:0] spi_channel,
    // Serial connections
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy, // AVR Rx buffer full
    
    // VGA outputs
    output red,    
    output green,
    output blue,
    output hsync,     
    output vsync
    );

wire rst = ~rst_n; // make reset active high

// these signals should be high-z when not used
assign spi_miso = 1'bz;
assign avr_rx = 1'bz;
assign spi_channel = 4'bzzzz;

assign led = 8'b0;
reg [9:0] hcount;     // VGA horizontal counter
reg [9:0] vcount;     // VGA vertical counter
reg [2:0] data;		  // RGB data
    
reg  vga_clk;

reg [15:0] move_box;
    
wire hcount_ov;
wire vcount_ov;
wire videosignal_active;
wire hsync;
wire vsync;

// VGA mode parameters
parameter hsync_end   = 10'd95,
   hdat_begin  = 10'd143,
   hdat_end  = 10'd783,
   hpixel_end  = 10'd799,
   vsync_end  = 10'd1,
   vdat_begin  = 10'd34,
   vdat_end  = 10'd514,
   vline_end  = 10'd524;

reg [2:0] color = 3'd2;

always @(posedge clk)
begin
 vga_clk = ~vga_clk;
end

assign hcount_ov = (hcount == hpixel_end);
assign  vcount_ov = (vcount == vline_end);

always @(posedge vga_clk)
begin
 if (hcount_ov)
  hcount <= 10'd0;
 else
  hcount <= hcount + 10'd1;
end

always @(posedge vga_clk)
begin
 if (hcount_ov)
 begin
  if (vcount_ov)
   vcount <= 10'd0;
  else
   vcount <= vcount + 10'd1;
 end
end


assign videosignal_active = ((hcount >= hdat_begin) && (hcount < hdat_end)) && ((vcount >= vdat_begin) && (vcount < vdat_end));

assign hsync = (hcount > hsync_end);
assign vsync = (vcount > vsync_end);

assign red = (videosignal_active) ?  data[0] : 0;      
assign green = (videosignal_active) ?  data[1] : 0;      
assign blue = (videosignal_active) ?  data[2] : 0;      

// generate "image"
always @(posedge vga_clk)
begin
  data <= 3'd0;
end

endmodule