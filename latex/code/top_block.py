#!/usr/bin/env python
##################################################
# Gnuradio Python Flow Graph
# Title: Top Block
# Generated: Fri Nov 16 20:33:07 2012
##################################################

from gnuradio import eng_notation
from gnuradio import gr
from gnuradio import uhd
from gnuradio import window
from gnuradio.eng_option import eng_option
from gnuradio.gr import firdes
from gnuradio.wxgui import fftsink2
from grc_gnuradio import wxgui as grc_wxgui
from optparse import OptionParser
import wx

class top_block(grc_wxgui.top_block_gui):

	def __init__(self):
		grc_wxgui.top_block_gui.__init__(self, title="Top Block")
		_icon_path = "/usr/share/icons/hicolor/32x32/apps/gnuradio-grc.png"
		self.SetIcon(wx.Icon(_icon_path, wx.BITMAP_TYPE_ANY))

		##################################################
		# Variables
		##################################################
		self.samp_rate = samp_rate = 100000

		##################################################
		# Blocks
		##################################################
		self.wxgui_fftsink2_0 = fftsink2.fft_sink_c(
			self.GetWin(),
			baseband_freq=0,
			y_per_div=10,
			y_divs=10,
			ref_level=0,
			ref_scale=2.0,
			sample_rate=samp_rate*10,
			fft_size=1024,
			fft_rate=15,
			average=False,
			avg_alpha=None,
			title="FFT Plot",
			peak_hold=False,
		)
		self.Add(self.wxgui_fftsink2_0.win)
		self.uhd_usrp_source_0 = uhd.usrp_source(
			device_addr="addr0=192.168.10.2,addr1=192.168.10.3",
			stream_args=uhd.stream_args(
				cpu_format="fc32",
				channels=range(2),
			),
		)
		self.uhd_usrp_source_0.set_clock_source("mimo", 1)
		self.uhd_usrp_source_0.set_time_source("mimo", 1)
		self.uhd_usrp_source_0.set_samp_rate(samp_rate)
		self.uhd_usrp_source_0.set_center_freq(4.9e9+20000, 0)
		self.uhd_usrp_source_0.set_gain(15, 0)
		self.uhd_usrp_source_0.set_center_freq(4.9e9+20000, 1)
		self.uhd_usrp_source_0.set_gain(15, 1)
		self.gr_file_sink_0_0 = gr.file_sink(gr.sizeof_gr_complex*1, "/home/sdruser/COLLINS/Pre/UChannel2_S.txt")
		self.gr_file_sink_0_0.set_unbuffered(False)
		self.gr_file_sink_0 = gr.file_sink(gr.sizeof_gr_complex*1, "/home/sdruser/COLLINS/Pre/UChannel1_S.txt")
		self.gr_file_sink_0.set_unbuffered(False)

		##################################################
		# Connections
		##################################################
		self.connect((self.uhd_usrp_source_0, 0), (self.gr_file_sink_0, 0))
		self.connect((self.uhd_usrp_source_0, 1), (self.gr_file_sink_0_0, 0))
		self.connect((self.uhd_usrp_source_0, 1), (self.wxgui_fftsink2_0, 0))

	def get_samp_rate(self):
		return self.samp_rate

	def set_samp_rate(self, samp_rate):
		self.samp_rate = samp_rate
		self.uhd_usrp_source_0.set_samp_rate(self.samp_rate)
		self.wxgui_fftsink2_0.set_sample_rate(self.samp_rate*10)

if __name__ == '__main__':
	parser = OptionParser(option_class=eng_option, usage="%prog: [options]")
	(options, args) = parser.parse_args()
	if gr.enable_realtime_scheduling() != gr.RT_OK:
		print "Error: failed to enable realtime scheduling."
	tb = top_block()
	tb.Run(True)

