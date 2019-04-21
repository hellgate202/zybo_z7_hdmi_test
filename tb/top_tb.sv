`timescale 1 ps / 1 ps

module top_tb;

parameter int Y_ACTIVE   = 1080;
parameter int Y_BLANKING = 45;
parameter int X_ACTIVE   = 1920;
parameter int X_BLANKING = 280;
parameter int PX_WIDTH   = 10;

parameter int PX_CLK_T   = 13465;
parameter int TMDS_CLK_T = 2693;

bit px_clk;
bit tmds_clk;
bit rst;

task automatic px_clk_gen();
  forever
    begin
      #( PX_CLK_T / 2 );
      px_clk = !px_clk;
    end
endtask

task automatic tmds_clk_gen();
  forever
    begin
      #( TMDS_CLK_T / 2 );
      tmds_clk = !tmds_clk;
    end
endtask

task automatic apply_rst();
  rst = 1'b1;
  @( posedge px_clk );
  rst = 1'b0;
endtask

axi4_stream_if #(
  .DATA_WIDTH ( 32     ),
  .USER_WIDTH ( 1      ),
  .ID_WIDTH   ( 1      ),
  .DEST_WIDTH ( 1      )
) video (
  .aclk       ( px_clk ),
  .aresetn    ( !rst   )
);

axi4_video_pattern_gen #(
  .Y_ACTIVE   ( Y_ACTIVE   ),
  .Y_BLANKING ( Y_BLANKING ),
  .X_ACTIVE   ( X_ACTIVE   ),
  .X_BLANKING ( X_BLANKING )
) pattern_gen (
  .clk_i      ( px_clk     ),
  .rst_i      ( rst        ),
  .video_o    ( video      )
);

hdmi_tx #(
  .X_RES        ( X_ACTIVE ),
  .Y_RES        ( Y_ACTIVE ),
  .PX_WIDTH     ( PX_WIDTH )
) hdmit_tx (
  .px_clk_i     ( px_clk   ),
  .tmds_clk_i   ( tmds_clk ),
  .rst_i        ( rst      ),
  .video_i      ( video    ),
  .hdmi_tx2_p_o (          ),
  .hdmi_tx2_n_o (          ),
  .hdmi_tx1_p_o (          ),
  .hdmi_tx1_n_o (          ),
  .hdmi_tx0_p_o (          ),
  .hdmi_tx0_n_o (          ),
  .hdmi_clk_p_o (          ),
  .hdmi_clk_n_o (          )
);

initial
  begin
    fork
      px_clk_gen();
      tmds_clk_gen();
    join_none
    apply_rst();
  end

endmodule
