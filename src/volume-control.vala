/*
 * -*- Mode:Vala; indent-tabs-mode:t; tab-width:4; encoding:utf8 -*-
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Ted Gould <ted@canonical.com>
 */

public abstract class VolumeControl : Object
{
	public enum VolumeReasons {
		PULSE_CHANGE,
		ACCOUNTS_SERVICE_SET,
		DEVICE_OUTPUT_CHANGE,
		USER_KEYPRESS,
		VOLUME_STREAM_CHANGE
	}

	public enum ActiveOutput {
		SPEAKERS,
		HEADPHONES,
		BLUETOOTH_HEADPHONES,
		BLUETOOTH_SPEAKER,
		USB_SPEAKER,
		USB_HEADPHONES,
		HDMI_SPEAKER,
		HDMI_HEADPHONES,
		CALL_MODE
	}

	public enum Stream {
		CURRENT,
		ALERT,
		MULTIMEDIA,
		ALARM,
		PHONE
	}

	public abstract class Volume : Object {
		public double volume;
		public VolumeReasons reason;

		public abstract void set_volume (double volume);
		public abstract void set_volume_for_stream (VolumeControl.Stream stream, double volume);
	}

	protected IndicatorSound.Options _options = null;

	protected VolumeControl(IndicatorSound.Options options) {
		_options = options;
	}

	public Stream str_to_stream (string str) {
		if (str == "multimedia")
			return Stream.MULTIMEDIA;
		if (str == "alert")
			return Stream.ALERT;
		if (str == "alarm")
			return Stream.ALARM;
		if (str == "phone")
			return Stream.PHONE;

		return Stream.CURRENT;
	}

	public Stream active_stream { get; protected set; default = Stream.ALERT; }
	public bool ready { get; protected set; default = false; }
	public virtual bool active_mic { get { return false; } set { } }
	public virtual bool mute { get { return false; } }
	public bool is_playing { get; protected set; default = false; }
	private double _pre_clamp_volume;
	public Volume volume;
	public virtual double mic_volume { get { return 0.0; } set { } }

	public abstract void set_mute (bool mute);

	public void set_volume_clamp (double unclamped, VolumeControl.VolumeReasons reason, Stream stream) {
		if (stream == Stream.CURRENT) {
			this.volume.set_volume (unclamped.clamp (0.0, _options.max_volume));
		} else {
			this.volume.set_volume_for_stream (stream, unclamped.clamp (0.0, _options.max_volume));
		}

		this.volume.reason = reason;
		_pre_clamp_volume = unclamped;
	}

	public double get_pre_clamped_volume () {
		return _pre_clamp_volume;
	}

	public abstract VolumeControl.ActiveOutput active_output();
	public signal void active_output_changed (VolumeControl.ActiveOutput active_output);
}
