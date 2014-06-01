/* ************************************************************************ */
/*                                                                          */
/*  haXe Video                                                              */
/*  Copyright (c)2007 Nicolas Cannasse                                      */
/*  Copyright (c)2011 af83                                                  */
/*                                                                          */
/* This library is free software; you can redistribute it and/or            */
/* modify it under the terms of the GNU Lesser General Public               */
/* License as published by the Free Software Foundation; either             */
/* version 2.1 of the License, or (at your option) any later version.       */
/*                                                                          */
/* This library is distributed in the hope that it will be useful,          */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of           */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        */
/* Lesser General Public License or the LICENSE file for more details.      */
/*                                                                          */
/* ************************************************************************ */
class Webcam {
    var nc : flash.net.NetConnection;
    var ns : flash.net.NetStream;
    var cam : flash.media.Camera;
    var file : String;
    var share : String;
    var h264Settings : flash.media.H264VideoStreamSettings;
    var cameraFPS : Int;

    public function new(host, file,?share, token, width, height, fps) {
        this.file = file;
        this.share = share;
        this.cam = flash.media.Camera.getCamera();
        if( this.cam == null )
            throw "Webcam not found";
        this.cam.setMode(width, height, fps, true);
        cameraFPS = cast(fps, Int);
        this.nc = new flash.net.NetConnection();
        this.nc.addEventListener(flash.events.NetStatusEvent.NET_STATUS,onEvent);
        this.nc.connect(host, token);
    }

    public function getCam() {
        return this.cam;
    }

    function onEvent(e) {
        if( e.info.code == "NetConnection.Connect.Success" ) {
            this.ns = new flash.net.NetStream(nc);
            this.ns.addEventListener(flash.events.NetStatusEvent.NET_STATUS, onEvent);
            this.ns.publish(this.file,this.share);
        } else if (e.info.code == "NetStream.Publish.Start") {
            this.cam.setKeyFrameInterval(cameraFPS);
            this.cam.setQuality(37500, 0); // 37500 bytes per second == 300 kbps
            this.ns.attachCamera(this.cam);
            h264Settings = new flash.media.H264VideoStreamSettings();
            // Use Baseline Profile, Level 3.1
            h264Settings.setProfileLevel(flash.media.H264Profile.BASELINE,
                flash.media.H264Level.LEVEL_3_1);
            h264Settings.setKeyFrameInterval(cameraFPS);
            h264Settings.setQuality(37500, 0); // 300 kbps
            this.ns.videoStreamSettings = h264Settings;

            //this.ns.bufferTime = 1;
        }
    }

    public function doStop() {
        if( this.ns != null )
            this.ns.close();
        this.nc.close();
    }
}
